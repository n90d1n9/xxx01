# Evolving Waraq into a Multi-Editor Core

The goal is to determine the best architecture for supporting a suite of different productivity editors (Docs, Sheets, Slides, Code, Notebook) under the "Waraq" umbrella.

## Current Direction

Use **Shared Core + Specialized Engines**. The living boundary contract is now
captured in [Waraq Shared Core Boundary](shared_core_boundary.md).

## Historical Review Prompt

> [!IMPORTANT]  
> This was the original review prompt for the architecture decision. The
> accepted direction is now documented in
> [Waraq Shared Core Boundary](shared_core_boundary.md).

## Architectural Analysis: One Engine vs. Separate Engines

Currently, `waraq` is deeply optimized for **code editing**. It uses a `Rope` text buffer, `tree-sitter` for syntax, and integrates with LSP and Jupyter kernels. 

### Can one single data structure power all of them?
**No.** The fundamental data structures needed for these editors are too different:
*   **Code Engine (`code_engine`)**: Needs a continuous 1D text stream optimized for fast string insertions/deletions (Rope).
*   **Docs Engine (`docs_engine`)**: Needs a hierarchical tree structure (like DOM) to handle blocks (paragraphs, lists), inline styles (bold, fonts), pagination, and embedded objects.
*   **Sheet Engine (`sheet_engine`)**: Needs a 2D sparse matrix for cells, paired with a Directed Acyclic Graph (DAG) for formula dependency evaluation.
*   **Slide Engine (`slide_engine`)**: Needs a 2D Scene Graph for absolute positioning of shapes, text boxes, and images on a fixed-size canvas.

### The Solution: Shared Core + Specialized Engines

While they cannot share the *same data structure*, they **should absolutely share the same underlying platform core**. If we give each their own completely isolated engine from scratch, we will duplicate thousands of lines of code for things like file saving, undo/redo logic, theming, and AI.

I propose splitting `waraq` into a **Layered Architecture**:

#### Layer 1: The Waraq Core Platform (`waraq-core`)
This will be the universal foundation that *all* engines depend on. It handles:
*   **Workspace & Files**: File System abstraction, Virtual File System (VFS), dirty state tracking.
*   **Command & History System**: A generic Undo/Redo stack that accepts abstract commands (so it can undo a text edit in `code`, or a cell format in `sheet`).
*   **Collaboration System**: CRDT abstractions and networking for real-time multiplayer.
*   **Extension/Plugin API**: Unified command palette, keybindings, and VS Code-style extensions.
*   **AI Integration**: Shared LLM client, prompt building, and agent task queues.
*   **Theming**: Global color tokens, light/dark mode support.

#### Layer 2: Specialized Data Engines
These engines depend on `waraq-core` and implement the actual logic for their respective domains:
*   **`code_engine`**: Moves the Rope buffer, tree-sitter, and LSP from the current `waraq` here.
*   **`docs_engine`**: Implements a Block-Tree / Operational Transformation model for rich text formatting.
*   **`sheet_engine`**: Implements a grid quad-tree and a formula evaluation engine.
*   **`slide_engine`**: Implements a Canvas Scene Graph.
*   **`maqal_engine`**: Acts as a hybrid orchestrator. It uses `code_engine` for code cells, `docs_engine` for rich text markdown cells, and adds the Jupyter kernel bridge.

## Proposed Changes

If approved, the implementation plan to achieve this will be executed in phases:

### Phase 1: Extract `waraq-core`
1. Rename the existing `waraq` crate or create a new `waraq-core` package.
2. Extract the non-text-specific subsystems from `waraq/src/` (e.g., extensions, AI, workspace configuration) into `waraq-core`.

### Phase 2: Isolate `code_engine` and `maqal_engine`
1. Move the `rope`, `syntax`, and `lsp` modules into a distinct `code_engine` library.
2. Move the `notebook` module into `maqal_engine`.
3. Update `Cargo.toml` dependencies so these engines import `waraq-core`.

### Phase 3: Scaffold New Engines
1. Initialize `docs_engine`, `sheet_engine`, and `slide_engine` with their fundamental data structures.
2. Wire them up to use `waraq-core`'s undo/redo and workspace systems.

## Open Questions

> [!WARNING]
> 1. **Current `waraq` usage:** Are there existing UI clients (like an Electron/Tauri app or Web front-end) currently relying heavily on the exact C/WASM bindings of `waraq`? Changing the architecture will break the current FFI boundaries unless we provide a compatibility layer.
> 2. **Prioritization:** Which engine (after code/notebook) is the highest priority for you right now? Docs, Sheets, or Slides?

## Verification Plan
*   **Automated Tests**: Ensure `cargo test` passes for the extracted `waraq-core` and `code_engine`.
*   **Benchmarks**: Verify `cargo bench` to ensure the extraction doesn't degrade text buffer performance.
