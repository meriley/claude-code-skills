---
allowed-tools: Bash(find:*, ls:*), Read, Grep, Glob, Task
argument-hint: [create|verify|improve]
description: Generate or audit complete Diátaxis documentation
---

# Documentation Audit: Diátaxis Framework

You are performing a comprehensive documentation audit following the Diátaxis framework (Tutorial, How-To, Reference, Explanation).

## Step 1: Determine Audit Mode

The user may have specified a mode: `create`, `verify`, or `improve`.

- **create**: Generate missing documentation following Diátaxis patterns
- **verify**: Audit existing documentation for accuracy and completeness
- **improve**: Suggest improvements to existing documentation

If no argument provided, default to `verify`.

## Step 2: Discover Documentation Files

Execute these commands to find all documentation:

```bash
!find . -type f -name "*.md" ! -path "./node_modules/*" ! -path "./.git/*" ! -path "./vendor/*" ! -path "./.venv/*" | sort
!ls -1 docs/ 2>/dev/null || echo "No docs/ directory"
!ls -1 README.md CONTRIBUTING.md CHANGELOG.md 2>/dev/null
```

## Step 3: Discover Source Code Files

Execute these commands to find source files for API verification:

```bash
!find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.go" -o -name "*.py" \) ! -path "./node_modules/*" ! -path "./.git/*" ! -path "./vendor/*" ! -path "./.venv/*" ! -path "*_test.*" ! -path "*.spec.*" ! -path "*.test.*" | head -50
```

## Step 4: Categorize Documentation by Diátaxis Type

Read each markdown file and categorize it:

**Tutorial** (Learning-oriented):
- Characteristics: Step-by-step, hands-on learning, "how to get started"
- Filenames often: `tutorial.md`, `getting-started.md`, `quickstart.md`, `first-steps.md`
- Content: Concrete steps, working examples, success criteria

**How-To Guide** (Task-oriented):
- Characteristics: Problem-solving, specific goals, "how to achieve X"
- Filenames often: `how-to-*.md`, `guide-*.md`, `migration.md`, `cookbook.md`
- Content: Steps to solve a problem, practical guidance

**Reference** (Information-oriented):
- Characteristics: Technical descriptions, API docs, "what is available"
- Filenames often: `api.md`, `reference.md`, `cli.md`, `configuration.md`, `API_REFERENCE.md`
- Content: Structured information, parameters, return values, complete coverage

**Explanation** (Understanding-oriented):
- Characteristics: Clarification, background, "why things work this way"
- Filenames often: `architecture.md`, `design.md`, `concepts.md`, `background.md`
- Content: Concepts, design decisions, alternatives, trade-offs

## Step 5: Create Documentation Matrix

Create a matrix showing what exists and what's missing:

```
| Type        | Exists | Files | Coverage | Quality Score |
|-------------|--------|-------|----------|---------------|
| Tutorial    | ✅/❌   | []    | 0-100%   | A/B/C/D/F    |
| How-To      | ✅/❌   | []    | 0-100%   | A/B/C/D/F    |
| Reference   | ✅/❌   | []    | 0-100%   | A/B/C/D/F    |
| Explanation | ✅/❌   | []    | 0-100%   | A/B/C/D/F    |
```

## Step 6: Invoke Technical Documentation Expert Agent

Use the Task tool with `subagent_type=technical-documentation-expert`:

### For "verify" Mode:

```
Task(
  subagent_type: "technical-documentation-expert",
  description: "Audit documentation accuracy",
  prompt: "Perform a comprehensive documentation verification audit with ZERO TOLERANCE for fabrication.

  Documentation files found:
  [list all .md files]

  Source code files available:
  [list all source files for verification]

  For EACH documentation file, verify:

  P0 - CRITICAL (Must Fix):
  1. Fabricated APIs: Every API/method/function mentioned MUST exist in source code
  2. Wrong Signatures: Parameters and return types MUST match source exactly
  3. Invalid Examples: All code examples MUST be syntactically valid and runnable
  4. Unverified Performance Claims: Any claim like '10x faster' MUST have benchmark proof

  P1 - HIGH (Should Fix):
  1. Missing Source References: Each API should link to source file:line
  2. Incomplete Coverage: All public APIs should be documented
  3. Marketing Language: Flag phrases like 'blazing fast', 'enterprise-grade', 'revolutionary'
  4. Decorative Emojis: Flag unnecessary emojis that don't aid comprehension
  5. Missing Error Documentation: Possible errors/exceptions should be documented

  P2 - MEDIUM (Nice to Have):
  1. Structural Issues: Missing sections, inconsistent formatting
  2. Outdated Examples: Examples using deprecated patterns
  3. Missing Cross-References: Related docs not linked
  4. Redundancy: Same information in multiple places

  For each documentation file, provide:
  1. **File**: Path to file
  2. **Diátaxis Type**: Tutorial/How-To/Reference/Explanation
  3. **Issues Found**: Grouped by P0/P1/P2 with line numbers
  4. **Verification Status**: For each API mentioned, confirm existence in source
  5. **Quality Score**: A (excellent) / B (good) / C (needs work) / D (major issues) / F (fabrication detected)

  Generate DOCUMENTATION AUDIT REPORT:

  ## Executive Summary
  - Total docs files: X
  - Files with P0 issues: X (BLOCK MERGE)
  - Files with P1 issues: X (SHOULD FIX)
  - Files with P2 issues: X (NICE TO HAVE)
  - Overall Documentation Quality: A/B/C/D/F

  ## Diátaxis Coverage Matrix
  [Show completeness by type]

  ## P0 Issues - CRITICAL (MUST FIX)
  [List all fabricated APIs, wrong signatures, invalid examples, unverified claims]

  ## P1 Issues - HIGH (SHOULD FIX)
  [List all missing references, incomplete coverage, marketing language, missing errors]

  ## P2 Issues - MEDIUM (NICE TO HAVE)
  [List all structural issues, outdated examples, missing links]

  ## Recommendations
  [Specific actions to improve documentation quality]"
)
```

### For "create" Mode:

```
Task(
  subagent_type: "technical-documentation-expert",
  description: "Generate missing documentation",
  prompt: "Analyze the codebase and generate missing documentation following Diátaxis framework.

  Source code files available:
  [list all source files]

  Existing documentation:
  [list all .md files]

  Identify gaps in documentation coverage:

  1. **Missing Tutorial**: Is there a getting-started guide?
  2. **Missing How-To Guides**: Are common tasks documented?
  3. **Missing Reference**: Are all public APIs documented?
  4. **Missing Explanation**: Are architectural decisions documented?

  For EACH gap identified:

  1. Determine Diátaxis type needed
  2. Analyze source code to extract accurate information
  3. Generate documentation using appropriate skill:
     - Tutorial → Invoke `tutorial-writer` skill
     - How-To → Invoke `migration-guide-writer` skill (or create custom how-to)
     - Reference → Invoke `api-doc-writer` skill
     - Explanation → Create architecture/design doc

  CRITICAL REQUIREMENTS:
  - ZERO FABRICATION: Every API must be verified in source
  - NO MARKETING LANGUAGE: Technical writing only
  - WORKING EXAMPLES: All code must be tested
  - ACCURATE SIGNATURES: Match source exactly

  Generate DOCUMENTATION CREATION PLAN:

  ## Missing Documentation Identified
  [List gaps by Diátaxis type]

  ## Recommended Documentation to Create
  1. [Type] [Filename] - [Purpose] - [Skill to use]
  2. ...

  ## Implementation Order
  [Prioritized list: Reference → Tutorial → How-To → Explanation]

  Ask user which documentation they want to create first."
)
```

### For "improve" Mode:

```
Task(
  subagent_type: "technical-documentation-expert",
  description: "Suggest documentation improvements",
  prompt: "Analyze existing documentation and suggest improvements.

  Documentation files:
  [list all .md files]

  Source code files:
  [list all source files]

  For EACH documentation file:

  1. Verify Diátaxis classification (is it correctly categorized?)
  2. Check adherence to Diátaxis pattern for that type
  3. Verify all APIs against source
  4. Suggest structural improvements
  5. Identify missing cross-references
  6. Check for outdated patterns

  Generate DOCUMENTATION IMPROVEMENT PLAN:

  ## Current State Assessment
  [Quality scores by file]

  ## Misclassified Documentation
  [Files that don't match their Diátaxis type]

  ## Improvement Recommendations by File
  1. **File**: [path]
     - Current Type: [type]
     - Issues: [list]
     - Suggested Changes: [specific edits]
     - Priority: P0/P1/P2

  ## Quick Wins (Easy improvements with high impact)
  [List low-effort, high-value changes]

  ## Long-term Improvements
  [List restructuring or major rewrites needed]"
)
```

## Step 7: Generate Output

After the agent completes, provide:

### For "verify" Mode:

1. **Documentation Audit Report** (from agent)
2. **Action Items**:
   - If P0 issues: "BLOCK: Fix fabricated APIs and invalid examples before proceeding"
   - If P1 issues: "RECOMMENDED: Address incomplete coverage and marketing language"
   - If P2 issues: "OPTIONAL: Consider structural improvements"
   - If no issues: "Documentation passes verification ✅"

### For "create" Mode:

1. **Documentation Creation Plan** (from agent)
2. **Next Steps**: "Which documentation would you like me to create first?"
3. Wait for user selection, then invoke appropriate skill

### For "improve" Mode:

1. **Documentation Improvement Plan** (from agent)
2. **Next Steps**: "Would you like me to implement any of these improvements?"
3. Wait for user approval before making changes

## Notes

- This command does NOT modify files in verify/improve modes without approval
- All API verifications are performed against actual source code
- Zero tolerance for fabricated content
- Follows technical-documentation-expert standards
- Can invoke sub-skills: `api-doc-writer`, `tutorial-writer`, `migration-guide-writer`
