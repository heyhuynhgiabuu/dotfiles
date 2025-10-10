// Types for fix operations
export interface FixParams {
  type: "imports" | "formatting" | "lint" | "unused" | "deprecated";
  files?: string[];
  dryRun?: boolean;
  backup?: boolean;
}

export interface FixChange {
  file: string;
  description: string;
  lineNumber?: number;
  before?: string;
  after?: string;
}

export interface FixError {
  type:
    | "permission"
    | "syntax"
    | "timeout"
    | "tool_missing"
    | "invalid_pattern";
  file?: string;
  message: string;
  suggestion?: string;
}

export interface FixableIssue {
  type: string;
  file: string;
  lineNumber?: number;
  description: string;
  fix: {
    action: string;
    target?: string;
    ruleId?: string;
    fixable?: boolean;
  };
}

export interface FixOptions {
  dryRun: boolean;
  backup: boolean;
}

export interface ImportStatement {
  raw: string;
  source: string;
  imports: string;
  lineNumber: number;
  isDefault: boolean;
  isNamespace: boolean;
  isSideEffect: boolean;
}

// Base fixer interface
export interface Fixer {
  detect(files: string[]): Promise<FixableIssue[]>;
  apply(issues: FixableIssue[], options: FixOptions): Promise<FixChange[]>;
  validate?(changes: FixChange[]): Promise<boolean>;
}
