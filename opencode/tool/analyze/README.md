# OpenCode Project Analyzer Tool

Advanced project analysis tool for OpenCode that provides comprehensive insights about project structure, dependencies, code quality, security, performance, and architecture.

## Features

- **Multi-mode Analysis**: Quick, deep, security, performance, and architecture modes
- **Intelligent Caching**: Session-based caching for improved performance
- **Pattern Detection**: Identifies common patterns, anti-patterns, and best practices
- **Auto-routing**: Recommends appropriate OpenCode agents based on analysis
- **Multiple Output Formats**: Summary, detailed, and agent-optimized formats

## Installation

1. The tool is located in `.opencode/tool/analyze.ts`
2. Dependencies are managed via `package.json` in the tool directory
3. Run `bun install` in the tool directory to install dependencies

## Usage in OpenCode

```bash
analyze [options]
```

### Options

- `--mode=<mode>` - Analysis mode: quick, deep, security, performance, architecture (default: quick)
- `--scope=<patterns>` - Comma-separated glob patterns for files to analyze
- `--exclude=<patterns>` - Comma-separated glob patterns to exclude
- `--cache=<boolean>` - Use cached results (default: true)
- `--format=<format>` - Output format: summary, detailed, agent (default: detailed)
- `--auto-route=<boolean>` - Auto-route to recommended agent (default: false)

### Examples

```bash
# Quick analysis with summary
analyze --format=summary

# Deep security analysis
analyze --mode=security --format=detailed

# Performance analysis with auto-routing
analyze --mode=performance --auto-route=true

# Analyze specific directories
analyze --scope="src/**/*.ts,lib/**/*.js" --exclude="**/*.test.ts"
```

## Analysis Modes

### Quick Mode (Default)

- Duration: <5 seconds
- Focuses on basic structure and dependencies
- Ideal for initial project understanding

### Deep Mode

- Duration: 10-30 seconds
- Comprehensive analysis including quality metrics
- Best for detailed project assessment

### Security Mode

- Duration: 15-45 seconds
- Scans for vulnerabilities and security issues
- Includes dependency vulnerability checks

### Performance Mode

- Duration: 10-25 seconds
- Identifies performance bottlenecks
- Analyzes bundle sizes and optimization opportunities

### Architecture Mode

- Duration: 20-40 seconds
- Evaluates architectural patterns and violations
- Provides design improvement suggestions

## Output Formats

### Summary Format

Concise overview with key metrics and top recommendations.

### Detailed Format

Complete analysis results with all findings and metrics.

### Agent Format

Optimized output for OpenCode agent consumption with structured data.

## Current Status

✅ **Working**: The monolithic version (`analyze.ts`) is functional and follows OpenCode tool conventions
❌ **Issue**: The modular implementation causes import errors - OpenCode tools work best as single files
🔧 **Solution**: Using the monolithic approach for stability while maintaining the modular design in subdirectories for reference

## Architecture

The tool uses a monolithic implementation that includes:

- **Analysis Engines**: Structure, dependency, quality, security, performance, and architecture analysis
- **Cache Manager**: Session-based caching with LRU eviction
- **Pattern Detection**: Security, performance, and architecture pattern matching
- **OpenCode SDK Integration**: Uses `@opencode-ai/sdk` for file operations and session management
- **Type System**: Comprehensive TypeScript types matching the specification

## File Structure

```
tool/
├── analyze.ts         # Main tool implementation (monolithic)
├── analyze.ts.bak     # Backup of working version
├── package.json       # Dependencies
├── analyze/           # Modular implementation (reference)
│   ├── README.md      # This documentation
│   ├── types.ts       # TypeScript definitions
│   ├── engines/       # Analysis engines
│   │   ├── structure.ts   # File structure analysis
│   │   ├── dependency.ts  # Dependency analysis
│   │   ├── security.ts    # Security analysis
│   │   ├── quality.ts     # Code quality analysis
│   │   ├── performance.ts # Performance analysis
│   │   └── architecture.ts # Architecture analysis
│   ├── cache/         # Caching system
│   │   ├── manager.ts     # Cache management
│   │   └── storage.ts     # Storage interface
│   └── patterns/      # Pattern detection
│       ├── security.ts    # Security patterns
│       ├── performance.ts # Performance patterns
│       └── architecture.ts # Architecture patterns
```

## Auto-Routing

Tool automatically recommends appropriate agent based on analysis:

```typescript
// Security issues detected → security agent
// Performance problems → devops agent
// Architecture violations → reviewer agent
// Code quality issues → language agent
// Complex multi-phase work → orchestrator agent
```

## Integration

- **Agent Selection**: Provides intelligent routing recommendations
- **Context Sharing**: Analysis results cached for session reuse
- **Workflow Integration**: First step for unknown projects
- **Spec Generation**: Feeds into spec planning workflows
