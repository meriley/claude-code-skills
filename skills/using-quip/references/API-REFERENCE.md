# Quip Automation API Reference

**Base URL:** `https://platform.quip.com/1/`
**Tenant UI:** `https://axon.quip.com/`
**Auth:** `Authorization: Bearer $QUIP_ACCESS_TOKEN`
**POST encoding:** `application/x-www-form-urlencoded` (NEVER `application/json`)

---

## Authentication

All requests require the Bearer token header:

```
Authorization: Bearer $QUIP_ACCESS_TOKEN
```

Personal Access Tokens are generated at:
`https://axon.quip.com/dev/token`

---

## Users

### Get Current User

```
GET users/current
```

Returns the authenticated user's profile.

**Response:**

```json
{
  "id": "string",
  "name": "string",
  "emails": ["user@example.com"],
  "profile_picture_url": "string",
  "subdomain": "axon",
  "url": "https://axon.quip.com",
  "private_folder_id": "string",
  "shared_folder_ids": ["string"],
  "group_folder_ids": ["string"],
  "disabled": false
}
```

### Get User by ID

```
GET users/{user_id}
```

**Response:** Same as current user.

### Get Multiple Users

```
GET users/?ids={id1},{id2},...
```

**Response:** `{ "{id}": {user_object}, ... }`

### Get Contacts

```
GET users/contacts
```

**Response:** Array of user objects.

---

## Teams

### Get Current Team

```
GET teams/current
```

**Response:**

```json
{
  "id": "string",
  "name": "string",
  "member_ids": ["string"]
}
```

---

## Folders

### Get Folder

```
GET folders/{folder_id}
```

**Response:**

```json
{
  "folder": {
    "id": "string",
    "title": "string",
    "creator_id": "string",
    "created_usec": 1234567890000000,
    "updated_usec": 1234567890000000,
    "color": "manila|red|orange|yellow|green|blue|purple",
    "parent_id": "string | null",
    "children": [
      { "thread_link": { "thread_id": "string" } },
      { "folder_link": { "folder_id": "string" } }
    ]
  },
  "member_ids": ["string"]
}
```

### Get Multiple Folders

```
GET folders/?ids={id1},{id2},...
```

**Response:** `{ "{id}": {folder_object}, ... }`

### Create Folder

```
POST folders/new
```

**Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes | Folder name |
| `parent_id` | string | No | Parent folder ID |
| `color` | string | No | manila, red, orange, yellow, green, blue, purple |
| `member_ids` | string | No | Comma-separated user/folder IDs to add as members |

**Response:** Folder object (see Get Folder).

### Update Folder

```
POST folders/update
```

**Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `folder_id` | string | Yes | Folder to update |
| `title` | string | No | New title |
| `color` | string | No | New color |

### Add Members to Folder

```
POST folders/add-members
```

**Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `folder_id` | string | Yes | Target folder |
| `member_ids` | string | Yes | Comma-separated user/thread/folder IDs |

### Remove Members from Folder

```
POST folders/remove-members
```

**Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `folder_id` | string | Yes | Target folder |
| `member_ids` | string | Yes | Comma-separated IDs to remove |

---

## Threads (Documents & Chats)

### Get Thread

```
GET threads/{thread_id}
```

**Response:**

```json
{
  "thread": {
    "id": "string",
    "title": "string",
    "type": "document|chat|spreadsheet|slides",
    "link": "https://axon.quip.com/{id}",
    "author_id": "string",
    "created_usec": 1234567890000000,
    "updated_usec": 1234567890000000,
    "owning_company_id": "string",
    "sharing": {}
  },
  "html": "<h1>Document title</h1><p data-section-id=\"ABC\">...</p>",
  "user_ids": ["string"],
  "shared_folder_ids": ["string"],
  "access_levels": {}
}
```

**Key field:** `html` contains the full document content with `data-section-id` attributes on each section element.

### Get Multiple Threads

```
GET threads/?ids={id1},{id2},...
```

**Response:** `{ "{id}": {thread_object}, ... }`

### Get Recent Threads

```
GET threads/recent
```

**Query params:**
| Param | Type | Description |
|-------|------|-------------|
| `count` | int | Number of results (default: 50, max: 200) |
| `max_updated_usec` | int | Cursor for pagination |

**Response:** Array of thread objects.

### Search Threads

```
GET threads/search?query={terms}&count={n}
```

**Query params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `query` | string | Yes | Search terms |
| `count` | int | No | Results to return (default: 10, max: 50) |
| `only_match_titles` | bool | No | Restrict to title matches |

**Response:** Array of thread objects sorted by relevance.

### Create Document

```
POST threads/new-document
```

**Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | No | Document title |
| `content` | string | No | Initial HTML content |
| `format` | string | No | `html` (default) or `markdown` — use `html` |
| `type` | string | No | `document` (default), `spreadsheet`, `slides` |
| `member_ids` | string | No | Comma-separated user/folder IDs to share with |

**Response:** Thread object.

### Create Chat Thread

```
POST threads/new-chat
```

**Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes | Chat thread title |
| `member_ids` | string | Yes | Comma-separated user IDs |

**Response:** Thread object.

### Copy Document

```
POST threads/copy-document
```

**Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `thread_id` | string | Yes | Source thread ID |
| `title` | string | No | New document title |
| `member_ids` | string | No | Share with these IDs |

**Response:** New thread object.

### Edit Document

```
POST threads/edit-document
```

**Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `thread_id` | string | Yes | Target document ID |
| `content` | string | Yes | HTML content to insert/replace |
| `format` | string | No | `html` (always use this) |
| `location` | int | No | Where to insert (see enum below) |
| `section_id` | string | Conditional | Required for locations 2–5 |

**Location Enum:**
| Value | Meaning |
|-------|---------|
| `0` | Append to end |
| `1` | Prepend to start |
| `2` | After `section_id` |
| `3` | Before `section_id` |
| `4` | Replace `section_id` |
| `5` | Delete `section_id` |

**Response:** Thread object with updated HTML.

### Delete Thread

```
POST threads/delete
```

**Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `thread_id` | string | Yes | Thread to delete |

**Response:** Empty 200 on success.

### Add Members to Thread

```
POST threads/add-members
```

**Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `thread_id` | string | Yes | Target thread |
| `member_ids` | string | Yes | Comma-separated user/folder IDs |

### Remove Members from Thread

```
POST threads/remove-members
```

**Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `thread_id` | string | Yes | Target thread |
| `member_ids` | string | Yes | Comma-separated IDs to remove |

---

## Messages

### Get Messages

```
GET messages/{thread_id}
```

**Query params:**
| Param | Type | Description |
|-------|------|-------------|
| `count` | int | Messages per page (default: 20, max: 200) |
| `max_created_usec` | int | Cursor — fetch messages older than this timestamp |

**Response:**

```json
[
  {
    "id": "string",
    "author_id": "string",
    "created_usec": 1234567890000000,
    "updated_usec": 1234567890000000,
    "html": "<p>Message content</p>",
    "author_name": "string",
    "parts": []
  }
]
```

**Pagination:** The oldest message in the batch gives the cursor for the next page. Stop when response is empty or count < requested.

### Post Message

```
POST messages/new
```

**Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `thread_id` | string | Yes | Thread to post to |
| `content` | string | Yes | HTML message content |
| `parts` | string | No | JSON-encoded message parts for rich content |

**Response:** Message object.

---

## Blobs (File Attachments)

### Get Blob

```
GET blob/{thread_id}/{blob_id}
```

Returns raw file content with appropriate `Content-Type` header.

### Upload Blob

```
PUT blob/{thread_id}
```

**Headers:**

```
Content-Type: {file mime type}
Authorization: Bearer $QUIP_ACCESS_TOKEN
```

**Body:** Raw file bytes.

**Response:**

```json
{
  "url": "https://platform.quip.com/1/blob/{thread_id}/{blob_id}"
}
```

---

## Pagination Pattern

For paginated endpoints (messages, recent threads):

```bash
CURSOR=""
while true; do
  PARAMS="count=200"
  if [ -n "$CURSOR" ]; then
    PARAMS="$PARAMS&max_created_usec=$CURSOR"
  fi

  RESPONSE=$(curl -s -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
    "https://platform.quip.com/1/messages/THREAD_ID?$PARAMS")

  COUNT=$(echo "$RESPONSE" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")

  # Process $RESPONSE here

  if [ "$COUNT" -eq 0 ]; then
    break
  fi

  CURSOR=$(echo "$RESPONSE" | python3 -c "
import json,sys
msgs = json.load(sys.stdin)
print(min(m['created_usec'] for m in msgs))
")
done
```

---

## Response Object Quick Reference

### Thread Object

```json
{
  "thread": {
    "id": "string", // Thread ID — use in API calls and URLs
    "title": "string",
    "type": "document|chat",
    "link": "https://axon.quip.com/{id}",
    "author_id": "string",
    "created_usec": 0,
    "updated_usec": 0
  },
  "html": "string", // Full document HTML with data-section-id attrs
  "user_ids": [],
  "shared_folder_ids": []
}
```

### Folder Object

```json
{
  "folder": {
    "id": "string",
    "title": "string",
    "creator_id": "string",
    "color": "string",
    "parent_id": "string|null",
    "children": [
      { "thread_link": { "thread_id": "string" } },
      { "folder_link": { "folder_id": "string" } }
    ]
  },
  "member_ids": []
}
```

### User Object

```json
{
  "id": "string",
  "name": "string",
  "emails": [],
  "profile_picture_url": "string",
  "private_folder_id": "string",
  "shared_folder_ids": [],
  "group_folder_ids": []
}
```

### Message Object

```json
{
  "id": "string",
  "author_id": "string",
  "author_name": "string",
  "created_usec": 0,
  "updated_usec": 0,
  "html": "string"
}
```
