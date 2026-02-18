# Quip API Examples

Complete working recipes. All POST requests use `application/x-www-form-urlencoded` encoding.

**CRITICAL:** Never use `Content-Type: application/json` with Quip API — it will return 400 errors.

---

## 1. Verify Credentials

Confirm your token is valid and see your user profile.

```bash
curl -s \
  -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  "https://platform.quip.com/1/users/current" \
  | python3 -m json.tool
```

**Expected response:**

```json
{
  "id": "ABCDEfgh",
  "name": "Your Name",
  "emails": ["you@axon.com"],
  "private_folder_id": "XYZPrivate",
  "shared_folder_ids": ["FolderID1", "FolderID2"],
  "subdomain": "axon"
}
```

If you get `401 Unauthorized`, the token is invalid or expired. Regenerate at `https://axon.quip.com/dev/token`.

---

## 2. Read a Document

Given URL: `https://axon.quip.com/ABC123xYZ`

```bash
# Step 1: Extract thread ID from URL (the path segment)
THREAD_ID="ABC123xYZ"

# Step 2: Fetch the thread
curl -s \
  -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  "https://platform.quip.com/1/threads/$THREAD_ID" \
  | python3 -c "
import json, sys
data = json.load(sys.stdin)
thread = data['thread']
print(f'Title: {thread[\"title\"]}')
print(f'Type: {thread[\"type\"]}')
print(f'URL: {thread[\"link\"]}')
print(f'Updated: {thread[\"updated_usec\"]}')
print()
print('--- Content ---')
# Strip HTML tags for quick preview
import re
text = re.sub('<[^>]+>', '', data.get('html', ''))
text = re.sub(r'\n{3,}', '\n\n', text)
print(text[:2000])
"
```

**To get raw HTML with section IDs:**

```bash
curl -s \
  -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  "https://platform.quip.com/1/threads/$THREAD_ID" \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['html'])"
```

---

## 3. Create a Document with Rich Content

```bash
curl -s -X POST \
  -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "title=Q3 2026 Planning Notes" \
  --data-urlencode "content=<h1>Q3 2026 Planning</h1>
<h2>Goals</h2>
<ul>
  <li>Launch feature X by end of quarter</li>
  <li>Reduce p99 latency by 30%</li>
</ul>
<h2>Key Decisions</h2>
<p>Decision: Use <b>approach A</b> for the migration.</p>
<h2>Action Items</h2>
<ol>
  <li>Alice: Draft technical spec by March 1</li>
  <li>Bob: Review infrastructure costs</li>
</ol>" \
  --data-urlencode "format=html" \
  --data-urlencode "type=document" \
  "https://platform.quip.com/1/threads/new-document" \
  | python3 -c "
import json, sys
data = json.load(sys.stdin)
thread = data['thread']
print(f'Created: {thread[\"title\"]}')
print(f'URL: {thread[\"link\"]}')
print(f'ID: {thread[\"id\"]}')
"
```

**To create in a specific folder** (add `member_ids`):

```bash
--data-urlencode "member_ids=FOLDER_ID"
```

---

## 4. Append a Section to an Existing Document

```bash
THREAD_ID="ABC123xYZ"

curl -s -X POST \
  -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "thread_id=$THREAD_ID" \
  --data-urlencode "location=0" \
  --data-urlencode "content=<h2>Update — February 2026</h2>
<p>Following our review, we decided to proceed with option B. Key points:</p>
<ul>
  <li>Timeline extended by 2 weeks</li>
  <li>Budget approved for additional resources</li>
</ul>" \
  --data-urlencode "format=html" \
  "https://platform.quip.com/1/threads/edit-document" \
  | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(f'Updated: {data[\"thread\"][\"title\"]}')
print(f'URL: {data[\"thread\"][\"link\"]}')
"
```

**To replace a specific section:**

```bash
# First, get section IDs
SECTION_ID=$(curl -s -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  "https://platform.quip.com/1/threads/$THREAD_ID" \
  | python3 -c "
import json, sys, re
html = json.load(sys.stdin)['html']
# Find all section IDs
sections = re.findall(r'data-section-id=\"([^\"]+)\"', html)
for s in sections:
    print(s)
" | head -3)

echo "Section IDs: $SECTION_ID"

# Then replace the first section
FIRST_SECTION=$(echo "$SECTION_ID" | head -1)
curl -s -X POST \
  -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "thread_id=$THREAD_ID" \
  --data-urlencode "location=4" \
  --data-urlencode "section_id=$FIRST_SECTION" \
  --data-urlencode "content=<h1>Revised Title</h1>" \
  --data-urlencode "format=html" \
  "https://platform.quip.com/1/threads/edit-document"
```

---

## 5. Search and Open First Result

```bash
QUERY="quarterly planning"

# Search for documents
RESULTS=$(curl -s \
  -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  "https://platform.quip.com/1/threads/search?query=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$QUERY'))")&count=5")

# Show results
echo "$RESULTS" | python3 -c "
import json, sys
threads = json.load(sys.stdin)
if not threads:
    print('No results found')
else:
    for i, t in enumerate(threads, 1):
        thread = t['thread']
        print(f'{i}. {thread[\"title\"]} — {thread[\"link\"]}')
"

# Fetch full content of the first result
FIRST_ID=$(echo "$RESULTS" | python3 -c "
import json, sys
threads = json.load(sys.stdin)
if threads:
    print(threads[0]['thread']['id'])
")

if [ -n "$FIRST_ID" ]; then
  curl -s \
    -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
    "https://platform.quip.com/1/threads/$FIRST_ID" \
    | python3 -c "
import json, sys, re
data = json.load(sys.stdin)
print(f'Title: {data[\"thread\"][\"title\"]}')
print()
text = re.sub('<[^>]+>', ' ', data.get('html', ''))
text = re.sub(r' {2,}', ' ', text)
print(text[:3000])
"
fi
```

---

## 6. Navigate and Organize Folder Structure

```bash
# Step 1: Get your root folders from current user
USER_DATA=$(curl -s -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  "https://platform.quip.com/1/users/current")

PRIVATE_FOLDER=$(echo "$USER_DATA" | python3 -c "import json,sys; print(json.load(sys.stdin)['private_folder_id'])")
SHARED_FOLDERS=$(echo "$USER_DATA" | python3 -c "import json,sys; print(','.join(json.load(sys.stdin)['shared_folder_ids'][:5]))")

echo "Private folder: $PRIVATE_FOLDER"
echo "Shared folders: $SHARED_FOLDERS"

# Step 2: List contents of your private folder
curl -s \
  -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  "https://platform.quip.com/1/folders/$PRIVATE_FOLDER" \
  | python3 -c "
import json, sys
data = json.load(sys.stdin)
folder = data['folder']
print(f'Folder: {folder[\"title\"]} ({folder[\"id\"]})')
print()
children = folder.get('children', [])
print(f'Contents ({len(children)} items):')
for child in children:
    if 'thread_link' in child:
        print(f'  [doc]    {child[\"thread_link\"][\"thread_id\"]}')
    elif 'folder_link' in child:
        print(f'  [folder] {child[\"folder_link\"][\"folder_id\"]}')
"

# Step 3: Create a new subfolder
curl -s -X POST \
  -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "title=2026 Planning" \
  --data-urlencode "parent_id=$PRIVATE_FOLDER" \
  --data-urlencode "color=blue" \
  "https://platform.quip.com/1/folders/new" \
  | python3 -c "
import json, sys
data = json.load(sys.stdin)
f = data['folder']
print(f'Created folder: {f[\"title\"]} ({f[\"id\"]})')
"
```

---

## 7. Post a Message to a Chat Thread

```bash
THREAD_ID="ChatThreadID123"

# Post a message
curl -s -X POST \
  -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "thread_id=$THREAD_ID" \
  --data-urlencode "content=<p>Status update: deployment to staging is complete. Tests are passing. Ready for review.</p>" \
  "https://platform.quip.com/1/messages/new" \
  | python3 -c "
import json, sys
msg = json.load(sys.stdin)
print(f'Message posted: {msg[\"id\"]}')
print(f'By: {msg[\"author_name\"]}')
"
```

---

## 8. Paginated Message Fetch

Fetch all messages from a chat thread, oldest first.

```bash
THREAD_ID="ChatThreadID123"
ALL_MESSAGES=()
CURSOR=""

while true; do
  if [ -z "$CURSOR" ]; then
    URL="https://platform.quip.com/1/messages/$THREAD_ID?count=200"
  else
    URL="https://platform.quip.com/1/messages/$THREAD_ID?count=200&max_created_usec=$CURSOR"
  fi

  BATCH=$(curl -s -H "Authorization: Bearer $QUIP_ACCESS_TOKEN" "$URL")

  COUNT=$(echo "$BATCH" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")
  echo "Fetched $COUNT messages..."

  # Process messages in this batch
  echo "$BATCH" | python3 -c "
import json, sys, re
msgs = json.load(sys.stdin)
for msg in reversed(msgs):  # API returns newest first; reverse for chronological
    text = re.sub('<[^>]+>', '', msg.get('html', ''))
    ts = msg['created_usec'] // 1000000
    print(f'[{ts}] {msg[\"author_name\"]}: {text.strip()[:200]}')
"

  if [ "$COUNT" -eq 0 ]; then
    break
  fi

  # Get oldest message timestamp as cursor for next page
  CURSOR=$(echo "$BATCH" | python3 -c "
import json,sys
msgs = json.load(sys.stdin)
print(min(m['created_usec'] for m in msgs))
")
done

echo "Done fetching messages."
```

---

## Common Mistakes to Avoid

| Mistake                                  | Correct Approach                                |
| ---------------------------------------- | ----------------------------------------------- |
| `Content-Type: application/json`         | Use `application/x-www-form-urlencoded`         |
| `POST` body as JSON string               | Use `--data-urlencode` flags with curl          |
| Using `axon.quip.com` as API host        | API host is `platform.quip.com`                 |
| Omitting `format=html`                   | Always specify `format=html` for HTML content   |
| Using Markdown in `content`              | Use HTML — Markdown loses fidelity on ingestion |
| Forgetting `section_id` for location 2–5 | Required; extract from `data-section-id` attrs  |
| Echoing `$QUIP_ACCESS_TOKEN` in output   | Never log or display the token                  |
