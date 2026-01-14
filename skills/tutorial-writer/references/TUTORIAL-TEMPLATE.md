# Complete Tutorial Template

This is the complete markdown structure for a Diátaxis-compliant tutorial. Use this when writing a new tutorial from scratch.

---

## Tutorial Structure Template

````markdown
# Getting Started with [System/Feature]

[Brief introduction - what they'll accomplish in 2-3 sentences]

## Prerequisites

**Before you start, you need:**

- [Tool/Language] version [X.Y] or higher
- [Dependency] installed ([link to installation])
- Basic understanding of [concept] (see [explanation link])
- [Any other requirements]

**Check your setup:**

```bash
# Verify installations
[command to check version]
# Expected output:
[what they should see]
```
````

## What You'll Build

By the end of this tutorial, you'll have:

- ✅ [Concrete outcome 1]
- ✅ [Concrete outcome 2]
- ✅ [Concrete outcome 3]

**Total time**: [Realistic estimate] minutes

---

## Step 1: [Action] ([time] minutes)

[Very brief context - WHAT not WHY. 1-2 sentences max.]

### Create [Thing]

```[language]
// VERIFIED code from source - exact imports and signatures
import "[actual/import/path]"

[exact code with real APIs]
```

**Run it:**

```bash
[exact command to run the code]
```

**Expected output:**

```
[EXACT output they should see - copy from when you tested it]
```

✅ **Success check**: [How to verify this step worked]

**What you just did**: [1 sentence explaining the step - still WHAT not WHY]

---

## Step 2: [Next Action] ([time] minutes)

[Repeat step structure]

### [Substep if needed]

[Code example with verified APIs]

**Run it:**

```bash
[command]
```

**Expected output:**

```
[output]
```

✅ **Success check**: [Verification]

---

## Step 3: [Continue Building]

[Continue progressive steps to final goal]

---

## Complete Working Code

[Full, complete, tested code that includes everything from all steps]

```[language]
// Complete working example - VERIFIED
import "[all/real/imports]"

[Complete code from your testing - this MUST work]
```

**Run the complete example:**

```bash
[command to run]
```

**Expected output:**

```
[complete output]
```

## What You Learned

In this tutorial, you:

- ✅ [Learned skill 1]
- ✅ [Learned skill 2]
- ✅ [Learned skill 3]

## Next Steps

Now that you have the basics:

- **Explore more features**: See [API Reference link]
- **Solve specific problems**: See [How-To Guides link]
- **Understand the design**: See [Explanation docs link]
- **Try these exercises**:
  1. [Extension exercise 1]
  2. [Extension exercise 2]

## Troubleshooting

[Common issues learners encounter]

### Problem: [Common Issue]

**What you see:**

```
[Error message or behavior]
```

**Fix:**

```[language]
[Solution code]
```

---

**Tutorial Metadata**

**Last Updated**: [YYYY-MM-DD]
**System Version**: [Version this tutorial is for]
**Verified**: ✅ Tutorial tested and working
**Test Date**: [YYYY-MM-DD]

**Verification**:

- ✅ All code examples tested
- ✅ All APIs verified against source
- ✅ Expected outputs confirmed
- ✅ Time estimates realistic
- ✅ Success criteria clear

**Source files verified**:

- `path/to/source/file1.ext`
- `path/to/source/file2.ext`

````

---

## Template Usage Guidelines

### Step Structure

Each step should follow this pattern:

1. **Brief context** (1-2 sentences max)
2. **Code block** (with verified APIs)
3. **Run command** (exact command)
4. **Expected output** (exact output from testing)
5. **Success check** (verification method)
6. **Brief explanation** (1 sentence, WHAT not WHY)

### Progressive Complexity

- **Step 1**: Absurdly simple (builds confidence)
- **Steps 2-3**: Introduce one concept at a time
- **Steps 4-6**: Build up to intermediate complexity
- **Final steps**: Complete the working example

### Language Style

- Use imperative mood: "Create a file" not "Let's create"
- Be direct: "Run the command" not "Now we'll run"
- No "we" or "us": "Install the package" not "We need to install"

### Success Criteria Format

Always use this pattern:

```markdown
✅ **Success check**: [Specific verification method]
````

Examples:

- ✅ **Success check**: You should see version `2.1.0` or higher
- ✅ **Success check**: The file `config.json` exists in your project directory
- ✅ **Success check**: The output shows "Server started on port 3000"

### Time Estimates

Be realistic and add buffer:

- **Simple operations** (install, create file): 3-5 minutes
- **Writing code**: 5-10 minutes per step
- **Configuration**: 7-10 minutes
- **Testing/debugging**: 10-15 minutes

**Add 50% buffer for beginners** - they read slower and make more mistakes.

### Expected Output Format

Always show complete, exact output:

```markdown
**Expected output:**
```

Starting service...
Loading configuration from config.json
Service ready on port 3000
Waiting for requests...

```

```

**Never:**

- "You should see output"
- "Something like: [...]"
- Partial or summarized output

### Code Verification Requirements

Every code block must be:

1. **Tested** - Actually run by you
2. **Verified** - APIs checked against source code
3. **Complete** - Includes all necessary imports
4. **Exact** - Uses real method signatures
5. **Working** - Produces documented output

### Troubleshooting Section Guidelines

Include 3-5 common issues:

```markdown
### Problem: [Short description]

**What you see:**
```

[Exact error message or behavior]

```

**Fix:**

[Step-by-step solution with code if needed]
```

Choose issues that:

- Beginners actually encounter
- You encountered during testing
- Have clear, specific fixes

---

## Example Tutorial Structure

Here's a complete example showing proper structure:

````markdown
# Getting Started with TaskService

Learn how to create and manage tasks using the TaskService API. By the end, you'll have a working task manager that creates, lists, and completes tasks.

## Prerequisites

**Before you start, you need:**

- Node.js version 18.0 or higher
- npm version 9.0 or higher
- Basic JavaScript/TypeScript knowledge (see [JavaScript basics](link))

**Check your setup:**

```bash
node --version
npm --version
```
````

Expected output:

```
v18.16.0
9.5.1
```

## What You'll Build

By the end of this tutorial, you'll have:

- ✅ A working task manager application
- ✅ Ability to create and list tasks
- ✅ Understanding of TaskService core APIs

**Total time**: 30-45 minutes

---

## Step 1: Install the TaskService package (5 minutes)

First, create a new directory and install the package.

```bash
mkdir my-task-app
cd my-task-app
npm init -y
npm install @company/task-service
```

✅ **Success check**: You should see `@company/task-service` in your `package.json` dependencies

**What you just did**: Created a new project and added the TaskService package.

---

## Step 2: Create your first task (10 minutes)

Create a file called `index.js`:

```javascript
// VERIFIED - TaskService API from @company/task-service v2.1.0
const { TaskService } = require("@company/task-service");

const service = new TaskService();

async function createTask() {
  const task = await service.create({
    title: "My first task",
    description: "Learning TaskService",
  });

  console.log("Task created:", task.id);
  return task;
}

createTask();
```

**Run it:**

```bash
node index.js
```

**Expected output:**

```
Task created: task_a1b2c3d4
```

✅ **Success check**: You see a task ID starting with `task_`

**What you just did**: Created your first task using the TaskService API.

---

[Continue with remaining steps...]

## Complete Working Code

Here's the complete working example with all features:

```javascript
// Complete task manager - VERIFIED working code
const { TaskService } = require("@company/task-service");

const service = new TaskService();

async function main() {
  // Create tasks
  const task1 = await service.create({
    title: "Learn TaskService",
    description: "Complete the tutorial",
  });

  const task2 = await service.create({
    title: "Build an app",
    description: "Use what I learned",
  });

  // List all tasks
  const tasks = await service.list();
  console.log(
    "All tasks:",
    tasks.map((t) => t.title),
  );

  // Complete first task
  await service.complete(task1.id);
  console.log("Task completed:", task1.id);
}

main();
```

**Run the complete example:**

```bash
node index.js
```

**Expected output:**

```
All tasks: [ 'Learn TaskService', 'Build an app' ]
Task completed: task_a1b2c3d4
```

## What You Learned

In this tutorial, you:

- ✅ Installed and set up TaskService
- ✅ Created tasks with title and description
- ✅ Listed all existing tasks
- ✅ Marked tasks as complete

## Next Steps

Now that you have the basics:

- **Explore more features**: See [TaskService API Reference](link)
- **Add task filtering**: See [How to filter tasks](link)
- **Understand task states**: See [Task lifecycle explanation](link)
- **Try these exercises**:
  1. Add task priorities (high, medium, low)
  2. Implement task search by title
  3. Add due dates to tasks

## Troubleshooting

### Problem: "Cannot find module '@company/task-service'"

**What you see:**

```
Error: Cannot find module '@company/task-service'
```

**Fix:**

Make sure you're in the correct directory and the package is installed:

```bash
pwd  # Should show my-task-app
npm install @company/task-service
```

---

### Problem: Task ID is undefined

**What you see:**

```
Task created: undefined
```

**Fix:**

Ensure you're using `await` when calling async functions:

```javascript
// ❌ Wrong
const task = service.create({ title: "Task" });

// ✅ Correct
const task = await service.create({ title: "Task" });
```

---

**Tutorial Metadata**

**Last Updated**: 2024-01-15
**System Version**: TaskService v2.1.0
**Verified**: ✅ Tutorial tested and working
**Test Date**: 2024-01-15

**Verification**:

- ✅ All code examples tested
- ✅ All APIs verified against source
- ✅ Expected outputs confirmed
- ✅ Time estimates realistic
- ✅ Success criteria clear

**Source files verified**:

- `node_modules/@company/task-service/dist/index.d.ts`
- `node_modules/@company/task-service/README.md`

```

---

## References

- Diátaxis Tutorial Pattern: https://diataxis.fr/tutorials/
- API Documentation Writer skill (for API reference links)
- Migration Guide Writer skill (for "Next Steps" links)
```
