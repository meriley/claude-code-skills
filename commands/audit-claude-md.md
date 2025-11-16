# CLAUDE.md Audit and Improvement Tool

Perform a comprehensive audit of the CLAUDE.md file in the current directory and suggest improvements based on best practices for agentic coding with Claude Code.

## Instructions for Claude:

<audit_process>
1. **Read and analyze the current CLAUDE.md file**
   - Use file reading tools to examine the existing CLAUDE.md
   - If no CLAUDE.md exists, note this for creation recommendation

2. **Evaluate against best practices**
   Check for the following essential elements and rate their quality:
   
   <evaluation_criteria>
   - **Bash Commands Section**: Are common commands documented with clear descriptions?
   - **Core Files & Functions**: Are key project files and utilities listed?
   - **Code Style Guidelines**: Are coding standards explicitly stated?
   - **Testing Instructions**: Are test commands and procedures documented?
   - **Repository Etiquette**: Are git workflows (branching, merging) defined?
   - **Developer Environment**: Is setup information (compilers, tools) included?
   - **Project-Specific Behaviors**: Are quirks, warnings, or unexpected behaviors noted?
   - **Conciseness**: Is the content brief and scannable (not overly verbose)?
   - **Human Readability**: Is it written for both humans and Claude to understand?
   - **Emphasis Usage**: Are critical instructions marked with "IMPORTANT" or "YOU MUST"?
   </evaluation_criteria>

3. **Generate improvement recommendations**
   For each area, provide:
   - Current state assessment
   - Specific improvement suggestions
   - Example content when helpful

4. **Create an improved version**
   Generate a complete, optimized CLAUDE.md incorporating all improvements
</audit_process>

<output_format>
Structure your response as follows:

## CLAUDE.md Audit Report

### Current State Analysis
[Detailed analysis of existing file or note if missing]

### Improvement Recommendations
[Specific, actionable recommendations organized by category]

### Optimized CLAUDE.md
```markdown
[Complete improved version of CLAUDE.md]
```

### Implementation Steps
[Clear steps to apply the improvements]
</output_format>

<best_practices_reminders>
Remember these Claude 4 and Claude Code best practices:
- Be explicit with instructions
- Use clear formatting and structure
- Include practical examples
- Keep content concise but comprehensive
- Use emphasis ("IMPORTANT", "YOU MUST") sparingly but effectively
- Focus on what TO DO rather than what NOT to do
- Ensure all commands and paths are accurate
- Make the file useful for both onboarding and daily reference
</best_practices_reminders>

When analyzing the CLAUDE.md, think hard about how to make it an effective tool for agentic coding that helps Claude understand the project context and work more efficiently.

$ARGUMENTS