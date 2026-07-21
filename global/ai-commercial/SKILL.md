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
Lyria music beds, standalone Three.js 3D (when the ask is real 3D, not HyperFrames), deterministic
captions from beat timings, and the 9:16 vertical hybrid: **`references/lyria-threejs-captions-playbook.md`**.

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
present. **Also use P5 to fix SOFT AVATAR V lip sync** (verified 2026-07-16): Avatar V on a photo
look can render mouth motion that doesn't tightly match phonemes — `POST /v3/lipsyncs` with
`mode:"precision"`, video+audio as uploaded asset_ids, `keep_the_same_format:true`, `fps_mode:"cfr"`
regenerates the mouth to match the exact audio while keeping the Avatar V look. Don't just re-roll
the render (Avatar V renders at 25fps; a re-roll rarely fixes soft sync). Before blaming assembly,
MEASURE: a clip's video vs audio stream duration + start_time — if they match pre/post-encode
(they will), the sync issue is in the render, not the concat.

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
**Ariel's own voice = his xAI custom clones.** Default to **`gpp66sriwbgy`** (his stated pick as the
one that sounds most like him, 2026-07-15). Others: `npoaqvdxjns6`, `anarpdtrfv7i`, `6vufxectrwux`.
Use these for any founder button or first-person Ariel VO, in preference to the HeyGen voice clones.

**Built-in xAI voices — the voice NAME is the voice_id.** (`leo eve ara rex sal` was a stale subset;
the real list is 26.) Male: `Altair` elegant/premium · `Atlas` commanding · `Castor` easygoing ·
`Cosmo` bright/curious · `Helios` upbeat/versatile · `Helix` bold/adrenaline · `Kepler` inventive ·
`Leo` authoritative · `Lumen` warm/articulate · `Lux` grounded/quietly wise · `Naksh` warm/wise ·
`Orion` rich/cinematic · `Perseus` trustworthy · `Rex` confident/clear · `Rigel` precise/professional ·
`Sal` smooth/balanced · `Sirius` quick-witted/playful · `Zagan` dramatic · `Zenith` sharp/driven.
Female: `Ara` warm/friendly · `Carina` soft/soothing · `Celeste` compassionate · `Eve` energetic ·
`Iris` friendly/charming · `Luna` gentle/nurturing · `Ursa` warm/steadfast.
Pick one per character and keep it fixed. Full table + usage: `scripts/gen_tts.py` docstring.

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
- **Ariel's real assets, resolved against the live API 2026-07-15 (the old note conflated voices with
  avatars — `80c4f65d` / `8404d63d` are VOICE ids, not avatar groups):**
  - **ARIEL'S PREFERRED LOOKS (his pick 2026-07-15) — all in offices, all genuinely him:**
    `48c2c143450044abb5cac4fb10b0974c` grey blazer, city window ·
    `aa42be6e4cdd4696a2ae016c13921cc1` navy blazer, boardroom ·
    `f57aaeab87ed452892b387563d3c24eb` tan blazer, presentation screen ·
    `25bbbeb5eec944b3a3e7271d80494caf` black suit, lounge ·
    `1556bb72d645418c9c4551d1e35d9580` white polo, open-plan office.
    **He explicitly does NOT want** the wine-cellar digital-twin look
    (`b636f6a57ba14b039aa4e10d1928cb6f`, "Ariel", `/avatar/v3/` preview) — that set ships baked into
    the twin and reads wrong for business work.
  - **`business_type:"generated"` does NOT mean a generated PERSON.** It means the LOOK (wardrobe +
    set) was synthesized from Ariel's likeness. All five above are visibly, unmistakably him. Do not
    reject them as "AI-invented faces" — that misread cost a whole P0 revision on 2026-07-15.
  - **Voice: use his xAI clones, NOT the HeyGen ones** (his instruction, 2026-07-15). Default
    **`gpp66sriwbgy`**. Generate the line with `gen_tts.py`, upload the mp3 as an audio asset, and
    drive the Avatar V twin from that `audio_asset_id` — same pattern as the Avatar IV path, so his
    real face is driven by his preferred voice. The HeyGen clones
    (`80c4f65d357140a5a6adda04c9a7e189` "Ariel Voice Clone 2026_06_25",
    `8404d63d254a4c48afe11d00e2e14025` "Ariel", the group's `default_voice_id`) still exist and
    still work, but are no longer the default — do not reach for them just because the avatar group
    points at one.
  - **THE REAL TRAP is the ENGINE, not the look.** `POST /v2/video/generate` has **no engine
    selector and silently gives you Avatar IV.** Using the right avatar is NOT enough. **Avatar V
    requires `POST /v3/videos` with `engine: {"type":"avatar_v"}`** — the v3 schema says outright
    "Defaults to Avatar IV when omitted". Verified 2026-07-15: identical line + identical
    `audio_asset_id`, v2 finished in **15 seconds at 1132 kbps**, v3+avatar_v took **~10 minutes at
    1772 kbps**. If a "dialogue shot" renders in seconds, it is Avatar IV — throw it away.
  - **Group shape (`111c9cd2c912466e9bb23392588da409`), for parsing only:** the generated photo looks
    carry an `id` field; the wine-cellar video twin carries `avatar_id`. Both are Ariel. Photo looks
    accept `engine: avatar_v` — the schema auto-selects an `instant_avatar` sibling in the group as
    the animation reference (`reference_look_id` overrides it).
  - The ElevenLabs voice `38db58ee85c24d07a91dd622f382d111` ("Ariel Agor - best") is **dead
    (0 credits)** but STILL LISTED in `/v2/voices` — never use it for the founder button.
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
