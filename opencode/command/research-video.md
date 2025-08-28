---
description: Research and analyze multimedia content (YouTube videos, local files)
agent: researcher
---

## Multimedia Research: $ARGUMENTS

**Target:** $ARGUMENTS

**FFmpeg availability:** `!command -v ffmpeg >/dev/null && echo "✅ Available: $(ffmpeg -version | head -n1)" || echo "❌ FFmpeg not found"`
**yt-dlp availability:** `!command -v yt-dlp >/dev/null && echo "✅ Available: $(yt-dlp --version)" || echo "❌ yt-dlp not found"`

## Research Workflow

### 1. **Content Analysis**
- **If YouTube URL:** Extract video metadata, audio transcription, key frames
- **If local file:** Process directly with FFmpeg for insights
- **If topic query:** Research traditional sources + find relevant video content

### 2. **Technical Processing**
- **Audio extraction:** Extract clear audio for transcription analysis
- **Frame sampling:** Capture key visual moments (slides, code, diagrams)
- **Metadata analysis:** Duration, resolution, encoding details
- **Content detection:** Code screens, presentation slides, demo interfaces

### 3. **Research Synthesis**
- **Cross-reference:** Combine multimedia insights with web research
- **Pattern extraction:** Identify key concepts, code patterns, workflows
- **Documentation:** Create structured summary with timestamps
- **Action items:** Suggest follow-up research or implementation steps

## Processing Commands

**Video info:** `!if echo "$ARGUMENTS" | grep -q "youtube.com\|youtu.be"; then yt-dlp --get-title --get-duration --get-description "$ARGUMENTS" 2>/dev/null || echo "Failed to fetch video info"; fi`

**Audio extraction preview:** `!if command -v ffmpeg >/dev/null && echo "$ARGUMENTS" | grep -q "youtube.com\|youtu.be"; then echo "Would extract audio from: $ARGUMENTS"; fi`

## Research Focus Areas

1. **Code Analysis:** Extract programming patterns, APIs, implementations
2. **Architecture Review:** System design, data flow, component structure  
3. **Tutorial Learning:** Step-by-step processes, best practices
4. **Conference Insights:** New technologies, industry trends, expert opinions
5. **Product Demos:** Feature analysis, UI/UX patterns, workflow optimization

**Action:** Process multimedia content with FFmpeg, combine with traditional research, deliver comprehensive analysis with visual references and timestamps.