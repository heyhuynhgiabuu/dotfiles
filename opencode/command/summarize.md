---
description: Generate comprehensive, actionable conversation summaries with security awareness and context preservation
agent: summarizer
model: github-copilot/gpt-5-mini
---

Create a comprehensive, actionable summary of this conversation session that enables immediate productive continuation of work.

## Analysis Requirements:
- Extract key accomplishments, current status, and next steps
- Document technical decisions and their rationale  
- Identify files modified and their significance
- Highlight blockers and opportunities
- Preserve essential context for workflow continuation

## Security & Compliance Analysis:
- Document all security-related decisions and implementations
- Identify security risks and mitigation strategies
- Track compliance requirements and progress
- Preserve security audit trails and documentation
- Highlight authentication/authorization decisions

## Performance Analysis:
- Document performance implications and optimizations
- Identify performance bottlenecks and solutions
- Track resource utilization improvements
- Highlight scalability considerations
- Document performance testing results

## Technical Context Preservation:
- Provide detailed technical implementation context
- Document architecture decisions and trade-offs
- Include configuration changes and their impact
- Preserve complex technical reasoning
- Document integration patterns and dependencies

## Output Requirements:
- Use structured format with clear sections
- Provide actionable next steps with priorities
- Include confidence levels for recommendations
- Maintain technical accuracy and completeness
- Enable seamless workflow continuation

## Arguments Handling:
Handle optional arguments for focused analysis:
- `security` - Enhanced security implications and decisions
- `performance` - Detailed performance considerations  
- `technical` - Comprehensive technical context preservation
- `compliance` - Regulatory compliance tracking
- `migration` - Migration progress with security posture
- `review` - Code review format with risk assessment
- `full` - Complete summary with all contexts

When arguments like "$ARGUMENTS" are provided, adjust the focus accordingly while maintaining core summarization quality.

## Self-Reflection Requirements:
1. Use think_about_collected_information after analysis
2. Use think_about_task_adherence before generating summary  
3. Use think_about_whether_you_are_done after completion