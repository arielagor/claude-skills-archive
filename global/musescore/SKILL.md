---
name: musescore
description: "Render, convert and score music notation headlessly with the MuseScore 4 CLI. Use when: (1) converting between notation/audio formats — MusicXML, MIDI, MSCZ, PDF, PNG, SVG, MP3, WAV, OGG, FLAC; (2) turning a MIDI file into readable sheet music; (3) engraving a score to PDF or to a transparent PNG/SVG for a slide, video or print piece; (4) generating an audio stem (MP3/WAV) from notation to feed a mix; (5) composing a short piece by authoring MusicXML directly and rendering it; (6) batch-converting a folder of scores. Triggers: 'convert this MIDI to sheet music', 'render this score', 'make a PDF of this music', 'turn this MusicXML into an mp3', 'notate this', 'export the score', 'engrave this'. NOT for sourcing or generating music from a prompt (use /media-use — Lyria 3), NOT for mixing or mastering a multi-track piece (use /hyperframes-audio or /audio-drama), NOT for TTS or narration (use /audio-drama, /timed-guided-audio)."
---

# MuseScore 4 — headless notation rendering and conversion

## What this gives you

MuseScore 4 is installed with a working command-line converter. It runs **fully headless** — no display, no `-platform offscreen`, no GUI window. That makes it a proper pipeline component: notation in, engraved PDF or rendered audio out.

- **Binary:** `C:\Program Files\MuseScore 4\bin\MuseScore4.exe`
- **Version:** 4.7.4 (build 7688c00), installed via `winget install Musescore.Musescore`
- Bash-friendly path: `"/c/Program Files/MuseScore 4/bin/MuseScore4.exe"`

Set it once at the top of any script:

```bash
MS="/c/Program Files/MuseScore 4/bin/MuseScore4.exe"
```

## The one rule: verify the artifact, never the exit code

MuseScore's exit code is not trustworthy in either direction. Both of these were measured on this machine, on this build:

- It **segfaulted (exit 139) after writing a completely correct file.** The `.musicxml` it produced parsed clean — right measure count, right note count. The crash happens on shutdown, after the write.
- It **exited 0 while writing nothing at all.** `-P` (export score and parts) returned success and produced no file.

So the gate is always the artifact:

```bash
"$MS" -o out.pdf in.musicxml >/dev/null 2>&1
[ -s out.pdf ] || { echo "FAILED: no output"; exit 1; }
```

For XML output, parse it rather than trusting its size. Use `defusedxml` — MusicXML carries a `DOCTYPE` and often comes from a download or a stranger's score, which is exactly the input class that makes the stdlib parser a liability (billion-laughs, external entities):

```bash
pip install defusedxml   # once
python -c "import defusedxml.ElementTree as ET; ET.parse('out.musicxml')" || echo "FAILED: malformed"
```

If `defusedxml` is unavailable and the file is one **you** just generated with MuseScore, `xml.etree.ElementTree` is acceptable — but do not point the stdlib parser at a score you did not produce.

This is the house rule from CLAUDE.md ("Verification Before Claiming Success") and MuseScore is a textbook case for it.

## Verified conversion matrix

All of these were run end to end and produced valid files.

**Input formats:** `.musicxml`, `.mxl`, `.mid`, `.mscz`, `.mscx`
(MuseScore also claims Capella, Guitar Pro, Bww and others — untested here.)

**Output formats:**

| Extension | Kind | Notes |
|---|---|---|
| `.pdf` | Engraved score | The main deliverable. Clean and reliable. |
| `.png` | Raster page | **Page-suffixed and 1200 DPI by default** — see gotchas. RGBA, transparent background. |
| `.svg` | Vector page | Page-suffixed. Best for slides and print. |
| `.mp3` | Audio | Default 128 kbps; `-b 320` for full quality. |
| `.wav` | Audio | Uncompressed, large. |
| `.ogg` / `.flac` | Audio | Both work. FLAC for lossless stems. |
| `.mid` | MIDI | Tiny; good for handing to a DAW or sampler. |
| `.musicxml` / `.mxl` | Notation interchange | `.mxl` is the compressed form and is far smaller. |
| `.mscz` | MuseScore native | Compressed project file. |
| `.mscx` | MuseScore native, uncompressed | **Litters the output directory** — see gotchas. |

## Core recipe — one output per invocation

This is the pattern that works. Loop in the shell; do not ask MuseScore to fan out.

```bash
MS="/c/Program Files/MuseScore 4/bin/MuseScore4.exe"
SRC="score.musicxml"

for out in score.pdf score.mid score.mp3; do
  "$MS" -o "$out" "$SRC" >/dev/null 2>&1
  if [ -s "$out" ]; then echo "ok   $out ($(stat -c%s "$out") bytes)"
  else echo "FAIL $out"; fi
done
```

Useful flags, all verified:

| Flag | Effect |
|---|---|
| `-o <file>` | Export to file; **format is chosen by the extension**. |
| `-r <DPI>` | Image resolution. Always pass this for PNG/SVG. |
| `-b <kbps>` | MP3 bitrate. `-b 320` measured 282 KB vs 113 KB at default. |
| `-f` | Force; ignore warnings on a score that has them. |
| `-F` | Factory settings — use for reproducible output in a pipeline. |
| `-j <file>` | Batch job file. **Partly broken — see gotchas.** |

## Gotchas

Each of these was hit and confirmed during setup, not read off a docs page.

**1. Image output is page-numbered — `out.png` is never written.**
Asking for `-o out.png` produces `out-1.png`, `out-2.png`, one per page. A script that checks for `out.png` will conclude the export failed while the files sit right there. Glob for them:

```bash
"$MS" -o out.png -r 300 score.musicxml >/dev/null 2>&1
ls out-*.png   # out-1.png, out-2.png, ...
```

**2. Default image resolution is 1200 DPI. Always pass `-r`.**
A single-page score exported with no `-r` came out **10200 × 13200 px, 698 KB**. With `-r 300` it was 2550 × 3300 px, 76 KB — a 9× smaller file for the same page. Pick deliberately:

- `-r 150` — web, thumbnails
- `-r 300` — print, slides, most video work
- `-r 600` — high-quality print only

PNGs are RGBA with a **transparent background**, which is exactly what you want for compositing over a slide or a HyperFrames scene, and wrong if you expected white — flatten it downstream if so.

**3. The `-j` job file only honours the first output.**
Given `{"in": "...", "out": ["a.pdf", "a.mp3", "a.mid"]}` it wrote **only `a.pdf`**, exited 0, and silently dropped the rest. Nested array forms error out with exit 23. Do not use `-j` for multi-format export; loop with `-o` instead. `-j` is only worth it for many *inputs*, one output each:

```json
[
  { "in": "score1.musicxml", "out": "score1.pdf" },
  { "in": "score2.musicxml", "out": "score2.pdf" }
]
```

**4. Exporting to `.mscx` dumps container files into the working directory.**
It writes `META-INF/`, `Thumbnails/`, `audiosettings.json`, `automation.json`, `viewsettings.json` and `score_style.mss` alongside the score. Export `.mscx` into a dedicated directory, or prefer `.mscz` (a single compressed file) unless you specifically need the plain-text form for diffing.

**5. Occasional segfault on exit, after a correct write.** Covered above. Never gate on the exit code.

**6. Back-to-back invocations are where crashes cluster.** Rapid sequential runs segfaulted more often than isolated ones. If a batch is flaky, retry the individual failure rather than the whole batch — and check the artifact first, since it has usually already been written correctly.

## Common workflows

### MIDI → readable sheet music
Verified working. MuseScore does the quantisation and voice-splitting.

```bash
"$MS" -o score.pdf performance.mid >/dev/null 2>&1
"$MS" -o score.musicxml performance.mid >/dev/null 2>&1   # editable
[ -s score.pdf ] && echo ok
```

Raw MIDI from a live performance engraves badly (unquantised rhythms, no key signature). If the notation looks like garbage, that is the MIDI's timing, not a MuseScore failure — the fix is quantising in a DAW first, or opening the file in the MuseScore GUI once to set the time and key signature.

### Notation → audio stem for a mix
Feeds `/audio-drama`, `/timed-guided-audio`, or a HyperFrames music bed.

```bash
"$MS" -o bed.wav score.musicxml >/dev/null 2>&1     # lossless into the mix
"$MS" -o bed.mp3 -b 320 score.musicxml >/dev/null 2>&1  # delivery
```

Use WAV or FLAC when the file is going into a mix and MP3 only for final delivery, so you are not stacking lossy encodes.

### Score → asset for a slide or video
```bash
"$MS" -o cue.svg score.musicxml >/dev/null 2>&1        # vector, scales cleanly
"$MS" -o cue.png -r 300 score.musicxml >/dev/null 2>&1  # transparent raster
ls cue-*.svg cue-*.png
```

SVG is the better choice for `/hyperframes` and `/cinematic-deck` — it stays sharp at any zoom and animates as vector.

### Composing from scratch
There is no "generate music from a prompt" here. To create a piece, author MusicXML directly and render it. Write the XML with the **Write tool** (never a bash heredoc — hook-enforced), then render as above. A minimal skeleton lives in the smoke test at the bottom of this file.

For *generated* music from a text prompt, this is the wrong skill — use `/media-use` (Lyria 3).

### Batch-converting a folder
```bash
mkdir -p pdf
for f in scores/*.musicxml; do
  base=$(basename "$f" .musicxml)
  "$MS" -o "pdf/$base.pdf" "$f" >/dev/null 2>&1
  [ -s "pdf/$base.pdf" ] && echo "ok $base" || echo "FAIL $base"
done
```

## How this composes with the rest of the stack

- **`/media-use`** — generates music from a prompt and resolves BGM/SFX. That is the *creative* source; MuseScore is the *notation and rendering* engine. Use media-use to invent a cue, MuseScore to engrave or convert one.
- **`/audio-drama` and `/timed-guided-audio`** — MuseScore renders the score to WAV/FLAC; those skills own casting, narration, ducking and the mix.
- **`/hyperframes*`** — SVG/PNG page exports drop straight into a composition as vector or transparent overlays.
- **`/clean-pdf` and `/agor-branded-doc`** — a rendered score PDF can be embedded as a figure in a typeset document.

## Smoke test

If MuseScore is behaving strangely, run this first to establish whether the install or the input is at fault. It writes a two-bar scale and renders it.

Create `test.musicxml` with the Write tool:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 4.0 Partwise//EN" "http://www.musicxml.org/dtds/partwise.dtd">
<score-partwise version="4.0">
  <part-list><score-part id="P1"><part-name>Piano</part-name></score-part></part-list>
  <part id="P1">
    <measure number="1">
      <attributes><divisions>1</divisions><key><fifths>0</fifths></key>
        <time><beats>4</beats><beat-type>4</beat-type></time>
        <clef><sign>G</sign><line>2</line></clef></attributes>
      <note><pitch><step>C</step><octave>4</octave></pitch><duration>1</duration><type>quarter</type></note>
      <note><pitch><step>D</step><octave>4</octave></pitch><duration>1</duration><type>quarter</type></note>
      <note><pitch><step>E</step><octave>4</octave></pitch><duration>1</duration><type>quarter</type></note>
      <note><pitch><step>F</step><octave>4</octave></pitch><duration>1</duration><type>quarter</type></note>
    </measure>
    <measure number="2">
      <note><pitch><step>G</step><octave>4</octave></pitch><duration>2</duration><type>half</type></note>
      <note><pitch><step>C</step><octave>4</octave></pitch><duration>2</duration><type>half</type></note>
    </measure>
  </part>
</score-partwise>
```

Then:

```bash
MS="/c/Program Files/MuseScore 4/bin/MuseScore4.exe"
"$MS" -o smoke.pdf test.musicxml >/dev/null 2>&1
[ -s smoke.pdf ] && echo "MuseScore OK" || echo "MuseScore BROKEN"
```

Expected on a healthy install: `smoke.pdf` around 17 KB, `smoke.mp3` around 113 KB at default bitrate.

## Reinstalling / upgrading

```bash
winget upgrade --id Musescore.Musescore --exact --silent
winget install --id Musescore.Musescore --exact --silent \
  --accept-package-agreements --accept-source-agreements
```

Installing needs a UAC prompt — it is a machine-wide MSI into `Program Files`. If the binary path ever changes, re-derive it rather than assuming:

```bash
ls "/c/Program Files/MuseScore 4/bin/MuseScore4.exe"
```
