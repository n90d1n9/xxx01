# Waraq Shared Core Boundary

Waraq should be a shared editor platform core, not one giant behavior engine.
Each product family should keep a specialized domain engine for its own model,
validation, replay semantics, and rendering behavior.

## Decision

Use **Shared Core + Specialized Engines**.

Waraq provides the common substrate that every editor family needs:

- stable operation envelopes and artifact transport
- operation logs, snapshots, restore preflight, lifecycle/readiness reporting
- command and shell navigation contracts
- shared editor infrastructure such as workspace/session state, selection,
  undo/redo, search, decorations, structured nodes, dependency references, and
  host-facing discovery APIs
- reusable conformance, replay, compaction, and lifecycle harnesses

Domain engines provide the behavior that makes each editor family different:

- `sheet_engine`: cell grid, formulas, dependency evaluation, sheet ranges
- `docs_engine`: rich text blocks, styles, pagination, comments, references
- `slide_engine`: scene graph, spatial layout, shapes, z-order, transitions
- `code_engine`: rope text, language tooling, syntax, LSP, refactoring
- `maqal_engine`: notebook cells, kernel execution, outputs, mixed media

This gives every editor a shared contract without forcing sheets, docs, slides,
code, and notebooks into the same data structure.

## Canonical Engine IDs

New Waraq-family artifacts should use these canonical ids:

| Engine | Canonical id | Current legacy id |
| --- | --- | --- |
| `sheet_engine` | `sheet.engine` | - |
| `docs_engine` | `docs.engine` | - |
| `slide_engine` | `slide.engine` | - |
| `code_engine` | `code.engine` | `code` |
| `maqal_engine` | `maqal.engine` | `maqal` |

The Rust core exposes the same information through
`waraq_shared_core_boundary()` so host tooling can inspect the boundary contract
without parsing Markdown. Use `waraq_shared_core_boundary_json()` when a tool
needs the same manifest as compact JSON.
Use `waraq_family_engine_registry()` when a tool or domain-engine test needs
only the canonical ids, legacy aliases, and registered engine records. Use
`validate_waraq_family_engine_registry()` to catch drift between the registry,
resolver, and advertised id lists before a host or product engine consumes an
inconsistent identity surface.
Use `resolve_waraq_engine_id(...)`, `canonical_waraq_engine_id(...)`, and
`is_waraq_family_engine_id(...)` when engines or host probes need to validate a
canonical id or migrate a legacy id such as `code` to `code.engine`.
Use `ArtifactEngineKit::for_waraq_family_engine(...)` when a registered family
engine needs the shared artifact contract, readiness profile, and lifecycle
checklist built from the canonical id.

## Ownership Matrix

| Concern | Waraq core owns | Domain engine owns |
| --- | --- | --- |
| Engine identity | contract shape for engine ids | stable id such as `docs.engine` |
| Operation transport | `OperationEnvelope`, `OperationLog`, artifact validation | domain edit enum and edit meaning |
| Snapshot transport | generic snapshot-plus-tail artifact shape | domain snapshot structure |
| Restore preflight | shared envelope/schema/wrong-engine checks | domain reference/range/object validation |
| Replay | harness contract and failure expectations | mutation semantics and no-partial-mutation policy |
| Compaction | shared planning, retained-tail metadata, lifecycle checks | rebuilding a domain snapshot from compacted edits |
| Commands | shell command model and navigation contracts | product-specific commands and shortcuts |
| UI shell | shared sidebar/info/navigation models | product panes, inspectors, toolbars, canvas/editing UI |
| Dependency graph | reusable graph primitives | formula, notebook, layout, or reference rules |

## Boundary Rules

- Keep Waraq reusable. Do not move formula rules, rich-text rules, slide layout,
  language-specific logic, or kernel execution rules into Waraq core.
- Keep domain engines thin but real. They should use Waraq artifacts and
  lifecycle harnesses, while owning their domain snapshot, edit enum, replay,
  and validation.
- Keep host UI separate from engine behavior. Flutter packages should compose
  shell/navigation/pane models and delegate product behavior to the relevant
  engine.
- Add shared abstractions only when two or more editor families need the same
  contract and the abstraction does not encode one family behavior.
- Prefer capability-style APIs over one-off helper calls when the surface will
  be used by command palettes, menus, shortcuts, tests, and external hosts.

## Required Engine Checklist

Every Waraq-family engine should:

- declare one stable engine id
- define a serializable domain edit enum
- define a serializable domain snapshot model
- alias Waraq artifact primitives for its domain types
- expose a readiness manifest based on Waraq's shared contract
- validate shared artifact conformance with Waraq helpers
- validate domain replay, including wrong-engine, wrong-document, invalid
  reference/range/object, and no-partial-mutation cases
- use shared artifact maintenance planning before domain compaction
- add compaction and lifecycle harness coverage when compaction is supported
- update capability or contract versions only when host-visible behavior changes

## Flutter Host Boundary

The Flutter shell layer should stay presentation-oriented:

- `WaraqShell` owns shared navigation layout.
- `WaraqDestinationRegistry` owns host destination composition.
- `WaraqShellCommand` owns stable shell navigation command metadata.
- `WaraqShellController` owns selected shell destination state.
- Host apps own the actual product panes and domain-specific interactions.

This keeps the shell reusable across code, docs, sheets, slides, and notebooks
without letting a UI package become the product engine.

## Anti-Patterns

Avoid:

- one universal data structure for every editor family
- separate product engines that invent incompatible artifact contracts
- giant cross-product classes that mix formulas, layout, rich text, language
  tooling, and notebook execution
- UI widgets that directly encode domain replay or persistence behavior
- domain engines that bypass shared artifact validation and lifecycle tests

## Short Answer

Yes, Waraq can be the same core engine for the editor family, but only as a
shared platform and contract layer. Each editor still needs its own specialized
engine behavior.
