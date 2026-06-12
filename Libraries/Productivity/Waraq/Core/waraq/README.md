# waraq-editor-core

High-performance, cross-platform code editor engine in Rust.

## Stats

- **34,000+ lines** of Rust source
- **1,000+ tests** across all modules
- **238 C exports** for FFI
- **71 source files** across 8 subsystems

## Architecture

```
waraq-editor-core/
├── src/
│   ├── core/          # Buffer, cursor, structured model, dependency graph...
│   ├── syntax/        # Tokenizer, highlighting, folding, brackets
│   ├── ai/            # Inline completion, agent, diff, context, prompts
│   ├── lsp/           # JSON-RPC client, protocol types, transport
│   ├── ext/           # Extension system (VS Code-compatible)
│   ├── notebook/      # Jupyter notebook engine
│   └── ffi/           # C API, WASM, JSON batch bridge
├── bindings/
│   ├── dart/          # Flutter/Dart FFI (566 lines)
│   ├── java/          # Java 21 FFM API (467 lines)
│   └── wasm/          # TypeScript/WASM (374 lines)
├── benches/           # Criterion benchmarks (14 functions)
├── tests/             # Integration tests (95 tests)
└── waraq_editor_core.h  # C header (331 lines)
```

## Product Engine Strategy

Decision: **Shared Core + Specialized Engines**.

`waraq` should remain the shared core engine, while each product keeps a
thin domain engine for its own behavior:

For the concise workspace-level boundary contract, see
[`docs/shared_core_boundary.md`](../../docs/shared_core_boundary.md).
Rust tooling can inspect the same contract with
`waraq_shared_core_boundary()` or serialize it with
`waraq_shared_core_boundary_json()`.
Use `waraq_family_engine_registry()` when tooling needs the canonical ids,
legacy aliases, and engine records without the full boundary manifest. Use
`validate_waraq_family_engine_registry()` in drift tests so the registry,
resolver, and advertised id lists stay aligned.
Use `resolve_waraq_engine_id(...)`, `canonical_waraq_engine_id(...)`, and
`is_waraq_family_engine_id(...)` when a domain engine or host probe needs to
validate canonical ids or migrate legacy ids like `code` and `maqal`.

```text
waraq core
  ├── text buffers, cursor, undo, search, decorations
  ├── semantic document model
  ├── dependency graph
  ├── extension, LSP, AI, notebook primitives
  ↓
sheet_engine  docs_engine  slide_engine  code_engine  maqal_engine
```

This avoids five incompatible editors without forcing every product into a
code-editor shape. Sheets own formulas and cell addressing, docs own rich-text
flow, slides own spatial layout, code owns language tooling, and notebooks own
kernel execution. The shared `StructuredDocument` and `DependencyGraph` provide
the common substrate: stable nodes, text regions, metadata, references, and
recalculation/execution ordering.

### Engine Boundary

Waraq owns reusable editor infrastructure and shared artifact transport. Domain
engines own product behavior. The boundary should stay explicit so Waraq can
serve sheets, docs, slides, code, and notebooks without becoming a giant class
or forcing every product to behave like a code editor.

Waraq owns:

- Text buffers, cursor movement, selection, undo/redo, search, formatting hooks,
  decorations, viewport state, and workspace/session primitives.
- Shared structured-document primitives: `StructuredDocument`, semantic nodes,
  text regions, metadata, references, and `DependencyGraph`.
- Shared artifact transport: `OperationEnvelope<Edit>`, `OperationLog<Edit>`,
  `OperationArtifact<Snapshot, Edit>`, schema validation, operation ordering,
  duplicate detection, wrong-engine rejection, wrong-document rejection, JSON
  round-trips, and snapshot-plus-tail artifact shape.
- Shared artifact maintenance planning: `ArtifactMaintenancePolicy`,
  `ArtifactMaintenancePlan`, retained-tail splitting, and the standard
  compaction metadata shape. Engines can use `artifact_compaction_info(...)`
  and `ARTIFACT_COMPACTION_METADATA_KEY` to inspect shared compaction metadata
  without hard-coded metadata keys. Engines can use
  `compact_artifact_with_replayed_prefix(...)` so Waraq handles the shared
  split/log/metadata work while the domain engine only replays the compacted
  prefix into its own snapshot model. Engines can then use
  `maintain_artifact_with_plan(...)` to share the final compact-or-preserve
  branch after they build any domain-validated maintenance plan, or
  `maintain_artifact_with_plan_outcome(...)` when hosts need a typed
  preserved-or-compacted result.
- Host-facing artifact discovery through `editor_artifact_capabilities_json`,
  `editor_artifact_capabilities_result_json`, `editor_artifact_contract_json`,
  `editor_artifact_contract_result_json`, `editor_artifact_boundary_json`,
  `editor_artifact_boundary_result_json`,
  `editor_artifact_engine_registry_json`,
  `editor_artifact_engine_registry_result_json`,
  `editor_artifact_resolve_engine_id_result_json`,
  `editor_artifact_engine_contract_result_json`,
  `editor_artifact_engine_readiness_manifest_result_json`,
  `editor_artifact_readiness_manifest_json`,
  `editor_artifact_test_profile_json`,
  `editor_artifact_lifecycle_profile_json`, and
  `editor_artifact_restore_preflight_result_json`, plus
  `artifact_contract_description(...)`.
- Reusable test/probe helpers such as `validate_artifact_conformance(...)` for
  checking the shared artifact contract in each domain engine, plus
  `domain_artifact_test_profile(...)` for discovering the full shared
  conformance/replay/compaction/lifecycle checklist. Engines can use
  `validate_domain_artifact_test_profile(...)` to catch profile drift,
  `validate_domain_artifact_test_profile_report(...)` when tooling needs the
  validated helper/check counts,
  `validate_artifact_lifecycle_harness(...)` when they want one representative
  test to compose conformance, replay, and compaction checks, then
  `validate_artifact_lifecycle_profile(...)` to verify the report against the
  engine's advertised shared profile, or
  `validate_artifact_lifecycle_profile_report(...)` when tooling needs the
  validated profile and lifecycle counts together.

Each domain engine owns:

- Its stable engine id, such as `sheet.engine`, `docs.engine`, `slide.engine`,
  `code.engine`, or `maqal.engine`.
- Its serializable edit enum and snapshot model.
- Domain validation: formula references, rich-text ranges, slide object ids,
  code-language edits, notebook cell/output/kernel state, and any other
  product-specific invariants.
- Replay semantics and failure policy. Waraq validates the transport envelope;
  the domain engine decides how edits change the domain model and how to avoid
  partial mutation on failed replay.
- Domain compaction execution: how a compacted operation prefix is replayed into
  a new domain snapshot.

When adding or changing a domain engine, prefer this checklist:

- Use the shared artifact primitives instead of inventing a parallel operation
  log format.
- Keep domain behavior in the domain crate; do not move formula, layout,
  rich-text, language, or kernel rules into Waraq core.
- Start with `ArtifactEngineKit::for_waraq_family_engine(ENGINE_ID)` to obtain
  the canonical engine id, shared contract, domain test profile, and validated
  readiness counts from one place. Use
  `ArtifactEngineKit::for_waraq_family_engine_with_compaction(ENGINE_ID, false)`
  only for registered family engines that intentionally omit compaction.
- For tooling that caches the full family list, call
  `waraq_family_engine_registry()` and assert
  `validate_waraq_family_engine_registry()` in one drift test.
- Expose `kit.readiness_manifest()` when host tooling needs one compact
  serializable summary of the contract, required helpers, check counts, and
  lifecycle requirement.
- Add a representative artifact test using `validate_artifact_conformance(...)`.
  Assert that `completed_checks` matches
  `REQUIRED_ARTIFACT_CONFORMANCE_CHECKS` so the engine proves every shared
  transport invariant Waraq expects.
- Use `domain_artifact_test_profile(ENGINE_ID)` to keep the engine's
  conformance, replay, compaction, and lifecycle tests aligned with Waraq's
  shared required check lists. Assert
  `validate_domain_artifact_test_profile(&profile)` so stale helpers and check
  lists fail in one place, or use
  `validate_domain_artifact_test_profile_report(&profile)` when the test or
  host needs the validated counts.
- Add domain replay tests for valid replay, wrong-engine rejection,
  wrong-document rejection, invalid references/ranges, and no partial mutation
  after failure.
- Use `ArtifactMaintenancePolicy` and `plan_artifact_maintenance(...)` for
  shared operation-tail growth decisions before implementing domain-specific
  compaction.
- Use `compact_artifact_with_replayed_prefix(...)` for compaction mechanics
  when the engine's snapshot type can be rebuilt from a compacted prefix log.
- Use `maintain_artifact_with_plan(...)` after the engine's planning wrapper so
  skip behavior and compacted-tail retention stay consistent.
- Use `maintain_artifact_with_plan_outcome(...)` for host-facing wrappers that
  need to report `ArtifactMaintenanceAction`, the maintenance plan, and
  compaction metadata without re-inspecting the artifact.
- Add a representative compaction harness test using
  `validate_artifact_compaction_harness(...)`. Assert that `completed_checks`
  matches `REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS` so compaction proves
  restore equivalence, retained-tail shape, metadata, required-compact policy,
  skip policy, and shared invalid-artifact rejection.
- Add one representative lifecycle harness test using
  `validate_artifact_lifecycle_harness(...)` when the engine supports
  conformance, replay, and compaction. Assert that
  `validate_artifact_lifecycle_profile(...)` accepts the report, or use
  `validate_artifact_lifecycle_profile_report(...)` when the test or host needs
  the validated counts, so the composed lifecycle proof stays aligned with
  Waraq's checklist.
- Update capability or contract versions only when the host-visible shape
  changes.

### Building a Waraq-Family Engine

A domain engine should be thin around its own model and explicit about where
Waraq's shared contract starts. Use this shape for docs, sheets, slides, code,
notebooks, and future editor families:

```rust
use serde::{Deserialize, Serialize};
use waraq_core::{
    artifact_compaction_info,
    compact_artifact_with_replayed_prefix,
    domain_artifact_test_profile,
    maintain_artifact_with_plan,
    maintain_artifact_with_plan_outcome,
    plan_artifact_maintenance, ArtifactMaintenanceAction, ArtifactMaintenancePolicy,
    validate_waraq_family_engine_registry,
    waraq_family_engine_registry,
    validate_artifact_compaction_harness, validate_artifact_conformance,
    validate_artifact_lifecycle_harness,
    validate_artifact_lifecycle_profile,
    validate_artifact_lifecycle_profile_report,
    validate_artifact_replay_harness,
    validate_domain_artifact_test_profile,
    validate_domain_artifact_test_profile_report,
    ArtifactEngineKit, ArtifactEngineKitBuildError, ArtifactEngineReadinessManifest,
    OperationArtifact, OperationEnvelope, OperationLog,
    ARTIFACT_COMPACTION_METADATA_KEY,
    REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS, REQUIRED_ARTIFACT_CONFORMANCE_CHECKS,
    REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS,
};

pub const ENGINE_ID: &str = "docs.engine";

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum DomainEdit {
    // Domain-owned operations, such as rich-text, formula, shape, or cell edits.
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DomainSnapshot {
    // Domain-owned persisted state.
}

pub type DomainOperation = OperationEnvelope<DomainEdit>;
pub type DomainOperationLog = OperationLog<DomainEdit>;
pub type DomainArtifact = OperationArtifact<DomainSnapshot, DomainEdit>;

pub fn domain_artifact_kit() -> Result<ArtifactEngineKit, ArtifactEngineKitBuildError> {
    ArtifactEngineKit::for_waraq_family_engine(ENGINE_ID)
}

pub fn domain_readiness_manifest() -> Result<ArtifactEngineReadinessManifest, ArtifactEngineKitBuildError> {
    Ok(domain_artifact_kit()?.readiness_manifest())
}

pub fn assert_domain_registry_is_current() {
    validate_waraq_family_engine_registry().expect("Waraq family-engine registry drifted");
    assert!(waraq_family_engine_registry()
        .canonical_engine_ids
        .contains(&ENGINE_ID));
}

pub fn plan_domain_artifact_maintenance(
    artifact: &DomainArtifact,
    policy: ArtifactMaintenancePolicy,
) -> Result<waraq_core::ArtifactMaintenancePlan, waraq_core::OperationLogError> {
    plan_artifact_maintenance(artifact, policy, ENGINE_ID)
}
```

The restore path should stay predictable:

1. Validate the artifact with `artifact.validate_for_engine(ENGINE_ID)`.
2. Rebuild domain state from `DomainSnapshot`.
3. Replay the retained `DomainOperationLog` against evolving state.
4. Validate domain references, ranges, object ids, formulas, cells, or layout
   constraints before each mutation.
5. Return an error without partially mutating state when validation fails.

Every engine should keep one representative artifact test that calls
`validate_artifact_conformance(ENGINE_ID, &artifact)` and asserts
`report.completed_checks == REQUIRED_ARTIFACT_CONFORMANCE_CHECKS`. It should
also use `validate_artifact_replay_harness(...)` to check valid restore,
wrong-engine rejection, wrong-document rejection, and failed replay with no
partial mutation, asserting
`report.completed_checks == REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS`. Engines
that expose compaction should also use
`validate_artifact_compaction_harness(...)` to check restore equivalence,
retained tail length, compaction metadata, operation-log metadata,
required-compact policy behavior, skip-policy behavior, and invalid-artifact
rejection, asserting
`report.completed_checks == REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS`. Then
add one `validate_artifact_lifecycle_harness(...)` test to prove the composed
conformance, replay, and compaction lifecycle in a single place, and pass its
report to `validate_artifact_lifecycle_profile(...)`. Finally, add
domain-specific replay tests for product references or ranges that Waraq cannot
understand.

For tooling or drift tests in registered product-family engines, prefer
`ArtifactEngineKit::for_waraq_family_engine(ENGINE_ID)`. It validates and
canonicalizes the id through Waraq's engine-id registry before returning the
shared contract, serializable test profile, and validated helper/check counts
together. Use `ArtifactEngineKit::for_engine(ENGINE_ID)` only for generic test
engines or experiments outside the registered family id list. Use
`kit.readiness_manifest()` when a host or dashboard needs a compact
serializable readiness summary without embedding the full profile checklist.
Use `domain_artifact_test_profile(ENGINE_ID)` when an engine only needs the raw
profile shape. Use
`validate_domain_artifact_test_profile(...)` when a test or host probe needs to
ensure the profile itself still matches Waraq's current shared checklist. Use
`validate_domain_artifact_test_profile_report(...)` when tooling also needs the
validated helper and shared-check counts. Lifecycle harness tests can use
`kit.validate_lifecycle_harness(...)` to run the composed harness and profile
validation in one call. Lower-level tests can compare
`completed_shared_check_count` against
`profile.required_lifecycle_shared_check_count()`, or use
`validate_artifact_lifecycle_profile_report(...)` when tooling needs to
validate a separately produced lifecycle proof.

Long-lived engines should also expose a small maintenance-planning wrapper
around `plan_artifact_maintenance(...)` so hosts can cap operation-tail growth
the same way across docs, sheets, slides, code, and notebooks. The actual
compaction step remains domain-owned because each engine must replay the
compacted prefix into its own snapshot model, but engines should prefer
`compact_artifact_with_replayed_prefix(...)` for the shared artifact mechanics.
Use `maintain_artifact_with_plan(...)` after any engine-specific planning
validation to keep the compact-or-preserve branch shared. Hosts or tests that
need to inspect compaction metadata should use `artifact_compaction_info(...)`
or `ARTIFACT_COMPACTION_METADATA_KEY` instead of spelling the metadata key in
each engine. If a host needs to know what maintenance did without re-parsing
the artifact, expose a domain wrapper around
`maintain_artifact_with_plan_outcome(...)`.

### Artifact Versioning Policy

Waraq tracks three related but different artifact versions. Bump the smallest
version scope that describes the host-visible change.

- `OPERATION_ENVELOPE_VERSION`: bump when the serialized shape or validation
  contract of `OperationEnvelope<Edit>`, `OperationLog<Edit>`, or
  `OperationArtifact<Snapshot, Edit>` changes. Examples include adding a
  required field, changing schema defaults, changing operation-log ordering
  rules, or changing document/engine validation in a way that affects stored
  artifacts.
- `ARTIFACT_CONTRACT_VERSION`: bump when the shared artifact contract vocabulary
  or guarantees change. It currently follows `OPERATION_ENVELOPE_VERSION`
  because the envelope schema is the only shared contract dimension. If future
  contract changes are host-visible but do not alter envelope serialization,
  split this into an independent version.
- `ARTIFACT_API_VERSION`: bump when the artifact FFI discovery or callable API
  changes. Examples include adding/removing/renaming an FFI function, changing
  `editor_artifact_capabilities_json`, changing `editor_artifact_contract_json`,
  changing `editor_artifact_boundary_json`, changing
  `editor_artifact_engine_registry_json`, changing
  `editor_artifact_resolve_engine_id_result_json`, changing
  `editor_artifact_engine_contract_result_json`, changing
  `editor_artifact_engine_readiness_manifest_result_json`, changing
  `editor_artifact_readiness_manifest_json`, changing
  `editor_artifact_test_profile_json`, changing
  `editor_artifact_lifecycle_profile_json`, changing result-envelope shape, or
  changing stable error-code names.

When any host-visible artifact shape changes:

- Update the related constant first.
- Update the golden fixtures in `src/ffi/artifact_api/fixtures/`.
- Keep nullable metadata calls and their `_result_json` variants aligned with
  the changed surface.
- Run the focused golden tests before the full workspace tests.

Do not bump artifact versions for internal refactors, private helper changes,
additional tests, or domain-engine behavior changes that do not affect Waraq's
shared artifact transport or FFI discovery surface.

### Artifact Host Workflow

A minimal host integration usually follows this sequence:

```c
char* caps = editor_artifact_capabilities_json();
char* caps_result = editor_artifact_capabilities_result_json();
char* contract = editor_artifact_contract_json();
char* contract_result = editor_artifact_contract_result_json();
char* boundary = editor_artifact_boundary_json();
char* boundary_result = editor_artifact_boundary_result_json();
char* engine_registry = editor_artifact_engine_registry_json();
char* engine_registry_result = editor_artifact_engine_registry_result_json();
char* engine_resolution = editor_artifact_resolve_engine_id_result_json("code");
char* engine_contract = editor_artifact_engine_contract_result_json("code");
char* engine_readiness = editor_artifact_engine_readiness_manifest_result_json("code");
char* readiness = editor_artifact_readiness_manifest_json();
char* profile = editor_artifact_test_profile_json();
char* lifecycle = editor_artifact_lifecycle_profile_json();
char* readiness_result = editor_artifact_readiness_manifest_result_json();
char* profile_result = editor_artifact_test_profile_result_json();
char* lifecycle_result = editor_artifact_lifecycle_profile_result_json();
/* Parse or cache discovery JSON before creating artifacts. */
editor_free_str(caps);
editor_free_str(caps_result);
editor_free_str(contract);
editor_free_str(contract_result);
editor_free_str(boundary);
editor_free_str(boundary_result);
editor_free_str(engine_registry);
editor_free_str(engine_registry_result);
editor_free_str(engine_resolution);
editor_free_str(engine_contract);
editor_free_str(engine_readiness);
editor_free_str(readiness);
editor_free_str(profile);
editor_free_str(lifecycle);
editor_free_str(readiness_result);
editor_free_str(profile_result);
editor_free_str(lifecycle_result);

EditorHandle* editor = editor_create_with_content("hello");
editor_set_file_uri(editor, "file:///main.txt");

char* op = editor_operation_insert_json(
    "op-1",
    "file:///main.txt",
    "actor-1",
    1,
    100,
    5,
    " world"
);

char* log0 = editor_operation_log_empty_json();
char* log1 = editor_operation_log_append_json(log0, op);

char* artifact = editor_artifact_capture(editor, "file:///main.txt", log1);
char* restore_preflight = editor_artifact_restore_preflight_result_json(artifact);
/* Parse restore_preflight and continue only when ok=true and restore_ready=true. */
EditorHandle* restored = editor_artifact_restore(artifact);
char* restored_text = editor_get_text(restored);
/* restored_text == "hello world" */

editor_free_str(restored_text);
editor_destroy(restored);
editor_free_str(restore_preflight);
editor_free_str(artifact);
editor_free_str(log1);
editor_free_str(log0);
editor_free_str(op);
editor_destroy(editor);
```

Every returned `char*` is Rust-owned and must be released with
`editor_free_str`. Every `EditorHandle*` must be released with `editor_destroy`.
Artifact FFI numeric parameters use fixed-width `uint64_t`; result-oriented
variants return `integer_out_of_range` if a host-provided offset or counter
cannot fit the current platform's in-memory index type.
Production hosts should prefer the result-oriented variants, such as
`editor_artifact_capabilities_result_json`,
`editor_artifact_contract_result_json`,
`editor_artifact_boundary_result_json`,
`editor_artifact_engine_registry_result_json`,
`editor_artifact_resolve_engine_id_result_json`,
`editor_artifact_engine_contract_result_json`,
`editor_artifact_engine_readiness_manifest_result_json`,
`editor_operation_insert_result_json`, `editor_operation_log_append_result_json`,
and `editor_artifact_capture_result_json`, because they return stable
`{ ok, value, error }` envelopes instead of only null-on-failure behavior.
Use `editor_artifact_resolve_engine_id_result_json` when accepting
Waraq-family engine ids from config, plugins, or older bindings; it canonicalizes
known legacy aliases such as `code` to `code.engine` and reports whether the
input was canonical or legacy.
Use `editor_artifact_engine_contract_result_json` when host tooling needs the
shared artifact contract scoped to a registered product-family engine id; it
accepts the same canonical ids and legacy aliases as the resolver.
Use `editor_artifact_engine_readiness_manifest_result_json` when host tooling
needs the shared readiness checklist for a registered product-family engine; it
accepts the same canonical ids and legacy aliases as the resolver, then returns
the compact manifest for the canonical engine id.
Call `editor_artifact_restore_preflight_result_json` before
`editor_artifact_restore` when opening saved artifacts; restore still returns an
opaque `EditorHandle*`, while preflight returns host-readable diagnostics and a
`restore_ready` success flag.
Readiness probes also have result-oriented variants:
`editor_artifact_readiness_manifest_result_json`,
`editor_artifact_test_profile_result_json`, and
`editor_artifact_lifecycle_profile_result_json`.
Long-lived hosts should also run `editor_artifact_maintenance_plan` and
`editor_artifact_maintain` so operation tails do not grow without compaction.
The same flow is available as a syntax-checked native example in
`examples/artifact_host_workflow.c`.

To build, link, and run the native example against Waraq's static library:

```sh
sh examples/smoke_artifact_host_workflow.sh
```

The smoke script runs `cargo build --offline`, compiles the C host with
`-std=c11 -Wall -Wextra -Werror`, compiles a C artifact symbol smoke from
`examples/artifact_api_symbols_smoke.c`, compiles a C++17 header/link smoke
from `examples/artifact_header_cpp_smoke.cpp`, links `libwaraq_core.a`, and
executes all checks.

`editor_artifact_capabilities_json` also advertises `function_catalog` and
`signature_families`. The catalog gives one row per artifact function with its
capability `kind`, `payload_family`, `signature_family`, and `c_signature`;
each signature family then lists all functions sharing that native ABI.
Bindings can use these sections to validate generated declarations against the
loaded runtime before calling into the artifact API.
Capabilities also advertise `payload_families`, which groups functions by the
semantic payload they return directly or as a `_result_json` success `value`.
For example, artifact capture, compaction, and maintenance calls all share the
`artifact` payload family, while operation builders share `operation_envelope`.
The same capability payload embeds `waraq_boundary_manifest` and
`waraq_engine_registry`, `artifact_readiness_manifest`, and advertises the
`waraq_engine_registry`, `waraq_engine_id_resolution`, and
`artifact_contract`/`artifact_readiness_manifest` payload families, so hosts can
perform one discovery call and still cache the shared-core boundary decision,
canonical/legacy engine ids, and compact contract/readiness snapshots.

Hosts that need the architecture contract between Waraq and its product-family
engines can read `waraq_boundary_manifest` from
`editor_artifact_capabilities_json` or call
`editor_artifact_boundary_json` directly. It returns the shared-core decision,
known family engines, the ownership matrix, engine checklist, Flutter host
boundary, and rejected anti-patterns. Host bindings that prefer envelope-based
metadata should call `editor_artifact_boundary_result_json`.
Hosts that only need the known product-family engine ids can read
`waraq_engine_registry` from `editor_artifact_capabilities_json` or call
`editor_artifact_engine_registry_json` directly. It returns the registry version,
canonical ids, accepted legacy aliases, accepted id count, and registered engine
records. Host bindings that prefer envelope-based metadata should call
`editor_artifact_engine_registry_result_json`.
Host bindings that accept engine ids should call
`editor_artifact_resolve_engine_id_result_json` before creating domain-specific
adapters, so canonical ids and supported legacy aliases are handled by the same
registry Waraq uses internally.
Host dashboards and generated bindings can then call
`editor_artifact_engine_contract_result_json` to fetch that family engine's
shared artifact contract, or
`editor_artifact_engine_readiness_manifest_result_json` with the canonical id or
legacy alias to fetch that family engine's shared readiness manifest without
loading the domain engine implementation.

Hosts that need a compact readiness summary for startup checks, dashboards, or
CI can read `artifact_readiness_manifest` from
`editor_artifact_capabilities_json` or call
`editor_artifact_readiness_manifest_json` directly. It returns the validated
Waraq editor readiness manifest with `manifest_version`, contract primitives,
required helper families, check counts, and lifecycle requirements. Hosts that
need lower-level profile counts can call `editor_artifact_test_profile_json`.
It returns the validated domain artifact profile summary for `waraq.editor`,
including helper counts, conformance/replay/compaction check counts, the total
`required_shared_check_count`, and the
`lifecycle_harness_shared_check_count` expected from lifecycle proofs.
Hosts that need to confirm the built-in editor path actually completes that
shared lifecycle can call `editor_artifact_lifecycle_profile_json`. It returns a
validated representative lifecycle proof with `expected_shared_check_count`,
`completed_shared_check_count`, and per-stage completed counts for conformance,
replay, and compaction.
Hosts that need explicit discovery or readiness errors instead of
null-on-failure metadata can call `editor_artifact_capabilities_result_json`,
`editor_artifact_contract_result_json`,
`editor_artifact_boundary_result_json`,
`editor_artifact_engine_registry_result_json`,
`editor_artifact_resolve_engine_id_result_json`,
`editor_artifact_engine_contract_result_json`,
`editor_artifact_engine_readiness_manifest_result_json`,
`editor_artifact_restore_preflight_result_json`,
`editor_artifact_readiness_manifest_result_json`,
`editor_artifact_test_profile_result_json`, and
`editor_artifact_lifecycle_profile_result_json`.

### Artifact Result Envelope

Result-oriented artifact functions end in `_result_json` and return compact
JSON with the `ok_value_error` envelope advertised by
`editor_artifact_capabilities_json`.
Capabilities also include `result_envelope_schema`, a structured description of
the `ok`, `value`, `error`, `error.code`, and `error.message` fields plus the
serialization fallback code. Host bindings can read it at startup to verify
their result parser against the loaded runtime.
Use `result_function_pairs` to migrate nullable metadata or legacy calls to
their preferred `_result_json` variants, `result_only_functions` for
result-envelope calls that have no nullable source, and `legacy_result_gaps`
for intentional gaps such as handle-returning APIs. For restore, call
`editor_artifact_restore_preflight_result_json` first, then call the
handle-returning `editor_artifact_restore` after a successful preflight.

```json
{"ok":true,"value":{}}
{"ok":false,"error":{"code":"invalid_range","message":"human-readable detail"}}
```

When `ok` is `true`, `value` is present and `error` is omitted. When `ok` is
`false`, `error` is present and `value` is omitted. `error.code` is the stable
machine-readable field for host logic; `error.message` is diagnostic text for
logs and UI. Hosts should read the capability `error_codes` array at startup so
bindings can validate against the runtime surface they loaded. Hosts that need
labels, grouping, or telemetry dimensions should read `error_code_catalog`,
which includes each stable code with a `category` and short `description`.

Current artifact error codes:

- Host input and parsing: `null_handle`, `null_artifact_json`,
  `null_engine_id`, `null_operation_id`, `null_document_id`, `null_actor_id`,
  `null_operation_json`, `null_operation_log_json`, `null_text`,
  `invalid_utf8`, `integer_out_of_range`, `invalid_document_id`,
  `invalid_artifact_json`, `invalid_operation_json`,
  `invalid_operation_log_json`, and `serialization_failed`.
- Engine identity: `artifact_engine_registry_unavailable` and
  `unknown_waraq_family_engine`.
- Artifact readiness: `artifact_capabilities_unavailable`,
  `artifact_readiness_manifest_unavailable`,
  `artifact_test_profile_unavailable`, and
  `artifact_lifecycle_profile_unavailable`.
- Replay and artifact contract: `invalid_offset`, `invalid_range`,
  `invalid_utf8_boundary`, `snapshot_document_mismatch`,
  `unsupported_schema_version`, `wrong_engine`, `empty_operation_id`,
  `empty_document_id`, `empty_artifact_document_id`, `empty_actor_id`,
  `invalid_sequence`, `duplicate_operation_id`, `non_monotonic_sequence`, and
  `operation_document_mismatch`.

### Artifact API Maintenance Checklist

When adding, removing, or changing a host-visible artifact API behavior, update
the contract in this order:

- Decide the smallest version bump first: `OPERATION_ENVELOPE_VERSION` for
  serialized artifact shape, `ARTIFACT_CONTRACT_VERSION` for shared contract
  vocabulary, or `ARTIFACT_API_VERSION` for FFI discovery, callable functions,
  result-envelope shape, or stable error-code names.
- Update the Rust FFI implementation in `src/ffi/artifact_api/`, then update
  `src/ffi/artifact_api/surface.rs` and
  `src/ffi/artifact_api/contract.rs` so metadata, legacy, result, ABI
  `function_catalog`, `signature_families`, `payload_families`,
  `result_function_pairs`, `result_only_functions`, `legacy_result_gaps`,
  `error_codes`, and
  `error_code_catalog` capability arrays describe the changed surface.
  Stable result-envelope error names should be emitted through
  `src/ffi/artifact_api/error_codes.rs` constants.
- Update golden fixtures in `src/ffi/artifact_api/fixtures/`.
- Update native host declarations in `waraq_editor_core.h`, then keep
  `examples/artifact_host_workflow.c`,
  `examples/artifact_api_symbols_smoke.c`,
  `examples/artifact_header_cpp_smoke.cpp`,
  `examples/smoke_artifact_host_workflow.sh`, and the README
  workflow/result-envelope docs aligned with the changed host behavior.
- Add or update focused tests for the changed behavior. At minimum, keep
  `test_artifact_capabilities_match_rust_ffi_exports`,
  `test_c_header_declares_advertised_artifact_api`, golden fixture tests,
  README error-code coverage, native signature-family coverage, and any
  affected artifact lifecycle tests passing.
- For domain-engine artifact changes, add or update
  `validate_artifact_conformance(...)` and
  `validate_artifact_replay_harness(...)` coverage plus domain replay tests for
  invalid domain references/ranges Waraq cannot understand. For engines with
  compaction, also keep `validate_artifact_compaction_harness(...)` coverage
  asserting `REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS`.
- Keep `validate_artifact_lifecycle_harness(...)` coverage when a domain engine
  supports all three shared harness families.
- Keep `domain_artifact_test_profile(...)` assertions aligned with the domain
  engine's shared helper coverage.
- When the domain-engine implementation recipe changes, keep
  `DOMAIN_ENGINE_IMPLEMENTATION_STEPS` and the
  `Building a Waraq-Family Engine` section aligned.
- Keep shared maintenance helpers such as `ArtifactMaintenancePolicy` and
  `plan_artifact_maintenance(...)` covered by representative domain-engine
  wrappers. Prefer `compact_artifact_with_replayed_prefix(...)` for engines
  that fold a retained operation prefix into the same artifact snapshot type,
  `maintain_artifact_with_plan(...)` for policy-based maintain wrappers, and
  `maintain_artifact_with_plan_outcome(...)` for wrappers that need typed
  preserved-or-compacted results.
- When the shared conformance report shape or required check list changes,
  update `src/core/fixtures/artifact_conformance_report.json` alongside the
  conformance tests and domain-engine checklist assertions.
- Run `cargo fmt`, the focused artifact tests, C and C++ syntax checks for
  `waraq_editor_core.h`, `examples/artifact_host_workflow.c`,
  `examples/artifact_api_symbols_smoke.c`, and
  `examples/artifact_header_cpp_smoke.cpp`,
  `sh examples/smoke_artifact_host_workflow.sh`,
  `cargo check --workspace --offline`, and
  `cargo test --workspace --offline`.

## Features

### Editor Core
- Rope-based text buffer (O(log n) edits)
- Multi-cursor with sort-and-merge
- Full undo/redo with group operations
- Unicode-aware word wrap
- Syntax highlighting (30+ languages)
- Bracket matching and rainbow brackets
- Code folding (5 fold sources)
- Indent guides
- Git gutter decorations

### Monaco-Compatible API
- `deltaDecorations` with glyph margin, overview ruler, inline styles
- TextModel API: `getLineContent`, `getOffsetAt`, `findMatches`, `getWordAtPosition`
- `executeEdits` with undo grouping
- Breadcrumbs / document outline
- Semantic tokens pipeline
- Inlay hints pipeline
- Document highlight

### Extension System
- VS Code-compatible manifest format
- Command registry with MRU palette
- Keybinding engine with chord sequences and when-clauses
- Theme engine (Dracula + GitHub Light built-in)
- Snippet engine with tab stops
- Provider traits: DocumentSymbol, Definition, Reference, SignatureHelp,
  InlayHint, DocumentHighlight, FoldingRange, Color, Rename, LinkedEditing

### AI Integration
- Inline completion with FNV-1a cache and debounce
- Agent tasks: Explain, Refactor, Generate, GenerateTests, FixDiagnostic
- FIM prompts for StarCoder, DeepSeek, Codestral
- Context extraction with token budget
- LSP → decoration pipeline: diagnostics, hover, code actions, edits

### Jupyter Notebook Engine
- Kernel-agnostic (28 kernels: Python, Java, Kotlin, Scala, Rust, Go, ...)
- Full nbformat 4.x read/write
- Magic commands (45 built-in: `%timeit`, `%%bash`, `%pip`, `%%html`, ...)
- Variable inspector, kernel completion bridge, notebook diff
- Export: HTML, Python script, Markdown, RST, LaTeX, Strip

### Workspace
- Multi-file workspace with tab management
- Find/replace across all files
- Session capture/restore
- Dirty tracking with save points
- Settings persistence (VS Code-style, with language overrides)
- Editor groups / split pane layout

### Structured Document Core
- Shared semantic node tree for code files, docs, sheets, slides, and notebooks
- Text regions for editable paragraphs, formulas, code cells, speaker notes, etc.
- Dependency graph for formula recalculation, notebook execution, references, and data bindings
- Adapter trait for format-specific loaders/savers such as DOCX, XLSX, PPTX, IPYNB, and source files

## Building

```bash
# Native library
cargo build --release

# WASM
wasm-pack build --target web --features wasm --out-dir pkg

# Run tests
cargo test

# Benchmarks
cargo bench
```

## License

MIT
