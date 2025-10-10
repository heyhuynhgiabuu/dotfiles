// @ts-nocheck
import { BaseEngine } from "./base";
import {
  AnalysisConfig,
  DependencyAnalysis,
  ExternalDependency,
  InternalDependency,
} from "../types";

export class DependencyEngine extends BaseEngine {
  async analyze(config: AnalysisConfig): Promise<DependencyAnalysis> {
    const cacheKey = `dependencies:${this.getCacheKey(config)}`;

    if (config.useCache) {
      const cached = await this.cache.get<DependencyAnalysis>(cacheKey);
      if (cached) return cached;
    }

    try {
      const external: ExternalDependency[] = [];
      const internal: InternalDependency[] = [];

      // Find package.json files
      const packageJsonCmd = `find . -name "package.json" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null`;
      const packageFiles = await this.executeCommand(packageJsonCmd);

      for (const packageFile of packageFiles
        .split("\n")
        .filter((f) => f.trim())) {
        try {
          const content = await this.executeCommand(`cat "${packageFile}"`);
          if (content) {
            const pkg = JSON.parse(content);

            if (pkg.dependencies) {
              for (const [name, version] of Object.entries(pkg.dependencies)) {
                external.push({
                  name,
                  version: version as string,
                  type: "production",
                  location: packageFile,
                });
              }
            }

            if (pkg.devDependencies) {
              for (const [name, version] of Object.entries(
                pkg.devDependencies,
              )) {
                external.push({
                  name,
                  version: version as string,
                  type: "development",
                  location: packageFile,
                });
              }
            }
          }
        } catch (error) {
          this.client.app
            .log({
              body: {
                service: "analyze-tool",
                level: "warn",
                message: `Failed to parse ${packageFile}: ${error.message}`,
              },
            })
            .catch(() => {});
        }
      }

      // Find pyproject.toml files
      const pyprojectCmd = `find . -name "pyproject.toml" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null`;
      const pyprojectFiles = await this.executeCommand(pyprojectCmd);

      for (const pyprojectFile of pyprojectFiles
        .split("\n")
        .filter((f) => f.trim())) {
        try {
          const content = await this.executeCommand(`cat "${pyprojectFile}"`);
          if (content && content.includes("dependencies")) {
            // Simple regex to extract dependencies from pyproject.toml
            const depMatch = content.match(/dependencies\s*=\s*\[([\s\S]*?)\]/);
            if (depMatch) {
              const deps = depMatch[1].match(/"([^"]+)"/g) || [];
              deps.forEach((dep) => {
                const cleanDep = dep.replace(/"/g, "").split(/[><=]/)[0];
                external.push({
                  name: cleanDep,
                  version: "latest",
                  type: "production",
                  location: pyprojectFile,
                });
              });
            }
          }
        } catch (error) {
          this.client.app
            .log({
              body: {
                service: "analyze-tool",
                level: "warn",
                message: `Failed to parse ${pyprojectFile}: ${error.message}`,
              },
            })
            .catch(() => {});
        }
      }

      // Find Brewfile
      const brewfileCmd = `find . -name "Brewfile*" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null`;
      const brewFiles = await this.executeCommand(brewfileCmd);

      for (const brewFile of brewFiles.split("\n").filter((f) => f.trim())) {
        try {
          const content = await this.executeCommand(`cat "${brewFile}"`);
          if (content) {
            const brewDeps = content.match(/^(brew|cask)\s+"([^"]+)"/gm) || [];
            brewDeps.forEach((dep) => {
              const match = dep.match(/(brew|cask)\s+"([^"]+)"/);
              if (match) {
                external.push({
                  name: match[2],
                  version: "latest",
                  type: match[1] as any,
                  location: brewFile,
                });
              }
            });
          }
        } catch (error) {
          this.client.app
            .log({
              body: {
                service: "analyze-tool",
                level: "warn",
                message: `Failed to parse ${brewFile}: ${error.message}`,
              },
            })
            .catch(() => {});
        }
      }

      const result: DependencyAnalysis = {
        external,
        internal,
        vulnerabilities: [],
        outdated: [],
      };

      await this.cache.set(cacheKey, result, 600);
      return result;
    } catch (error) {
      this.client.app
        .log({
          body: {
            service: "analyze-tool",
            level: "warn",
            message: `Dependency analysis failed: ${error.message}`,
          },
        })
        .catch(() => {});
      return {
        external: [],
        internal: [],
        vulnerabilities: [],
        outdated: [],
      };
    }
  }
}
