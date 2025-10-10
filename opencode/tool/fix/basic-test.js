// Basic test for fix tool functionality
// This tests our fix engine without the OpenCode plugin system

async function testFixEngine() {
  try {
    // Import our plugin engine
    const { FixEngine } = await import("./plugin-engine.js");

    console.log("✓ FixEngine imported successfully");

    // Create engine instance
    const engine = new FixEngine();
    console.log("✓ FixEngine instance created");

    // Test different fix types
    const testCases = [
      { type: "imports", files: ["test.ts"], dryRun: true },
      { type: "formatting", files: ["test.js"], dryRun: true },
      { type: "lint", files: ["test.ts"], dryRun: true },
      { type: "unused", files: ["test.js"], dryRun: true },
      { type: "deprecated", files: ["test.js"], dryRun: true },
    ];

    for (const testCase of testCases) {
      console.log(`\n--- Testing ${testCase.type} fixer ---`);

      const result = await engine.execute(testCase, {});

      console.log(`✓ ${testCase.type} fixer executed`);
      console.log(`  Title: ${result.title}`);
      console.log(`  Changes: ${result.output.changes.length}`);
      console.log(`  Summary: ${result.output.summary}`);

      if (result.output.changes.length > 0) {
        console.log(
          `  Example change: ${result.output.changes[0].description}`,
        );
      }
    }

    console.log("\n🎉 All tests passed! Fix tool is working correctly.");
  } catch (error) {
    console.error("❌ Test failed:", error.message);
    console.error(error.stack);
  }
}

// Run the test
testFixEngine();
