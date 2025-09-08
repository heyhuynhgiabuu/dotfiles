/**
 * Universal Context Engineering Plugin for OpenCode
 * Detects tech stacks and provides intelligent landscape mapping
 * Supports Java/Spring Boot, Go, TypeScript/JavaScript, and infrastructure
 */

export const UniversalContextEngineering = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  await client.app.log({
    body: {
      service: "universal-context-engineering",
      level: "info",
      message: `🌍 Universal Context Engineering Plugin loaded for: ${project?.name || directory}`,
    },
  });

  // Performance caching
  const techStackCache = new Map();

  // Tech Stack Detection with caching
  const detectTechStack = (filePath) => {
    if (techStackCache.has(filePath)) {
      return techStackCache.get(filePath);
    }

    let result;
    if (!filePath) {
      result = { language: "unknown", framework: null, buildSystem: null };
    } else {
      const fileExt = filePath.split(".").pop()?.toLowerCase();
      const fileName = filePath.split("/").pop()?.toLowerCase();

      // Java Ecosystem
      if (
        fileExt === "java" ||
        fileName === "pom.xml" ||
        fileName === "build.gradle"
      ) {
        result = {
          language: "java",
          framework: detectJavaFramework(filePath),
          buildSystem: fileName === "pom.xml" ? "maven" : "gradle",
        };
      }
      // Go Ecosystem
      else if (
        fileExt === "go" ||
        fileName === "go.mod" ||
        fileName === "go.sum"
      ) {
        result = {
          language: "go",
          framework: detectGoFramework(filePath),
          buildSystem: "go-modules",
        };
      }
      // JavaScript/TypeScript Ecosystem
      else if (
        ["js", "ts", "jsx", "tsx", "json"].includes(fileExt) ||
        fileName === "package.json"
      ) {
        result = {
          language:
            fileExt === "ts" || fileExt === "tsx" ? "typescript" : "javascript",
          framework: detectJSFramework(filePath),
          buildSystem: "npm",
        };
      }
      // Configuration & Infrastructure
      else if (["yml", "yaml"].includes(fileExt)) {
        result = {
          language: "yaml",
          framework: detectInfraFramework(filePath),
          buildSystem: null,
        };
      } else if (fileExt === "dockerfile" || fileName === "dockerfile") {
        result = {
          language: "docker",
          framework: null,
          buildSystem: "docker",
        };
      } else {
        result = { language: "generic", framework: null, buildSystem: null };
      }
    }

    techStackCache.set(filePath, result);
    return result;
  };

  // Framework Detection Functions
  const detectJavaFramework = (filePath) => {
    if (filePath.includes("spring") || filePath.includes("SpringApplication")) {
      return "spring-boot";
    }
    if (
      filePath.includes("javax.servlet") ||
      filePath.includes("jakarta.servlet")
    ) {
      return "servlet";
    }
    return "java-core";
  };

  const detectGoFramework = (filePath) => {
    if (
      filePath.includes("gin") ||
      filePath.includes("github.com/gin-gonic/gin")
    ) {
      return "gin";
    }
    if (
      filePath.includes("fiber") ||
      filePath.includes("github.com/gofiber/fiber")
    ) {
      return "fiber";
    }
    if (
      filePath.includes("echo") ||
      filePath.includes("github.com/labstack/echo")
    ) {
      return "echo";
    }
    return "go-standard";
  };

  const detectJSFramework = (filePath) => {
    if (filePath.includes("next") || filePath.includes("Next.js")) {
      return "nextjs";
    }
    if (filePath.includes("react") || filePath.includes("React")) {
      return "react";
    }
    if (filePath.includes("vue") || filePath.includes("Vue")) {
      return "vue";
    }
    if (filePath.includes("express") || filePath.includes("app.listen")) {
      return "express";
    }
    if (filePath.includes("svelte") || filePath.includes("Svelte")) {
      return "svelte";
    }
    return "vanilla-js";
  };

  const detectInfraFramework = (filePath) => {
    if (filePath.includes("kubernetes") || filePath.includes("k8s")) {
      return "kubernetes";
    }
    if (filePath.includes("docker-compose")) {
      return "docker-compose";
    }
    if (filePath.includes("github/workflows") || filePath.includes(".github")) {
      return "github-actions";
    }
    return "config";
  };

  // Universal Landscape Detection
  const detectInformationLandscape = (filePath) => {
    if (!filePath)
      return { name: "General Codebase", type: "generic", tech: null };

    const techStack = detectTechStack(filePath);
    const pathLower = filePath.toLowerCase();

    // Documentation Landscape
    if (
      pathLower.includes("readme") ||
      pathLower.includes("docs/") ||
      pathLower.includes(".md")
    ) {
      return {
        name: "Documentation Space",
        type: "docs",
        tech: techStack,
        context: "Technical documentation and guides",
      };
    }

    // Configuration Landscape
    if (
      pathLower.includes("config") ||
      pathLower.includes(".yml") ||
      pathLower.includes(".yaml") ||
      pathLower.includes(".json") ||
      pathLower.includes(".toml") ||
      pathLower.includes(".ini")
    ) {
      return {
        name: "Configuration Space",
        type: "config",
        tech: techStack,
        context: `${techStack.framework || techStack.language} configuration`,
      };
    }

    // Build System Landscape
    if (
      pathLower.includes("pom.xml") ||
      pathLower.includes("build.gradle") ||
      pathLower.includes("package.json") ||
      pathLower.includes("go.mod")
    ) {
      return {
        name: "Build System",
        type: "build",
        tech: techStack,
        context: `${techStack.buildSystem} build configuration`,
      };
    }

    // Test Landscape
    if (
      pathLower.includes("test") ||
      pathLower.includes("spec") ||
      pathLower.includes("__tests__")
    ) {
      return {
        name: "Test Suite",
        type: "test",
        tech: techStack,
        context: `${techStack.framework || techStack.language} tests`,
      };
    }

    // Source Code Landscapes by Tech Stack
    if (techStack.language === "java") {
      if (pathLower.includes("src/main/java")) {
        return {
          name: "Java Source Code",
          type: "source-main",
          tech: techStack,
          context: `${techStack.framework} main source code`,
        };
      }
      if (pathLower.includes("src/main/resources")) {
        return {
          name: "Java Resources",
          type: "resources",
          tech: techStack,
          context: `${techStack.framework} application resources`,
        };
      }
    }

    if (techStack.language === "go") {
      if (pathLower.includes("cmd/") || pathLower.includes("main.go")) {
        return {
          name: "Go Entry Points",
          type: "source-main",
          tech: techStack,
          context: `${techStack.framework} application entry points`,
        };
      }
      if (pathLower.includes("internal/") || pathLower.includes("pkg/")) {
        return {
          name: "Go Package Code",
          type: "source-pkg",
          tech: techStack,
          context: `${techStack.framework} package implementation`,
        };
      }
    }

    if (
      techStack.language === "javascript" ||
      techStack.language === "typescript"
    ) {
      if (pathLower.includes("src/") || pathLower.includes("lib/")) {
        return {
          name: "JavaScript Source",
          type: "source-main",
          tech: techStack,
          context: `${techStack.framework} application code`,
        };
      }
      if (pathLower.includes("components/") || pathLower.includes("pages/")) {
        return {
          name: "UI Components",
          type: "source-ui",
          tech: techStack,
          context: `${techStack.framework} user interface components`,
        };
      }
    }

    // Infrastructure Landscape
    if (
      pathLower.includes("docker") ||
      pathLower.includes("kubernetes") ||
      pathLower.includes("terraform") ||
      pathLower.includes("ansible")
    ) {
      return {
        name: "Infrastructure Code",
        type: "infra",
        tech: techStack,
        context: `${techStack.framework || "Infrastructure"} deployment and operations`,
      };
    }

    // Generic Source Code
    if (techStack.language !== "unknown" && techStack.language !== "generic") {
      return {
        name: `${techStack.language.charAt(0).toUpperCase() + techStack.language.slice(1)} Source`,
        type: "source",
        tech: techStack,
        context: `${techStack.framework || techStack.language} source code`,
      };
    }

    return {
      name: "General Codebase",
      type: "generic",
      tech: techStack,
      context: "Mixed or unidentified codebase",
    };
  };

  // Generate Enhanced Navigation Metadata
  const generateNavigationMetadata = async (toolName, landscape, output) => {
    const { tech } = landscape;
    const relatedPaths = await generateRelatedPaths(tech);

    const metadata = `

<!-- UNIVERSAL_CONTEXT_ENGINEERING_METADATA
Landscape: ${landscape.name} (${landscape.type})
Tech_Stack: ${tech.language}${tech.framework ? ` + ${tech.framework}` : ""}${tech.buildSystem ? ` (${tech.buildSystem})` : ""}
Tool: ${toolName}
Context: ${landscape.context}
Navigation_Paths:
${relatedPaths.map((path) => `- ${path.type}: ${path.description} (${path.pattern})`).join("\n")}
Context_Signals:
- Information_Density: ${output.content ? "high" : "low"}
- Exploration_Depth: surface
- Tech_Context: ${tech.framework || tech.language}
- Build_System: ${tech.buildSystem || "unknown"}
Expert_Guidance:
${generateExpertGuidance(landscape, tech)}
-->`;

    return metadata;
  };

  // Generate tech-stack specific related paths + SDK file discovery
  const generateRelatedPaths = async (tech) => {
    const paths = [];

    // Static patterns (existing logic)
    if (tech.language === "java") {
      paths.push(
        {
          type: "Source",
          description: "Main Java source code",
          pattern: "src/main/java/**/*.java",
        },
        {
          type: "Resources",
          description: "Application resources",
          pattern: "src/main/resources/**/*",
        },
        {
          type: "Tests",
          description: "Unit tests",
          pattern: "src/test/java/**/*.java",
        },
        {
          type: "Config",
          description: "Spring Boot config",
          pattern: "application*.yml",
        },
      );
    } else if (tech.language === "go") {
      paths.push(
        {
          type: "Main",
          description: "Application entry points",
          pattern: "cmd/**/*.go",
        },
        {
          type: "Internal",
          description: "Internal packages",
          pattern: "internal/**/*.go",
        },
        { type: "Pkg", description: "Public packages", pattern: "pkg/**/*.go" },
        { type: "Tests", description: "Go tests", pattern: "**/*_test.go" },
      );
    } else if (
      tech.language === "javascript" ||
      tech.language === "typescript"
    ) {
      paths.push(
        {
          type: "Source",
          description: "Application source",
          pattern: "src/**/*.{js,ts,jsx,tsx}",
        },
        {
          type: "Components",
          description: "UI components",
          pattern: "components/**/*.{js,ts,jsx,tsx}",
        },
        {
          type: "Pages",
          description: "Page components",
          pattern: "pages/**/*.{js,ts,jsx,tsx}",
        },
        {
          type: "Config",
          description: "Build config",
          pattern: "*.config.{js,ts}",
        },
      );
    }

    // Enhanced with SDK file discovery
    try {
      const discoveredFiles = await client.find.files({
        query: {
          query: `*.${tech.language === "javascript" || tech.language === "typescript" ? "{js,ts,jsx,tsx}" : tech.language}`,
        },
      });

      if (discoveredFiles?.length > 0) {
        paths.push({
          type: "Discovered",
          description: `Found ${discoveredFiles.length} ${tech.language} files`,
          pattern: `${tech.language} files in project`,
          count: discoveredFiles.length,
        });
      }
    } catch {}

    return paths;
  };

  // Generate expert guidance based on tech stack
  const generateExpertGuidance = (landscape, tech) => {
    if (tech.language === "java" && tech.framework === "spring-boot") {
      return `- Spring Boot: Check application.yml, @Controller, @Service, @Repository patterns
- Maven/Gradle: Look for dependencies in pom.xml/build.gradle
- Architecture: Follow src/main/java package structure
- Testing: Locate @Test classes in src/test/java`;
    }

    if (tech.language === "go") {
      return `- Go Modules: Check go.mod for dependencies
- Project Structure: cmd/ for binaries, pkg/ for libraries, internal/ for private code
- ${tech.framework || "Standard"}: Look for HTTP handlers and middleware
- Testing: Find *_test.go files with TestXxx functions`;
    }

    if (tech.language === "javascript" || tech.language === "typescript") {
      return `- ${tech.framework || "JS"}: Check package.json for dependencies and scripts
- Build System: Look for webpack, vite, or next.config files
- Components: Explore src/components or pages/ directory structure
- State Management: Look for Redux, Context, or state management patterns`;
    }

    return `- Generic: Explore related files in ${landscape.type} category
- Build: Check for build configuration files
- Dependencies: Look for package management files
- Testing: Search for test files and directories`;
  };

  // Security patterns (enhanced for all tech stacks)
  const BLOCKED_PATTERNS = [
    ".env",
    "secret",
    "private",
    "password",
    "token",
    "key",
    "credential",
    "application-prod.yml",
    "prod.properties",
    ".pem",
    ".p12",
    ".keystore",
    "id_rsa",
    "id_ed25519",
    ".ssh/",
    "secrets.yml",
    "vault.yml",
  ];

  const isSensitiveFile = (filePath) => {
    if (!filePath) return false;
    const path = filePath.toLowerCase();
    return BLOCKED_PATTERNS.some((pattern) => path.includes(pattern));
  };

  // Notification system (unchanged)
  const extractSummary = (text) => {
    if (!text) return null;
    const lines = text.split(/\r?\n/).filter((l) => l.trim());
    if (!lines.length) return null;

    for (let i = Math.max(0, lines.length - 3); i < lines.length; i++) {
      const match = lines[i].match(
        /^(?:[*\-]\s*)?(?:summary|Summary):\s*(.+)$/i,
      );
      if (match && match[1].trim().length > 2) {
        return match[1].trim().slice(0, 100);
      }
    }
    return lines[lines.length - 1].slice(0, 80);
  };

  // Event throttling (unchanged)
  let lastMessage = { text: null };
  let lastEventTime = 0;
  let processedEvents = new Set();

  return {
    // Enhanced security hook with tech-stack awareness
    "tool.execute.before": async (input) => {
      if (input.tool === "read" && isSensitiveFile(input.args?.filePath)) {
        await client.app.log({
          body: {
            service: "universal-context-engineering",
            level: "warn",
            message: `🔒 Security: Blocked read of sensitive file: ${input.args.filePath}`,
          },
        });
        throw new Error("Blocked: Attempted to read sensitive file");
      }
    },

    // Universal context engineering hook
    "tool.execute.after": async (input, output) => {
      if (output.success === false) return;

      const enhanceableTools = [
        "read",
        "list",
        "glob",
        "grep",
        "find",
        "search",
      ];
      if (!enhanceableTools.includes(input.tool)) return;

      try {
        // Session-aware context
        let sessionContext = "";
        try {
          const currentSession = await client.session.current();
          if (currentSession?.title) {
            sessionContext = currentSession.title
              .toLowerCase()
              .includes("debug")
              ? "debug"
              : currentSession.title.toLowerCase().includes("test")
                ? "test"
                : currentSession.title.toLowerCase().includes("refactor")
                  ? "refactor"
                  : "";
          }
        } catch {}

        // Extract filePath from output content
        let filePath = "";

        if (output.title && typeof output.title === "string") {
          filePath = output.title;
        } else if (output.content && typeof output.content === "string") {
          const pathMatches = output.content.match(
            /\/[a-zA-Z0-9._\-\/]+\.(java|go|js|ts|jsx|tsx|md|yml|yaml|json|xml|toml|gradle|properties)/,
          );
          if (pathMatches) {
            filePath = pathMatches[0];
          }
        }

        // For list tool, check if output has path info
        if (input.tool === "list" && output.content) {
          const pathMatch = output.content.match(/^([\/\w\-._]+)\/$/m);
          if (pathMatch) {
            filePath = pathMatch[1];
          }
        }

        const landscape = detectInformationLandscape(filePath);
        const metadata = await generateNavigationMetadata(
          input.tool,
          landscape,
          output,
        );

        // Enhanced strategic logging
        if (filePath) {
          await client.app.log({
            body: {
              service: "universal-context-engineering",
              level: "info",
              message: `🌍 Landscape: ${landscape.name} (${landscape.tech.language}${landscape.tech.framework ? `+${landscape.tech.framework}` : ""}) for ${filePath.split("/").pop()}`,
            },
          });
        }

        await client.app.log({
          body: {
            service: "universal-context-engineering",
            level: "info",
            message: `📍 Context: ${landscape.context} | Tech: ${landscape.tech.language}${landscape.tech.buildSystem ? ` (${landscape.tech.buildSystem})` : ""} | Session: ${sessionContext || "general"} | Density: ${output.content ? "high" : "low"}`,
          },
        });

        await client.app.log({
          body: {
            service: "universal-context-engineering",
            level: "info",
            message: `✨ Enhanced '${input.tool}' with ${landscape.name} context + ${landscape.tech.framework || landscape.tech.language} expertise`,
          },
        });

        // Smart toast guidance for complex frameworks
        if (landscape.tech.framework === "spring-boot") {
          await client.tui.showToast({
            body: {
              message:
                "Spring Boot detected - try searching @Controller or @Service",
              variant: "info",
            },
          });
        } else if (landscape.tech.framework === "nextjs") {
          await client.tui.showToast({
            body: {
              message: "Next.js detected - check pages/ and components/",
              variant: "info",
            },
          });
        } else if (
          landscape.tech.framework === "gin" ||
          landscape.tech.framework === "fiber"
        ) {
          await client.tui.showToast({
            body: {
              message: `${landscape.tech.framework} detected - look for handlers and middleware`,
              variant: "info",
            },
          });
        }

        // Append metadata to output
        if (output.content && typeof output.content === "string") {
          output.content += metadata;
        }
      } catch (error) {
        await client.app.log({
          body: {
            service: "universal-context-engineering",
            level: "error",
            message: `❌ Universal context engineering failed for ${input.tool}: ${error.message}`,
          },
        });
      }
    },

    // Event handling (unchanged)
    event: async ({ event }) => {
      const now = Date.now();

      if (
        event.type === "message.part.updated" &&
        event.properties?.part?.type === "text"
      ) {
        if (now - lastEventTime > 5000) {
          lastMessage.text = event.properties.part.text;
          lastEventTime = now;
        }
        return;
      }

      if (event.type === "session.idle") {
        const eventId = `${event.type}-${now}`;
        if (processedEvents.has(eventId)) return;
        processedEvents.add(eventId);

        const summary = extractSummary(lastMessage.text) || "Session completed";
        await client.app.log({
          body: {
            service: "universal-context-engineering",
            level: "info",
            message: `🎯 Session completed: ${summary}`,
          },
        });

        if (processedEvents.size > 10) {
          processedEvents.clear();
        }
      }
    },
  };
};
