# Project Analyzer Tool Specification

## Overview

Advanced project analysis tool that provides comprehensive insights for OpenCode agents and users. Combines OpenCode SDK capabilities with intelligent analysis patterns to deliver actionable project intelligence.

## Tool Definition

**File**: `.opencode/tool/analyze.ts`
**Name**: `analyze`
**SDK Integration**: `@opencode-ai/sdk`

## Arguments

```typescript
{
  mode: tool.schema.enum(["quick", "deep", "security", "performance", "architecture"]).optional().describe("Analysis mode (default: quick)"),
  scope: tool.schema.array(tool.schema.string()).optional().describe("Specific paths to analyze"),
  exclude: tool.schema.array(tool.schema.string()).optional().describe("Patterns to exclude"),
  cache: tool.schema.boolean().optional().describe("Use cached results (default: true)"),
  format: tool.schema.enum(["detailed", "summary", "agent"]).optional().describe("Output format (default: detailed)")
}
```

## Analysis Modes

### Quick Mode (Default)

- **Duration**: <5 seconds
- **Scope**: File structure, basic dependencies, common patterns
- **Tools**: glob, basic file reads, package.json analysis
- **Use Case**: Initial project understanding, agent routing decisions

### Deep Mode

- **Duration**: 10-30 seconds
- **Scope**: Comprehensive analysis including code quality, architecture patterns
- **Tools**: SDK find.text, find.symbols, file.read, advanced pattern matching
- **Use Case**: Detailed project assessment, refactoring planning

### Security Mode

- **Duration**: 15-45 seconds
- **Scope**: Security vulnerabilities, compliance checks, sensitive data detection
- **Tools**: Security pattern matching, dependency vulnerability scanning
- **Use Case**: Security audits, compliance verification

### Performance Mode

- **Duration**: 10-25 seconds
- **Scope**: Performance bottlenecks, optimization opportunities
- **Tools**: Performance pattern detection, bundle analysis
- **Use Case**: Performance optimization, scalability assessment

### Architecture Mode

- **Duration**: 20-40 seconds
- **Scope**: Architectural patterns, design violations, improvement suggestions
- **Tools**: Dependency graph analysis, pattern recognition
- **Use Case**: Architecture reviews, system design improvements

## Implementation Strategy

### Core Components

1. **SDK Client Integration**

```typescript
const client = createOpencodeClient({ baseUrl: context.baseUrl });
```

2. **Multi-Phase Analysis**

- Phase 1: Structure mapping (glob patterns)
- Phase 2: Content analysis (SDK find operations)
- Phase 3: Pattern recognition (intelligent matching)
- Phase 4: Insight generation (actionable recommendations)

3. **Caching Layer**

- Session-based caching using SDK
- Incremental analysis for changed files
- Cache invalidation on file modifications

4. **Agent-Optimized Output**

- Structured data for agent consumption
- Human-readable summaries
- Actionable recommendations with priority levels

### Analysis Engines

#### Structure Engine

```typescript
interface StructureAnalysis {
  directories: DirectoryInfo[];
  keyFiles: KeyFile[];
  patterns: DetectedPattern[];
  size: ProjectSize;
}
```

#### Dependency Engine

```typescript
interface DependencyAnalysis {
  external: ExternalDependency[];
  internal: InternalDependency[];
  vulnerabilities: Vulnerability[];
  outdated: OutdatedPackage[];
}
```

#### Quality Engine

```typescript
interface QualityAnalysis {
  coverage: CoverageMetrics;
  complexity: ComplexityMetrics;
  maintainability: MaintainabilityScore;
  techDebt: TechDebtItem[];
}
```

#### Security Engine

```typescript
interface SecurityAnalysis {
  issues: SecurityIssue[];
  compliance: ComplianceCheck[];
  secrets: SecretDetection[];
  permissions: PermissionAnalysis;
}
```

#### Performance Engine

```typescript
interface PerformanceAnalysis {
  bottlenecks: PerformanceBottleneck[];
  bundleSize: BundleAnalysis;
  recommendations: OptimizationRecommendation[];
}
```

#### Architecture Engine

```typescript
interface ArchitectureAnalysis {
  patterns: ArchitecturalPattern[];
  violations: ArchitecturalViolation[];
  suggestions: ArchitecturalSuggestion[];
  coupling: CouplingAnalysis;
}
```

## Output Format

### Detailed Format

```typescript
interface DetailedAnalysisResult {
  metadata: AnalysisMetadata;
  project: ProjectInfo;
  structure: StructureAnalysis;
  dependencies: DependencyAnalysis;
  quality: QualityAnalysis;
  security: SecurityAnalysis;
  performance: PerformanceAnalysis;
  architecture: ArchitectureAnalysis;
  recommendations: Recommendation[];
}
```

### Summary Format

```typescript
interface SummaryAnalysisResult {
  overview: ProjectOverview;
  keyInsights: KeyInsight[];
  criticalIssues: CriticalIssue[];
  nextSteps: NextStep[];
}
```

### Agent Format

```typescript
interface AgentAnalysisResult {
  routing: AgentRoutingInfo;
  context: AgentContext;
  priorities: AgentPriority[];
  capabilities: RequiredCapability[];
}
```

## Performance Optimizations

### Caching Strategy

- **File-level caching**: Cache analysis results per file with modification timestamps
- **Pattern caching**: Cache regex compilation and pattern matching results
- **Dependency caching**: Cache dependency resolution for unchanged package files
- **Session persistence**: Maintain analysis state across OpenCode session

### Batch Operations

- **Parallel file reading**: Use SDK batch operations for file content
- **Concurrent analysis**: Run independent analysis engines in parallel
- **Streaming results**: Provide partial results for long-running analysis

### Resource Management

- **Memory limits**: Implement memory-efficient streaming for large files
- **Timeout handling**: Graceful degradation for slow operations
- **Progress reporting**: Real-time progress updates for deep analysis

## Error Handling

### Graceful Degradation

- **Partial results**: Return available analysis even if some components fail
- **Fallback modes**: Switch to simpler analysis if advanced features fail
- **Error context**: Provide specific error information without breaking flow

### Recovery Strategies

- **Retry logic**: Intelligent retry for transient failures
- **Alternative approaches**: Multiple analysis paths for critical insights
- **User feedback**: Clear error messages with suggested actions

## Integration Points

### Agent Routing

- **Security issues** → security agent
- **Performance problems** → devops agent
- **Code quality issues** → language agent
- **Architecture concerns** → specialist agent

### Tool Orchestration

- **Discovery phase**: analyze → glob → grep → read
- **Deep analysis**: analyze → SDK operations → specialized tools
- **Verification**: analyze → bash → test execution

### Context Enhancement

- **Project understanding**: Provide rich context for all subsequent operations
- **Agent preparation**: Pre-load relevant information for specialized agents
- **Decision support**: Enable intelligent tool and agent selection

## Usage Examples

```bash
# Quick project overview
@build analyze the project structure

# Deep security analysis
@build analyze --mode security --format detailed

# Performance bottleneck identification
@build analyze --mode performance --scope src/

# Architecture review for specific modules
@build analyze --mode architecture --scope "src/core,src/api"

# Agent-optimized analysis for routing
@build analyze --format agent
```

## Benefits

1. **Intelligent Agent Routing**: Provides context for optimal agent selection
2. **Comprehensive Insights**: Multi-dimensional project understanding
3. **Performance Optimized**: Efficient caching and batch operations
4. **Actionable Results**: Specific recommendations with priority levels
5. **SDK Integration**: Leverages OpenCode's advanced capabilities
6. **Extensible Design**: Foundation for specialized analysis tools

## Future Enhancements

1. **Machine Learning Integration**: Pattern recognition improvement over time
2. **Custom Analysis Rules**: User-defined analysis patterns and checks
3. **Integration APIs**: Connect with external analysis tools and services
4. **Real-time Monitoring**: Continuous analysis during development
5. **Team Insights**: Collaborative analysis and shared project intelligence
