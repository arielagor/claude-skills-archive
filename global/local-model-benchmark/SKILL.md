---
name: local-model-benchmark
description: |
  Honestly benchmark and qualify a LOCAL model (Ollama, llama.cpp, LM Studio) before adopting it
  for real work. Use when: (1) you just pulled a local model and want to know if it is fast enough,
  (2) deciding between a big local model and a smaller one, (3) a local-model call appears to hang
  or produce nothing, (4) `ollama ps` stays empty after a request, (5) a model returns an empty
  `response` field, (6) you need tokens/sec on-device rather than a vibe. Covers detached execution
  so long loads survive, the native-endpoint stats fields, minimum sample size, reasoning-model
  detection, and reading the server log for the CPU-vs-GPU path.
author: Claude Code
version: 1.0.0
date: 2026-08-28
---

# Local Model Benchmark

## Problem

A freshly pulled local model looks usable because it downloaded and registered. Registration says
nothing about whether it is fast enough to work with. Getting an honest number is harder than it
looks, because the three obvious ways to measure all mislead:

- Running the request from a backgrounded agent task, which gets reaped and **aborts the load**
- Measuring with a tiny token cap, which reports per-call overhead rather than throughput
- Reading the `response` field, which is empty on reasoning models

## Context / Trigger Conditions

- Just ran `ollama pull` and want to know if the model is practical
- Choosing between model sizes on the same machine
- A request seems to hang forever with no output
- `ollama ps` shows an empty table even though a request was sent
- The model returns an empty `response` with `done_reason: "length"`
- You want to know whether inference is running on GPU or CPU

## Solution

### 1. Run it detached, or the load dies with your task

The first request must load the whole model from disk, which takes 30-90+ s for a large one. A
`run_in_background` task holding that HTTP request gets reaped by the harness, and the client
disconnect **cancels the load server-side**. Nothing goes resident and the next attempt starts over.

Write a script that records its own state, then launch it so it outlives the session:

```powershell
# bench.ps1 - writes a .status sidecar, then the payload
$out = "<scratch>\bench.json"
"STARTED" | Set-Content "$out.status"
$body = @{
  model = $M; prompt = $P; stream = $false; keep_alive = "30m"
  options = @{ num_predict = 128; num_ctx = 2048 }
} | ConvertTo-Json -Depth 5
try {
  $r = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 3600
  $r | ConvertTo-Json -Depth 5 | Set-Content $out
  "DONE" | Set-Content "$out.status"
} catch {
  "ERROR" | Set-Content "$out.status"
}
```

Launch and poll the sidecar, not the process:

```powershell
Start-Process pwsh -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',"$sp\bench.ps1" -WindowStyle Hidden
```

Pass `keep_alive` so the model stays resident and you do not pay the load cost again next call.

### 2. Use the native endpoint for real numbers

`/api/generate` returns timing fields. The OpenAI-compatible `/v1/chat/completions` returns none of
them and forces you to estimate.

| Field | Meaning |
|---|---|
| `load_duration` | cold load from disk (ns) |
| `prompt_eval_count` / `prompt_eval_duration` | prompt processing |
| `eval_count` / `eval_duration` | generation, this is the tok/s number |

generation tok/s = `eval_count` divided by (`eval_duration` / 1e9)

`ollama run --verbose <model> "<prompt>"` prints the same stats natively and is fine for a quick
look, but it emits TUI spinner escape codes when piped, so prefer the API for anything scripted.

### 3. Generate enough tokens or the number is fiction

Per-call overhead swamps a small sample. The same model, same machine, same session:

- `num_predict: 3` reported **6.81 tok/s**
- `num_predict: 16` reported **9.80 tok/s**

Use at least **64-128 tokens**, and discard the first (cold) run.

### 4. Check whether it is a reasoning model

If `response` is empty and the content is in a `thinking` field, the model spends a reasoning
preamble before answering. This changes the verdict completely: at 1.5 tok/s a routine 500-token
thinking block is roughly 5.6 minutes before the first word of the actual reply, and an agent loop
chains several per task. A reasoning model that benchmarks "slow but tolerable" is often unusable
interactively.

### 5. Read the server log for the execution path

`%LOCALAPPDATA%\Ollama\server.log` on Windows. Look at the `load_tensors` lines:

- `CPU model buffer size` plus `CPU_REPACK`, with no GPU offload line, means **pure CPU inference**
- A GPU offload line tells you how many layers actually reached the card

Integrated graphics do not count, and Ollama will not use an NPU.

## Verification

The benchmark is honest when all four hold:

1. The run completed detached, not from a reaped background task
2. `eval_count` is at least 64
3. You checked whether output landed in `thinking` rather than `response`
4. You know from the log whether it ran on CPU or GPU

## Example

Measured on an Intel Core Ultra 7 255U, no discrete GPU, 31.5 GB RAM:

| Model | Generation | Cold load | Verdict |
|---|---|---|---|
| 27B Q4 (reasoning, 17 GB) | 1.49 tok/s | 80.0 s | unusable interactively |
| 9B Q4 | 9.80 tok/s | 36.5 s | practical default |

A 6.6x gap. The bigger model was not "slower but better"; the reasoning preamble made it
categorically unsuitable for an agent loop on this hardware.

## Notes

- Verify a model EXISTS before spending the bandwidth. Fetch its registry manifest, and run a
  known-bogus name alongside as a 404 control so a 200 means something:
  `curl -s -o /dev/null -w "%{http_code}" https://registry.ollama.ai/v2/<ns>/<model>/manifests/latest`
  The manifest also reveals the true download size and whether there is an `image.projector` layer
  (multimodal).
- `ollama pull` can stall with the client alive at ~1% CPU after finishing a layer. Kill the client
  and re-run; it resumes from the finalized blob.
- Compare download progress in BYTES. A manifest layer of `16810714496` bytes is 15.656 GiB, so a
  `du -h` reading makes a COMPLETE layer look 93% done and a stall look like normal progress.
- `ollama ps` empty despite `keep_alive` means the model was evicted and the load cost recurs. Set
  `OLLAMA_KEEP_ALIVE` persistently if that matters.
- A watcher that polls process-liveness BEFORE re-checking state emits a false failure when the
  process exits and writes its result in the same interval. Re-check state after observing exit.
- See also: `benchmark-models` (gstack) for cross-cloud comparison of Claude/GPT/Gemini via their
  CLIs. That skill does not cover local models; this one does not cover cloud models.

## References

- Ollama API response fields: https://github.com/ollama/ollama/blob/main/docs/api.md
- Verified empirically on this machine, 2026-08-26 to 2026-08-28, Ollama 0.32.14.
