# Web Action Verification and Investigation Tool

Use Playwright MCP to navigate to a URL, perform an action (click), verify expected behavior, and if verification fails, investigate the issue and generate a prompt to fix it.

## Usage
Provide arguments in this format: "<URL>" "<button_identifier>" "<expected_behavior>"
Example: /project:verify-web-action "https://example.com" "Submit button" "form should submit and show success message"

## Instructions for Claude:

<verification_process>
IMPORTANT: Think hard about each step to ensure accurate verification and investigation.

1. **Setup and Navigation**
   - Ensure Playwright MCP is available and properly configured
   - Use browser_navigate to go to the specified URL
   - Wait for the page to fully load using browser_wait_for if needed
   - Take an initial browser_snapshot to understand the page structure

2. **Locate and Interact with Element**
   <element_location_strategy>
   - First use browser_snapshot to get the accessibility tree
   - Identify the target button using these prioritized methods:
     a) Role-based: Look for role="button" with matching text
     b) Text content: Match the button text provided
     c) ARIA labels: Check aria-label attributes
     d) Test IDs: Look for data-testid attributes
   - Store the exact ref from the snapshot for clicking
   - If multiple matches exist, choose the most likely based on context
   </element_location_strategy>

3. **Perform the Action**
   - Use browser_click with both element description and ref
   - After clicking, wait briefly for any transitions/animations
   - Capture browser_console_messages to check for JavaScript errors
   - Take another browser_snapshot to see the post-click state

4. **Verify Expected Behavior**
   <verification_checks>
   Based on the expected behavior description, check for:
   - **Visual changes**: New elements, removed elements, text changes
   - **Navigation**: URL changes, page redirects
   - **Messages**: Success/error messages, toasts, alerts
   - **Form states**: Cleared inputs, disabled buttons
   - **Network activity**: Use browser_network_requests to verify API calls
   - **Console errors**: Check for any JavaScript errors
   </verification_checks>

5. **Investigation Process (if verification fails)**
   <investigation_steps>
   If the expected behavior is NOT observed:
   
   a) **Gather comprehensive diagnostics**:
      - Take a browser_take_screenshot for visual evidence
      - Collect all browser_console_messages
      - Review browser_network_requests for failed API calls
      - Use browser_evaluate to check element states/properties
      - Check if the button was actually clicked (may need retry)
   
   b) **Analyze common failure patterns**:
      - Element not clickable (overlapped, disabled, not visible)
      - JavaScript errors preventing functionality
      - Network/API failures
      - Timing issues (action triggered too early)
      - Wrong element selected
      - Missing dependencies or configuration
   
   c) **Deep investigation using browser_evaluate**:
      ```javascript
      // Example investigations:
      // Check button state
      (element) => ({
        disabled: element.disabled,
        ariaDisabled: element.getAttribute('aria-disabled'),
        classList: Array.from(element.classList),
        computedStyle: window.getComputedStyle(element).pointerEvents
      })
      
      // Check for overlapping elements
      () => {
        const rect = element.getBoundingClientRect();
        const topElement = document.elementFromPoint(rect.x + rect.width/2, rect.y + rect.height/2);
        return topElement === element;
      }
      ```
   </investigation_steps>

6. **Generate Fix Prompt**
   <fix_prompt_generation>
   Create a detailed prompt for another AI agent that includes:
   
   a) **Context**:
      - URL and intended action
      - Expected vs actual behavior
      - Specific failure mode identified
   
   b) **Diagnostic Data**:
      - Relevant error messages
      - Network request failures
      - JavaScript console errors
      - Element state information
   
   c) **Suggested Fix Approach**:
      - Specific code changes needed
      - Files likely to be modified
      - Testing approach to verify fix
   
   d) **Code Investigation Hints**:
      - CSS selectors or IDs to search for
      - Event handler patterns to look for
      - API endpoints that may need fixing
   </fix_prompt_generation>
</verification_process>

<output_format>
## Verification Report

### Test Configuration
- **URL**: [URL tested]
- **Target Element**: [Button description]
- **Expected Behavior**: [What should happen]

### Execution Results
[✅ PASSED / ❌ FAILED]

#### Actions Performed
1. [List each action taken]
2. [Include any waits or retries]

#### Verification Details
[Detailed explanation of what was checked and results]

### Investigation Results (if failed)
#### Failure Analysis
- **Primary Issue**: [Main reason for failure]
- **Evidence**: 
  - Console errors: [Any JavaScript errors]
  - Network issues: [Failed requests]
  - Element state: [Relevant properties]

#### Root Cause
[Detailed explanation of why the functionality isn't working]

### Generated Fix Prompt

```
Title: Fix [specific functionality] on [page/component]

Context:
[Comprehensive background about the issue]

The Issue:
[Precise description of what's broken]

Technical Details:
- Error: [Specific error messages]
- Failed Request: [Any API/network failures]  
- Element State: [Relevant HTML/CSS/JS details]

Required Fix:
1. [First specific change needed]
2. [Second specific change needed]
3. [Any additional changes]

Files to Check:
- [List specific files based on investigation]

Testing:
After implementing the fix, verify by:
1. [Specific test step]
2. [Another test step]

Success Criteria:
[What should happen when fixed]
```

### Additional Notes
[Any other relevant observations or recommendations]
</output_format>

<best_practices>
- Always use browser_snapshot before interacting with elements
- Store exact element refs from snapshots for accurate targeting
- Handle timing issues with appropriate waits
- Check console messages after every action
- Use browser_evaluate for deep element inspection
- Provide specific, actionable fix prompts
- Include all relevant diagnostic data in reports
</best_practices>

<error_handling>
If any Playwright MCP operations fail:
- Check if Playwright MCP server is running
- Verify browser installation with browser_install if needed
- Ensure proper permissions for the requested URL
- Fall back to alternative investigation methods
</error_handling>

Parse the arguments from: $ARGUMENTS