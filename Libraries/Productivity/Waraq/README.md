# Waraq

Waraq is the shared productivity editor platform core for the editor family.
It should provide common contracts, artifact lifecycle infrastructure, shell
navigation primitives, and reusable engine harnesses while each product family
keeps its own domain behavior.

## Architecture Direction

Use **Shared Core + Specialized Engines**:

```text
Waraq shared core
  ├── artifact transport and lifecycle contracts
  ├── operation envelopes, logs, snapshots, restore preflight
  ├── command and shell navigation primitives
  ├── shared structured nodes, references, dependency graph primitives
  └── conformance, replay, compaction, lifecycle harnesses

sheet_engine   docs_engine   slide_engine   code_engine   maqal_engine
```

Waraq is shared; behavior stays specialized. Sheets own formulas, docs own rich
text flow, slides own spatial layout, code owns language tooling, and notebooks
own kernel execution.

The Rust core exposes this boundary as typed data through
`waraq_shared_core_boundary()` and as compact JSON through
`waraq_shared_core_boundary_json()` for host tooling and drift tests.
It also exposes engine-id registry helpers such as
`waraq_family_engine_registry()`, `validate_waraq_family_engine_registry()`,
`resolve_waraq_engine_id(...)`, `canonical_waraq_engine_id(...)`, and
`is_waraq_family_engine_id(...)` so family engines can share canonical and
legacy id handling while drift tests keep the registry, resolver, and advertised
id lists aligned. Registered family engines should build readiness kits with
`ArtifactEngineKit::for_waraq_family_engine(...)` so legacy ids are
canonicalized before the shared artifact profile is generated.

## Key Docs

- [Shared core boundary](docs/shared_core_boundary.md)
- [Implementation plan](docs/implementation_plan.md)
- [Core crate README](Core/waraq/README.md)
- [Flutter shell package](Flutter_Plugin/ky_code_editor/README.md)

## Current Package Map

- `Core/waraq`: Rust shared core and artifact contract surface.
- `Core/code_engine`: code-focused domain engine layer.
- `Core/maqal_engine`: notebook-focused domain engine layer.
- `Flutter_Plugin/ky_code_editor`: reusable Flutter shell/sidebar package for
  Waraq editor surfaces.
- `Flutter_Plugin/maqal`: Flutter plugin scaffold for notebook integration.

## Working Rule

Before adding a feature, decide whether it is:

- shared editor infrastructure, which belongs in Waraq core
- domain behavior, which belongs in the relevant engine
- host presentation, which belongs in the Flutter package or app

When in doubt, keep the shared core smaller and make the domain boundary more
explicit.
