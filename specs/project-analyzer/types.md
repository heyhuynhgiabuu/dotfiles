# Project Analyzer Type Definitions

## Core Types

### Analysis Configuration

```typescript
interface AnalysisConfig {
  mode: "quick" | "deep" | "security" | "performance" | "architecture";
  scope: string[];
  exclude: string[];
  useCache: boolean;
  format: "detailed" | "summary" | "agent";
}

interface AnalysisMetadata {
  mode: string;
  timestamp: string;
  duration: number;
  scope: string[];
  exclude: string[];
  version: string;
}
```

### Project Information

```typescript
interface ProjectInfo {
  name: string;
  type: ProjectType;
  version?: string;
  description?: string;
  size: ProjectSize;
  technologies: Technology[];
}

interface ProjectSize {
  files: number;
  lines: number;
  bytes: number;
  directories: number;
}

interface Technology {
  name: string;
  version?: string;
  category: "language" | "framework" | "library" | "tool" | "database";
  confidence: number;
}

type ProjectType =
  | "web-app"
  | "mobile-app"
  | "library"
  | "cli-tool"
  | "api"
  | "microservice"
  | "monorepo"
  | "unknown";
```

## Structure Analysis

```typescript
interface StructureAnalysis {
  directories: DirectoryInfo[];
  keyFiles: KeyFile[];
  patterns: DetectedPattern[];
  size: ProjectSize;
}

interface DirectoryInfo {
  path: string;
  type: DirectoryType;
  fileCount: number;
  purpose: string;
  importance: "critical" | "high" | "medium" | "low";
}

interface KeyFile {
  path: string;
  type: FileType;
  purpose: string;
  importance: "critical" | "high" | "medium" | "low";
  size: number;
  lastModified: string;
}

interface DetectedPattern {
  name: string;
  description: string;
  files: string[];
  confidence: number;
  category: "architecture" | "framework" | "convention" | "anti-pattern";
}

type DirectoryType =
  | "source"
  | "test"
  | "config"
  | "docs"
  | "assets"
  | "build"
  | "vendor"
  | "unknown";

type FileType =
  | "package"
  | "config"
  | "documentation"
  | "environment"
  | "deployment"
  | "test"
  | "source"
  | "asset";
```

## Dependency Analysis

```typescript
interface DependencyAnalysis {
  external: ExternalDependency[];
  internal: InternalDependency[];
  vulnerabilities: Vulnerability[];
  outdated: OutdatedPackage[];
  graph: DependencyGraph;
}

interface ExternalDependency {
  name: string;
  version: string;
  type: "production" | "development" | "peer" | "optional";
  license: string;
  size: number;
  lastUpdated: string;
  maintainers: number;
  downloads: number;
}

interface InternalDependency {
  from: string;
  to: string;
  type: "import" | "require" | "dynamic";
  strength: number;
}

interface Vulnerability {
  id: string;
  severity: "critical" | "high" | "medium" | "low";
  package: string;
  version: string;
  title: string;
  description: string;
  fixedIn?: string;
  cwe?: string[];
}

interface OutdatedPackage {
  name: string;
  current: string;
  wanted: string;
  latest: string;
  type: "major" | "minor" | "patch";
}

interface DependencyGraph {
  nodes: DependencyNode[];
  edges: DependencyEdge[];
  cycles: string[][];
  depth: number;
}
```

## Quality Analysis

```typescript
interface QualityAnalysis {
  coverage: CoverageMetrics;
  complexity: ComplexityMetrics;
  maintainability: MaintainabilityScore;
  techDebt: TechDebtItem[];
  codeSmells: CodeSmell[];
}

interface CoverageMetrics {
  lines: number;
  functions: number;
  branches: number;
  statements: number;
  files: FileCoverage[];
}

interface ComplexityMetrics {
  cyclomatic: number;
  cognitive: number;
  halstead: HalsteadMetrics;
  maintainabilityIndex: number;
}

interface MaintainabilityScore {
  score: number;
  grade: "A" | "B" | "C" | "D" | "F";
  factors: MaintainabilityFactor[];
}

interface TechDebtItem {
  file: string;
  line: number;
  type: "code-smell" | "bug" | "vulnerability" | "duplication";
  severity: "critical" | "major" | "minor" | "info";
  effort: string;
  description: string;
}

interface CodeSmell {
  type: string;
  file: string;
  line: number;
  description: string;
  suggestion: string;
}
```

## Security Analysis

```typescript
interface SecurityAnalysis {
  issues: SecurityIssue[];
  compliance: ComplianceCheck[];
  secrets: SecretDetection[];
  permissions: PermissionAnalysis;
  dependencies: SecurityDependencyCheck[];
}

interface SecurityIssue {
  id: string;
  type: SecurityIssueType;
  severity: "critical" | "high" | "medium" | "low" | "info";
  file: string;
  line?: number;
  title: string;
  description: string;
  recommendation: string;
  cwe?: string;
  owasp?: string;
}

interface ComplianceCheck {
  standard: "OWASP" | "NIST" | "SOC2" | "GDPR" | "HIPAA";
  requirement: string;
  status: "compliant" | "non-compliant" | "partial" | "unknown";
  details: string;
}

interface SecretDetection {
  type: "api-key" | "password" | "token" | "certificate" | "private-key";
  file: string;
  line: number;
  confidence: number;
  masked: string;
}

type SecurityIssueType =
  | "sql-injection"
  | "xss"
  | "csrf"
  | "insecure-auth"
  | "hardcoded-secret"
  | "insecure-transport"
  | "path-traversal"
  | "command-injection";
```

## Performance Analysis

```typescript
interface PerformanceAnalysis {
  bottlenecks: PerformanceBottleneck[];
  bundleSize: BundleAnalysis;
  recommendations: OptimizationRecommendation[];
  metrics: PerformanceMetrics;
}

interface PerformanceBottleneck {
  type: "memory" | "cpu" | "io" | "network" | "database";
  location: string;
  severity: "critical" | "high" | "medium" | "low";
  description: string;
  impact: string;
  suggestion: string;
}

interface BundleAnalysis {
  totalSize: number;
  gzippedSize: number;
  chunks: BundleChunk[];
  duplicates: DuplicateModule[];
  unusedCode: UnusedCode[];
}

interface OptimizationRecommendation {
  type:
    | "code-splitting"
    | "lazy-loading"
    | "caching"
    | "compression"
    | "minification";
  priority: "high" | "medium" | "low";
  description: string;
  estimatedImpact: string;
  effort: "low" | "medium" | "high";
}

interface PerformanceMetrics {
  buildTime: number;
  bundleSize: number;
  dependencies: number;
  asyncOperations: number;
}
```

## Architecture Analysis

```typescript
interface ArchitectureAnalysis {
  patterns: ArchitecturalPattern[];
  violations: ArchitecturalViolation[];
  suggestions: ArchitecturalSuggestion[];
  coupling: CouplingAnalysis;
  cohesion: CohesionAnalysis;
}

interface ArchitecturalPattern {
  name: string;
  type: "design-pattern" | "architectural-pattern" | "anti-pattern";
  confidence: number;
  files: string[];
  description: string;
}

interface ArchitecturalViolation {
  rule: string;
  severity: "error" | "warning" | "info";
  file: string;
  line?: number;
  description: string;
  suggestion: string;
}

interface ArchitecturalSuggestion {
  category: "structure" | "patterns" | "dependencies" | "testing";
  priority: "high" | "medium" | "low";
  title: string;
  description: string;
  benefits: string[];
  effort: "low" | "medium" | "high";
}

interface CouplingAnalysis {
  afferent: number;
  efferent: number;
  instability: number;
  modules: ModuleCoupling[];
}

interface CohesionAnalysis {
  score: number;
  type:
    | "functional"
    | "sequential"
    | "communicational"
    | "procedural"
    | "temporal"
    | "logical"
    | "coincidental";
  modules: ModuleCohesion[];
}
```

## Recommendations

```typescript
interface Recommendation {
  id: string;
  category: RecommendationCategory;
  priority: "critical" | "high" | "medium" | "low";
  title: string;
  description: string;
  rationale: string;
  effort: "low" | "medium" | "high";
  impact: "low" | "medium" | "high";
  tags: string[];
  relatedFiles: string[];
  steps: RecommendationStep[];
}

interface RecommendationStep {
  order: number;
  description: string;
  command?: string;
  files?: string[];
  estimated_time: string;
}

type RecommendationCategory =
  | "security"
  | "performance"
  | "maintainability"
  | "architecture"
  | "dependencies"
  | "testing"
  | "documentation";
```

## Output Formats

### Summary Format

```typescript
interface SummaryAnalysisResult {
  overview: ProjectOverview;
  keyInsights: KeyInsight[];
  criticalIssues: CriticalIssue[];
  nextSteps: NextStep[];
}

interface ProjectOverview {
  name: string;
  type: ProjectType;
  health: "excellent" | "good" | "fair" | "poor" | "critical";
  score: number;
  technologies: string[];
  size: ProjectSize;
}

interface KeyInsight {
  category: string;
  insight: string;
  impact: "positive" | "negative" | "neutral";
  confidence: number;
}

interface CriticalIssue {
  type: string;
  severity: "critical" | "high";
  description: string;
  files: string[];
  recommendation: string;
}

interface NextStep {
  priority: number;
  action: string;
  category: string;
  effort: string;
  impact: string;
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

interface AgentRoutingInfo {
  recommendedAgent: string;
  confidence: number;
  reasoning: string;
  alternatives: AgentAlternative[];
}

interface AgentContext {
  projectType: ProjectType;
  technologies: Technology[];
  complexity: "low" | "medium" | "high";
  riskLevel: "low" | "medium" | "high";
  keyAreas: string[];
}

interface AgentPriority {
  agent: string;
  tasks: string[];
  urgency: "immediate" | "soon" | "later";
  dependencies: string[];
}

interface RequiredCapability {
  capability: string;
  importance: "required" | "preferred" | "optional";
  agents: string[];
}
```

## Cache Types

```typescript
interface CacheEntry {
  data: any;
  expiry: number;
  lastAccessed: number;
  version: string;
}

interface CacheStats {
  hits: number;
  misses: number;
  size: number;
  hitRate: number;
}
```

## Error Types

```typescript
interface AnalysisError {
  code: string;
  message: string;
  file?: string;
  line?: number;
  stack?: string;
  recoverable: boolean;
}

interface PartialResults {
  completed: string[];
  failed: string[];
  results: Partial<AnalysisResult>;
  errors: AnalysisError[];
}
```
