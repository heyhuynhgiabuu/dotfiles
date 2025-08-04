# Best Practices for Using Serena MCP with OpenCode Agents

This document outlines recommended practices for leveraging Serena MCP capabilities within OpenCode agents to enhance code analysis, navigation, and understanding.

## Core Principles

### 1. Always Use Serena for Code Navigation First
Before resorting to direct file reading or grep operations, use Serena's symbol-based tools:
- `serena_find_symbol` for precise location of functions, classes, and variables
- `serena_get_symbols_overview` for understanding file and project structure
- `serena_find_referencing_symbols` for impact analysis and usage patterns

### 2. Preserve Global Protocol Integrity
Agents should reference and extend the global operating protocol rather than replace it:
- Always mention following the Global Development Assistant - Enhanced Operating Protocol
- Maintain core principles like KISS, EmpiricalRigor, and Research-First Methodology
- Use the 13-Step Structured Workflow for complex tasks

### 3. Leverage Contextual Awareness
Use Serena's capabilities to maintain context:
- Track symbol relationships and dependencies
- Understand codebase structure before making changes
- Preserve session continuity through symbol references

## Serena Tool Usage Patterns

### Symbol Analysis Workflow
1. **Identify Targets**: Use `serena_find_symbol` to locate relevant code elements
2. **Understand Context**: Use `serena_get_symbols_overview` to see the broader structure
3. **Analyze Impact**: Use `serena_find_referencing_symbols` to understand dependencies
4. **Verify Changes**: Use search tools to confirm modifications

### Pattern Recognition
- Use `serena_search_for_pattern` for finding common code patterns
- Look for anti-patterns and security vulnerabilities
- Identify similar implementations for consistency

### Code Modification Guidance
- Use symbol-based tools to understand existing code before modifications
- Ensure changes align with existing patterns and architecture
- Verify that modifications don't break existing references

## Agent-Specific Serena Integration

### Security Audit Agent
- Use `serena_find_symbol` to locate authentication and authorization code
- Search for hardcoded secrets with pattern matching
- Analyze data flow through symbol references

### DevOps Deployer Agent
- Locate Dockerfiles and deployment configurations through symbol search
- Understand service relationships and dependencies
- Verify infrastructure code patterns and best practices

### API Reviewer Agent
- Find API endpoints and service methods
- Analyze data flow and error handling patterns
- Check for security and performance anti-patterns

### Documentation Writer Agent
- Locate functions and classes that need documentation
- Understand usage patterns through reference analysis
- Extract example usage from existing code

### Backend Troubleshooter Agent
- Find error handling and logging code
- Trace error propagation through symbol references
- Identify potential failure points in the codebase

### Simple Researcher Agent
- Search for implementation patterns in the codebase
- Find similar solutions to adapt
- Locate relevant examples and references

## Quality Assurance Practices

### Verification Process
1. **Symbol Verification**: Confirm symbol locations and references
2. **Pattern Confirmation**: Verify that identified patterns are correct
3. **Impact Assessment**: Ensure changes don't break existing functionality
4. **Context Preservation**: Maintain awareness of broader codebase implications

### Error Handling
- When Serena tools don't find expected symbols, fall back to direct file analysis
- Document when tools fail and why
- Provide clear explanations when symbol-based analysis isn't possible

## Performance Optimization

### Efficient Tool Usage
- Use specific symbol names rather than broad searches
- Limit search scope to relevant directories when possible
- Combine multiple Serena tools for comprehensive analysis

### Cache Awareness
- Understand that Serena maintains internal caches for performance
- Leverage session continuity for related queries
- Avoid redundant symbol lookups in the same session

## Integration with Global Protocol

### Maintaining Protocol Compliance
- Reference global principles in agent responses
- Follow structured workflows for complex tasks
- Maintain quality standards and verification processes

### Extending vs. Replacing
- Extend global capabilities with specialized knowledge
- Preserve core safety and verification mechanisms
- Enhance rather than override global principles

## Common Patterns and Anti-Patterns

### Recommended Patterns
- Symbol-first analysis approach
- Cross-referencing for impact assessment
- Pattern-based problem solving
- Contextual documentation generation

### Anti-Patterns to Avoid
- Direct file reading without symbol analysis
- Ignoring symbol relationships and dependencies
- Overlooking global protocol requirements
- Failing to verify tool results

## Troubleshooting Serena Integration

### Common Issues
- Symbols not found (check naming, scope, or file indexing)
- Performance slowdowns (limit search scope, use specific queries)
- Incomplete results (verify project indexing status)

### Resolution Strategies
- Fall back to direct file analysis when needed
- Use multiple approaches to verify findings
- Document limitations and workarounds

This documentation should be updated as new patterns and best practices emerge through usage.