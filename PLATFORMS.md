# Platform-Specific Extraction

This file contains platform-specific strategies for content extraction. Load this when the standard extraction (Step 2) needs enhancement.

---

## Platform Detection

Identify the platform from the URL:

| URL Pattern | Platform |
|------------|----------|
| `twitter.com`, `x.com` | Twitter/X |
| `youtube.com`, `youtu.be` | YouTube |
| `xiaohongshu.com`, `xhslink.com` | XHS (Xiaohongshu) |
| `mp.weixin.qq.com` | WeChat Article |
| `bilibili.com`, `b23.tv` | Bilibili |
| `reddit.com` | Reddit |
| `medium.com` | Medium |
| `github.com` | GitHub |
| Everything else | Generic web page |

---

## Text-Based Platforms

### Twitter/X
- x-reader or WebFetch handles extraction well
- Extract: tweet text, author, engagement metrics, thread (if applicable)
- For threads: extract all tweets in sequence

### Reddit
- x-reader handles well
- Extract: post title, body, top comments (if relevant)
- For link posts: also extract the linked content

### Medium / Blog Posts
- x-reader or WebFetch handles well
- These are the simplest case — mostly clean text content

### GitHub
- x-reader handles well
- For repos: extract README content
- For issues/PRs: extract description and key comments

### WeChat Articles
- x-reader handles well for public articles
- Some articles may be login-walled — if extraction fails, note this to user
- If Playwright is available, can attempt deep extraction (see Deep Extraction below)

---

## Image-Heavy Platforms

### XHS (Xiaohongshu) — Image Posts
XHS posts often contain the actual content in images, not text.

**Extraction strategy:**
1. Use x-reader to get the post (returns image URLs in markdown format)
2. Download key images to a temp location:
   ```bash
   curl -s -o /tmp/digest_img_{n}.jpg "{image_url}"
   ```
3. Use Claude's built-in vision capability to read text from downloaded images via the `Read` tool
4. Combine: text content from post + OCR text from images
5. Clean up temp files after processing

**If image download fails:**
- Note honestly: "This post contains image-based content that couldn't be fully extracted"
- Include whatever text content was available

---

## Video Platforms

### YouTube
- x-reader extracts subtitles/captions automatically
- No additional tools needed for most YouTube videos
- If no captions available, note this to user

### Bilibili
- x-reader extracts subtitles when available
- Fallback: title + description only

### XHS — Video Posts
- x-reader may not extract video audio content
- **If Whisper + ffmpeg are available**, use the video transcription pipeline:

**Video Transcription Pipeline:**

1. **Extract video URL** using Playwright:
   ```python
   # Use Playwright to open the post page and intercept .mp4 URLs
   # Script should handle:
   #   - Cookie consent dialogs (auto-click "agree")
   #   - Login state reuse from saved storage state
   ```

2. **Download video:**
   ```bash
   curl -s -o /tmp/digest_video.mp4 "{video_url}"
   ```

3. **Extract audio:**
   ```bash
   ffmpeg -y -i /tmp/digest_video.mp4 -vn -acodec pcm_s16le -ar 16000 -ac 1 /tmp/digest_audio.wav
   ```

4. **Transcribe:**
   ```bash
   whisper /tmp/digest_audio.wav --model small --language {detected_language} --output_format txt --output_dir /tmp/whisper_out
   ```

5. **Read transcript:**
   ```
   Read /tmp/whisper_out/digest_audio.txt
   ```

6. **Clean up:**
   ```bash
   rm -f /tmp/digest_video.mp4 /tmp/digest_audio.wav /tmp/whisper_out/digest_audio.*
   ```

**If Whisper/ffmpeg not available:**
- Extract title, description, and any text overlay from the post
- Note: "Video content was not transcribed. Install Whisper + ffmpeg for video transcription."

### TikTok / Instagram Reels / Other Video Platforms
- Same pipeline as XHS video posts if Whisper + ffmpeg available
- Without transcription tools: title + description only

---

## Deep Extraction with Playwright

For platforms that require login or block simple fetching:

**When to use Playwright:**
- x-reader or WebFetch returns incomplete/empty content
- Platform is known to require login (XHS logged-in content)
- User reports content is missing

**Login state management:**
- Save browser state to `/tmp/digest_storage_state.json`
- Reuse across sessions until expired
- If login needed: launch browser with `headless=False` for user to authenticate manually
- After login: save state for future reuse

**Playwright extraction script pattern:**
```python
from playwright.sync_api import sync_playwright

def extract(url, storage_state_path="/tmp/digest_storage_state.json"):
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=storage_state_path)
        page = context.new_page()
        page.goto(url, wait_until="networkidle")
        # Extract content based on platform-specific selectors
        content = page.content()
        browser.close()
        return content
```

---

## Fallback Strategy

When extraction fails at any level:

```
1. Try x-reader MCP          → Success? Use it.
2. Try WebFetch               → Success? Use it.
3. Try Playwright (if avail)  → Success? Use it.
4. All failed                 → Tell user honestly:
   "Couldn't fully extract content from this URL.
    You can paste the content directly and I'll digest it."
```

Never fabricate or guess content. Honest failure is better than hallucinated success.
