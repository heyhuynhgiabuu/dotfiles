# Context Compression Guidance

What it does:
- Provides rules and an example strategy for automatic context compression.

Usage (example):
- If the accumulated context token count >= auto_compress_threshold (1500), compress history using:
  1. Summarize earlier messages to a short JSON summary
  2. Store compressed result in persistent store (or file)
  3. Retain last N messages uncompressed for relevance

Key info:
- Token budgets: SCS/AWS = 2000; auto_compress_threshold = 1500
- compressed-context-sample.json in templates/ demonstrates format
- Ensure summaries do not contain secrets

That's it:
- Implement compression as a reversible summarization operation and keep original logs off-line if required by policy.