# VectorCode Plugin - Manual Testing Checklist

## 🧪 Comprehensive Testing Guide

This checklist ensures the plugin works correctly across all functionality and edge cases.

## ✅ Pre-Testing Setup

### Environment Verification

- [ ] **Node.js Version Check**

  ```bash
  node --version  # Should be >=18.0.0
  ```

- [ ] **VectorCode CLI Installation**

  ```bash
  vectorcode --version  # Should be >=0.7.0
  which vectorcode      # Should return path
  ```

- [ ] **OpenCode Installation**

  ```bash
  opencode --version  # Should be installed and working
  ```

- [ ] **Plugin Compilation**
  ```bash
  cd vectorcode
  npm install
  npm run build
  ls dist/  # Should contain index.js and index.d.ts
  ```

### Project Setup

- [ ] **VectorCode Project Initialization**

  ```bash
  cd /path/to/test/project
  vectorcode init
  vectorcode ls  # Should work without errors
  ```

- [ ] **Plugin Installation**

  ```bash
  # Copy plugin to OpenCode plugins directory
  mkdir -p ~/.opencode/plugins
  cp vectorcode encode-vectorcode-plugin ~/.opencode/plugin
  # Verify files are in place
  ls ~/.opencode/plugins/vectorcode/
  ```

## 🚀 Core Functionality Tests

### Test 1: Get VectorCode Context

**Command**: `/getVectorCodeContext`

**Expected Outcome**: ✅ Success

- [ ] **Basic Execution**
  - Command executes without errors
  - Returns JSON response with `"success": true`
  - Contains `projectRoot`, `prompts`, `collections`, `timestamp`

- [ ] **Response Structure Validation**

  ```json
  {
    "success": true,
    "data": {
      "projectRoot": "/path/to/project",
      "prompts": "...",
      "collections": [...],
      "timestamp": "2025-01-05T..."
    },
    "command": "getVectorCodeContext"
  }
  ```

- [ ] **Edge Cases**
  - Works in empty project (no indexed files)
  - Works in project with existing collections
  - Handles missing VectorCode config gracefully

### Test 2: Query VectorCode - Basic

**Command**: `/queryVectorCode {"query": "function"}`

**Expected Outcome**: ✅ Success or No Results

- [ ] **Basic Query Execution**
  - Command executes without errors
  - Returns JSON response with `"success": true`
  - Contains `query`, `results`, `options`, `projectRoot`, `timestamp`

- [ ] **Response Structure Validation**
  ```json
  {
    "success": true,
    "data": {
      "query": "function",
      "results": [...],
      "options": {...},
      "projectRoot": "/path/to/project",
      "timestamp": "2025-01-05T..."
    },
    "command": "queryVectorCode"
  }
  ```

### Test 3: Query VectorCode - Advanced Options

**Command**: `/queryVectorCode {"query": "typescript", "number": 5, "include": ["path", "document"], "exclude": ["test"]}`

**Expected Outcome**: ✅ Success

- [ ] **Options Processing**
  - Number parameter respected (max 5 results)
  - Include parameter applied correctly
  - Exclude parameter filters results
  - All options reflected in response

- [ ] **Response Validation**
  - Results count ≤ specified number
  - Each result contains requested fields
  - No excluded files in results

### Test 4: Index VectorCode - Single File

**Command**: `/indexVectorCode {"filePaths": ["README.md"]}`

**Expected Outcome**: ✅ Success

- [ ] **Single File Indexing**
  - Command executes without errors
  - File is successfully indexed
  - Response confirms indexing completion

- [ ] **Response Structure**
  ```json
  {
    "success": true,
    "data": {
      "indexedPaths": ["README.md"],
      "options": {...},
      "projectRoot": "/path/to/project",
      "result": "...",
      "timestamp": "2025-01-05T..."
    },
    "command": "indexVectorCode"
  }
  ```

### Test 5: Index VectorCode - Multiple Files/Directories

**Command**: `/indexVectorCode {"filePaths": ["src/", "docs/"], "recursive": true}`

**Expected Outcome**: ✅ Success

- [ ] **Directory Indexing**
  - Multiple paths processed correctly
  - Recursive option applied
  - All files in directories indexed

- [ ] **Verification**
  ```bash
  vectorcode ls  # Should show new collections
  ```

## ❌ Error Handling Tests

### Test 6: Empty Query Error

**Command**: `/queryVectorCode {"query": ""}`

**Expected Outcome**: ❌ Error

- [ ] **Error Response**
  - Returns `"success": false`
  - Contains meaningful error message
  - Error: "Query cannot be empty"

### Test 7: Empty File Paths Error

**Command**: `/indexVectorCode {"filePaths": []}`

**Expected Outcome**: ❌ Error

- [ ] **Error Response**
  - Returns `"success": false`
  - Contains meaningful error message
  - Error: "File paths cannot be empty"

### Test 8: Invalid File Path

**Command**: `/indexVectorCode {"filePaths": ["/non/existent/file.txt"]}`

**Expected Outcome**: ❌ Error (handled by VectorCode CLI)

- [ ] **Error Handling**
  - Plugin doesn't crash
  - Returns error response from VectorCode CLI
  - Error message is informative

### Test 9: VectorCode CLI Not Available

**Simulate**: Temporarily rename/remove vectorcode binary

**Command**: Any VectorCode command

**Expected Outcome**: ❌ Error

- [ ] **Graceful Degradation**
  - Error message: "VectorCode CLI not found"
  - Includes installation instructions
  - Plugin doesn't crash OpenCode

## 🔧 Advanced Testing

### Test 10: Project Root Override

**Command**: `/getVectorCodeContext {"projectRoot": "/different/path"}`

**Expected Outcome**: ✅ Success or ❌ Error (if path invalid)

- [ ] **Custom Project Root**
  - Uses specified project root
  - Response reflects correct project root
  - Works with valid paths
  - Errors gracefully with invalid paths

### Test 11: Large Query Results

**Command**: `/queryVectorCode {"query": "the", "number": 100}`

**Expected Outcome**: ✅ Success

- [ ] **Performance**
  - Command completes in reasonable time (<30 seconds)
  - Response is properly formatted
  - Large JSON doesn't break OpenCode display

### Test 12: Special Characters in Query

**Command**: `/queryVectorCode {"query": "function(param) => result"}`

**Expected Outcome**: ✅ Success

- [ ] **Character Handling**
  - Special characters handled correctly
  - No shell injection issues
  - Query processed as expected

## 🔄 Integration Tests

### Test 13: End-to-End Workflow

**Workflow**: Index → Query → Verify

**Steps**:

1. `/indexVectorCode {"filePaths": ["package.json"], "force": true}`
2. `/queryVectorCode {"query": "package.json"}`
3. Verify the indexed file appears in query results

**Expected Outcome**: ✅ Success

- [ ] **Workflow Completion**
  - Indexing succeeds
  - Query finds indexed content
  - Results include the indexed file

### Test 14: Multiple Sessions

**Test**: Run commands across different OpenCode sessions

**Expected Outcome**: ✅ Consistent

- [ ] **Session Independence**
  - Plugin works consistently across sessions
  - No state leakage between sessions
  - Previous indexing persists correctly

## 📊 Performance Tests

### Test 15: Response Time

**Commands**: All basic commands

**Expected Outcome**: ✅ Reasonable Performance

- [ ] **Response Times**
  - getVectorCodeContext: <5 seconds
  - queryVectorCode (small): <10 seconds
  - indexVectorCode (single file): <15 seconds

### Test 16: Resource Usage

**Monitor**: System resources during plugin execution

**Expected Outcome**: ✅ Reasonable Usage

- [ ] **Resource Consumption**
  - No memory leaks
  - CPU usage reasonable
  - No hanging processes

## 🎯 Final Verification

### Test 17: Complete Feature Matrix

| Feature           | Command                           | Status          | Notes |
| ----------------- | --------------------------------- | --------------- | ----- |
| Get Context       | `/getVectorCodeContext`           | [ ] ✅ / [ ] ❌ |       |
| Basic Query       | `/queryVectorCode`                | [ ] ✅ / [ ] ❌ |       |
| Advanced Query    | `/queryVectorCode` (with options) | [ ] ✅ / [ ] ❌ |       |
| Single File Index | `/indexVectorCode`                | [ ] ✅ / [ ] ❌ |       |
| Directory Index   | `/indexVectorCode` (recursive)    | [ ] ✅ / [ ] ❌ |       |
| Error Handling    | Invalid inputs                    | [ ] ✅ / [ ] ❌ |       |
| Cross-Platform    | macOS/Linux                       | [ ] ✅ / [ ] ❌ |       |

### Test 18: Documentation Accuracy

- [ ] **README Examples**
  - All example commands work as documented
  - Example responses match actual output
  - Installation instructions are accurate

- [ ] **Error Messages**
  - Error messages match documentation
  - Troubleshooting guide is helpful
  - All edge cases are documented

## 📝 Test Results Template

```markdown
## Test Results - [Date]

**Environment:**

- OS: [macOS/Linux version]
- Node.js: [version]
- VectorCode: [version]
- OpenCode: [version]

**Test Summary:**

- Total Tests: 18
- Passed: \_\_\_/18
- Failed: \_\_\_/18
- Success Rate: \_\_\_%

**Failed Tests:**
[List any failed tests with details]

**Notes:**
[Any additional observations or recommendations]

**Overall Status:** ✅ PASS / ❌ FAIL / ⚠️ PARTIAL
```

## 🚨 Critical Issues Checklist

If any of these fail, the plugin should not be released:

- [ ] **Plugin Compilation**: Must build without errors
- [ ] **VectorCode CLI Detection**: Must gracefully handle missing CLI
- [ ] **Basic Commands**: All three main commands must work
- [ ] **Error Handling**: Must not crash OpenCode on errors
- [ ] **JSON Responses**: All responses must be valid JSON
- [ ] **Cross-Platform**: Must work on both macOS and Linux

## ✅ Sign-off

**Tester:** **\*\***\_\_\_\_**\*\***  
**Date:** **\*\***\_\_\_\_**\*\***  
**Status:** ✅ APPROVED / ❌ NEEDS WORK  
**Notes:** **\*\***\_\_\_\_**\*\***

