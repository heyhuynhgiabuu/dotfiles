# Advanced Reasoning Protocol

## Purpose
This protocol enhances agent reasoning capabilities for complex queries by introducing structured hypothesis generation, validation, and synthesis. It enables agents to think more deeply, explore multiple angles, and provide confident, evidence-based responses.

## Guidelines

### 1. Hypothesis Generation
- For complex or ambiguous queries, generate 2-3 hypotheses to explore different interpretations or solutions.
- Base hypotheses on available context, user intent, and domain knowledge.
- Clearly state each hypothesis for transparency.

### 2. Validation with Tools
- Use available tools (e.g., webfetch for web research, grep for code search, Serena 'think' tools for reflection) to validate each hypothesis.
- Prioritize empirical evidence over assumptions.
- Document findings from each validation step.

### 3. Synthesis and Confidence Scoring
- Synthesize validated findings into actionable insights.
- Assign confidence scores (e.g., High/Medium/Low) based on evidence strength.
- Provide recommendations with rationale and potential alternatives.

### 4. Error Handling and Iteration
- If a hypothesis fails validation, iterate by refining or generating new ones.
- Escalate to user clarification if ambiguity persists.
- Log reasoning process for future improvement.

## Integration with Other Protocols
- Combine with Context Management Protocol for maintaining reasoning state.
- Use Event Schema for logging hypothesis validation events.
- Reference in agent prompts (e.g., beta-prompt.md) for consistent application.

## Example Workflow
1. **Query**: "Optimize database performance for high-traffic app."
2. **Hypotheses**:
   - Indexing issues.
   - Query optimization needed.
   - Hardware scaling required.
3. **Validation**: Use grep to search code for queries, webfetch for best practices.
4. **Synthesis**: Recommend indexing with High confidence, based on evidence.

## Benefits
- Improved decision quality for complex tasks.
- Reduced errors through evidence-based reasoning.
- Enhanced user trust via transparent confidence scores.

## Manual Verification Checklist
- [ ] Hypotheses are clearly stated and relevant.
- [ ] Tools are used effectively for validation.
- [ ] Confidence scores are evidence-based.
- [ ] Synthesis provides actionable insights.

## Context Rot Integration

This protocol integrates with Context Rot principles for optimized reasoning processes. For detailed Context Rot implementation, see `context-rot-protocol.md`.

### Key Integration Points
- **Context-Aware Hypothesis Generation**: Generate hypotheses based on context length and structure
- **Context Rot-Aware Validation**: Use optimized validation strategies for different context sizes
- **Dynamic Context Management**: Apply context optimization during reasoning processes
- **Performance-Based Reasoning**: Adjust reasoning complexity based on context constraints

### Reference Implementation
See `context-rot-protocol.md` for complete context optimization strategies and reasoning enhancement techniques.