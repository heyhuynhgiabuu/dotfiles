// @ts-nocheck
export const SECURITY_PATTERNS = {
  secrets: [
    {
      pattern: /password\s*=\s*["'][^"']+["']/gi,
      type: "password",
      severity: "high",
    },
    {
      pattern: /api[_-]?key\s*=\s*["'][^"']+["']/gi,
      type: "api-key",
      severity: "critical",
    },
    {
      pattern: /secret\s*=\s*["'][^"']+["']/gi,
      type: "secret",
      severity: "high",
    },
    {
      pattern: /token\s*=\s*["'][^"']+["']/gi,
      type: "token",
      severity: "medium",
    },
    {
      pattern: /-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----/gi,
      type: "private-key",
      severity: "critical",
    },
  ],

  vulnerabilities: [
    {
      pattern: /eval\s*\(/gi,
      type: "code-injection",
      severity: "critical",
      cwe: "CWE-94",
    },
    {
      pattern: /exec\s*\(/gi,
      type: "command-injection",
      severity: "critical",
      cwe: "CWE-78",
    },
    {
      pattern: /innerHTML\s*=/gi,
      type: "xss",
      severity: "high",
      cwe: "CWE-79",
    },
    {
      pattern: /document\.write\s*\(/gi,
      type: "xss",
      severity: "high",
      cwe: "CWE-79",
    },
    {
      pattern: /\$\{[^}]*\}/gi,
      type: "template-injection",
      severity: "medium",
      cwe: "CWE-94",
    },
    {
      pattern: /SELECT\s+.*\s+FROM\s+.*\s+WHERE\s+.*\+/gi,
      type: "sql-injection",
      severity: "critical",
      cwe: "CWE-89",
    },
  ],

  insecureTransport: [
    {
      pattern: /http:\/\/(?!localhost|127\.0\.0\.1)/gi,
      type: "insecure-transport",
      severity: "medium",
    },
    { pattern: /ftp:\/\//gi, type: "insecure-transport", severity: "medium" },
    { pattern: /telnet:\/\//gi, type: "insecure-transport", severity: "high" },
  ],

  weakCrypto: [
    { pattern: /md5\s*\(/gi, type: "weak-hash", severity: "medium" },
    { pattern: /sha1\s*\(/gi, type: "weak-hash", severity: "medium" },
    { pattern: /des\s*\(/gi, type: "weak-encryption", severity: "high" },
    { pattern: /rc4\s*\(/gi, type: "weak-encryption", severity: "high" },
  ],
};

export function detectSecurityIssues(content: string, filePath: string) {
  const issues = [];
  const lines = content.split("\n");

  for (const category of Object.values(SECURITY_PATTERNS)) {
    for (const rule of category) {
      lines.forEach((line, index) => {
        const matches = line.match(rule.pattern);
        if (matches) {
          issues.push({
            type: rule.type,
            severity: rule.severity,
            file: filePath,
            line: index + 1,
            description: `Detected ${rule.type}: ${matches[0]}`,
            cwe: rule.cwe || undefined,
          });
        }
      });
    }
  }

  return issues;
}
