# Diagram Review Checklist

Full checklist for reviewing Mermaid diagrams, Excalidraw conversion code, and `.excalidraw` files.

---

## P0 - Critical (Must Fix Before Merge)

### Mermaid Syntax

- [ ] **M0-1** Diagram parses without error (validate at mermaid.live or in renderer)
- [ ] **M0-2** No duplicate node IDs in the same diagram
- [ ] **M0-3** All referenced nodes are defined (no dangling edge targets)
- [ ] **M0-4** Subgraph IDs do not conflict with node IDs

### Excalidraw Conversion Code

- [ ] **E0-1** `parseMermaidToExcalidraw` called with `await` (it returns a Promise)
- [ ] **E0-2** `convertToExcalidrawElements` imported from `@excalidraw/excalidraw`, NOT from `@excalidraw/mermaid-to-excalidraw`
- [ ] **E0-3** Both return values used: `const { elements, files } = await parseMermaidToExcalidraw(...)`
- [ ] **E0-4** `files` passed to Excalidraw `initialData` alongside `elements` (required for non-flowchart image fallbacks)

### .excalidraw File Structure

- [ ] **F0-1** Top-level `type` field is `"excalidraw"`
- [ ] **F0-2** Top-level `version` field is present (integer)
- [ ] **F0-3** `elements` field is an array
- [ ] **F0-4** `appState` field is an object
- [ ] **F0-5** `files` field is present (can be empty object `{}`)

---

## P1 - High (Should Fix)

### Mermaid Clarity

- [ ] **M1-1** All nodes have descriptive labels — no bare IDs (`A --> B` without `[text]`)
- [ ] **M1-2** Edge labels are meaningful, not generic (`-->|yes|` not `-->|ok|`)
- [ ] **M1-3** Diagram has a title or is embedded under a descriptive heading in the doc
- [ ] **M1-4** Non-flowchart type used when Excalidraw native shapes are expected — use `flowchart` instead

### Excalidraw Compatibility (when conversion is intended)

- [ ] **M1-5** No FontAwesome icons in node labels (`fa:fa-user`) — renders as text only
- [ ] **M1-6** No Markdown formatting in labels (`**bold**`, `_italic_`) — stripped on conversion
- [ ] **M1-7** No cross arrow heads (`--x`) — converted to bar heads silently
- [ ] **M1-8** Unsupported shape types avoided if native shapes matter: `[\text\]`, `[(text)]`, `{{text}}`, `>text]` all fall back to rectangle

### Excalidraw Conversion Code

- [ ] **E1-1** try/catch wraps the `parseMermaidToExcalidraw` call
- [ ] **E1-2** CSS imported: `import "@excalidraw/excalidraw/index.css"` in entry point
- [ ] **E1-3** Next.js/SSR: Excalidraw loaded with dynamic import (`ssr: false`) or `use client` directive
- [ ] **E1-4** Loading state shown while async conversion runs (not blank/flash)
- [ ] **E1-5** Hardcoded Mermaid strings extracted to named constants (not inline template literals)

---

## P2 - Medium (Consider Fixing)

### Mermaid Structure

- [ ] **M2-1** Diagrams with 8+ nodes use `subgraph` to group related nodes
- [ ] **M2-2** Consistent direction — no unexplained mixing of `TD` and `LR` in a single diagram
- [ ] **M2-3** Diagrams with 15+ nodes consider splitting into multiple smaller diagrams
- [ ] **M2-4** Orphaned nodes (defined but not connected) removed unless intentional
- [ ] **M2-5** Parallel/redundant edges between the same two nodes collapsed or labelled distinctly

### Diagram Type Appropriateness

- [ ] **M2-6** `flowchart` used for process/system diagrams (not `graph`, which is deprecated syntax)
- [ ] **M2-7** `sequenceDiagram` used for time-ordered interactions (not flowchart with manual ordering)
- [ ] **M2-8** `erDiagram` used for data model relationships (not flowchart with manual cardinality labels)
- [ ] **M2-9** `classDiagram` used for OOP/type hierarchies

### Excalidraw Code Quality

- [ ] **E2-1** `fontSize` option passed explicitly if consistent sizing matters (default is implementation-dependent)
- [ ] **E2-2** Component handles empty `elements` array gracefully (diagram with no nodes)
- [ ] **E2-3** `.excalidraw` files committed to repo have `appState.viewBackgroundColor` set

---

## P3 - Low (Nice to Have)

### Mermaid Style

- [ ] **M3-1** Node labels use title case for proper nouns, lowercase for actions
- [ ] **M3-2** Long labels (>40 chars) broken onto multiple lines using `<br/>`
- [ ] **M3-3** `click` interactions added for nodes that link to external docs (GitHub-rendered Mermaid supports this)
- [ ] **M3-4** Diagram source file named descriptively (not `diagram.md`, but `auth-flow.md`)

### Documentation Integration

- [ ] **M3-5** Diagram is surrounded by prose explaining what it shows and why
- [ ] **M3-6** If both Mermaid source and `.excalidraw` export exist, they are kept in sync
- [ ] **M3-7** Complex diagrams have a legend for non-obvious shapes or arrow meanings

---

## Shape Quick Reference

| Want             | Use in Mermaid  | Excalidraw Result          |
| ---------------- | --------------- | -------------------------- | --- | ---------------- |
| Rectangle        | `A[text]`       | ✅ Rectangle               |
| Diamond/decision | `A{text}`       | ✅ Diamond                 |
| Circle/event     | `A((text))`     | ✅ Ellipse                 |
| Labeled arrow    | `A -->          | label                      | B`  | ✅ Arrow + label |
| Grouped nodes    | `subgraph name` | ✅ Frame                   |
| Cylindrical/DB   | `A[(text)]`     | ⚠️ Falls back to rectangle |
| Hexagon          | `A{{text}}`     | ⚠️ Falls back to rectangle |
| Subroutine       | `A[\text\]`     | ⚠️ Falls back to rectangle |

---

## Common Issue Quick Reference

| Issue                                          | Code | Severity | Fix                                  |
| ---------------------------------------------- | ---- | -------- | ------------------------------------ |
| Missing `await` on parseMermaid                | E0-1 | P0       | Add `await`                          |
| Wrong import for `convertToExcalidrawElements` | E0-2 | P0       | Import from `@excalidraw/excalidraw` |
| Raw node IDs as labels                         | M1-1 | P1       | Add `[descriptive text]`             |
| No error handling                              | E1-1 | P1       | Wrap in try/catch                    |
| Missing CSS import                             | E1-2 | P1       | Add index.css import                 |
| SSR crash in Next.js                           | E1-3 | P1       | Use dynamic import with `ssr: false` |
| Non-flowchart for Excalidraw                   | M1-4 | P1       | Switch to `flowchart TD/LR`          |
| No subgraphs on large diagram                  | M2-1 | P2       | Group with `subgraph`                |
| Mixed directions                               | M2-2 | P2       | Pick one direction                   |
| Deprecated `graph` syntax                      | M2-6 | P2       | Use `flowchart`                      |
