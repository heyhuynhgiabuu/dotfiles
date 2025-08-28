---
description: Enhanced research with multimedia support
agent: researcher  
---

## Research: $ARGUMENTS

**Query:** $ARGUMENTS

**System Check:**
`!command -v ffmpeg >/dev/null && echo "🎬 FFmpeg: $(ffmpeg -version | head -n1 | cut -d' ' -f3)" || echo "⚠️ FFmpeg not available"`
`!command -v yt-dlp >/dev/null && echo "📺 yt-dlp: $(yt-dlp --version)" || echo "⚠️ yt-dlp not available"`

## Auto-Detection & Processing

**Content type detection:**
- **YouTube URLs:** Automatic video processing with audio/frame extraction
- **Technical topics:** Search for related video tutorials + traditional sources  
- **Code/architecture:** Look for implementation examples, demos, talks
- **General research:** Comprehensive web search + multimedia supplements

## Research Strategy

### 1. **Primary Sources**
- Documentation, official guides, specifications
- Academic papers, whitepapers, case studies
- GitHub repositories, code examples
- Stack Overflow, technical forums

### 2. **Multimedia Enhancement** 
- Conference talks and technical presentations
- Tutorial videos and coding sessions
- Product demos and feature walkthroughs
- Expert interviews and panel discussions

### 3. **Synthesis & Analysis**
- Extract key concepts and implementation patterns
- Cross-reference multiple sources for accuracy
- Identify best practices and common pitfalls
- Generate actionable insights and next steps

**Action:** Conduct comprehensive research combining traditional sources with multimedia analysis. Deliver structured findings with practical implementation guidance.