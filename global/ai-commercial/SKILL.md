---
name: ai-commercial
description: |
  Produce an agency-grade AI commercial (dialogue-driven or cinematic) using the proven hybrid
  HeyGen + Seedance + xAI-TTS pipeline — the one that made "The Two Owners" for app.agor.me:
  clean lip-sync (mouths say the exact words), coherent character/world continuity shot-to-shot,
  a real founder button, ducked music, and native 16:9 + 9:16 masters. Use when Ariel wants a
  video AD / commercial / spot / brand film with SPEAKING characters and scene-to-scene coherence
  (not a single talking-head — that's the `heygen` skill; not a HyperFrames explainer — that's
  `hyperframes-longform-video`; not client AI-visibility work — that's `ai-ads`). Triggers:
  "make a commercial", "cinematic ad", "Super Bowl style spot", "dialogue ad where the mouths
  actually say the words", "characters that stay consistent between scenes".
---

# AI Commercial — the hybrid dialogue-ad pipeline

> See also: `seedance-narrated-short` is the narrated, no-lip-sync, long-form counterpart (a novel or essay adapted into a cinematic short with a narrator OVER the footage instead of speaking characters). Use that when nobody needs to lip-sync exact words.

The two things that make an AI spot look amateur — **mouths that don't say the words** and
**characters/worlds that drift shot-to-shot** — are solved by *routing each shot to the right
engine* and *engineering continuity*, not in post. This skill is the codified, verified pipeline.

**A commercial is 90% decided before a frame is generated.** Do P0 pre-pro and get it approved
before spending any generation. Full craft reference: **`references/agency-guide.md`** (14 sections).
Exact CLI per stage: **`references/heygen-pipeline-cheatsheet.md`**.

## The one decision that matters: route every shot

| Shot need | Engine | Lip-sync to exact words? |
|---|---|---|
| Character clearly SPEAKS on camera (AI-cast face) | **Avatar IV** (still + audio_asset_id) | **Yes** |
| Character speaks, real person plays them | **Avatar V** (trained twin) | **Yes** |
| Cinematic scene / b-roll / action / reaction / VO-over | **Seedance** (`cinematic_avatar`) | No |
| A Seedance shot where someone must clearly speak | Seedance **then Lipsync Precision** vs the VO | Yes (retrofit) |

Tag every storyboard shot **DIALOGUE** or **CINEMATIC** — that tag picks the engine. On a DIALOGUE
shot, one voice per character drives the face; on a wide CINEMATIC shot, use VO (a small face fails
lip-sync). Don't use Video Agent for a directed multi-shot spot (it steals editorial control).

## Workflow (P0 → P6)

**P0 — Pre-pro (no API, must be approved first).** Brief → **SMP** (one insight-driven sentence) →
**Big Idea** → two-column A/V script (~2.5 words/sec; a :60 ≈ 150 spoken words max) → storyboard
10–14 shots, each tagged DIALOGUE/CINEMATIC with ONE camera move → draw the **180° line** and fix
each character's screen side (A frame-left looking right; B frame-right looking left) → write ONE
**global style block** (palette/lighting/lens/grain) pasted verbatim into every prompt. Deliver this
as a concept doc for sign-off (template: the old `P0-concept-the-two-owners.md`).

**P1 — Character bible (once each).** Build each character as a stable **`group_id`** (Avatar IV
from a still, or Avatar V twin for a real person) + a reference still; assign one voice per
character. Save `AVATAR-<char>.md` (Group ID + Voice ID). Upload ≤3 non-human element refs
(set, hero prop, wardrobe). *Look IDs are ephemeral — store the group_id, resolve looks at runtime.*

**P2 — Lock the VO.** `python scripts/gen_tts.py lines.json` → one MP3 per line in the character's
voice. The SAME MP3 drives the Avatar shot AND any Seedance lipsync repair (identical timing).

**P3 — DIALOGUE shots → Avatar IV/V.** Drive the still with `audio_asset_id` (the uploaded VO mp3)
so the mouth says the exact words. Frame to the assigned 180° side. When the face is set, never
describe it in the prompt — say "the selected person."

**P4 — CINEMATIC shots → Seedance** (`cinematic_avatar`): same `avatar_id`, same element
`references`, global style block verbatim + **"preserve composition and colors"**, one camera move,
≤5 beats, ≤15s, draft 720p. No first/last-frame/seed/negatives exist — engineer continuity (§7):
same avatar every shot, ≤3 reusable element refs, end each shot on a composition that matches the
next shot's opening, crossfade seams.

**P5 — Repair any Seedance talking shot → Lipsync Precision** vs the P2 VO. **Three hard input
rules** (any wrong = fail): audio/video within **15%** duration (trim clip to VO length first) ·
source must carry an **audio track** (mux silent if none) · a **frontal prominent face** must be
present.

**P6 — Assemble + deliver (local ffmpeg, no API).**
```bash
python scripts/assemble.py edl-16x9.json     # 16:9 master, native end card, ducked music
python scripts/assemble.py edl-9x16.json     # 9:16 master (w/h swapped, NATIVE 9:16 end card)
python scripts/deliver.py master-16x9.mp4              # ~3 MiB for reliable SendUserFile
python scripts/deliver.py master-9x16.mp4 --height 960
```
Then run the QC checklist below. **Never derive 9:16 by center-cropping the 16:9** — it slices the
wide end-card text. Build the vertical from its own EDL with a native 9:16 card (`endcards.py`
renders both aspects). Reframe dialogue shots to the vertical via the assembler's crop-to-fill.

## Scripts (all parameterized, in `scripts/`)
- **`gen_tts.py lines.json`** — xAI Grok TTS → `audio/<id>.mp3`. One voice per character.
- **`endcards.py --aspect 16x9|9x16 ...`** — native end-card PNG (text is ALWAYS a post overlay).
- **`assemble.py edl.json`** — normalize shots → concat → ducked music bed → master.
- **`deliver.py master.mp4`** — compress to ~3 MiB so SendUserFile beats the 30s upload timeout.

### lines.json
```json
[ {"id":"ray-02","voice":"sal","text":"I'll call you right back, I promise."},
  {"id":"maya-03","voice":"ara","text":"Rough morning, Ray?"} ]
```
xAI voices: `leo eve ara rex sal` — pick one per character and keep it fixed.

### edl.json (the edit decision list)
```json
{ "out":"commercial-16x9.mp4", "w":1920, "h":1080, "fps":30,
  "audio_dir":"audio", "clips_dir":"_film/shots", "music":"assets/music.mp3", "music_vol":0.14,
  "endcard":{"headline":"Never miss another customer.","url":"app.agor.me","tag":"Your always-on AI receptionist"},
  "seq":[ {"kind":"insert","src":"insert-01","vo":"ray-01","dur":3.2},
          {"kind":"dlg","src":"ray-02"},
          {"kind":"dlg","src":"maya-03"},
          {"kind":"insert","src":"insert-11","dur":3.0},
          {"kind":"dlg","src":"founder"},
          {"kind":"card","dur":6.0} ] }
```
kinds: `dlg` keep the shot's baked-in audio · `insert` cinematic trimmed to `dur` (+ optional `vo`
padded over it) · `card` end card (aspect auto from w/h), silent, 0.5s fade-in, must be last.
For 9:16: copy the EDL, set `w:1080,h:1920`, keep the same seq — the card renders native-vertical.

## Verified constraints (don't relearn these)
- HeyGen CLI runs in **WSL** (`export WSLENV=HEYGEN_API_KEY`), never Git Bash.
- Seedance `cinematic_avatar`: **no first/last-frame, no seed, no negatives, no human-face element
  refs**; `references` ≤9 img / ≤3 vid; `duration` 4–15s; 720p/1080p. Identity comes from `avatar_id`.
- Lipsync Precision: 15% duration match · source needs an audio track · frontal prominent face.
- **Capture each `video_id` at submit; recover by ID** (`heygen video get`) — `--wait` jobs die on
  session events.
- ~1 credit/generation on the current plan (verify Activity Feed). Draft 720p, finalize 1080p;
  Seedance clips are non-editable after generation.
- On-screen text is ALWAYS a post overlay (AI renders gibberish text).
- Pronunciation: spell "Agor" as **"uh-gor"** in any TTS script (see `feedback_agor_pronunciation_uhgore`).
- Ariel's live voice = HeyGen Avatar V **starfish** clones `80c4f65d` / `8404d63d`. The ElevenLabs
  voice `38db58ee` is **dead (0 credits)** — never use it for the founder button.
- SendUserFile: ≲3 MiB, one file per call, `display:"render"`.

## QC checklist (watch the final for)
- [ ] Mouth matches the words on every spoken line (no drift / rubber-mouth).
- [ ] Same face/identity per character across every shot and BOTH engines.
- [ ] 180°/screen direction never flips; eyelines match in shot-reverse-shot.
- [ ] Lighting, palette, wardrobe consistent at every cut.
- [ ] One voice per character, consistent loudness; music ducked under speech. **Check on phone speakers:** dialogue must sit clearly above music. Target dialogue ≈ −16 LUFS with the music bed ≥ 3 dB below and ducking harder under speech (assemble.py does this; verify with `ffmpeg -ss <dlg> -t 4 -i out.mp4 -af loudnorm=print_format=summary -f null -`).
- [ ] No gibberish AI text on screen; end-card text fits its aspect (not cropped).
- [ ] Hook lands in the first 3s; button/CTA is clean.
- [ ] Aspect-correct framing in both 16:9 and 9:16 (no key action cropped).

## Reference implementation
`C:\Users\ariel\.claude\projects\agor-agents-launch-video\commercial\` — "The Two Owners" (:46,
16:9 + 9:16). `P0-concept-the-two-owners.md` (P0 template), `gen_dialogue_audio.py` /
`build_vg2.py` (the originals these scripts generalize). GBrain:
`references/agency-grade-ai-commercial-guide`, `references/heygen-seedance-cli-wsl`.
