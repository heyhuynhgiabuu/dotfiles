// @ts-nocheck
export interface AnalysisConfig {
  mode: "quick" | "deep" | "security" | "performance" | "architecture";
  scope: string[];
  exclude: string[];
  useCache: boolean;
  format: "detailed" | "summary" | "agent";
}

export interface AnalysisResult {
  metadata: AnalysisMetadata;
  project?: ProjectInfo;
  structure?: StructureAnalysis;
  dependencies?: DependencyAnalysis;
  quality?: QualityAnalysis;
  security?: SecurityAnalysis;
  performance?: PerformanceAnalysis;
  architecture?: ArchitectureAnalysis;
  recommendations?: Recommendation[];
}

export interface AnalysisMetadata {
  mode: string;
  timestamp: string;
  duration: number;
  scope: string[];
  exclude: string[];
  version: string;
}

export interface ProjectInfo {
  name: string;
  type: ProjectType;
  version?: string;
  description?: string;
  size: ProjectSize;
  technologies: Technology[];
}

export interface ProjectSize {
  files: number;
  lines: number;
  bytes: number;
  directories: number;
}

export interface Technology {
  name: string;
  version?: string;
  category: "language" | "framework" | "library" | "tool" | "database";
  confidence: number;
}

export type ProjectType =
  | "web-app"
  | "mobile-app"
  | "library"
  | "cli-tool"
  | "api"
  | "microservice"
  | "monorepo"
  | "unknown";

export interface StructureAnalysis {
  directories: DirectoryInfo[];
  keyFiles: KeyFile[];
  patterns: DetectedPattern[];
  size: ProjectSize;
}

export interface DirectoryInfo {
  path: string;
  type: DirectoryType;
  fileCount: number;
  purpose: string;
  importance: "critical" | "high" | "medium" | "low";
}

export interface KeyFile {
  path: string;
  type: FileType;
  purpose: string;
  importance: "critical" | "high" | "medium" | "low";
  size: number;
  lastModified: string;
}

export interface DetectedPattern {
  name: string;
  description: string;
  files: string[];
  confidence: number;
  category: "architecture" | "framework" | "convention" | "anti-pattern";
}

export type DirectoryType =
  | "source"
  | "test"
  | "config"
  | "docs"
  | "assets"
  | "build"
  | "vendor"
  | "unknown";

export type FileType =
  | "package"
  | "config"
  | "documentation"
  | "environment"
  | "deployment"
  | "test"
  | "source"
  | "asset";

export interface DependencyAnalysis {
  external: ExternalDependency[];
  internal: InternalDependency[];
  vulnerabilities: Vulnerability[];
  outdated: OutdatedPackage[];
  graph: DependencyGraph;
}

export interface ExternalDependency {
  name: string;
  version: string;
  type: "production" | "development" | "peer" | "optional";
  license: string;
  size: number;
  lastUpdated: string;
  maintainers: number;
  downloads: number;
}

export interface InternalDependency {
  from: string;
  to: string;
  type: "import" | "require" | "dynamic";
  strength: number;
}

export interface Vulnerability {
  id: string;
  severity: "critical" | "high" | "medium" | "low";
  package: string;
  version: string;
  title: string;
  description: string;
  fixedIn?: string;
  cwe?: string[];
}

export interface OutdatedPackage {
  name: string;
  current: string;
  wanted: string;
  latest: string;
  type: "major" | "minor" | "patch";
}

export interface DependencyGraph {
  nodes: DependencyNode[];
  edges: DependencyEdge[];
  cycles: string[][];
  depth: number;
}

export interface DependencyNode {
  id: string;
  name: string;
  version: string;
  type: string;
}

export interface DependencyEdge {
  from: string;
  to: string;
  type: string;
}

export interface QualityAnalysis {
  coverage: CoverageMetrics;
  complexity: ComplexityMetrics;
  maintainability: MaintainabilityScore;
  techDebt: TechDebtItem[];
  codeSmells: CodeSmell[];
}

export interface CoverageMetrics {
  lines: number;
  functions: number;
  branches: number;
  statements: number;
  files: FileCoverage[];
}

export interface FileCoverage {
  file: string;
  lines: number;
  functions: number;
  branches: number;
  statements: number;
}

export interface ComplexityMetrics {
  cyclomatic: number;
  cognitive: number;
  halstead: HalsteadMetrics;
  maintainabilityIndex: number;
}

export interface HalsteadMetrics {
  vocabulary: number;
  length: number;
  difficulty: number;
  volume: number;
  effort: number;
  time: number;
  bugs: number;
}

export interface MaintainabilityScore {
  score: number;
  grade: "A" | "B" | "C" | "D" | "F";
  factors: MaintainabilityFactor[];
}

export interface MaintainabilityFactor {
  name: string;
  score: number;
  weight: number;
  description: string;
}

export interface TechDebtItem {
  file: string;
  line: number;
  type: "code-smell" | "bug" | "vulnerability" | "duplication";
  severity: "critical" | "major" | "minor" | "info";
  effort: string;
  description: string;
}

export interface CodeSmell {
  type: string;
  file: string;
  line: number;
  description: string;
  suggestion: string;
}

export interface SecurityAnalysis {
  issues: SecurityIssue[];
  compliance: ComplianceCheck[];
  secrets: SecretDetection[];
  permissions: PermissionAnalysis;
  dependencies: SecurityDependencyCheck[];
}

export interface SecurityIssue {
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

export interface ComplianceCheck {
  standard: "OWASP" | "NIST" | "SOC2" | "GDPR" | "HIPAA";
  requirement: string;
  status: "compliant" | "non-compliant" | "partial" | "unknown";
  details: string;
}

export interface SecretDetection {
  type: "api-key" | "password" | "token" | "certificate" | "private-key";
  file: string;
  line: number;
  confidence: number;
  masked: string;
}

export interface PermissionAnalysis {
  files: FilePermission[];
  directories: DirectoryPermission[];
  issues: PermissionIssue[];
}

export interface FilePermission {
  path: string;
  permissions: string;
  owner: string;
  group: string;
  issues: string[];
}

export interface DirectoryPermission {
  path: string;
  permissions: string;
  owner: string;
  group: string;
  issues: string[];
}

export interface PermissionIssue {
  path: string;
  type: string;
  severity: string;
  description: string;
}

export interface SecurityDependencyCheck {
  package: string;
  version: string;
  vulnerabilities: Vulnerability[];
  license: string;
  riskLevel: "low" | "medium" | "high" | "critical";
}

export type SecurityIssueType =
  | "sql-injection"
  | "xss"
  | "csrf"
  | "insecure-auth"
  | "hardcoded-secret"
  | "insecure-transport"
  | "path-traversal"
  | "command-injection";

export interface PerformanceAnalysis {
  bottlenecks: PerformanceBottleneck[];
  bundleSize: BundleAnalysis;
  recommendations: OptimizationRecommendation[];
  metrics: PerformanceMetrics;
}

export interface PerformanceBottleneck {
  type: "memory" | "cpu" | "io" | "network" | "database";
  location: string;
  severity: "critical" | "high" | "medium" | "low";
  description: string;
  impact: string;
  suggestion: string;
}

export interface BundleAnalysis {
  totalSize: number;
  gzippedSize: number;
  chunks: BundleChunk[];
  duplicates: DuplicateModule[];
  unusedCode: UnusedCode[];
}

export interface BundleChunk {
  name: string;
  size: number;
  files: string[];
}

export interface DuplicateModule {
  name: string;
  instances: number;
  totalSize: number;
  files: string[];
}

export interface UnusedCode {
  file: string;
  type: "function" | "variable" | "import" | "class";
  name: string;
  line: number;
}

export interface OptimizationRecommendation {
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

export interface PerformanceMetrics {
  buildTime: number;
  bundleSize: number;
  dependencies: number;
  asyncOperations: number;
}

export interface ArchitectureAnalysis {
  patterns: ArchitecturalPattern[];
  violations: ArchitecturalViolation[];
  suggestions: ArchitecturalSuggestion[];
  coupling: CouplingAnalysis;
  cohesion: CohesionAnalysis;
}

export interface ArchitecturalPattern {
  name: string;
  type: "design-pattern" | "architectural-pattern" | "anti-pattern";
  confidence: number;
  files: string[];
  description: string;
}

export interface ArchitecturalViolation {
  rule: string;
  severity: "error" | "warning" | "info";
  file: string;
  line?: number;
  description: string;
  suggestion: string;
}

export interface ArchitecturalSuggestion {
  category: "structure" | "patterns" | "dependencies" | "testing";
  priority: "high" | "medium" | "low";
  title: string;
  description: string;
  benefits: string[];
  effort: "low" | "medium" | "high";
}

export interface CouplingAnalysis {
  afferent: number;
  efferent: number;
  instability: number;
  modules: ModuleCoupling[];
}

export interface CohesionAnalysis {
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

export interface ModuleCoupling {
  module: string;
  afferent: number;
  efferent: number;
  instability: number;
}

export interface ModuleCohesion {
  module: string;
  score: number;
  type: string;
  issues: string[];
}

export interface Recommendation {
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

export interface RecommendationStep {
  order: number;
  description: string;
  command?: string;
  files?: string[];
  estimated_time: string;
}

export type RecommendationCategory =
  | "security"
  | "performance"
  | "maintainability"
  | "architecture"
  | "dependencies"
  | "testing"
  | "documentation";

export interface SummaryAnalysisResult {
  overview: ProjectOverview;
  keyInsights: KeyInsight[];
  criticalIssues: CriticalIssue[];
  nextSteps: NextStep[];
}

export interface ProjectOverview {
  name: string;
  type: ProjectType;
  health: "excellent" | "good" | "fair" | "poor" | "critical";
  score: number;
  technologies: string[];
  size: ProjectSize;
}

export interface KeyInsight {
  category: string;
  insight: string;
  impact: "positive" | "negative" | "neutral";
  confidence: number;
}

export interface CriticalIssue {
  type: string;
  severity: "critical" | "high";
  description: string;
  files: string[];
  recommendation: string;
}

export interface NextStep {
  priority: number;
  action: string;
  category: string;
  effort: string;
  impact: string;
}

export interface AgentAnalysisResult {
  routing: AgentRoutingInfo;
  context: AgentContext;
  priorities: AgentPriority[];
  capabilities: RequiredCapability[];
}

export interface AgentRoutingInfo {
  recommendedAgent: string;
  confidence: number;
  reasoning: string;
  alternatives: AgentAlternative[];
}

export interface AgentAlternative {
  agent: string;
  confidence: number;
  reasoning: string;
}

export interface AgentContext {
  projectType: ProjectType;
  technologies: Technology[];
  complexity: "low" | "medium" | "high";
  riskLevel: "low" | "medium" | "high";
  keyAreas: string[];
}

export interface AgentPriority {
  agent: string;
  tasks: string[];
  urgency: "immediate" | "soon" | "later";
  dependencies: string[];
}

export interface RequiredCapability {
  capability: string;
  importance: "required" | "preferred" | "optional";
  agents: string[];
}

export interface CacheEntry {
  data: any;
  expiry: number;
  lastAccessed: number;
  version: string;
}

export interface CacheStats {
  hits: number;
  misses: number;
  size: number;
  hitRate: number;
}

export interface AnalysisError {
  code: string;
  message: string;
  file?: string;
  line?: number;
  stack?: string;
  recoverable: boolean;
}

export interface PartialResults {
  completed: string[];
  failed: string[];
  results: Partial<AnalysisResult>;
  errors: AnalysisError[];
}
