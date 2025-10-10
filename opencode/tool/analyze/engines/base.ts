// @ts-nocheck
import { AnalysisConfig } from "../types";
import { CacheManager } from "../cache/manager";

export abstract class BaseEngine {
  constructor(
    protected client: any,
    protected cache: CacheManager,
  ) {}

  abstract analyze(config: AnalysisConfig): Promise<any>;

  protected getCacheKey(config: AnalysisConfig): string {
    return JSON.stringify({
      mode: config.mode,
      scope: config.scope,
      exclude: config.exclude,
    });
  }

  protected async executeCommand(cmd: string): Promise<string> {
    try {
      const { execSync } = require("child_process");
      return execSync(cmd, { encoding: "utf8", maxBuffer: 10 * 1024 * 1024 });
    } catch (error) {
      this.client.app
        .log({
          body: {
            service: "analyze-tool",
            level: "warn",
            message: `Command failed: ${cmd} - ${error.message}`,
          },
        })
        .catch(() => {});
      return "";
    }
  }
}
