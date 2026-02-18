# Excalidraw API Reference

Detailed API reference for `@excalidraw/mermaid-to-excalidraw` and `@excalidraw/excalidraw` conversion utilities.

## parseMermaidToExcalidraw

```typescript
import { parseMermaidToExcalidraw } from "@excalidraw/mermaid-to-excalidraw";

parseMermaidToExcalidraw(
  mermaidSyntax: string,
  options?: { fontSize?: number }
): Promise<{ elements: ExcalidrawSkeletonElement[], files: BinaryFiles }>
```

**Parameters:**

| Parameter          | Type                | Description                      |
| ------------------ | ------------------- | -------------------------------- |
| `mermaidSyntax`    | `string`            | Valid Mermaid diagram definition |
| `options.fontSize` | `number` (optional) | Font size for text elements      |

**Returns:** Promise resolving to:

- `elements` - Skeleton Excalidraw elements (not yet fully qualified)
- `files` - Binary file data (used for non-flowchart diagrams that render as images)

**Important:** The returned `elements` are skeleton elements — they must be passed to `convertToExcalidrawElements` before rendering.

## convertToExcalidrawElements

```typescript
import { convertToExcalidrawElements } from "@excalidraw/excalidraw";

convertToExcalidrawElements(
  elements: ExcalidrawSkeletonElement[]
): ExcalidrawElement[]
```

Converts skeleton elements (from `parseMermaidToExcalidraw`) to fully qualified Excalidraw elements with all required properties (IDs, coordinates, styles, etc.).

**Note:** Import from `@excalidraw/excalidraw`, not from `mermaid-to-excalidraw`.

## Full Workflow

```typescript
import { parseMermaidToExcalidraw } from "@excalidraw/mermaid-to-excalidraw";
import { convertToExcalidrawElements } from "@excalidraw/excalidraw";

try {
  const { elements, files } = await parseMermaidToExcalidraw(mermaidSyntax, {
    fontSize: 16,
  });
  const excalidrawElements = convertToExcalidrawElements(elements);
  // Use excalidrawElements and files in Excalidraw component or file export
} catch (e) {
  // Handle parse errors (invalid Mermaid syntax)
  console.error("Failed to parse Mermaid:", e.message);
}
```

## React Component Integration

```tsx
import { Excalidraw } from "@excalidraw/excalidraw";
import "@excalidraw/excalidraw/index.css"; // Required CSS

function DiagramViewer({ mermaidSource }: { mermaidSource: string }) {
  const [initialData, setInitialData] =
    React.useState<ExcalidrawInitialDataState | null>(null);

  React.useEffect(() => {
    parseMermaidToExcalidraw(mermaidSource, { fontSize: 16 })
      .then(({ elements, files }) => ({
        elements: convertToExcalidrawElements(elements),
        files,
      }))
      .then(setInitialData)
      .catch(console.error);
  }, [mermaidSource]);

  if (!initialData) return <div>Loading diagram...</div>;

  return (
    <div style={{ height: "500px", width: "100%" }}>
      <Excalidraw initialData={initialData} />
    </div>
  );
}
```

## .excalidraw File Format

The `.excalidraw` format is JSON with this structure:

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "https://excalidraw.com",
  "elements": [...],
  "appState": {
    "viewBackgroundColor": "#ffffff",
    "gridSize": null
  },
  "files": {}
}
```

**Generate and save:**

```typescript
import { writeFileSync } from "fs";

const excalidrawFile = {
  type: "excalidraw",
  version: 2,
  source: "https://excalidraw.com",
  elements: excalidrawElements,
  appState: { viewBackgroundColor: "#ffffff" },
  files,
};

writeFileSync("output.excalidraw", JSON.stringify(excalidrawFile, null, 2));
```

Open the resulting file at https://excalidraw.com or in the Excalidraw desktop app.

## Supported Flowchart Node Shapes

| Mermaid Syntax | Renders As  | Excalidraw Shape     |
| -------------- | ----------- | -------------------- |
| `A[Text]`      | Rectangle   | `rectangle`          |
| `A{Text}`      | Diamond     | `diamond`            |
| `A((Text))`    | Circle      | `ellipse`            |
| `A>Text]`      | Asymmetric  | Rectangle (fallback) |
| `A[\Text\]`    | Subroutine  | Rectangle (fallback) |
| `A[(Text)]`    | Cylindrical | Rectangle (fallback) |
| `A{{Text}}`    | Hexagon     | Rectangle (fallback) |

## Supported Arrow Types

| Mermaid Syntax   | Description      |
| ---------------- | ---------------- |
| `-->`            | Directed arrow   |
| `---`            | Undirected line  |
| `==>`            | Thick arrow      |
| `-.->`           | Dotted arrow     |
| `--\|label\|-->` | Arrow with label |

**Note:** Cross arrow heads (`--x`) are converted to bar arrow heads.

## Non-Flowchart Handling

For diagram types other than `flowchart` (e.g., sequence, ER, class), the conversion renders the diagram as a static image element in Excalidraw:

- The `files` object contains the rendered image data
- The `elements` array contains a single image element referencing the file
- The image is not interactive — it's a rasterized snapshot

To confirm a diagram will render natively, check: `elements[0].type !== "image"`.

## Error Handling

```typescript
try {
  const result = await parseMermaidToExcalidraw(mermaidSyntax);
  // success
} catch (e) {
  if (e.message.includes("Parse error")) {
    // Invalid Mermaid syntax — validate at https://mermaid.live
  } else {
    // Other conversion error
    throw e;
  }
}
```

## Common Issues

**`convertToExcalidrawElements` not found:**

- Ensure importing from `@excalidraw/excalidraw`, not `@excalidraw/mermaid-to-excalidraw`
- Verify package version supports this export (`>=0.17.0`)

**Diagram renders as image instead of shapes:**

- Only `flowchart` / `graph` diagrams produce native shapes
- Switch to `flowchart TD` or `flowchart LR`

**Missing CSS styles:**

- Add `import "@excalidraw/excalidraw/index.css"` to your entry point

**Server-side rendering (SSR) issues:**

- Excalidraw is client-only; wrap component with dynamic import or `use client`
- Next.js: `const Excalidraw = dynamic(() => import("@excalidraw/excalidraw").then(m => m.Excalidraw), { ssr: false })`
