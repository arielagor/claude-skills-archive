---
name: pipeline-run
description: Run a specific phase of the MVAT agent pipeline with automatic checkpointing. Use when executing pipeline rollout phases (R1-R6) or running specific pipeline stages.
user_invocable: true
---

# Pipeline Run

Execute a phase of the MVAT agent pipeline with automatic progress checkpointing.

## Usage
The user will specify which phase or stage to run (e.g., "run R6 stage 4" or "run pipeline stage Engineering").

## Steps

1. **Read current state:**
   - `products/active-product.json` — which product is active
   - `rollout/current-phase.json` — current rollout phase
   - `governance/kill-switch.json` — which agents are enabled
   - `governance/circuit-breakers.json` — any tripped breakers

2. **Identify the work** for the requested phase/stage from `orchestration/`.

3. **Create a checkpoint file** at `rollout/checkpoints/checkpoint-{phase}-{stage}-{timestamp}.json`:
   ```json
   {
     "phase": "R6",
     "stage": "Engineering",
     "started_at": "ISO timestamp",
     "status": "in_progress",
     "completed_agents": [],
     "pending_agents": ["list"],
     "artifacts_produced": []
   }
   ```

4. **For each agent in the stage**, spawn it as a Task sub-agent with its spec from `.claude/agents/`. After each agent completes:
   - Update the checkpoint file with the completed agent
   - Commit the checkpoint: `git add rollout/checkpoints/ && git commit -m "checkpoint: {agent} completed in {phase}/{stage}"`

5. **On completion or failure**, update the checkpoint with final status and write a handoff doc:
   - `rollout/checkpoints/handoff-{phase}-{stage}.md` — what was done, what remains, any blockers

6. **If the session is about to end** (context getting long), immediately commit all progress and write the handoff doc so the next session can resume cleanly.

## Recovery
If a previous checkpoint exists for this phase/stage:
- Read it to see what agents already completed
- Skip completed agents
- Resume from where it left off

## Constraints
- Always commit after each agent completes (incremental progress)
- Never skip governance checks (kill-switch, circuit-breakers)
- Write escalations to `governance/escalations/` for any ambiguity
- Follow model tier policy from CLAUDE.md when spawning agents
