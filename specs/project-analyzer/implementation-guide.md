# Project Analyzer Implementation Guide

## File Structure

```
.opencode/tool/
├── analyze.ts              # Main analyzer tool
├── analyze/
│   ├── engines/
│   │   ├── structure.ts    # Structure analysis engine
│   │   ├── dependency.ts   # Dependency analysis engine
│   │   ├── quality.ts      # Code quality engine
│   │   ├── security.ts     # Security analysis engine
│   │   ├── performance.ts  # Performance analysis engine
│   │   └── architecture.ts # Architecture analysis engine
│   ├── cache/
│   │   ├── manager.ts      # Cache management
│   │   └── storage.ts      # Cache storage interface
│   ├── patterns/
│   │   ├── security.ts     # Security patterns
│   │   ├── performance.ts  # Performance patterns
│   │   └── architecture.ts # Architecture patterns
│   └── types.ts           # TypeScript definitions
```

## Core Implementation

### Main Tool (analyze.ts)

```typescript
import { tool } from "@opencode-ai/plugin";
import { createOpencodeClient } from "@opencode-ai/sdk";
import { AnalysisEngine } from "./analyze/engines";
import { CacheManager } from "./analyze/cache/manager";

export default tool({
  description: "Comprehensive project analysis with multi-dimensional insights",
  args: {
    mode: tool.schema
      .enum(["quick", "deep", "security", "performance", "architecture"])
      .optional()
      .describe("Analysis mode (default: quick)"),
    scope: tool.schema
      .array(tool.schema.string())
      .optional()
      .describe("Specific paths to analyze"),
    exclude: tool.schema
      .array(tool.schema.string())
      .optional()
      .describe("Patterns to exclude"),
    cache: tool.schema
      .boolean()
      .optional()
      .describe("Use cached results (default: true)"),
    format: tool.schema
      .enum(["detailed", "summary", "agent"])
      .optional()
      .describe("Output format (default: detailed)"),
  },

  async execute(args, context) {
    const client = createOpencodeClient({
      baseUrl: context.baseUrl || "http://localhost:4096",
    });

    const cache = new CacheManager(context.sessionID);
    const engine = new AnalysisEngine(client, cache);

    const config = {
      mode: args.mode || "quick",
      scope: args.scope || [],
      exclude: args.exclude || ["node_modules", ".git", "dist", "build"],
      useCache: args.cache !== false,
      format: args.format || "detailed",
    };

    try {
      const result = await engine.analyze(config);
      return formatOutput(result, config.format);
    } catch (error) {
      return {
        error: true,
        message: `Analysis failed: ${error.message}`,
        partialResults: await engine.getPartialResults(),
      };
    }
  },
});

function formatOutput(result: AnalysisResult, format: string) {
  switch (format) {
    case "summary":
      return createSummaryOutput(result);
    case "agent":
      return createAgentOutput(result);
    default:
      return result;
  }
}
```

### Analysis Engine (engines/index.ts)

```typescript
import { StructureEngine } from "./structure";
import { DependencyEngine } from "./dependency";
import { QualityEngine } from "./quality";
import { SecurityEngine } from "./security";
import { PerformanceEngine } from "./performance";
import { ArchitectureEngine } from "./architecture";

export class AnalysisEngine {
  private engines: Map<string, BaseEngine>;

  constructor(
    private client: OpencodeClient,
    private cache: CacheManager,
  ) {
    this.engines = new Map([
      ["structure", new StructureEngine(client, cache)],
      ["dependency", new DependencyEngine(client, cache)],
      ["quality", new QualityEngine(client, cache)],
      ["security", new SecurityEngine(client, cache)],
      ["performance", new PerformanceEngine(client, cache)],
      ["architecture", new ArchitectureEngine(client, cache)],
    ]);
  }

  async analyze(config: AnalysisConfig): Promise<AnalysisResult> {
    const startTime = Date.now();
    const results: Partial<AnalysisResult> = {
      metadata: {
        mode: config.mode,
        timestamp: new Date().toISOString(),
        scope: config.scope,
        exclude: config.exclude,
      },
    };

    const engineOrder = this.getEngineOrder(config.mode);

    for (const engineName of engineOrder) {
      const engine = this.engines.get(engineName);
      if (!engine) continue;

      try {
        const engineResult = await engine.analyze(config);
        results[engineName] = engineResult;
      } catch (error) {
        console.warn(`Engine ${engineName} failed:`, error.message);
        results[engineName] = { error: error.message };
      }
    }

    results.metadata.duration = Date.now() - startTime;
    return results as AnalysisResult;
  }

  private getEngineOrder(mode: string): string[] {
    const orders = {
      quick: ["structure", "dependency"],
      deep: ["structure", "dependency", "quality", "architecture"],
      security: ["structure", "dependency", "security"],
      performance: ["structure", "dependency", "performance"],
      architecture: ["structure", "dependency", "quality", "architecture"],
    };
    return orders[mode] || orders.quick;
  }
}
```

### Structure Engine (engines/structure.ts)

```typescript
export class StructureEngine extends BaseEngine {
  async analyze(config: AnalysisConfig): Promise<StructureAnalysis> {
    const cacheKey = `structure:${this.getCacheKey(config)}`;

    if (config.useCache) {
      const cached = await this.cache.get(cacheKey);
      if (cached) return cached;
    }

    const [directories, files] = await Promise.all([
      this.analyzeDirectories(config),
      this.analyzeFiles(config),
    ]);

    const result = {
      directories: directories,
      keyFiles: this.identifyKeyFiles(files),
      patterns: this.detectPatterns(files),
      size: this.calculateSize(files),
    };

    await this.cache.set(cacheKey, result, 300); // 5 min TTL
    return result;
  }

  private async analyzeDirectories(
    config: AnalysisConfig,
  ): Promise<DirectoryInfo[]> {
    const patterns = [
      "**/*",
      "!node_modules/**",
      "!.git/**",
      ...config.exclude.map((pattern) => `!${pattern}`),
    ];

    const files = await this.client.find.files({
      query: { query: patterns.join(",") },
    });

    return this.buildDirectoryTree(files);
  }

  private identifyKeyFiles(files: string[]): KeyFile[] {
    const keyPatterns = [
      { pattern: /package\.json$/, type: "package", importance: "critical" },
      { pattern: /README\.md$/i, type: "documentation", importance: "high" },
      { pattern: /\.env/, type: "environment", importance: "high" },
      { pattern: /docker/i, type: "deployment", importance: "medium" },
      { pattern: /test|spec/i, type: "test", importance: "medium" },
    ];

    return files
      .map((file) => {
        const match = keyPatterns.find((p) => p.pattern.test(file));
        return match
          ? {
              path: file,
              type: match.type,
              importance: match.importance,
              purpose: this.inferPurpose(file, match.type),
            }
          : null;
      })
      .filter(Boolean);
  }
}
```

### Cache Manager (cache/manager.ts)

```typescript
export class CacheManager {
  private storage = new Map<string, CacheEntry>();
  private readonly maxSize = 100;
  private readonly defaultTTL = 1800; // 30 minutes

  constructor(private sessionID: string) {}

  async get<T>(key: string): Promise<T | null> {
    const fullKey = `${this.sessionID}:${key}`;
    const entry = this.storage.get(fullKey);

    if (!entry) return null;

    if (Date.now() > entry.expiry) {
      this.storage.delete(fullKey);
      return null;
    }

    entry.lastAccessed = Date.now();
    return entry.data as T;
  }

  async set<T>(key: string, data: T, ttl = this.defaultTTL): Promise<void> {
    const fullKey = `${this.sessionID}:${key}`;

    if (this.storage.size >= this.maxSize) {
      this.evictLRU();
    }

    this.storage.set(fullKey, {
      data,
      expiry: Date.now() + ttl * 1000,
      lastAccessed: Date.now(),
    });
  }

  private evictLRU(): void {
    let oldestKey = "";
    let oldestTime = Date.now();

    for (const [key, entry] of this.storage.entries()) {
      if (entry.lastAccessed < oldestTime) {
        oldestTime = entry.lastAccessed;
        oldestKey = key;
      }
    }

    if (oldestKey) {
      this.storage.delete(oldestKey);
    }
  }
}
```

## Testing Strategy

### Unit Tests

```typescript
// test/analyze.test.ts
import { describe, it, expect, beforeEach } from "bun:test";
import { AnalysisEngine } from "../analyze/engines";
import { MockOpencodeClient } from "./mocks/client";
import { MockCacheManager } from "./mocks/cache";

describe("AnalysisEngine", () => {
  let engine: AnalysisEngine;
  let mockClient: MockOpencodeClient;
  let mockCache: MockCacheManager;

  beforeEach(() => {
    mockClient = new MockOpencodeClient();
    mockCache = new MockCacheManager();
    engine = new AnalysisEngine(mockClient, mockCache);
  });

  it("should perform quick analysis", async () => {
    const config = { mode: "quick", scope: [], exclude: [], useCache: false };
    const result = await engine.analyze(config);

    expect(result.metadata.mode).toBe("quick");
    expect(result.structure).toBeDefined();
    expect(result.dependency).toBeDefined();
  });

  it("should use cache when enabled", async () => {
    const config = { mode: "quick", scope: [], exclude: [], useCache: true };

    await engine.analyze(config);
    expect(mockCache.setCalls).toBeGreaterThan(0);

    await engine.analyze(config);
    expect(mockCache.getCalls).toBeGreaterThan(0);
  });
});
```

### Integration Tests

```typescript
// test/integration.test.ts
describe("Analyzer Integration", () => {
  it("should analyze real project structure", async () => {
    const result = await analyzeTestProject({
      mode: "deep",
      scope: ["src/"],
      exclude: ["node_modules"],
    });

    expect(result.structure.directories).toContain("src");
    expect(result.quality.maintainability).toBeDefined();
    expect(result.recommendations).toBeArray();
  });
});
```

## Performance Benchmarks

### Benchmark Suite

```typescript
// benchmark/analyze.bench.ts
import { bench, describe } from "bun:test";

describe("Analysis Performance", () => {
  bench("quick mode - small project", async () => {
    await analyzeProject({ mode: "quick", projectSize: "small" });
  });

  bench("deep mode - medium project", async () => {
    await analyzeProject({ mode: "deep", projectSize: "medium" });
  });

  bench("cache hit performance", async () => {
    await analyzeProjectWithCache({ useCache: true });
  });
});
```

## Deployment Checklist

### Pre-deployment

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Performance benchmarks meet targets
- [ ] Cross-platform compatibility verified
- [ ] Error handling tested
- [ ] Cache performance validated

### Post-deployment

- [ ] Monitor analysis performance
- [ ] Track cache hit rates
- [ ] Collect user feedback
- [ ] Monitor error rates
- [ ] Validate agent routing improvements
