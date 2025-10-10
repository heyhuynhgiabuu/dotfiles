// Test file for fix tool functionality - simple version
// This file contains various issues that the fix tool should detect and fix

// Mixed imports (some used, some unused) - for imports fixer testing
import path from "path";
import { unusedFunction } from "./nonexistent";

// Used imports
const usedVariable = "used";
const usedNumber = 123;

// Unused variables (will be detected by unused fixer)
const unusedVariable1 = "this is not used";
const anotherUnusedVar = 42;

// Formatting issues (intentionally bad spacing and style)
function badlyFormatted() {
  const x = 1;
  const y = 2;
  return x + y;
}

// Unused function (will be detected by unused fixer)
function completelyUnusedFunction() {
  return "never called anywhere";
}

// Used function
function usedFunction() {
  return "this is called";
}

// Some usage to make variables/functions "used"
console.log(usedVariable);
console.log(usedNumber);
console.log(path.join("/", "test"));
console.log(usedFunction());

// Test array with bad formatting
const testArray = [1, 2, 3]; // Bad spacing
