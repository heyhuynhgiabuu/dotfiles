// @ts-nocheck
export const PERFORMANCE_PATTERNS = {
  bottlenecks: [
    {
      pattern: /for\s*\([^)]*\)\s*{\s*for\s*\([^)]*\)/gi,
      type: "nested-loops",
      severity: "medium",
    },
    {
      pattern: /while\s*\([^)]*\)\s*{\s*while\s*\([^)]*\)/gi,
      type: "nested-loops",
      severity: "medium",
    },
    {
      pattern: /\.forEach\([^)]*\)\s*{\s*[^}]*\.forEach/gi,
      type: "nested-iteration",
      severity: "medium",
    },
    {
      pattern: /document\.getElementById\s*\(/gi,
      type: "dom-query",
      severity: "low",
    },
    {
      pattern: /document\.querySelector\s*\(/gi,
      type: "dom-query",
      severity: "low",
    },
    { pattern: /JSON\.parse\s*\(/gi, type: "json-parsing", severity: "low" },
  ],

  memoryLeaks: [
    {
      pattern: /setInterval\s*\(/gi,
      type: "interval-leak",
      severity: "medium",
    },
    { pattern: /setTimeout\s*\(/gi, type: "timeout-leak", severity: "low" },
    {
      pattern: /addEventListener\s*\(/gi,
      type: "event-listener-leak",
      severity: "medium",
    },
    {
      pattern: /new\s+Array\s*\(\s*\d{4,}\s*\)/gi,
      type: "large-array",
      severity: "medium",
    },
  ],

  inefficientOperations: [
    {
      pattern: /\+\s*=\s*["'][^"']*["']/gi,
      type: "string-concatenation",
      severity: "low",
    },
    {
      pattern: /\.innerHTML\s*\+=/gi,
      type: "dom-manipulation",
      severity: "medium",
    },
    {
      pattern: /\.appendChild\s*\(/gi,
      type: "dom-manipulation",
      severity: "low",
    },
    { pattern: /new\s+RegExp\s*\(/gi, type: "regex-creation", severity: "low" },
  ],

  blockingOperations: [
    { pattern: /fs\.readFileSync\s*\(/gi, type: "sync-io", severity: "high" },
    { pattern: /fs\.writeFileSync\s*\(/gi, type: "sync-io", severity: "high" },
    { pattern: /XMLHttpRequest\s*\(/gi, type: "sync-xhr", severity: "medium" },
    { pattern: /alert\s*\(/gi, type: "blocking-ui", severity: "low" },
  ],
};

export function detectPerformanceIssues(content: string, filePath: string) {
  const issues = [];
  const lines = content.split("\n");

  for (const [category, patterns] of Object.entries(PERFORMANCE_PATTERNS)) {
    for (const rule of patterns) {
      lines.forEach((line, index) => {
        const matches = line.match(rule.pattern);
        if (matches) {
          issues.push({
            type: rule.type,
            severity: rule.severity,
            file: filePath,
            line: index + 1,
            category,
            description: `Performance issue: ${rule.type}`,
            suggestion: getPerformanceSuggestion(rule.type),
          });
        }
      });
    }
  }

  return issues;
}

function getPerformanceSuggestion(type: string): string {
  const suggestions = {
    "nested-loops": "Consider optimizing algorithm complexity",
    "nested-iteration": "Use more efficient iteration methods",
    "dom-query": "Cache DOM queries or use more efficient selectors",
    "json-parsing": "Consider streaming or lazy parsing for large data",
    "interval-leak": "Ensure intervals are cleared properly",
    "timeout-leak": "Clear timeouts when no longer needed",
    "event-listener-leak": "Remove event listeners when components unmount",
    "large-array": "Consider using more memory-efficient data structures",
    "string-concatenation": "Use template literals or array join",
    "dom-manipulation": "Batch DOM operations or use virtual DOM",
    "regex-creation": "Cache compiled regular expressions",
    "sync-io": "Use asynchronous I/O operations",
    "sync-xhr": "Use fetch API or async XMLHttpRequest",
    "blocking-ui": "Use non-blocking UI patterns",
  };

  return suggestions[type] || "Consider optimizing this operation";
}
