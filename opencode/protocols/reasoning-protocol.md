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

## Context Rot Integration for Advanced Reasoning

### Context-Aware Hypothesis Generation

When generating hypotheses, consider Context Rot principles:

#### 1. Context Length Impact
- **Short Context (<500 tokens)**: Generate detailed, comprehensive hypotheses
- **Medium Context (500-2000 tokens)**: Focus on high-quality, focused hypotheses
- **Long Context (>2000 tokens)**: Prioritize essential hypotheses, avoid over-analysis

#### 2. Information Structure Considerations
- **Critical Information First**: Place most important hypotheses at the beginning
- **Logical Flow Disruption**: Break complex reasoning into digestible chunks
- **Relevance Filtering**: Focus on hypotheses directly related to the core problem
- **Semantic Similarity Management**: Avoid redundant or overlapping hypotheses

### Context Rot-Aware Validation Strategy

#### Validation Efficiency
- **Relevance-Based Validation**: Prioritize validation of hypotheses with highest relevance scores
- **Context Length Optimization**: Use compressed context for validation when appropriate
- **Progressive Validation**: Validate simpler hypotheses first, complex ones later
- **Early Termination**: Stop validation when sufficient evidence is gathered

#### Performance-Based Validation
- **Quality Thresholds**: Set different validation standards based on context length
- **Adaptive Rigor**: Increase validation depth for critical hypotheses
- **Resource-Aware Validation**: Adjust validation complexity based on available context

### Context Optimization During Reasoning

#### Dynamic Context Management
- **Compression During Reasoning**: Apply relevance filtering as hypotheses are generated
- **Information Structure Optimization**: Reorganize context based on reasoning progress
- **Staleness Prevention**: Remove outdated reasoning branches and assumptions
- **Critical Path Preservation**: Ensure essential reasoning context remains accessible

#### Reasoning Quality Gates
- **Context Quality Checks**: Validate context quality before major reasoning steps
- **Performance Monitoring**: Track reasoning effectiveness as context changes
- **Optimization Triggers**: Automatically optimize context when reasoning quality drops

### Context Rot Mitigation Strategies

#### 1. Hypothesis Prioritization
- **Relevance Scoring**: Score hypotheses by relevance to core objective
- **Context Efficiency**: Prioritize hypotheses that require less context to validate
- **Information Density**: Focus on hypotheses with high information value per token

#### 2. Validation Optimization
- **Targeted Validation**: Use specific context chunks for hypothesis validation
- **Context Chunking**: Break large contexts into focused validation units
- **Progressive Refinement**: Start with broad validation, refine with focused context

#### 3. Reasoning Structure
- **Modular Reasoning**: Break complex reasoning into independent modules
- **Context Boundaries**: Use clear separators between reasoning phases
- **Essential Information Focus**: Keep critical information prominent throughout reasoning

### Implementation Guidelines

#### Context Length Thresholds for Reasoning
- **<500 tokens**: Full reasoning with comprehensive hypothesis exploration
- **500-2000 tokens**: Focused reasoning with optimized hypothesis selection
- **>2000 tokens**: Minimal reasoning with essential hypothesis validation only

#### Quality Metrics Integration
- **Relevance Score Tracking**: Monitor hypothesis relevance throughout reasoning
- **Context Efficiency Measurement**: Track tokens used per reasoning step
- **Performance Correlation**: Link reasoning quality to context optimization

#### Continuous Optimization
- **Feedback Integration**: Use reasoning outcomes to improve context optimization
- **Adaptive Strategies**: Adjust reasoning approach based on context performance
- **Learning Loop**: Incorporate successful patterns into future reasoning processes

This integration ensures advanced reasoning processes are optimized for Context Rot principles, maximizing reasoning effectiveness while minimizing context-related performance degradation.