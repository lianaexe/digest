# /digest

**Turn bookmarks into knowledge.** An AI-powered skill for [Claude Code](https://claude.ai/code) that extracts, understands, and structures content from any URL — right when you save it.

> Stop hoarding links. Start digesting them.

<div align="center">

https://github.com/lianaexe/digest/raw/main/demo.mp4

</div>

---

## The Problem

You bookmark things. You never go back.

Your "Read Later" list has 200+ items. Your browser tabs are a graveyard. That XHS post, that Twitter thread, that YouTube video — saved and forgotten.

**Existing tools stop at "saving":** Readwise highlights but doesn't synthesize. Notion Web Clipper copies but doesn't think. Browser bookmarks just... exist.

## The Solution

`/digest` processes content **at the moment you save it.** Paste a URL, say why you saved it (or don't), and AI does the rest:

- Extracts the full content (text, images, video transcripts)
- Understands your intent (saving for later? researching? planning a trip?)
- Generates a structured note in **your** format
- Saves it where **you** want it

The result: content that's actually **yours**, not just a link collecting dust.

---

## Features

- **Any URL** — articles, tweets, XHS posts, YouTube videos, WeChat articles, Reddit threads, and more
- **5 digest modes** — AI picks the right one based on what you say (or ask)
- **Multi-URL research** — drop several links and get a comparison table
- **Multiple output formats** — Markdown (default), HTML, or Slides
- **Auto-language** — output matches your input language (English, Chinese, Japanese, etc.)
- **Smart, not annoying** — only asks questions when it genuinely needs to

## Digest Modes

| Mode | When | What You Get |
|------|------|-------------|
| **Quick Save** | Just drop a link | Summary + tags — fast and done |
| **Resonance** | "This really hit me" | The quote that moved you + space for your thoughts |
| **Research** | "Comparing options" | Structured analysis + comparison table |
| **Actionable** | "I want to try this" | Step-by-step checklist you can act on |
| **Breakdown** | "How did they do this?" | Structure analysis + reusable patterns |

---

## Install

### Quick Start

Clone this repo into your Claude Code skills directory:

```bash
# Navigate to your Claude Code skills directory
mkdir -p ~/.claude/skills
cd ~/.claude/skills

# Clone the skill
git clone https://github.com/lianaexe/digest.git
```

That's it. Run `/digest <url>` in Claude Code and it will guide you through first-time setup.

### Enhanced Setup (Optional)

For the best experience, install these optional tools. The skill works without them but with reduced capabilities:

<details>
<summary><strong>x-reader MCP</strong> (Recommended) — Rich content extraction</summary>

Unlocks high-quality extraction from 20+ platforms including XHS, WeChat, Twitter, YouTube, and Reddit. Without it, the skill falls back to basic web fetching which may miss images, comments, and engagement data.

```bash
claude mcp add x-reader -- npx -y x-reader-mcp
```
</details>

<details>
<summary><strong>Whisper + ffmpeg</strong> — Video transcription</summary>

Unlocks video-to-text transcription for any platform. Without it, video posts will only capture titles and descriptions, not spoken content.

```bash
# macOS
brew install ffmpeg
pip3 install openai-whisper

# Linux
sudo apt-get install ffmpeg
pip3 install openai-whisper
```
</details>

<details>
<summary><strong>Playwright</strong> — Deep extraction for walled content</summary>

Unlocks extraction from login-walled platforms (some XHS and WeChat content). Without it, some posts may return incomplete content.

```bash
pip3 install playwright
python3 -m playwright install chromium
```
</details>

Or install everything at once:

```bash
cd ~/.claude/skills/digest
bash scripts/setup.sh all
```

---

## Usage

### Quick save (most common)

```
/digest https://twitter.com/elonmusk/status/123456
```

AI extracts and summarizes — no questions asked.

### Save with intent

```
/digest https://xhs.com/explore/abc123 planning a trip to Tokyo next month
```

AI detects your intent, picks Actionable mode, generates a checklist.

### Research multiple URLs

```
/digest comparing these AI code editors
https://cursor.com
https://windsurf.com
https://bolt.new
```

AI extracts all three, generates a comparison table.

### Breakdown for learning

```
/digest https://youtube.com/watch?v=xyz break down how they structured this
```

AI analyzes the content's structure, techniques, and reusable patterns.

---

## Configuration

On first run, `/digest` auto-detects your environment and asks a few quick questions:

- **Output directory** — where to save notes (auto-detects Obsidian vaults)
- **Default format** — Markdown or HTML
- **Optional tools** — offers to install enhanced extraction tools

Config is saved to `.digest-config` in the skill directory. You can edit it anytime:

```yaml
output_dir: ~/my-notes/Inbox/
default_format: markdown
language: auto
```

---

## Examples

See the [examples/](examples/) directory for sample outputs:

- [Quick Save](examples/quick-save.md) — a blog post summarized
- [Research](examples/research.md) — multi-source comparison
- [Actionable](examples/actionable.md) — travel guide turned into checklist

---

## How It Works

```
URL + optional note
       │
       ▼
Extract content (x-reader MCP → WebFetch fallback)
       │
       ▼
Evaluate intent signal strength
  ├─ Weak/none → Quick Save (no questions)
  ├─ Clear intent → Ask 1 confirming question
  └─ Explicit instruction → Execute directly
       │
       ▼
Select digest mode → Generate structured output
       │
       ▼
Save to your configured directory ✅
```

---

## Supported Platforms

Works with any URL. Enhanced extraction for:

| Platform | Text | Images | Video | Notes |
|----------|------|--------|-------|-------|
| Twitter/X | ✅ | ✅ | — | Threads supported |
| YouTube | ✅ | — | ✅ | Auto-captions extracted |
| XHS (Xiaohongshu) | ✅ | ✅ | ✅* | Image OCR + video transcription |
| WeChat Articles | ✅ | ✅ | — | Some may need Playwright |
| Bilibili | ✅ | — | ✅ | Subtitles extracted |
| Reddit | ✅ | ✅ | — | Comments included |
| Medium / Blogs | ✅ | ✅ | — | Clean extraction |
| GitHub | ✅ | — | — | READMEs, issues, PRs |

*\*Requires Whisper + ffmpeg for video transcription*

---

## Requirements

- [Claude Code](https://claude.ai/code) — the runtime environment
- That's it. Everything else is optional enhancement.

---

## Contributing

Contributions welcome! Some areas that could use help:

- **New platform handlers** in `PLATFORMS.md`
- **Output template improvements** in `TEMPLATES.md`
- **Translations** for README and examples
- **Bug reports** and feature requests via Issues

---

## License

MIT — see [LICENSE](LICENSE)

---

Built with Claude Code. Digested with love.
