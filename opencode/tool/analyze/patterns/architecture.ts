// @ts-nocheck
export const ARCHITECTURE_PATTERNS = {
  designPatterns: [
    {
      pattern: /class\s+\w*Factory\w*/gi,
      type: "factory-pattern",
      confidence: 0.8,
    },
    {
      pattern: /class\s+\w*Singleton\w*/gi,
      type: "singleton-pattern",
      confidence: 0.9,
    },
    {
      pattern: /class\s+\w*Observer\w*/gi,
      type: "observer-pattern",
      confidence: 0.8,
    },
    {
      pattern: /class\s+\w*Strategy\w*/gi,
      type: "strategy-pattern",
      confidence: 0.8,
    },
    {
      pattern: /class\s+\w*Adapter\w*/gi,
      type: "adapter-pattern",
      confidence: 0.8,
    },
    {
      pattern: /class\s+\w*Decorator\w*/gi,
      type: "decorator-pattern",
      confidence: 0.8,
    },
  ],

  architecturalPatterns: [
    { pattern: /\/controllers?\//gi, type: "mvc-pattern", confidence: 0.7 },
    { pattern: /\/models?\//gi, type: "mvc-pattern", confidence: 0.7 },
    { pattern: /\/views?\//gi, type: "mvc-pattern", confidence: 0.7 },
    { pattern: /\/services?\//gi, type: "service-layer", confidence: 0.8 },
    {
      pattern: /\/repositories?\//gi,
      type: "repository-pattern",
      confidence: 0.8,
    },
    {
      pattern: /\/components?\//gi,
      type: "component-architecture",
      confidence: 0.9,
    },
    {
      pattern: /\/middleware\//gi,
      type: "middleware-pattern",
      confidence: 0.8,
    },
  ],

  antiPatterns: [
    { pattern: /class\s+\w*Manager\w*/gi, type: "god-object", confidence: 0.6 },
    { pattern: /class\s+\w*Util\w*/gi, type: "utility-class", confidence: 0.5 },
    {
      pattern: /function\s+\w*DoEverything\w*/gi,
      type: "god-function",
      confidence: 0.7,
    },
    { pattern: /global\s+\w+/gi, type: "global-state", confidence: 0.6 },
  ],

  layerViolations: [
    {
      pattern: /import.*\/database\/.*from.*\/ui\//gi,
      type: "layer-violation",
      severity: "high",
    },
    {
      pattern: /import.*\/models\/.*from.*\/views\//gi,
      type: "layer-violation",
      severity: "high",
    },
    {
      pattern: /import.*\/backend\/.*from.*\/frontend\//gi,
      type: "layer-violation",
      severity: "critical",
    },
  ],
};

export function detectArchitecturalPatterns(files: string[]) {
  const patterns = [];
  const violations = [];

  // Detect patterns based on file structure
  const hasControllers = files.some((f) => /\/controllers?\//i.test(f));
  const hasModels = files.some((f) => /\/models?\//i.test(f));
  const hasViews = files.some((f) => /\/views?\//i.test(f));
  const hasServices = files.some((f) => /\/services?\//i.test(f));
  const hasComponents = files.some((f) => /\/components?\//i.test(f));

  if (hasControllers && hasModels && hasViews) {
    patterns.push({
      name: "MVC Architecture",
      type: "architectural-pattern",
      confidence: 0.9,
      files: files.filter((f) => /\/(controllers?|models?|views?)\//i.test(f)),
      description: "Model-View-Controller pattern detected",
    });
  }

  if (hasServices) {
    patterns.push({
      name: "Service Layer",
      type: "architectural-pattern",
      confidence: 0.8,
      files: files.filter((f) => /\/services?\//i.test(f)),
      description: "Service layer pattern detected",
    });
  }

  if (hasComponents) {
    patterns.push({
      name: "Component Architecture",
      type: "architectural-pattern",
      confidence: 0.9,
      files: files.filter((f) => /\/components?\//i.test(f)),
      description: "Component-based architecture detected",
    });
  }

  return { patterns, violations };
}

export function detectArchitecturalViolations(
  content: string,
  filePath: string,
) {
  const violations = [];
  const lines = content.split("\n");

  for (const rule of ARCHITECTURE_PATTERNS.layerViolations) {
    lines.forEach((line, index) => {
      const matches = line.match(rule.pattern);
      if (matches) {
        violations.push({
          rule: "Layer separation violation",
          severity: rule.severity,
          file: filePath,
          line: index + 1,
          description: `Architectural violation: ${rule.type}`,
          suggestion: "Maintain proper layer separation",
        });
      }
    });
  }

  return violations;
}

export function generateArchitecturalSuggestions(
  patterns: any[],
  files: string[],
) {
  const suggestions = [];

  if (patterns.length === 0) {
    suggestions.push({
      category: "structure",
      priority: "high",
      title: "Define architectural pattern",
      description: "Project lacks clear architectural patterns",
      benefits: ["Better code organization", "Improved maintainability"],
      effort: "high",
    });
  }

  const hasUtils = files.some((f) => /\/utils?\//i.test(f));
  if (!hasUtils && files.length > 10) {
    suggestions.push({
      category: "structure",
      priority: "medium",
      title: "Add utility layer",
      description: "Consider adding a utilities layer for shared functions",
      benefits: ["Code reusability", "Better organization"],
      effort: "low",
    });
  }

  const hasTests = files.some((f) => /\/(tests?|spec)\//i.test(f));
  if (!hasTests) {
    suggestions.push({
      category: "testing",
      priority: "high",
      title: "Add test structure",
      description: "Project lacks organized test structure",
      benefits: ["Better code quality", "Regression prevention"],
      effort: "medium",
    });
  }

  return suggestions;
}
