---
name: using-quip
description: Read, create, edit, search, and organize Quip documents and folders using the Quip Automation API. Use when the user mentions Quip documents, Quip folders, axon.quip.com URLs, or asks to read/write/search Quip content.
version: 1.0.0
---

# Using Quip

Interact with Quip (axon.quip.com) via the Quip Automation REST API. Supports reading, creating, editing, searching, and organizing documents and folders.

## When to Use

- User provides an `axon.quip.com` URL and wants to read, edit, or discuss the document
- User asks to create a new Quip document or folder
- User wants to search Quip for documents by keyword
- User wants to append content to an existing Quip document
- User asks about Quip folder structure or wants to organize documents

## When NOT to Use

- Real-time collaboration or commenting on specific selected text (use the Quip UI)
- Uploading large binary attachments (use the Blobs API directly)
- Anything requiring OAuth flows — only Bearer token auth is supported here

---

## Configuration

```bash
# Required: set in shell profile or export before invoking Claude
export QUIP_ACCESS_TOKEN="your-personal-access-token"
```

| Setting            | Value                                          |
| ------------------ | ---------------------------------------------- |
| API base URL       | `https://platform.quip.com/1/`                 |
| Human-facing URL   | `https://axon.quip.com/{thread_id}`            |
| Auth header        | `Authorization: Bearer $QUIP_ACCESS_TOKEN`     |
| POST body encoding | `application/x-www-form-urlencoded` (NOT JSON) |

**CRITICAL:** The API base is `platform.quip.com`, NOT `axon.quip.com`. The tenant domain is only used for human-facing links.

**NEVER echo or log `$QUIP_ACCESS_TOKEN` in output.**

---

## Extracting Thread IDs from URLs

Given `https://axon.quip.com/XYZ123AbC`, the thread ID is `XYZ123AbC` (the path segment after the domain).

```bash
# Extract thread ID from URL
THREAD_ID=$(echo "https://axon.quip.com/XYZ123AbC" | sed 's|.*/||')
```

---

## Content Format

Quip documents use HTML. Always use `format=html` when creating or editing content. Markdown loses fidelity on ingestion.

| HTML Tag                | Purpose       |
| ----------------------- | ------------- |
| `<h1>`, `<h2>`, `<h3>`  | Headings      |
| `<p>`                   | Paragraph     |
| `<b>`, `<i>`            | Bold, italic  |
| `<ul><li>...</li></ul>` | Bulleted list |
| `<ol><li>...</li></ul>` | Numbered list |
| `<code>`                | Inline code   |
| `<pre>`                 | Code block    |

---

## Edit Location Enum

When editing documents, `location` controls where content is inserted:

| Value | Intent                        | Requires `section_id`? |
| ----- | ----------------------------- | ---------------------- |
| `0`   | Append to end of document     | No                     |
| `1`   | Prepend to start of document  | No                     |
| `2`   | After the specified section   | Yes                    |
| `3`   | Before the specified section  | Yes                    |
| `4`   | Replace the specified section | Yes                    |
| `5`   | Delete the specified section  | Yes                    |

**Extracting section IDs:** Fetch the document HTML, then find `data-section-id` attributes:

```bash
curl -s -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  "https://platform.quip.com/1/threads/THREAD_ID" \
  | python3 -c "
import json,sys
from html.parser import HTMLParser

class SectionParser(HTMLParser):
    def handle_starttag(self, tag, attrs):
        for name, val in attrs:
            if name == 'data-section-id':
                print(f'{tag}: {val}')

data = json.load(sys.stdin)
SectionParser().feed(data['html'])
"
```

---

## Quick Start

### 1. Verify Credentials

```bash
curl -s -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  "https://platform.quip.com/1/users/current" | python3 -m json.tool
```

### 2. Read a Document

```bash
# Given URL: https://axon.quip.com/ABC123
curl -s -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  "https://platform.quip.com/1/threads/ABC123" | python3 -m json.tool
```

### 3. Create a Document

```bash
curl -s -X POST \
  -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "title=My Document" \
  --data-urlencode "content=<h1>Title</h1><p>Body text.</p>" \
  --data-urlencode "format=html" \
  --data-urlencode "type=document" \
  "https://platform.quip.com/1/threads/new-document" | python3 -m json.tool
```

### 4. Append to a Document

```bash
curl -s -X POST \
  -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "thread_id=ABC123" \
  --data-urlencode "content=<p>New paragraph appended.</p>" \
  --data-urlencode "location=0" \
  --data-urlencode "format=html" \
  "https://platform.quip.com/1/threads/edit-document" | python3 -m json.tool
```

### 5. Search Documents

```bash
curl -s -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  "https://platform.quip.com/1/threads/search?query=quarterly+review&count=10" \
  | python3 -m json.tool
```

---

## Workflows

### Reading a Document

1. Extract thread ID from the `axon.quip.com` URL
2. `GET threads/{thread_id}` — returns `thread.html` (full content) and metadata
3. Parse HTML for structure; use `data-section-id` attributes if editing is needed
4. Present content in a readable format to the user

### Creating a Document

1. Compose content as HTML
2. `POST threads/new-document` with `title`, `content`, `format=html`, `type=document`
3. Optionally specify `member_ids` to share with users/folders immediately
4. Return the document URL: `https://axon.quip.com/{thread.thread.id}`

### Editing a Document

1. Fetch the document to get current HTML and section IDs
2. Determine `location` enum (0=append, 4=replace section, etc.)
3. For targeted edits: extract `section_id` from `data-section-id` attributes
4. `POST threads/edit-document` with `thread_id`, `content`, `location`, optionally `section_id`

### Searching for Documents

1. `GET threads/search?query={terms}&count={n}` — returns array of thread objects
2. Present titles and URLs to user
3. User can select a result → fetch full document with `GET threads/{id}`

### Navigating Folder Structure

1. `GET users/current` → note `private_folder_id` and `shared_folder_ids`
2. `GET folders/{folder_id}` → `children` array contains `thread_link` and `folder_link` items
3. Recurse into subfolders as needed
4. Use folder IDs when creating documents in a specific location (`member_ids`)

### Organizing Documents

1. Create new folder: `POST folders/new` with `title`, optionally `parent_id` and `color`
2. Move document to folder: `POST folders/add-members` with `folder_id` and `member_ids`
3. Remove document from folder: `POST folders/remove-members`

### Posting Messages

1. Get thread ID (document or chat thread)
2. `POST messages/new` with `thread_id` and `content`
3. Optionally use `author_id` for named attribution

---

## Error Handling

| HTTP Status | Meaning                      | Action                                       |
| ----------- | ---------------------------- | -------------------------------------------- |
| `400`       | Bad request / invalid params | Check param names and encoding               |
| `401`       | Unauthorized                 | Verify `$QUIP_ACCESS_TOKEN` is set and valid |
| `403`       | Forbidden                    | User lacks access to this thread/folder      |
| `404`       | Not found                    | Check thread/folder ID is correct            |
| `429`       | Rate limited                 | Wait and retry with exponential backoff      |
| `500`       | Server error                 | Retry once; escalate if persistent           |

---

## Validation Checklist

After any write operation:

- [ ] Response HTTP status is 200
- [ ] Response body contains expected fields (`thread.id`, `folder.id`, etc.)
- [ ] Document URL resolves: `https://axon.quip.com/{id}`
- [ ] For edits: fetch document again and verify content change is present
- [ ] Token was NOT echoed in any output

---

## Reference Files

For complete endpoint specs:

```
Read ~/.claude/skills/using-quip/references/API-REFERENCE.md
```

Use when: You need exact parameter names, response schemas, or pagination patterns.

For complete working examples:

```
Read ~/.claude/skills/using-quip/references/EXAMPLES.md
```

Use when: You need a full curl recipe for a specific workflow.
