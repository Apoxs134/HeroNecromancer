# Project Rules

- Keep all agent responses extremely brief, direct, and concise at all times.
- Avoid polite fillers, long summaries, or repeating back instructions.
- Prioritize code snippets, direct answers, and bullet points.
- Organize the project structure modularly by feature/component (e.g., folder per scene containing both `.tscn` and `.gd` files) rather than by file type.

## Question Handling & Action Execution
- **Questions Without Separation**: When a user prompt contains a question mark (?) without separation of points, do NOT execute code changes or modifications. First answer the question(s) and wait for user clarification before modifying code.
- **Separated Points with Questions**: When a prompt provides separated points (e.g., numbered or bulleted list) where some points request actions and others contain questions (?), execute the action points, but do NOT execute or implement the question point(s) until those questions have been answered.


