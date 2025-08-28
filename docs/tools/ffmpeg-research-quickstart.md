# FFmpeg Research Command Quick Start

## Architecture: Command-Based Approach ✅

**Decision**: Use OpenCode **commands** instead of plugins for FFmpeg research integration.

### Why Commands Work Better
- ✅ **User-initiated workflows**: Research tasks triggered by `/research` commands
- ✅ **Shell integration**: Direct FFmpeg/yt-dlp execution via `!command`` syntax
- ✅ **Agent routing**: Routes to `researcher` agent with domain expertise  
- ✅ **Rich templates**: Arguments, file references, shell output integration
- ✅ **Natural UX**: `/research video-url` or `/research topic` workflows

### Available Commands

#### `/research` - Enhanced Research
- **Auto-detection**: YouTube URLs → automatic multimedia processing
- **Fallback**: Traditional web research when FFmpeg unavailable
- **Synthesis**: Combines multimedia insights with authoritative sources

#### `/research-video` - Dedicated Multimedia
- **Specialized**: Focused video analysis and processing
- **Technical**: Extracts code, slides, demonstrations from videos
- **Comprehensive**: Audio, frames, metadata analysis

## Usage Examples

```bash
# Enhanced research with auto-multimedia detection
/research "JWT security patterns from https://youtube.com/watch?v=example"
# → Auto-triggers FFmpeg processing + traditional research

# Dedicated video analysis  
/research-video "https://youtube.com/watch?v=example"
# → Focused multimedia processing and analysis

# Traditional research (no video)
/research "React performance optimization techniques"
# → Web research + looks for relevant video content
```

## Installation & Prerequisites

### System Requirements
```bash
# macOS (Homebrew)
brew install ffmpeg yt-dlp

# Ubuntu/Debian  
sudo apt install ffmpeg && pip install yt-dlp

# RHEL/CentOS/Fedora
sudo yum install ffmpeg && pip install yt-dlp
```

### Verification
```bash
# Check FFmpeg
command -v ffmpeg && echo "✅ Available" || echo "❌ Missing"

# Check yt-dlp  
command -v yt-dlp && echo "✅ Available" || echo "❌ Missing"

# Test functionality
ffmpeg -version | head -1
yt-dlp --version
```

## Integration Status

### ✅ Completed
- Command-based architecture implemented
- FFmpeg detection and processing
- YouTube URL auto-detection
- Cross-platform compatibility
- Research agent integration maintained

### ⚠️ Cleanup Needed
- Plugin files can be removed (no longer used)
- Documentation reflects new command approach

## Manual Verification Steps

1. **Test commands**: Try `/research` and `/research-video` in OpenCode TUI
2. **Verify detection**: Commands show FFmpeg/yt-dlp availability  
3. **Cross-platform**: Test on both macOS and Linux
4. **Fallback**: Confirm graceful degradation when FFmpeg unavailable

## Troubleshooting

### Common Issues
- **FFmpeg not found**: Install via package manager
- **yt-dlp not found**: Install via `pip install yt-dlp`  
- **Permission denied**: Check temp directory permissions
- **Video not accessible**: Verify URL is valid and public

### Advanced Usage
```bash
# Manual FFmpeg operations (when needed)
ffmpeg -i "video.mp4" -vn -acodec libmp3lame -ab 128k "audio.mp3"
ffmpeg -i "video.mp4" -vf "fps=1/30" -frames:v 10 "frame_%03d.png"
yt-dlp --dump-json "https://youtube.com/watch?v=VIDEO_ID"
```

**Bottom Line**: FFmpeg research integration is complete using command-based architecture. More maintainable, user-friendly, and aligned with OpenCode's design patterns.