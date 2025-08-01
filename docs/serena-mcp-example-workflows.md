# Serena MCP Example Workflows

This document provides practical examples of how OpenCode agents leverage Serena MCP capabilities to enhance their operations.

## Example 1: Security Audit with Symbol Analysis

### Scenario
A developer requests a security audit of a new authentication module.

### Serena-Enhanced Workflow

**Step 1: Symbol Identification**
```
serena_find_symbol(name_path="auth", relative_path="src/auth")
```
Result: Locates `AuthService` class and `authenticate` method

**Step 2: Dependency Mapping**
```
serena_get_symbols_overview(relative_path="src/auth")
```
Result: Shows `AuthService` depends on `UserRepository` and `TokenService`

**Step 3: Impact Analysis**
```
serena_find_referencing_symbols(name_path="AuthService", relative_path="src/auth/service.py")
```
Result: Identifies 12 components that use authentication service

**Step 4: Vulnerability Pattern Search**
```
serena_search_for_pattern(substring_pattern="password.*plaintext", relative_path="src")
```
Result: Finds potential plaintext password handling

**Step 5: Security Review Output**
The agent provides a comprehensive security review that includes:
- Specific locations of authentication code
- Dependencies that might be affected by changes
- Usage patterns across the codebase
- Potential security vulnerabilities with exact locations

### Benefits Over Traditional Approach
- Precise identification of security-sensitive code
- Complete impact analysis before suggesting changes
- Pattern-based vulnerability detection
- Context-aware recommendations

## Example 2: API Performance Review

### Scenario
A developer requests performance optimization for a slow API endpoint.

### Serena-Enhanced Workflow

**Step 1: Endpoint Location**
```
serena_find_symbol(name_path="getUserData", relative_path="src/api")
```
Result: Locates the specific endpoint handler

**Step 2: Code Path Analysis**
```
serena_find_referencing_symbols(name_path="DatabaseService.query", relative_path="src/database/service.py")
```
Result: Shows all database queries used by the endpoint

**Step 3: Performance Anti-Pattern Search**
```
serena_search_for_pattern(substring_pattern=".*forEach.*query", relative_path="src")
```
Result: Identifies potential N+1 query problems

**Step 4: Architecture Overview**
```
serena_get_symbols_overview(relative_path="src/api/user")
```
Result: Shows the complete structure of user-related endpoints

**Step 5: Performance Recommendations**
The agent provides specific performance improvements:
- Exact locations of slow database queries
- N+1 query patterns with file references
- Alternative implementation approaches
- Impact assessment of proposed changes

### Benefits Over Traditional Approach
- Precise identification of performance bottlenecks
- Complete understanding of data flow
- Pattern-based optimization suggestions
- Impact analysis for proposed changes

## Example 3: Documentation Generation

### Scenario
A developer requests documentation for a complex service class.

### Serena-Enhanced Workflow

**Step 1: Class Identification**
```
serena_find_symbol(name_path="PaymentProcessor", relative_path="src/payment")
```
Result: Locates the main service class

**Step 2: Method Discovery**
```
serena_find_symbol(name_path="PaymentProcessor/", depth=1, relative_path="src/payment/service.py")
```
Result: Lists all public methods of the class

**Step 3: Usage Analysis**
```
serena_find_referencing_symbols(name_path="PaymentProcessor.processPayment", relative_path="src/payment/service.py")
```
Result: Shows how the main method is used across the codebase

**Step 4: Example Extraction**
```
serena_search_for_pattern(substring_pattern="new PaymentProcessor.*processPayment", relative_path="src")
```
Result: Finds actual usage examples in the codebase

**Step 5: Documentation Output**
The agent generates comprehensive documentation that includes:
- Clear purpose statement based on code analysis
- Usage examples extracted from real code
- Parameter and return value documentation
- Related methods and dependencies

### Benefits Over Traditional Approach
- Accurate method and parameter information
- Real usage examples from the codebase
- Complete dependency mapping
- Consistent documentation style

## Example 4: Backend Troubleshooting

### Scenario
A developer reports 500 errors after a deployment.

### Serena-Enhanced Workflow

**Step 1: Error Handler Location**
```
serena_find_symbol(name_path="ErrorHandler", relative_path="src")
```
Result: Locates centralized error handling code

**Step 2: Recent Changes Analysis**
```
serena_find_symbol(name_path="UserService", relative_path="src/user")
```
Result: Identifies recently modified user service

**Step 3: Error Propagation Tracking**
```
serena_find_referencing_symbols(name_path="UserService.getUser", relative_path="src/user/service.py")
```
Result: Shows all components that call the user service

**Step 4: Error Pattern Search**
```
serena_search_for_pattern(substring_pattern="500.*UserService", relative_path="src")
```
Result: Finds specific error handling patterns

**Step 5: Troubleshooting Recommendations**
The agent provides targeted troubleshooting steps:
- Exact location of error-prone code
- Usage patterns that trigger the error
- Related components that might be affected
- Specific fix recommendations with code examples

### Benefits Over Traditional Approach
- Precise error source identification
- Complete impact analysis
- Pattern-based root cause analysis
- Targeted fix recommendations

## Example 5: DevOps Configuration Review

### Scenario
A developer requests review of Docker deployment configurations.

### Serena-Enhanced Workflow

**Step 1: Configuration Location**
```
serena_find_symbol(name_path="DockerService", relative_path="deploy")
```
Result: Locates Docker-related configuration code

**Step 2: Dependency Analysis**
```
serena_get_symbols_overview(relative_path="deploy/docker")
```
Result: Shows relationships between Docker services

**Step 3: Security Pattern Search**
```
serena_search_for_pattern(substring_pattern="privileged.*true", relative_path="deploy")
```
Result: Identifies potential security issues in Docker configs

**Step 4: Best Practice Verification**
```
serena_search_for_pattern(substring_pattern="USER.*root", relative_path="deploy")
```
Result: Finds containers running as root user

**Step 5: Configuration Recommendations**
The agent provides specific DevOps improvements:
- Exact locations of security issues
- Best practice violations with file references
- Alternative configuration approaches
- Impact assessment of proposed changes

### Benefits Over Traditional Approach
- Precise identification of configuration issues
- Complete service relationship mapping
- Pattern-based security analysis
- Context-aware recommendations

## Integration Patterns

### Pattern 1: Symbol-First Analysis
Always start with symbol identification before direct file analysis:
1. Use `serena_find_symbol` to locate relevant code
2. Use `serena_get_symbols_overview` to understand context
3. Use `serena_find_referencing_symbols` to assess impact
4. Fall back to direct analysis only when needed

### Pattern 2: Pattern-Based Problem Solving
Use search capabilities to identify common issues:
1. Define patterns for common problems (security, performance, etc.)
2. Search the codebase for these patterns
3. Analyze findings in context
4. Provide targeted solutions

### Pattern 3: Contextual Documentation
Generate documentation based on actual code usage:
1. Locate symbols that need documentation
2. Analyze how they're used in practice
3. Extract real examples from the codebase
4. Generate accurate, contextual documentation

## Best Practice Implementation

### For Agent Developers
- Always reference Serena capabilities in agent prompts
- Design workflows that leverage symbol-based analysis
- Provide fallback mechanisms for direct file analysis
- Maintain awareness of global protocol requirements

### For Agent Users
- Understand that agents use symbol analysis for precision
- Provide specific symbol names when possible
- Expect context-aware recommendations
- Verify suggestions in the context of their codebase

These examples demonstrate how Serena MCP enhances OpenCode agents by providing precise code analysis, contextual understanding, and pattern-based problem solving while maintaining integration with the global development protocol.