---
name: digest
description: "Turn any URL into structured, personalized notes. AI extracts, understands, and digests content from articles, videos, social posts (Twitter, YouTube, XHS, WeChat, Reddit, etc.). Use when user pastes a URL with /digest or asks to save/digest/summarize content from a link."
metadata:
  author: lianaexe
  version: "1.0.0"
  license: MIT
---

# /digest — AI Content Digestion Skill

Turn any URL into your own knowledge. Not "read later" — "understand now."

## Usage

```
/digest <url> [optional: why you saved it or what you want]
/digest <url1> <url2> ... [optional: context for batch processing]
```

## Core Flow

### Step 1: Check Configuration

On first run, if no config exists at `.digest-config` in this skill's directory:

1. **Auto-detect environment** (silent):
   - Scan for Obsidian vaults: `find ~ -maxdepth 3 -name ".obsidian" -type d 2>/dev/null`
   - Check installed tools: x-reader MCP, whisper, ffmpeg, playwright
   - Detect user locale

2. **Ask setup questions** via AskUserQuestion — you MUST ask BOTH questions, do NOT skip any:

   Q1 — Markdown output directory:
   - If Obsidian vault detected: offer `{vault}/Inbox/` as recommended option
   - Always offer: `~/Documents/digest/md/`
   - Always offer: Custom path

   Q2 — HTML output directory:
   - Offer: `~/Documents/digest/html/` (recommended)
   - If Obsidian vault detected: also offer `{vault}/Inbox/`
   - Always offer: Custom path

3. **Offer dependency installation** if missing tools detected:

   For each missing tool, explain what it unlocks and what happens without it:

   - **x-reader MCP** (recommended):
     - Unlocks: Rich content extraction from 20+ platforms (XHS, WeChat, Twitter, YouTube, Reddit...)
     - Without: Falls back to basic WebFetch — works but may miss images, comments, engagement data
   - **Whisper + ffmpeg** (optional):
     - Unlocks: Video transcription — digest video content from any platform
     - Without: Video posts only capture title/description, not spoken content
   - **Playwright** (optional):
     - Unlocks: Deep extraction for login-walled platforms (XHS, some WeChat articles)
     - Without: Some posts may return incomplete content

   If user consents, run `scripts/setup.sh` to install selected tools.

4. **Save config** to `.digest-config` in this skill's directory:
   ```yaml
   md_output_dir: ~/obsidian-vault/Inbox/    # where markdown files go
   html_output_dir: ~/Documents/digest/html/  # where HTML files go
   language: auto
   tools:
     x_reader: true/false
     whisper: true/false
     ffmpeg: true/false
     playwright: true/false
   ```

5. **Immediately process** the user's original URL (don't make them wait or re-enter it).

### Step 2: Extract Content

**IMPORTANT — Maximize speed by running extraction in parallel with config reading.** When possible, start fetching the URL content at the same time as reading the config file. Do NOT wait for config to finish before starting extraction.

Select the best available extraction method:

**Priority chain:**
1. `x-reader` MCP `read_url` (best quality — if available)
2. `WebFetch` tool (Claude Code built-in, always works)

For multiple URLs, use `x-reader` `read_batch` if available, otherwise extract sequentially.

After extraction, check if deep extraction is needed — see `PLATFORMS.md` for platform-specific logic.

### Step 3: Evaluate Signal Strength, Select Mode & Ask Format

This step has two parts: **mode selection** (based on signal strength) and **format selection** (always ask).

#### 3a: Mode Selection

Based on what the user said (if anything), determine the digest mode:

| User Input | Mode Action | Mode |
|------------|------------|------|
| Bare URL, no comment | Auto-select, no mode question | Quick Save |
| URL + vague note ("nice", "cool", "不错") | Auto-select, no mode question | Quick Save |
| URL + clear intent ("planning a trip", "researching X") | Ask 1 confirming question | Auto-detect (see below) |
| URL + explicit instruction ("break this down", "compare these") | Auto-select, no mode question | Match to mode directly |
| Multiple URLs + context | Auto-select, no mode question | Research |

**Mode detection rules** (when auto-detecting):

- **Quick Save**: Default when no clear intent. Bare links, vague notes.
- **Resonance**: Emotional language — "this hit hard", "so true", "太触动了", "有共鸣". User references a specific point that moved them.
- **Research**: Analytical intent — "researching", "comparing", "analyzing", "调研", "对比". Multiple URLs. Questions about trade-offs.
- **Actionable**: Practical intent — "want to try", "how to", "making a plan", "做攻略", "想试试". Tutorial/guide content.
- **Breakdown**: Learning intent — "how did they do this", "break it down", "learn from this", "拆解", "学习". Content creation analysis.

When the detected mode is ambiguous, ask ONE confirming question:
"Detected this is about [topic]. Would you like me to: 1) [Mode A action] 2) [Mode B action] 3) Just save it"

#### 3b: Format Selection (ALWAYS ask — ask EARLY)

**TIMING IS CRITICAL**: Ask the format question AS SOON AS the user submits their URL — do NOT wait for content extraction or transcription to finish. The format question should be asked **in parallel with extraction** so the user answers while content is being fetched/transcribed. For fast extractions (text articles), you may ask after extraction. But for slow extractions (video transcription, Playwright), you MUST ask BEFORE extraction completes.

ALWAYS ask the user what output format they want for THIS digest via AskUserQuestion. Combine with any mode question when possible (one AskUserQuestion call, not two).

Format options:
- **Markdown** (default / recommended) — saved to `md_output_dir`
- **HTML** — saved to `html_output_dir`, auto-opened in browser after saving
- **Both** — generates both formats, saves to respective directories, opens HTML in browser

### Step 4: Generate Output

Load the appropriate template from `TEMPLATES.md` based on the selected mode and output format.

**Key rules:**
- Output language follows user's input language (if they write in Chinese, output in Chinese; English → English; etc.)
- NEVER fabricate content — only use what was actually extracted from the URL
- Tags should be 2-4 relevant topic tags based on actual content, in the user's language
- Keep summaries concise — the user wants insights, not repetition
- For image OCR: if images can't be read, note this honestly rather than guessing

### Step 5: Save & Confirm

1. Read output directories from `.digest-config`
2. Generate filename: `{cleaned_title, max 60 chars}`
3. Save based on user's format choice:
   - **Markdown**: write `{filename}.md` to `md_output_dir`
   - **HTML**: write `{filename}.html` to `html_output_dir`, then run `open {filepath}` to preview in browser
   - **Both**: write both files to their respective directories, open the HTML in browser
5. Display a **digest card** to confirm (use box-drawing characters for visual structure):

```
┌─────────────────────────────────────────────────┐
│  ✅ Digested: {title}                           │
│  📝 {mode} | {platform} | {author}              │
│  🏷️  {tag1} · {tag2} · {tag3}                   │
│                                                 │
│  💡 {2-3 sentence summary}                      │
│                                                 │
│  📄 {output_dir}/{filename}                     │
└─────────────────────────────────────────────────┘
```

The digest card should be visually clean and give the user a complete snapshot of what was digested. Adjust the box width to fit the content.

---

## Reference Files

- **TEMPLATES.md** — Output templates for all 5 modes (Markdown + HTML). Load when generating output.
- **PLATFORMS.md** — Platform-specific extraction strategies (video transcription, image OCR, login-walled content). Load when deep extraction is needed.
