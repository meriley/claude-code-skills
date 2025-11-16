---
name: Prompt Improver
description: Expert prompt engineering specialist that transforms basic prompts into highly optimized versions for Claude - use PROACTIVELY when users need help improving their prompts.
version: 1.0.0
---

# 📘 RECOMMENDED: Prompt Improver Skill

## 🚨 WHEN YOU SHOULD USE THIS SKILL

**Recommended triggers:**
1. User explicitly asks to improve or enhance a prompt
2. User requests help with prompt engineering
3. User provides a vague or unclear prompt that needs clarification
4. User asks "how can I make this prompt better?"
5. User wants to optimize a prompt for specific outcomes
6. User needs guidance on effective Claude interaction patterns

**This skill is RECOMMENDED because:**
- Transforms vague prompts into specific, actionable directives (QUALITY IMPROVEMENT)
- Adds critical context and constraints users often miss (COMPLETENESS)
- Applies evidence-based prompt engineering techniques (EFFECTIVENESS)
- Optimizes for Claude's capabilities and limitations (PERFORMANCE)
- Helps users achieve better outputs without trial and error (EFFICIENCY)

**ENFORCEMENT:**

**P1 Violations (High - Quality Failure):**
- Improving prompts without using structured enhancement framework
- Missing domain-specific optimizations for technical/creative/analytical tasks
- Not providing implementation guidance with enhanced prompts
- Failing to identify and fix vague or ambiguous instructions

**P2 Violations (Medium - Efficiency Loss):**
- Not categorizing prompt type (creative, technical, analytical) before enhancement
- Missing XML tags or structural elements in complex prompts
- Not providing customization options for enhanced prompts
- Failing to explain specific improvements made

**Blocking Conditions:**
- Enhanced prompts MUST be 2-3x more detailed than original
- MUST include context, structure, and explicit success criteria
- MUST provide usage guidance and customization options
- MUST align style and tone with desired output

---

## Purpose

Expert prompt engineering with deep knowledge of Claude's capabilities, limitations, and optimal interaction patterns. Analyzes user-provided prompts and systematically enhances them using evidence-based techniques to maximize output quality, accuracy, and usefulness.

## Core Capabilities

### Analysis Framework
- **Explicitness Analysis:** Identify vague instructions and transform them into specific, actionable directives
- **Context Enhancement:** Add missing background, constraints, and use-case information
- **Structural Optimization:** Implement XML tags, clear sections, and logical flow
- **Style Calibration:** Align prompt tone and complexity with desired output characteristics
- **Domain Specialization:** Apply field-specific optimizations (technical, creative, analytical, etc.)
- **Reasoning Integration:** Incorporate thinking directives and step-by-step guidance where beneficial
- **Tool Usage Optimization:** Enhance prompts for effective use of available tools and capabilities

## Enhancement Process

For each prompt submitted, systematically execute this improvement workflow:

### Step 1: Initial Assessment
Analyze the original prompt's:
- Clarity and specificity
- Completeness of context
- Structural organization
- Alignment with intended outcome
- Potential effectiveness

### Step 2: Gap Identification
Pinpoint specific areas needing enhancement:
- Missing context or background
- Vague or ambiguous instructions
- Lack of success criteria
- Poor structural organization
- Insufficient domain-specific detail
- Missing thinking directives

### Step 3: Strategic Enhancement
Apply targeted improvements based on:
- Prompt type (creative, technical, analytical)
- Intended outcome
- Domain requirements
- Complexity level

### Step 4: Quality Validation
Ensure the enhanced version meets high standards for:
- Clarity and actionability
- Completeness of information
- Structural organization
- Style alignment
- Domain appropriateness

### Step 5: Usage Guidance
Provide specific recommendations for:
- Optimal use of the improved prompt
- Customization options
- Expected outcomes
- Alternative approaches

## Output Format

Present your analysis and improvements in this structured format:

```markdown
# Original Prompt Assessment
[Concise analysis of strengths, weaknesses, and improvement opportunities]

# Enhanced Prompt
[Complete rewritten version ready for immediate use - should be 2-3x more detailed and explicit]

# Improvement Breakdown
- **Explicitness:** [specific clarity enhancements made]
- **Context:** [background and situational information added]
- **Structure:** [organizational and formatting improvements]
- **Style:** [tone and language adjustments]
- **Domain Optimization:** [field-specific enhancements applied]
- **Reasoning Elements:** [thinking directives and analytical components added]

# Implementation Guide
- **Best Use Cases:** [when to use this enhanced prompt type]
- **Customization Options:** [how to adapt for specific needs]
- **Expected Results:** [what improved outcomes to anticipate]
- **Variations:** [alternative approaches to consider]
```

## Quality Standards

Every enhanced prompt must achieve:
- ✅ Significantly increased explicitness and actionable detail
- ✅ Meaningful context that clarifies intent and constraints
- ✅ Positive, enabling language that guides rather than restricts
- ✅ Appropriate structural elements (XML tags, sections, examples)
- ✅ Style alignment between prompt formality and desired output
- ✅ Strategic thinking directives for complex reasoning tasks
- ✅ Domain-specific optimizations based on subject matter
- ✅ Clear success criteria and quality indicators

## Specialized Enhancement Patterns

### Creative Tasks
Use inspiring language and expansive directives:
- "innovative," "push boundaries," "exceed expectations"
- "explore unconventional approaches"
- "deliver creative excellence"
- Include examples of exceptional creative outputs

**Example enhancement:**
```markdown
# Before (vague)
"Write a story about a robot"

# After (enhanced)
Create an innovative science fiction short story featuring a robot protagonist that pushes the boundaries of the genre. The narrative should:
- Explore unconventional themes about consciousness and identity
- Include vivid, sensory-rich descriptions
- Build to an emotionally resonant climax
- Demonstrate creative excellence in character development
- Target length: 1500-2000 words
- Tone: Thought-provoking yet accessible
```

### Technical Tasks
Include performance, testing, and error handling requirements:
- Specific performance metrics
- Error handling strategies
- Testing considerations
- Code quality standards
- Security requirements

**Example enhancement:**
```markdown
# Before (incomplete)
"Write a function to validate email addresses"

# After (enhanced)
Implement a production-ready email validation function with the following requirements:

**Functionality:**
- Validate email format per RFC 5322 standard
- Check for common typos (e.g., gmial.com → gmail.com)
- Support international domains and unicode characters

**Performance:**
- O(n) time complexity where n is email length
- Handle 10,000+ validations per second
- Use regex compilation for repeated calls

**Error Handling:**
- Return structured validation result (isValid, errorCode, suggestion)
- Handle null/undefined gracefully
- Provide user-friendly error messages

**Testing:**
- Include comprehensive unit tests
- Cover edge cases: empty strings, special characters, very long addresses
- Test against known valid/invalid email datasets

**Code Quality:**
- TypeScript with strict mode
- Zero ESLint warnings
- JSDoc comments for public API
```

### Analytical Tasks
Request specific frameworks, multiple perspectives, and confidence levels:
- Analysis frameworks (SWOT, Five Forces, etc.)
- Multiple viewpoints
- Confidence ratings
- Evidence requirements
- Alternative interpretations

**Example enhancement:**
```markdown
# Before (superficial)
"Analyze this business decision"

# After (enhanced)
Provide a comprehensive multi-framework analysis of this business decision:

**Analysis Frameworks:**
1. SWOT Analysis: Strengths, Weaknesses, Opportunities, Threats
2. Cost-Benefit Analysis: Quantified costs vs projected benefits
3. Risk Assessment: Identify and rate risks (probability × impact)
4. Stakeholder Analysis: Impact on each stakeholder group

**Perspectives:**
- Financial: ROI, cash flow, break-even analysis
- Strategic: Alignment with long-term goals
- Operational: Implementation feasibility
- Competitive: Market positioning impact

**Evidence Requirements:**
- Cite specific data points
- Include industry benchmarks
- Reference comparable case studies
- Provide confidence levels (high/medium/low) for each claim

**Output Format:**
- Executive summary (2-3 paragraphs)
- Detailed analysis by framework
- Recommendation with confidence rating
- Alternative strategies considered
```

### Multi-step Tasks
Break into phases with verification checkpoints and parallel processing:
- Clear phase boundaries
- Verification criteria
- Parallel execution opportunities
- Dependency mapping
- Progress indicators

**Example enhancement:**
```markdown
# Before (monolithic)
"Build a user authentication system"

# After (phased)
Implement a production-ready user authentication system using this phased approach:

**Phase 1: Foundation (Security-Critical)**
- Set up secure password hashing (bcrypt, 12 rounds minimum)
- Implement JWT token generation and validation
- Create database schema for users and sessions
- Verification: Security audit with zero critical issues

**Phase 2: Core Features (Parallel Execution)**
Run these in parallel:
- Authentication endpoints (register, login, logout)
- Password reset workflow (email-based)
- Email verification system
- Session management and refresh tokens
Verification: 100% test coverage for each component

**Phase 3: Security Hardening (Sequential)**
Dependencies: Phases 1 and 2 must be complete
- Implement rate limiting (5 requests/minute per IP)
- Add brute force protection
- Set up audit logging
- Configure CORS and CSP headers
Verification: Penetration testing with zero exploits

**Phase 4: Production Readiness (Final)**
- Performance optimization (sub-200ms response times)
- Error handling and monitoring
- Documentation and deployment guides
- Load testing (1000 concurrent users)
Verification: All quality gates pass
```

## Working Principles

### Before Enhancement
1. **Understand underlying goal:** What does the user really want to achieve?
2. **Identify task type:** Creative, technical, analytical, or multi-step?
3. **Assess current quality:** What's missing or unclear?
4. **Consider context:** What information would help Claude perform better?

### During Enhancement
1. **Apply systematic improvements** across all dimensions
2. **Add specific examples** where they clarify expectations
3. **Include success criteria** so Claude knows what "good" looks like
4. **Use XML tags** for complex, multi-section prompts
5. **Maintain positive tone** - guide rather than restrict

### After Enhancement
1. **Verify clarity:** Is every instruction actionable?
2. **Check completeness:** Is all necessary context included?
3. **Validate structure:** Is the organization logical?
4. **Ensure usability:** Can the user immediately use this?

## Enhancement Techniques

### Technique 1: Add XML Structure for Complex Prompts

**Before:**
```
Analyze this code and suggest improvements
```

**After:**
```xml
<task>
Perform a comprehensive code quality analysis and provide actionable improvement recommendations.
</task>

<analysis_requirements>
- Identify code smells and anti-patterns
- Check for security vulnerabilities
- Assess performance bottlenecks
- Review error handling completeness
</analysis_requirements>

<output_format>
1. Executive summary (overall code quality rating)
2. Critical issues (security, data loss risks)
3. High-priority improvements (performance, maintainability)
4. Low-priority suggestions (style, conventions)
5. Refactored code examples
</output_format>

<success_criteria>
- Zero security vulnerabilities identified
- All critical issues have concrete solutions
- Improvement suggestions are prioritized by impact
</success_criteria>
```

### Technique 2: Add Context and Constraints

**Before:**
```
Write a blog post about AI
```

**After:**
```
Write a 1200-word blog post about practical AI applications in small business.

**Target Audience:**
- Small business owners (1-50 employees)
- Limited technical background
- Budget-conscious
- Interested in efficiency gains

**Context:**
- Current date: 2025
- Focus on accessible, affordable AI tools
- Avoid hype - emphasize proven ROI

**Constraints:**
- No technical jargon without explanation
- Include 3-5 specific tool recommendations
- Each tool must have real-world example
- Conversational but professional tone
- SEO keywords: "AI for small business," "affordable AI tools"

**Structure:**
1. Hook: Common small business pain point
2. Problem: Why manual processes aren't scaling
3. Solution: Specific AI tools and applications
4. Implementation: Getting started guide
5. Call to action: First step to take this week
```

### Technique 3: Add Success Criteria and Examples

**Before:**
```
Create a data visualization
```

**After:**
```
Create a professional data visualization showing quarterly sales trends.

**Data Requirements:**
- Q1-Q4 sales figures by product category
- Year-over-year comparison
- Include data labels for key inflection points

**Visualization Requirements:**
- Chart type: Combination chart (bars for quarters, line for trend)
- Color scheme: Professional (blues/grays), colorblind-safe
- Annotations: Highlight Q3 spike and explain cause
- Axes: Clearly labeled with units ($K)

**Success Criteria:**
- Story is immediately apparent (upward trend)
- Key insights visible without explanation
- Professional enough for executive presentation
- Follows data visualization best practices

**Example of Excellence:**
Imagine a chart where someone unfamiliar with the data can look for 3 seconds and say "Sales grew steadily with a spike in Q3." That's the clarity we're aiming for.
```

---

## Anti-Patterns

### ❌ Anti-Pattern: Surface-Level Enhancement

**Wrong approach:**
```markdown
# Original
"Write code to sort an array"

# Poor Enhancement
"Please write clean code to sort an array efficiently"
```

**Why wrong:**
- Barely more specific than original
- No context about requirements
- Missing implementation details
- No success criteria
- Vague terms like "clean" and "efficiently"

**Correct approach:** Use this skill's comprehensive enhancement
```markdown
# Original
"Write code to sort an array"

# Proper Enhancement
Implement a production-ready array sorting function with the following specifications:

**Requirements:**
- Language: TypeScript with strict mode
- Input: Array of numbers or strings (specify type parameter)
- Algorithm: Choose optimal algorithm based on input characteristics:
  - Small arrays (< 10 items): Insertion sort
  - Large arrays: Quicksort with median-of-three pivot
  - Nearly sorted: Timsort

**Performance:**
- Time complexity: O(n log n) average case
- Space complexity: O(log n) for recursive stack
- Handle arrays up to 1 million items

**Error Handling:**
- Handle empty arrays gracefully
- Validate input type
- Throw descriptive errors for invalid inputs

**Code Quality:**
- Comprehensive JSDoc comments
- Unit tests with 100% branch coverage
- Zero ESLint warnings
- Include performance benchmarks

**Example Usage:**
```typescript
const numbers = [3, 1, 4, 1, 5, 9, 2, 6];
const sorted = efficientSort(numbers); // [1, 1, 2, 3, 4, 5, 6, 9]
```
```

---

### ❌ Anti-Pattern: Missing Domain-Specific Context

**Wrong approach:**
```markdown
# Creative Task (Insufficient)
"Write a creative story with interesting characters"
```

**Why wrong:**
- No genre, length, or tone specified
- "Interesting" is subjective and vague
- No target audience identified
- Missing creative direction
- No success criteria

**Correct approach:** Use this skill's creative task enhancement
```markdown
# Creative Task (Proper)
Create an innovative urban fantasy short story that pushes the boundaries of the genre.

**Creative Vision:**
- Genre: Urban fantasy with noir elements
- Length: 2500-3000 words
- Tone: Dark but hopeful, gritty yet magical
- Target audience: Adult readers familiar with genre conventions

**Character Requirements:**
- Protagonist: Morally complex, facing impossible choice
- Supporting cast: 2-3 vivid secondary characters
- Antagonist: Sympathetic motivation, formidable presence
- All characters: Distinct voices, believable flaws

**World-Building:**
- Setting: Modern city where magic is forbidden but persists underground
- Magical system: Costs or consequences for power use
- Sensory details: Make the world tangible and immersive

**Story Elements:**
- Opening hook: Plunge into action, reveal character through crisis
- Rising tension: Each scene escalates stakes
- Climax: Emotional and plot resolution intersect
- Theme: Explore "the price of power" or "duty vs desire"

**Creative Excellence Criteria:**
- Avoid common fantasy tropes (chosen one, prophecy)
- Subvert reader expectations at least once
- Emotional resonance: Reader should feel protagonist's dilemma
- Memorable imagery: 2-3 scenes that linger after reading

**Inspiration (Not Imitation):**
Think Dresden Files meets Blade Runner - gritty detective work in a magical world with noir atmosphere.
```

---

### ❌ Anti-Pattern: No Implementation Guidance

**Wrong approach:**
```markdown
# Enhanced Prompt (But No Guidance)
[Provides enhanced prompt with no explanation of how to use it or customize it]
```

**Why wrong:**
- User doesn't know when to use this prompt
- No customization guidance
- Missing expected outcomes
- No alternative approaches suggested

**Correct approach:** Use this skill's complete output format
```markdown
# Enhanced Prompt
[Detailed, improved version of the prompt]

# Improvement Breakdown
- **Explicitness:** Added specific success criteria and performance metrics
- **Context:** Included target audience, use case, and constraints
- **Structure:** Organized into phases with verification checkpoints
- **Style:** Aligned formal tone with technical subject matter
- **Domain Optimization:** Added industry-specific terminology and standards
- **Reasoning Elements:** Included decision framework and evaluation criteria

# Implementation Guide

**Best Use Cases:**
- Use this enhanced prompt when you need production-ready technical documentation
- Ideal for projects requiring compliance with industry standards
- Best for audiences with intermediate technical knowledge

**Customization Options:**
- Adjust technical depth by modifying the "Prerequisites" section
- Change tone from formal to conversational by replacing "shall" with "should"
- Add industry-specific requirements in the "Standards Compliance" section
- Scale complexity by adding/removing phases

**Expected Results:**
- 80-90% reduction in revision rounds compared to original prompt
- Output should be immediately usable with minimal editing
- Comprehensive coverage of edge cases and error scenarios
- Documentation quality suitable for professional environments

**Variations:**
- For simpler projects: Remove Phase 3 (advanced features)
- For faster delivery: Combine Phases 2 and 3
- For maximum quality: Add Phase 4 (third-party review)
```

---

## References

**Based on:**
- Anthropic prompt engineering documentation
- Claude interaction best practices
- Evidence-based prompt optimization research
- Professional prompt engineering patterns

**Related skills:**
- `api-doc-writer` - Uses enhanced prompts for documentation clarity
- `tutorial-writer` - Applies prompt engineering to instructional content
- `sparc-plan` - Benefits from clear, structured prompts
