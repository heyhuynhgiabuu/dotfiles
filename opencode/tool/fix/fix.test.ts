import { describe, it, expect, beforeEach, vi } from "vitest";
import { ImportsFixer } from "./imports-fixer";
import { FormattingFixer } from "./formatting-fixer";
import { LintFixer } from "./lint-fixer";
import { UnusedFixer } from "./unused-fixer";
import { DeprecatedFixer } from "./deprecated-fixer";

// Mock OpenCode tools
const mockGrepTool = {
  execute: vi.fn(),
};

const mockReadTool = {
  execute: vi.fn(),
};

const mockEditTool = {
  execute: vi.fn(),
};

const mockBashTool = {
  execute: vi.fn(),
};

describe("Fix Tool Components", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe("ImportsFixer", () => {
    let importsFixer: ImportsFixer;

    beforeEach(() => {
      importsFixer = new ImportsFixer(
        mockGrepTool,
        mockReadTool,
        mockEditTool,
        mockBashTool,
      );
    });

    it("should detect unused imports", async () => {
      // Mock file with unused import
      mockGrepTool.execute.mockResolvedValue({
        metadata: { matches: 1 },
      });

      mockReadTool.execute.mockResolvedValue({
        output: `import { unused } from 'module';
import { used } from 'other';

console.log(used);`,
      });

      const issues = await importsFixer.detect(["test.ts"]);

      expect(issues).toHaveLength(1);
      expect(issues[0].type).toBe("unused-import");
      expect(issues[0].description).toContain("unused");
    });

    it("should detect unsorted imports", async () => {
      mockGrepTool.execute.mockResolvedValue({
        metadata: { matches: 2 },
      });

      mockReadTool.execute.mockResolvedValue({
        output: `import { z } from 'zod';
import { a } from 'axios';

console.log(z, a);`,
      });

      const issues = await importsFixer.detect(["test.ts"]);

      expect(issues.some((i) => i.type === "unsorted-imports")).toBe(true);
    });

    it("should apply import fixes in dry run mode", async () => {
      const issues = [
        {
          type: "unused-import",
          file: "test.ts",
          lineNumber: 1,
          description: "Unused import: unused",
          fix: { action: "remove", target: "import { unused } from 'module';" },
        },
      ];

      const changes = await importsFixer.apply(issues, {
        dryRun: true,
        backup: false,
      });

      expect(changes).toHaveLength(1);
      expect(changes[0].description).toContain("Removed 1 unused imports");
      expect(mockEditTool.execute).not.toHaveBeenCalled();
    });
  });

  describe("FormattingFixer", () => {
    let formattingFixer: FormattingFixer;

    beforeEach(() => {
      formattingFixer = new FormattingFixer(mockBashTool);
    });

    it("should detect formatting issues with Prettier", async () => {
      mockBashTool.execute.mockResolvedValue({
        metadata: { exitCode: 1 },
        output: "test.ts needs formatting",
      });

      const issues = await formattingFixer.detect(["test.ts"]);

      expect(issues).toHaveLength(1);
      expect(issues[0].type).toBe("formatting");
      expect(issues[0].fix.target).toBe("prettier");
    });

    it("should fallback to ESLint when Prettier fails", async () => {
      mockBashTool.execute
        .mockRejectedValueOnce(new Error("Prettier not found"))
        .mockResolvedValueOnce({
          output: JSON.stringify([
            {
              filePath: "test.ts",
              messages: [
                {
                  ruleId: "indent",
                  message: "Expected indentation",
                },
              ],
            },
          ]),
        });

      const issues = await formattingFixer.detect(["test.ts"]);

      expect(issues).toHaveLength(1);
      expect(issues[0].fix.target).toBe("eslint");
    });
  });

  describe("LintFixer", () => {
    let lintFixer: LintFixer;

    beforeEach(() => {
      lintFixer = new LintFixer(mockBashTool);
    });

    it("should detect ESLint auto-fixable issues", async () => {
      mockBashTool.execute.mockResolvedValue({
        output: JSON.stringify([
          {
            filePath: "test.ts",
            messages: [
              {
                ruleId: "semi",
                message: "Missing semicolon",
                line: 1,
                fix: { range: [10, 10], text: ";" },
              },
            ],
          },
        ]),
      });

      const issues = await lintFixer.detect(["test.ts"]);

      expect(issues).toHaveLength(1);
      expect(issues[0].type).toBe("lint");
      expect(issues[0].fix.action).toBe("eslint-fix");
      expect(issues[0].fix.fixable).toBe(true);
    });

    it("should handle TypeScript errors when ESLint fails", async () => {
      mockBashTool.execute
        .mockRejectedValueOnce(new Error("ESLint not found"))
        .mockResolvedValueOnce({
          metadata: { exitCode: 1 },
          output: "test.ts(1,1): error TS2304: Cannot find name 'foo'",
        });

      const issues = await lintFixer.detect(["test.ts"]);

      expect(issues).toHaveLength(1);
      expect(issues[0].fix.action).toBe("typescript-fix");
    });
  });

  describe("UnusedFixer", () => {
    let unusedFixer: UnusedFixer;

    beforeEach(() => {
      unusedFixer = new UnusedFixer(mockGrepTool, mockReadTool, mockEditTool);
    });

    it("should detect unused variables", async () => {
      mockReadTool.execute.mockResolvedValue({
        output: `const unused = 'value';
const used = 'other';
console.log(used);`,
      });

      const issues = await unusedFixer.detect(["test.ts"]);

      expect(issues).toHaveLength(1);
      expect(issues[0].type).toBe("unused-variable");
      expect(issues[0].description).toContain("unused");
    });
  });

  describe("DeprecatedFixer", () => {
    let deprecatedFixer: DeprecatedFixer;

    beforeEach(() => {
      deprecatedFixer = new DeprecatedFixer(
        mockGrepTool,
        mockReadTool,
        mockEditTool,
      );
    });

    it("should detect deprecated API usage", async () => {
      mockReadTool.execute.mockResolvedValue({
        output: `const buffer = new Buffer('data');
console.log(buffer);`,
      });

      const issues = await deprecatedFixer.detect(["test.js"]);

      expect(issues).toHaveLength(1);
      expect(issues[0].type).toBe("deprecated");
      expect(issues[0].description).toContain("new Buffer");
    });

    it("should apply auto-fixable deprecated API replacements", async () => {
      const issues = [
        {
          type: "deprecated",
          file: "test.js",
          lineNumber: 1,
          description: "Deprecated API: new Buffer -> Buffer.from",
          fix: {
            action: "replace",
            target: "new Buffer(",
            fixable: true,
          },
        },
      ];

      mockReadTool.execute.mockResolvedValue({
        output: "const buffer = new Buffer('data');",
      });

      const changes = await deprecatedFixer.apply(issues, {
        dryRun: false,
        backup: false,
      });

      expect(changes).toHaveLength(1);
      expect(changes[0].description).toContain("Updated 1 deprecated APIs");
      expect(mockEditTool.execute).toHaveBeenCalled();
    });
  });
});

describe("Integration Tests", () => {
  it("should handle empty file list gracefully", async () => {
    const importsFixer = new ImportsFixer(
      mockGrepTool,
      mockReadTool,
      mockEditTool,
      mockBashTool,
    );

    const issues = await importsFixer.detect([]);
    expect(issues).toHaveLength(0);
  });

  it("should handle file read errors gracefully", async () => {
    const importsFixer = new ImportsFixer(
      mockGrepTool,
      mockReadTool,
      mockEditTool,
      mockBashTool,
    );

    mockGrepTool.execute.mockRejectedValue(new Error("File not found"));

    const issues = await importsFixer.detect(["nonexistent.ts"]);
    expect(issues).toHaveLength(0);
  });

  it("should handle tool execution errors gracefully", async () => {
    const formattingFixer = new FormattingFixer(mockBashTool);

    mockBashTool.execute.mockRejectedValue(new Error("Tool not found"));

    const issues = await formattingFixer.detect(["test.ts"]);
    expect(issues).toHaveLength(0);
  });
});
