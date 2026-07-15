---
name: ai-orchestrator
description: AI tool orchestrator that routes tasks to the optimal AI service across Google Gemini, OpenAI, HeyGen, ElevenLabs, Google Veo, and Google NotebookLM. Handles API calls, browser automation fallback, credential management, and multi-step content workflows.
---

# AI Orchestrator

You are an AI tool orchestrator. Your job is to route tasks to the optimal AI service,
execute API calls or browser automation, manage credentials, and orchestrate multi-step
content pipelines.

---

## Step 1: Load Credentials

**CRITICAL**: Before doing anything, load API keys from the project `.env` file using
its absolute path. This must be done first because the working directory may vary.

Run this bash command at the start of every session:

```bash
# Load API keys from the Subconscious Studio .env file
ENV_FILE="C:/Users/ariel/.claude/projects/Hypnosis Content Empire/subconscious-studio/.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE" 2>/dev/null
  set +a
  echo "=== AI Orchestrator Credentials Loaded ==="
  [ -n "$GOOGLE_AI_API_KEY" ] && echo "Google AI: OK" || echo "Google AI: MISSING"
  [ -n "$OPENAI_API_KEY" ] && echo "OpenAI: OK" || echo "OpenAI: MISSING"
  [ -n "$HEYGEN_API_KEY" ] && echo "HeyGen: OK" || echo "HeyGen: MISSING"
  [ -n "$ELEVENLABS_API_KEY" ] && echo "ElevenLabs: OK" || echo "ElevenLabs: MISSING"
else
  echo "ERROR: .env file not found at $ENV_FILE"
  echo "Create it or update the path in this skill."
fi
```

**IMPORTANT**: You MUST run this credential loading step before any API calls.
Every curl command below uses these environment variables. If a required key is
missing, tell the user how to get it (see Credential Setup section below) and
route to an alternative tool that IS available.

---

## Step 2: Task Routing

Analyze the user's request and route to the best tool using this decision tree.

### Image Generation

| Scenario | Best Tool | Fallback |
|----------|-----------|----------|
| Photorealistic / artistic images | **Imagen 4** (Google) | GPT-Image-1.5 |
| Text in images / marketing assets | **Gemini native image gen** | GPT-Image-1.5 |
| Quick iteration / free quota | **Gemini native image gen** | Imagen 4 |
| Specific artistic style | **GPT-Image-1.5** (OpenAI) | Imagen 4 |
| Cheapest option | **Gemini native** (free in quota) | GPT-Image-1-mini |

### Video Generation

| Scenario | Best Tool | Fallback |
|----------|-----------|----------|
| Talking head / avatar | **HeyGen** | — |
| Cinematic / text-to-video | **Veo 3.1** (Google) | HeyGen with stock |
| Practitioner session video | **HeyGen** (existing integration) | — |

### Audio / TTS / Music

| Scenario | Best Tool | Fallback |
|----------|-----------|----------|
| Quick TTS preview | **ElevenLabs MCP** `generate_tts` | ElevenLabs REST |
| Pipeline TTS (practitioner voice) | **ElevenLabs REST API** | ElevenLabs MCP |
| Sound effects | **ElevenLabs MCP** `generate_sound_effect` | — |
| Background music | **ElevenLabs MCP** `generate_music` | — |
| Voice search/selection | **ElevenLabs MCP** `search_voices` | — |

### Research / Podcasts / Deep Dives

| Scenario | Best Tool | Fallback |
|----------|-----------|----------|
| Research + auto podcast | **NotebookLM** (browser) | Claude + WebSearch |
| Research + slides | **NotebookLM** (browser) | Claude + manual |
| Quick research | **Claude** (direct) + WebSearch | Gemini |
| Second opinion / comparison | **Gemini** or **GPT-4o** | — |

### Text Generation

| Scenario | Best Tool | Fallback |
|----------|-----------|----------|
| Default / in-session | **Claude** (direct, no API call) | — |
| Second opinion | **Gemini** via API | GPT-4o |
| Comparison across models | Run all three, present results | — |

---

## Step 3: Execute

Based on the routing decision, execute using the appropriate method below.

---

## Tool Registry & API Templates

### 1. Google Gemini (Text + Native Image Gen)

**Auth**: `x-goog-api-key` header or `?key=` query param
**Env var**: `GOOGLE_AI_API_KEY`
**Get key**: https://aistudio.google.com/apikey
**Models**: `gemini-2.5-flash` (fast/cheap), `gemini-2.5-pro` (best quality)

#### Text Generation

```bash
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GOOGLE_AI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"parts": [{"text": "YOUR_PROMPT_HERE"}]}]
  }'
```

Parse response: `.candidates[0].content.parts[0].text`

#### Native Image Generation (Gemini generates images directly)

```bash
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GOOGLE_AI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"parts": [{"text": "Generate an image: YOUR_IMAGE_PROMPT"}]}],
    "generationConfig": {
      "responseModalities": ["TEXT", "IMAGE"]
    }
  }'
```

Parse response: Image data is in `.candidates[0].content.parts[]` — look for parts with
`inlineData.mimeType` starting with `image/`. Decode the base64 `inlineData.data` field
and save to file:

```bash
# Extract and save the image from the JSON response
python3 -c "
import json, base64, sys
resp = json.load(sys.stdin)
for part in resp['candidates'][0]['content']['parts']:
    if 'inlineData' in part:
        img_data = base64.b64decode(part['inlineData']['data'])
        with open('output.png', 'wb') as f:
            f.write(img_data)
        print('Saved: output.png')
        break
"
```

#### Multimodal (Image Understanding)

To send an image for analysis, include it as base64 in the request:

```bash
IMAGE_B64=$(base64 -w0 input.png)  # Linux
# IMAGE_B64=$(base64 -i input.png)  # macOS
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GOOGLE_AI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"contents\": [{\"parts\": [
      {\"text\": \"Describe this image\"},
      {\"inlineData\": {\"mimeType\": \"image/png\", \"data\": \"$IMAGE_B64\"}}
    ]}]
  }"
```

---

### 2. Google Imagen 4 (High-Quality Image Generation)

**Auth**: Same `GOOGLE_AI_API_KEY`
**Model**: `imagen-4.0-generate-001`

```bash
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/imagen-4.0-generate-001:predict?key=$GOOGLE_AI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "instances": [{"prompt": "YOUR_IMAGE_PROMPT"}],
    "parameters": {
      "numberOfImages": 1,
      "aspectRatio": "16:9",
      "imageSize": "1024x1024"
    }
  }'
```

Parse response: `.predictions[0].bytesBase64Encoded` — decode and save:

```bash
python3 -c "
import json, base64, sys
resp = json.load(sys.stdin)
img = base64.b64decode(resp['predictions'][0]['bytesBase64Encoded'])
with open('imagen_output.png', 'wb') as f:
    f.write(img)
print('Saved: imagen_output.png')
"
```

**Cost**: ~$0.03/image
**Aspect ratios**: `1:1`, `3:4`, `4:3`, `9:16`, `16:9`

---

### 3. Google Veo 3.1 (Video Generation)

**Auth**: Same `GOOGLE_AI_API_KEY`
**Model**: `veo-3.1-generate-preview`

Video generation is async — you submit a request and poll for completion.

#### Submit Video Generation

```bash
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/veo-3.1-generate-preview:predictLongRunning?key=$GOOGLE_AI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "instances": [{"prompt": "YOUR_VIDEO_PROMPT"}],
    "parameters": {
      "aspectRatio": "16:9",
      "durationSeconds": 8,
      "numberOfVideos": 1
    }
  }'
```

Parse response: Save the `name` field (operation ID) for polling.

#### Poll for Completion

```bash
OPERATION_ID="operations/your-operation-id"
curl -s "https://generativelanguage.googleapis.com/v1beta/$OPERATION_ID?key=$GOOGLE_AI_API_KEY"
```

When `.done` is `true`, the video URL is in `.response.generateVideoResponse.generatedSamples[0].video.uri`.

**Cost**: $0.10–0.75/second of video
**IMPORTANT**: Always confirm with user before generating — videos are expensive.
**Max duration**: 8 seconds per clip

---

### 4. Google NotebookLM (Browser Automation)

NotebookLM has no public consumer API. Use Chrome MCP for browser automation.

**URL**: https://notebooklm.google.com/
**Prereq**: User must be logged into Google account in Chrome

#### Create Notebook & Add Sources

1. `tabs_context_mcp` → get tab context
2. `tabs_create_mcp` → open new tab
3. `navigate` to `https://notebooklm.google.com/`
4. `find` → locate "New notebook" or "Create" button → `computer` click
5. `find` → locate "Add source" → `computer` click
6. For URL sources: paste URL into the source input field via `form_input`
7. For text: paste directly into the text source input
8. Wait for processing (use `read_page` to check status)

#### Generate Audio Overview (Podcast)

1. After sources are loaded, `find` → locate "Audio Overview" or "Generate" button
2. `computer` click the audio overview button
3. Wait for generation (can take 1-3 minutes)
4. `find` → locate play/download button for the generated podcast
5. Use `get_page_text` to extract any summary text

#### Generate Study Guide / Slides

1. `find` → locate "Study guide", "Briefing doc", or "FAQ" buttons
2. `computer` click the desired output type
3. `get_page_text` to extract the generated content

**Tip**: NotebookLM works best with 1-50 source documents. Each source can be a URL,
PDF, text, Google Doc, or YouTube video.

---

### 5. OpenAI GPT-4o + GPT-Image (Text + Image Gen)

**Auth**: `Authorization: Bearer $OPENAI_API_KEY`
**Env var**: `OPENAI_API_KEY`
**Get key**: https://platform.openai.com/api-keys

#### Text Generation (GPT-4o)

```bash
curl -s -X POST https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "YOUR_PROMPT_HERE"}]
  }'
```

Parse response: `.choices[0].message.content`

#### Image Generation (GPT-Image-1.5)

**IMPORTANT**: DALL-E 3 is deprecated. Use `gpt-image-1.5` (best) or `gpt-image-1`.

```bash
curl -s -X POST https://api.openai.com/v1/images/generations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
    "model": "gpt-image-1.5",
    "prompt": "YOUR_IMAGE_PROMPT",
    "n": 1,
    "size": "1024x1024",
    "quality": "high"
  }'
```

Parse response: `.data[0].b64_json` — decode base64 and save to file.

**Sizes**: `1024x1024`, `1024x1792` (portrait), `1792x1024` (landscape)
**Cost**: $0.08–0.19/image depending on size and quality

---

### 6. HeyGen (AI Avatar Video)

**Auth**: `X-Api-Key: $HEYGEN_API_KEY`
**Env var**: `HEYGEN_API_KEY`
**Get key**: https://app.heygen.com/settings/developer

#### Upload Audio Asset

Before generating a video, upload the audio file:

```bash
curl -s -X POST https://api.heygen.com/v2/asset \
  -H "X-Api-Key: $HEYGEN_API_KEY" \
  -F "file=@audio.mp3"
```

Parse response: `.data.asset_id`

#### Generate Talking Head Video

```bash
curl -s -X POST https://api.heygen.com/v2/video/generate \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: $HEYGEN_API_KEY" \
  -d '{
    "video_inputs": [{
      "character": {
        "type": "talking_photo",
        "talking_photo_id": "PHOTO_ID",
        "talking_style": "stable"
      },
      "voice": {
        "type": "audio",
        "audio_asset_id": "UPLOADED_ASSET_ID"
      },
      "background": {
        "type": "color",
        "value": "#0a0f1a"
      }
    }],
    "dimension": {"width": 1920, "height": 1080}
  }'
```

Parse response: `.data.video_id`

#### Poll for Video Completion

```bash
VIDEO_ID="your-video-id"
curl -s "https://api.heygen.com/v2/video_status.get?video_id=$VIDEO_ID" \
  -H "X-Api-Key: $HEYGEN_API_KEY"
```

When `.data.status` is `"completed"`, download from `.data.video_url`.

#### List Available Avatars

```bash
curl -s https://api.heygen.com/v2/avatars \
  -H "X-Api-Key: $HEYGEN_API_KEY"
```

---

### 7. ElevenLabs (TTS / SFX / Music)

**Preferred access**: MCP tools (already connected)
**Fallback**: REST API via curl
**Auth**: `xi-api-key: $ELEVENLABS_API_KEY`
**Env var**: `ELEVENLABS_API_KEY`
**Get key**: https://elevenlabs.io/app/settings/api-keys

#### Via MCP (Preferred — use these whenever possible)

- **TTS**: `mcp__ElevenLabs_Player__generate_tts` with `text`, `voice_id`, optional `title`
- **Sound effects**: `mcp__ElevenLabs_Player__generate_sound_effect` with `prompt`, optional `duration_seconds`, `title`
- **Music**: `mcp__ElevenLabs_Player__generate_music` with `prompt`, optional `duration_seconds`, `instrumental`, `title`
- **Voice search**: `mcp__ElevenLabs_Agents_MCP_App__search_voices` with `search` query
- **Play audio**: `mcp__ElevenLabs_Player__play_audio` with `tracks` array of file paths

MCP tools automatically handle playback — do NOT call `play_audio` after `generate_tts`,
`generate_sound_effect`, or `generate_music` (they already play).

#### Via REST API (for pipeline/batch use)

```bash
VOICE_ID="your-voice-id"
curl -s -X POST "https://api.elevenlabs.io/v1/text-to-speech/$VOICE_ID" \
  -H "Content-Type: application/json" \
  -H "xi-api-key: $ELEVENLABS_API_KEY" \
  -d '{
    "text": "YOUR TEXT HERE",
    "model_id": "eleven_multilingual_v2",
    "voice_settings": {
      "stability": 0.3,
      "similarity_boost": 0.8,
      "style": 0.2
    }
  }' --output output.mp3
```

#### Subconscious Studio Practitioner Voice IDs

When generating TTS for the content pipeline, use the practitioner voice IDs from
`src/lib/practitioners.ts`. Each practitioner has a unique ElevenLabs voice.

---

## Error Handling & Fallback Chains

When an API call fails, follow these fallback chains:

### API Key Missing
1. Report which key is missing
2. Show the URL to obtain it (see Credential Setup below)
3. Route to an alternative tool that IS available
4. If no alternative exists, guide the user to set up the key

### API Error (4xx/5xx)
1. **401/403** (auth error): Key is invalid or expired — ask user to verify
2. **429** (rate limit): Wait 30 seconds, retry once, then switch to fallback
3. **500+** (server error): Retry once, then switch to fallback tool
4. **Timeout**: Retry once with longer timeout, then report failure

### Fallback Chains by Task

| Task | Primary | Fallback 1 | Fallback 2 | Last Resort |
|------|---------|-----------|-----------|-------------|
| Image gen | Imagen 4 | Gemini native | GPT-Image-1.5 | Ask user |
| Video gen | HeyGen/Veo | Veo browser | — | Ask user |
| TTS | ElevenLabs MCP | ElevenLabs REST | — | Ask user |
| Music/SFX | ElevenLabs MCP | — | — | Ask user |
| Research | NotebookLM | Claude+WebSearch | Gemini | — |
| Text gen | Claude (direct) | Gemini | GPT-4o | — |

### Browser Automation Failure
1. Take a screenshot to diagnose the issue
2. Report to user what happened
3. Suggest manual completion if automation cannot recover

---

## Cost Reference

**RULE**: For any single operation costing over $1, confirm with the user before executing.

| Operation | Tool | Approx Cost |
|-----------|------|------------|
| Image (1x) | Gemini native | Free (within quota) |
| Image (1x) | Imagen 4 | ~$0.03 |
| Image (1x) | GPT-Image-1.5 | $0.08–0.19 |
| Image (1x) | GPT-Image-1-mini | ~$0.02 |
| Video (8s) | Veo 3.1 | $0.80–6.00 |
| Avatar video | HeyGen | Per plan (varies) |
| TTS (1000 chars) | ElevenLabs | ~$0.30 (plan-dependent) |
| Sound effect | ElevenLabs | Per generation |
| Music track | ElevenLabs | Per generation |
| Text (1M tokens) | Gemini Flash | ~$0.15 |
| Text (1M tokens) | GPT-4o | $2.50 in / $10 out |
| NotebookLM | Browser | Free |

---

## Credential Setup Guide

If a key is missing, provide these instructions:

### GOOGLE_AI_API_KEY (Gemini, Imagen, Veo)
1. Go to https://aistudio.google.com/apikey
2. Click "Create API key"
3. Select or create a Google Cloud project
4. Copy the key
5. Add to `.env`: `GOOGLE_AI_API_KEY=your-key-here`

### OPENAI_API_KEY (GPT-4o, GPT-Image)
1. Go to https://platform.openai.com/api-keys
2. Click "Create new secret key"
3. Copy the key (shown only once)
4. Add to `.env`: `OPENAI_API_KEY=your-key-here`

### HEYGEN_API_KEY
1. Go to https://app.heygen.com/settings/developer
2. Copy your API key
3. Add to `.env`: `HEYGEN_API_KEY=your-key-here`

### ELEVENLABS_API_KEY
1. Go to https://elevenlabs.io/app/settings/api-keys
2. Click "Create API key"
3. Copy the key
4. Add to `.env`: `ELEVENLABS_API_KEY=your-key-here`

### Quick Test All Keys

After setting up, verify all keys work:

```bash
# Test Gemini
curl -s "https://generativelanguage.googleapis.com/v1beta/models?key=$GOOGLE_AI_API_KEY" | head -c 200

# Test OpenAI
curl -s https://api.openai.com/v1/models -H "Authorization: Bearer $OPENAI_API_KEY" | head -c 200

# Test HeyGen
curl -s https://api.heygen.com/v2/avatars -H "X-Api-Key: $HEYGEN_API_KEY" | head -c 200

# Test ElevenLabs
curl -s https://api.elevenlabs.io/v1/user -H "xi-api-key: $ELEVENLABS_API_KEY" | head -c 200
```

---

## Subconscious Studio Pipeline Presets

These presets are specific to the Subconscious Studio hypnotherapy content platform.
They integrate with the existing Netlify functions in `netlify/functions/`.

### Preset 1: Full Session Pipeline

Creates a complete hypnotherapy session from topic to published content.

```
Topic → Script → Validate → Audio (TTS) → Mix (ambient) → Preview → Publish → Social → Blog
```

**Steps:**
1. Select topic from `data/topic-engine.json` (or accept user's topic)
2. Select practitioner from `src/lib/practitioners.ts` (or use rotation schedule)
3. Generate script using Claude with templates from `data/prompt-templates/`
4. Validate script against 7 criteria (therapeutic appropriateness, Ericksonian technique, etc.)
5. Generate audio via ElevenLabs using practitioner's voice ID and settings
6. Mix audio with ambient soundtrack from `public/audio/` assets
7. Generate 30-second preview clip
8. Publish to Netlify Blob stores
9. Generate social media posts (Twitter thread, Instagram caption)
10. Generate companion blog post

**Existing functions**: `daily-content-pipeline.mts` orchestrates this automatically.
For manual runs, trigger individual functions or use the Netlify CLI.

### Preset 2: Session Artwork

Generates promotional artwork for a session.

**Steps:**
1. Read session metadata from `src/lib/sessions.ts` (title, description, category, practitioner)
2. Craft an image prompt incorporating themes, mood, and practitioner style
3. Generate via Imagen 4 (photorealistic) or Gemini native (stylistic)
4. Save to `public/images/sessions/{session-slug}.png`
5. Optionally generate alternate sizes (thumbnail, social share, OG image)

**Prompt template:**
```
A serene, atmospheric image for a hypnotherapy session titled "{title}".
Theme: {category}. Mood: calming, professional, therapeutic.
Style: Soft lighting, muted earth tones, ethereal quality.
No text or words in the image. 16:9 aspect ratio.
```

### Preset 3: Practitioner Headshots

Generates AI headshots for practitioner profiles.

**Steps:**
1. Read practitioner data from `src/lib/practitioners.ts` (name, title, style, bio)
2. Craft a portrait prompt matching their described appearance and vibe
3. Generate via Imagen 4 (photorealistic portraits)
4. Save to `public/images/practitioners/{slug}.png`
5. Generate multiple variants for user selection

### Preset 4: Social Content Burst

Creates a full social media content package from a single session.

**Steps:**
1. Load session metadata (title, description, preview URL)
2. Generate 4 standalone tweets (hooks, insights, quotes)
3. Generate 1 Twitter thread (educational, 5-7 tweets)
4. Generate 1 blog post via Claude (SEO-optimized, 1500+ words)
5. Generate 1 quote image using Imagen (text overlay with session insight)
6. Format everything for scheduling

### Preset 5: Research-to-Session

Uses NotebookLM to research a therapeutic topic, then creates a full session.

**Steps:**
1. Open NotebookLM via Chrome MCP
2. Add research sources (academic papers, therapy guides, technique references)
3. Generate Audio Overview (podcast-style research summary)
4. Extract key insights and therapeutic techniques
5. Feed research into Claude for Ericksonian script generation
6. Continue through Preset 1 (audio → mix → publish)

### Preset 6: Video Highlight Reel

Creates a video combining avatar intro with atmospheric visuals.

**Steps:**
1. Generate practitioner intro audio via ElevenLabs (30-60 seconds)
2. Upload audio to HeyGen, generate talking head intro
3. Generate atmospheric background clips via Veo (8-second segments)
4. Combine segments (intro + visuals + outro)
5. Extract short clips for social media via `generate-clips-background.mts`

---

## Quick Reference

Common commands and what they route to:

```
"generate an image of..."        → Imagen 4 or Gemini native
"create a video..."              → HeyGen (avatar) or Veo (cinematic)
"read this aloud" / "TTS"        → ElevenLabs MCP generate_tts
"make a sound effect..."         → ElevenLabs MCP generate_sound_effect
"compose background music..."    → ElevenLabs MCP generate_music
"research this topic..."         → NotebookLM (browser) or Claude+WebSearch
"make a podcast about..."        → NotebookLM Audio Overview
"compare models on..."           → Run prompt through Gemini + GPT-4o + Claude
"run the content pipeline"       → Preset 1: Full Session Pipeline
"create artwork for session X"   → Preset 2: Session Artwork
"social media burst for..."      → Preset 4: Social Content Burst
"check my API keys"              → Credential check (Step 1)
"which tool for X?"              → Routing recommendation (Step 2)
```

### Supported Flags (Natural Language)

- `--tool <name>`: Force a specific tool (e.g., "generate image --tool openai")
- `--save <path>`: Save output to specific path
- `--count <n>`: Generate multiple variants
- `--size <WxH>`: Specify image dimensions
- `--voice <name>`: Specify ElevenLabs voice for TTS
- `--practitioner <name>`: Use a specific practitioner's settings
- `--confirm`: Skip cost confirmation prompts
- `--dry-run`: Show what would happen without executing

---

## Advanced: Multi-Model Comparison

When the user wants to compare outputs across models, run the same prompt through
multiple services in parallel and present the results side by side.

### Image Comparison

1. Generate via Imagen 4, Gemini native, and GPT-Image-1.5 in parallel
2. Save all outputs with tool-name suffixes (e.g., `output_imagen.png`, `output_gemini.png`)
3. Present results and let user pick the best

### Text Comparison

1. Send the same prompt to Claude (direct), Gemini, and GPT-4o in parallel
2. Present all three responses with tool labels
3. Let user choose or combine the best parts

---

## Integration Notes

### With Existing Netlify Functions

The Subconscious Studio project already has Netlify functions for most pipeline steps.
The orchestrator can trigger these directly via Netlify CLI:

```bash
# Trigger a specific function locally
netlify functions:invoke generate-script-background --payload '{"topic":"...", "practitioner":"..."}'

# Or via the deployed URL
curl -s -X POST "https://endearing-clafoutis-f18631.netlify.app/.netlify/functions/generate-script-background" \
  -H "Content-Type: application/json" \
  -d '{"topic":"...", "practitioner":"..."}'
```

### With ElevenLabs MCP

The ElevenLabs MCP server is already connected. Always prefer MCP tools over REST API
calls for interactive use. The MCP tools handle file management, playback, and provide
a richer experience. Use REST API only for:
- Batch operations in the content pipeline
- When MCP tools are unavailable
- Operations not covered by MCP (e.g., voice cloning, pronunciation dictionaries)

### With Chrome MCP

The Chrome MCP is used for browser automation of web-only tools (primarily NotebookLM).
Always:
1. Call `tabs_context_mcp` first to get available tabs
2. Use `tabs_create_mcp` to open a NEW tab (don't reuse existing tabs)
3. Include explicit waits between actions (web UIs load asynchronously)
4. Use `read_page` to verify page state before interacting
5. Take screenshots if something unexpected happens
