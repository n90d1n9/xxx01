//! Shared-core boundary manifest for Waraq-family engines.
//!
//! This module keeps the high-level architecture decision available to Rust
//! tooling, tests, and host probes: Waraq is the shared platform contract while
//! each editor family owns its specialized domain behavior.

use serde::Serialize;

/// Canonical engine id for the sheet editor family.
pub const WARAQ_SHEET_ENGINE_ID: &str = "sheet.engine";

/// Canonical engine id for the document editor family.
pub const WARAQ_DOCS_ENGINE_ID: &str = "docs.engine";

/// Canonical engine id for the slide editor family.
pub const WARAQ_SLIDE_ENGINE_ID: &str = "slide.engine";

/// Canonical engine id for the code editor family.
pub const WARAQ_CODE_ENGINE_ID: &str = "code.engine";

/// Canonical engine id for the notebook editor family.
pub const WARAQ_MAQAL_ENGINE_ID: &str = "maqal.engine";

/// Legacy engine id currently used by the code domain crate.
pub const WARAQ_CODE_LEGACY_ENGINE_ID: &str = "code";

/// Legacy engine id currently used by the maqal domain crate.
pub const WARAQ_MAQAL_LEGACY_ENGINE_ID: &str = "maqal";

/// Accepted Waraq-family architecture decision.
pub const WARAQ_ENGINE_BOUNDARY_DECISION: &str = "Shared Core + Specialized Engines";

/// Current schema version for the Waraq-family engine registry snapshot.
pub const WARAQ_FAMILY_ENGINE_REGISTRY_VERSION: u32 = 1;

/// Canonical Waraq-family engine ids accepted for new artifacts.
pub const WARAQ_CANONICAL_ENGINE_IDS: &[&str] = &[
    WARAQ_SHEET_ENGINE_ID,
    WARAQ_DOCS_ENGINE_ID,
    WARAQ_SLIDE_ENGINE_ID,
    WARAQ_CODE_ENGINE_ID,
    WARAQ_MAQAL_ENGINE_ID,
];

/// Legacy Waraq-family engine ids accepted during compatibility migrations.
pub const WARAQ_LEGACY_ENGINE_IDS: &[&str] =
    &[WARAQ_CODE_LEGACY_ENGINE_ID, WARAQ_MAQAL_LEGACY_ENGINE_ID];

/// One product-family engine known to the shared Waraq platform.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
pub struct WaraqFamilyEngine {
    /// Human-readable product family name.
    pub family: &'static str,
    /// Rust crate or package name for the family engine.
    pub crate_name: &'static str,
    /// Canonical engine id that new artifacts should use.
    pub canonical_engine_id: &'static str,
    /// Existing short id kept for compatibility during migration.
    pub legacy_engine_id: Option<&'static str>,
    /// Domain behavior owned by this specialized engine.
    pub domain_owns: &'static str,
}

/// How a host-provided engine id matched the Waraq-family registry.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum WaraqEngineIdStatus {
    /// The id already uses the canonical family-engine id.
    Canonical,
    /// The id is a legacy compatibility alias that should be migrated.
    Legacy,
}

impl WaraqEngineIdStatus {
    /// Stable host-readable status id.
    pub const fn as_str(self) -> &'static str {
        match self {
            Self::Canonical => "canonical",
            Self::Legacy => "legacy",
        }
    }
}

/// Result of resolving an engine id against Waraq's family-engine registry.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
pub struct WaraqEngineIdResolution {
    /// Human-readable product family name.
    pub family: &'static str,
    /// Rust crate or package name for the family engine.
    pub crate_name: &'static str,
    /// Canonical engine id that should be used for new artifacts.
    pub canonical_engine_id: &'static str,
    /// Engine id that matched the registry.
    pub matched_engine_id: &'static str,
    /// Whether the matched id was canonical or a legacy alias.
    pub status: WaraqEngineIdStatus,
}

impl WaraqEngineIdResolution {
    /// Return true when the matched id was already canonical.
    pub const fn is_canonical(self) -> bool {
        matches!(self.status, WaraqEngineIdStatus::Canonical)
    }
}

/// Runtime-discoverable snapshot of Waraq's registered product-family engines.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
pub struct WaraqFamilyEngineRegistry {
    /// Registry schema version for tooling and serialized snapshots.
    pub registry_version: u32,
    /// Architecture decision this registry supports.
    pub decision: &'static str,
    /// Canonical engine ids accepted for new Waraq-family artifacts.
    pub canonical_engine_ids: &'static [&'static str],
    /// Legacy aliases accepted during compatibility migrations.
    pub legacy_engine_ids: &'static [&'static str],
    /// Total number of canonical and legacy ids accepted by this registry.
    pub accepted_engine_id_count: usize,
    /// Registered product-family engine records.
    pub family_engines: &'static [WaraqFamilyEngine],
}

impl WaraqFamilyEngineRegistry {
    /// Total number of canonical and legacy ids accepted by this registry.
    pub const fn accepted_engine_id_count(&self) -> usize {
        self.accepted_engine_id_count
    }

    /// Return all accepted ids with canonical ids first and legacy aliases second.
    pub fn accepted_engine_ids(&self) -> Vec<&'static str> {
        self.canonical_engine_ids
            .iter()
            .chain(self.legacy_engine_ids.iter())
            .copied()
            .collect()
    }
}

/// Validated summary of the Waraq-family engine registry.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct WaraqFamilyEngineRegistryReport {
    /// Registry schema version that was validated.
    pub registry_version: u32,
    /// Architecture decision validated by the registry.
    pub decision: &'static str,
    /// Number of registered product-family engines.
    pub family_engine_count: usize,
    /// Number of canonical engine ids.
    pub canonical_engine_count: usize,
    /// Number of legacy compatibility aliases.
    pub legacy_engine_count: usize,
    /// Total number of accepted canonical and legacy ids.
    pub accepted_engine_id_count: usize,
    /// Canonical engine ids in registry order.
    pub canonical_engine_ids: Vec<&'static str>,
    /// Legacy engine aliases in registry order.
    pub legacy_engine_ids: Vec<&'static str>,
}

/// Error returned when the Waraq-family engine registry is internally inconsistent.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub enum WaraqFamilyEngineRegistryError {
    /// A registered engine omitted a required descriptive field.
    EmptyEngineField {
        /// Canonical id of the engine record with the empty field.
        engine_id: &'static str,
        /// Required field that was empty.
        field: &'static str,
    },
    /// Two registered engines or canonical-id entries used the same canonical id.
    DuplicateCanonicalEngineId {
        /// Duplicated canonical engine id.
        engine_id: &'static str,
    },
    /// Two registered engines or legacy-id entries used the same legacy alias.
    DuplicateLegacyEngineId {
        /// Duplicated legacy engine alias.
        engine_id: &'static str,
    },
    /// A legacy alias collided with a canonical engine id.
    LegacyEngineIdCollidesWithCanonicalId {
        /// Engine id present in both canonical and legacy spaces.
        engine_id: &'static str,
    },
    /// The canonical-id list no longer matches the registered engine records.
    CanonicalEngineIdListDrift {
        /// Canonical ids derived from registered engines.
        expected: Vec<&'static str>,
        /// Canonical ids advertised by the registry constant.
        actual: Vec<&'static str>,
    },
    /// The legacy-id list no longer matches the registered engine records.
    LegacyEngineIdListDrift {
        /// Legacy aliases derived from registered engines.
        expected: Vec<&'static str>,
        /// Legacy aliases advertised by the registry constant.
        actual: Vec<&'static str>,
    },
    /// A canonical id in the registry could not be resolved by the resolver.
    UnresolvableCanonicalEngineId {
        /// Canonical engine id that failed to resolve.
        engine_id: &'static str,
    },
    /// A legacy id in the registry could not be resolved by the resolver.
    UnresolvableLegacyEngineId {
        /// Legacy engine alias that failed to resolve.
        engine_id: &'static str,
    },
}

/// One row in the shared-core ownership matrix.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
pub struct WaraqBoundaryConcern {
    /// Concern being assigned across Waraq and domain engines.
    pub concern: &'static str,
    /// Responsibility owned by Waraq core.
    pub waraq_core_owns: &'static str,
    /// Responsibility owned by each domain engine.
    pub domain_engine_owns: &'static str,
}

/// Host-readable manifest for the Waraq shared-core boundary.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
pub struct WaraqSharedCoreBoundary {
    /// Architecture decision for Waraq-family engines.
    pub decision: &'static str,
    /// Summary of Waraq's role.
    pub shared_core_summary: &'static str,
    /// Known product-family engines.
    pub family_engines: &'static [WaraqFamilyEngine],
    /// Ownership matrix for shared and domain behavior.
    pub ownership_matrix: &'static [WaraqBoundaryConcern],
    /// Required engine implementation checklist.
    pub required_engine_checklist: &'static [&'static str],
    /// Flutter-shell responsibilities that should remain presentation focused.
    pub flutter_host_boundary: &'static [&'static str],
    /// Architecture anti-patterns to reject.
    pub anti_patterns: &'static [&'static str],
}

/// Known Waraq-family engines and their canonical ids.
pub const WARAQ_FAMILY_ENGINES: &[WaraqFamilyEngine] = &[
    WaraqFamilyEngine {
        family: "Sheets",
        crate_name: "sheet_engine",
        canonical_engine_id: WARAQ_SHEET_ENGINE_ID,
        legacy_engine_id: None,
        domain_owns: "cell grid, formulas, dependency evaluation, sheet ranges",
    },
    WaraqFamilyEngine {
        family: "Docs",
        crate_name: "docs_engine",
        canonical_engine_id: WARAQ_DOCS_ENGINE_ID,
        legacy_engine_id: None,
        domain_owns: "rich text blocks, styles, pagination, comments, references",
    },
    WaraqFamilyEngine {
        family: "Slides",
        crate_name: "slide_engine",
        canonical_engine_id: WARAQ_SLIDE_ENGINE_ID,
        legacy_engine_id: None,
        domain_owns: "scene graph, spatial layout, shapes, z-order, transitions",
    },
    WaraqFamilyEngine {
        family: "Code",
        crate_name: "code_engine",
        canonical_engine_id: WARAQ_CODE_ENGINE_ID,
        legacy_engine_id: Some(WARAQ_CODE_LEGACY_ENGINE_ID),
        domain_owns: "rope text, language tooling, syntax, LSP, refactoring",
    },
    WaraqFamilyEngine {
        family: "Maqal",
        crate_name: "maqal_engine",
        canonical_engine_id: WARAQ_MAQAL_ENGINE_ID,
        legacy_engine_id: Some(WARAQ_MAQAL_LEGACY_ENGINE_ID),
        domain_owns: "notebook cells, kernel execution, outputs, mixed media",
    },
];

/// Ownership matrix for Waraq shared contracts and domain behavior.
pub const WARAQ_BOUNDARY_OWNERSHIP: &[WaraqBoundaryConcern] = &[
    WaraqBoundaryConcern {
        concern: "Engine identity",
        waraq_core_owns: "contract shape for engine ids",
        domain_engine_owns: "stable id such as docs.engine",
    },
    WaraqBoundaryConcern {
        concern: "Operation transport",
        waraq_core_owns: "OperationEnvelope, OperationLog, artifact validation",
        domain_engine_owns: "domain edit enum and edit meaning",
    },
    WaraqBoundaryConcern {
        concern: "Snapshot transport",
        waraq_core_owns: "generic snapshot-plus-tail artifact shape",
        domain_engine_owns: "domain snapshot structure",
    },
    WaraqBoundaryConcern {
        concern: "Restore preflight",
        waraq_core_owns: "shared envelope, schema, and wrong-engine checks",
        domain_engine_owns: "domain reference, range, and object validation",
    },
    WaraqBoundaryConcern {
        concern: "Replay",
        waraq_core_owns: "harness contract and failure expectations",
        domain_engine_owns: "mutation semantics and no-partial-mutation policy",
    },
    WaraqBoundaryConcern {
        concern: "Compaction",
        waraq_core_owns: "shared planning, retained-tail metadata, lifecycle checks",
        domain_engine_owns: "rebuilding a domain snapshot from compacted edits",
    },
    WaraqBoundaryConcern {
        concern: "Commands",
        waraq_core_owns: "shell command model and navigation contracts",
        domain_engine_owns: "product-specific commands and shortcuts",
    },
    WaraqBoundaryConcern {
        concern: "UI shell",
        waraq_core_owns: "shared sidebar, info, and navigation models",
        domain_engine_owns: "product panes, inspectors, toolbars, canvas, editing UI",
    },
    WaraqBoundaryConcern {
        concern: "Dependency graph",
        waraq_core_owns: "reusable graph primitives",
        domain_engine_owns: "formula, notebook, layout, or reference rules",
    },
];

/// Checklist every Waraq-family domain engine should satisfy.
pub const WARAQ_REQUIRED_ENGINE_CHECKLIST: &[&str] = &[
    "declare one stable engine id",
    "define a serializable domain edit enum",
    "define a serializable domain snapshot model",
    "alias Waraq artifact primitives for its domain types",
    "expose a readiness manifest based on Waraq's shared contract",
    "validate shared artifact conformance with Waraq helpers",
    "validate domain replay, including wrong-engine, wrong-document, invalid reference/range/object, and no-partial-mutation cases",
    "use shared artifact maintenance planning before domain compaction",
    "add compaction and lifecycle harness coverage when compaction is supported",
    "update capability or contract versions only when host-visible behavior changes",
];

/// Presentation-layer responsibilities for Flutter hosts.
pub const WARAQ_FLUTTER_HOST_BOUNDARY: &[&str] = &[
    "WaraqShell owns shared navigation layout",
    "WaraqDestinationRegistry owns host destination composition",
    "WaraqShellCommand owns stable shell navigation command metadata",
    "WaraqShellController owns selected shell destination state",
    "host apps own product panes and domain-specific interactions",
];

/// Boundary anti-patterns that make Waraq harder to reuse.
pub const WARAQ_BOUNDARY_ANTI_PATTERNS: &[&str] = &[
    "one universal data structure for every editor family",
    "separate product engines that invent incompatible artifact contracts",
    "giant cross-product classes that mix formulas, layout, rich text, language tooling, and notebook execution",
    "UI widgets that directly encode domain replay or persistence behavior",
    "domain engines that bypass shared artifact validation and lifecycle tests",
];

/// Return the current Waraq-family engine registry snapshot.
pub fn waraq_family_engine_registry() -> WaraqFamilyEngineRegistry {
    WaraqFamilyEngineRegistry {
        registry_version: WARAQ_FAMILY_ENGINE_REGISTRY_VERSION,
        decision: WARAQ_ENGINE_BOUNDARY_DECISION,
        canonical_engine_ids: WARAQ_CANONICAL_ENGINE_IDS,
        legacy_engine_ids: WARAQ_LEGACY_ENGINE_IDS,
        accepted_engine_id_count: WARAQ_CANONICAL_ENGINE_IDS.len() + WARAQ_LEGACY_ENGINE_IDS.len(),
        family_engines: WARAQ_FAMILY_ENGINES,
    }
}

/// Serialize the current Waraq-family engine registry as compact JSON.
pub fn waraq_family_engine_registry_json() -> Result<String, serde_json::Error> {
    serde_json::to_string(&waraq_family_engine_registry())
}

/// Validate that Waraq's family-engine registry, id lists, and resolver agree.
pub fn validate_waraq_family_engine_registry(
) -> Result<WaraqFamilyEngineRegistryReport, WaraqFamilyEngineRegistryError> {
    let registry = waraq_family_engine_registry();
    let report = validate_waraq_family_engine_registry_parts(
        registry.registry_version,
        registry.decision,
        registry.canonical_engine_ids,
        registry.legacy_engine_ids,
        registry.family_engines,
    )?;

    for &engine_id in registry.canonical_engine_ids {
        let Some(resolution) = resolve_waraq_engine_id(engine_id) else {
            return Err(
                WaraqFamilyEngineRegistryError::UnresolvableCanonicalEngineId { engine_id },
            );
        };
        if resolution.status != WaraqEngineIdStatus::Canonical {
            return Err(
                WaraqFamilyEngineRegistryError::UnresolvableCanonicalEngineId { engine_id },
            );
        }
    }

    for &engine_id in registry.legacy_engine_ids {
        let Some(resolution) = resolve_waraq_engine_id(engine_id) else {
            return Err(WaraqFamilyEngineRegistryError::UnresolvableLegacyEngineId { engine_id });
        };
        if resolution.status != WaraqEngineIdStatus::Legacy {
            return Err(WaraqFamilyEngineRegistryError::UnresolvableLegacyEngineId { engine_id });
        }
    }

    Ok(report)
}

/// Return the family engine record that matches a canonical or legacy id.
pub fn waraq_family_engine_for_id(engine_id: &str) -> Option<&'static WaraqFamilyEngine> {
    WARAQ_FAMILY_ENGINES.iter().find(|engine| {
        engine.canonical_engine_id == engine_id || engine.legacy_engine_id == Some(engine_id)
    })
}

/// Resolve a canonical or legacy id into Waraq's stable engine identity.
pub fn resolve_waraq_engine_id(engine_id: &str) -> Option<WaraqEngineIdResolution> {
    let engine = waraq_family_engine_for_id(engine_id)?;
    let (matched_engine_id, status) = if engine.canonical_engine_id == engine_id {
        (engine.canonical_engine_id, WaraqEngineIdStatus::Canonical)
    } else {
        (engine.legacy_engine_id?, WaraqEngineIdStatus::Legacy)
    };

    Some(WaraqEngineIdResolution {
        family: engine.family,
        crate_name: engine.crate_name,
        canonical_engine_id: engine.canonical_engine_id,
        matched_engine_id,
        status,
    })
}

/// Return the canonical Waraq-family engine id for a canonical or legacy id.
pub fn canonical_waraq_engine_id(engine_id: &str) -> Option<&'static str> {
    resolve_waraq_engine_id(engine_id).map(|resolution| resolution.canonical_engine_id)
}

/// Return true when the id is a canonical Waraq-family engine id.
pub fn is_waraq_canonical_engine_id(engine_id: &str) -> bool {
    WARAQ_CANONICAL_ENGINE_IDS.contains(&engine_id)
}

/// Return true when the id is a legacy Waraq-family compatibility alias.
pub fn is_waraq_legacy_engine_id(engine_id: &str) -> bool {
    WARAQ_LEGACY_ENGINE_IDS.contains(&engine_id)
}

/// Return true when the id is accepted by Waraq's family-engine registry.
pub fn is_waraq_family_engine_id(engine_id: &str) -> bool {
    resolve_waraq_engine_id(engine_id).is_some()
}

/// Return the current Waraq shared-core boundary manifest.
pub fn waraq_shared_core_boundary() -> WaraqSharedCoreBoundary {
    WaraqSharedCoreBoundary {
        decision: WARAQ_ENGINE_BOUNDARY_DECISION,
        shared_core_summary:
            "Waraq owns the shared platform contract; specialized engines own product behavior.",
        family_engines: WARAQ_FAMILY_ENGINES,
        ownership_matrix: WARAQ_BOUNDARY_OWNERSHIP,
        required_engine_checklist: WARAQ_REQUIRED_ENGINE_CHECKLIST,
        flutter_host_boundary: WARAQ_FLUTTER_HOST_BOUNDARY,
        anti_patterns: WARAQ_BOUNDARY_ANTI_PATTERNS,
    }
}

/// Serialize the current Waraq shared-core boundary manifest as compact JSON.
pub fn waraq_shared_core_boundary_json() -> Result<String, serde_json::Error> {
    serde_json::to_string(&waraq_shared_core_boundary())
}

fn validate_waraq_family_engine_registry_parts(
    registry_version: u32,
    decision: &'static str,
    canonical_engine_ids: &'static [&'static str],
    legacy_engine_ids: &'static [&'static str],
    family_engines: &'static [WaraqFamilyEngine],
) -> Result<WaraqFamilyEngineRegistryReport, WaraqFamilyEngineRegistryError> {
    for engine in family_engines {
        if engine.family.is_empty() {
            return Err(WaraqFamilyEngineRegistryError::EmptyEngineField {
                engine_id: engine.canonical_engine_id,
                field: "family",
            });
        }
        if engine.crate_name.is_empty() {
            return Err(WaraqFamilyEngineRegistryError::EmptyEngineField {
                engine_id: engine.canonical_engine_id,
                field: "crate_name",
            });
        }
        if engine.canonical_engine_id.is_empty() {
            return Err(WaraqFamilyEngineRegistryError::EmptyEngineField {
                engine_id: engine.canonical_engine_id,
                field: "canonical_engine_id",
            });
        }
        if engine.domain_owns.is_empty() {
            return Err(WaraqFamilyEngineRegistryError::EmptyEngineField {
                engine_id: engine.canonical_engine_id,
                field: "domain_owns",
            });
        }
    }

    let expected_canonical_engine_ids = family_engines
        .iter()
        .map(|engine| engine.canonical_engine_id)
        .collect::<Vec<_>>();
    let expected_legacy_engine_ids = family_engines
        .iter()
        .filter_map(|engine| engine.legacy_engine_id)
        .collect::<Vec<_>>();

    if let Some(engine_id) = first_duplicate(expected_canonical_engine_ids.iter().copied()) {
        return Err(WaraqFamilyEngineRegistryError::DuplicateCanonicalEngineId { engine_id });
    }

    if let Some(engine_id) = first_duplicate(canonical_engine_ids.iter().copied()) {
        return Err(WaraqFamilyEngineRegistryError::DuplicateCanonicalEngineId { engine_id });
    }

    if let Some(engine_id) = first_duplicate(expected_legacy_engine_ids.iter().copied()) {
        return Err(WaraqFamilyEngineRegistryError::DuplicateLegacyEngineId { engine_id });
    }

    if let Some(engine_id) = first_duplicate(legacy_engine_ids.iter().copied()) {
        return Err(WaraqFamilyEngineRegistryError::DuplicateLegacyEngineId { engine_id });
    }

    for &legacy_engine_id in legacy_engine_ids {
        if canonical_engine_ids.contains(&legacy_engine_id) {
            return Err(
                WaraqFamilyEngineRegistryError::LegacyEngineIdCollidesWithCanonicalId {
                    engine_id: legacy_engine_id,
                },
            );
        }
    }

    for &legacy_engine_id in &expected_legacy_engine_ids {
        if expected_canonical_engine_ids.contains(&legacy_engine_id) {
            return Err(
                WaraqFamilyEngineRegistryError::LegacyEngineIdCollidesWithCanonicalId {
                    engine_id: legacy_engine_id,
                },
            );
        }
    }

    if expected_canonical_engine_ids != canonical_engine_ids {
        return Err(WaraqFamilyEngineRegistryError::CanonicalEngineIdListDrift {
            expected: expected_canonical_engine_ids,
            actual: canonical_engine_ids.to_vec(),
        });
    }

    if expected_legacy_engine_ids != legacy_engine_ids {
        return Err(WaraqFamilyEngineRegistryError::LegacyEngineIdListDrift {
            expected: expected_legacy_engine_ids,
            actual: legacy_engine_ids.to_vec(),
        });
    }

    Ok(WaraqFamilyEngineRegistryReport {
        registry_version,
        decision,
        family_engine_count: family_engines.len(),
        canonical_engine_count: canonical_engine_ids.len(),
        legacy_engine_count: legacy_engine_ids.len(),
        accepted_engine_id_count: canonical_engine_ids.len() + legacy_engine_ids.len(),
        canonical_engine_ids: canonical_engine_ids.to_vec(),
        legacy_engine_ids: legacy_engine_ids.to_vec(),
    })
}

fn first_duplicate<I>(ids: I) -> Option<&'static str>
where
    I: IntoIterator<Item = &'static str>,
{
    let mut seen = std::collections::HashSet::new();
    ids.into_iter().find(|engine_id| !seen.insert(*engine_id))
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashSet;

    const SHARED_BOUNDARY_DOC: &str = include_str!("../../../../docs/shared_core_boundary.md");
    const WARAQ_README: &str = include_str!("../../../../README.md");
    const CORE_README: &str = include_str!("../../README.md");

    #[test]
    fn shared_core_boundary_manifest_lists_canonical_engines() {
        let boundary = waraq_shared_core_boundary();

        assert_eq!(boundary.decision, WARAQ_ENGINE_BOUNDARY_DECISION);
        assert_eq!(boundary.family_engines.len(), 5);
        assert_eq!(
            boundary
                .family_engines
                .iter()
                .map(|engine| engine.canonical_engine_id)
                .collect::<Vec<_>>(),
            vec![
                WARAQ_SHEET_ENGINE_ID,
                WARAQ_DOCS_ENGINE_ID,
                WARAQ_SLIDE_ENGINE_ID,
                WARAQ_CODE_ENGINE_ID,
                WARAQ_MAQAL_ENGINE_ID,
            ]
        );
        assert_eq!(
            boundary.family_engines[3].legacy_engine_id,
            Some(WARAQ_CODE_LEGACY_ENGINE_ID)
        );
        assert_eq!(
            boundary.family_engines[4].legacy_engine_id,
            Some(WARAQ_MAQAL_LEGACY_ENGINE_ID)
        );
    }

    #[test]
    fn family_engine_registry_snapshot_lists_accepted_ids() {
        let registry = waraq_family_engine_registry();

        assert_eq!(
            registry.registry_version,
            WARAQ_FAMILY_ENGINE_REGISTRY_VERSION
        );
        assert_eq!(registry.decision, WARAQ_ENGINE_BOUNDARY_DECISION);
        assert_eq!(registry.family_engines, WARAQ_FAMILY_ENGINES);
        assert_eq!(registry.canonical_engine_ids, WARAQ_CANONICAL_ENGINE_IDS);
        assert_eq!(registry.legacy_engine_ids, WARAQ_LEGACY_ENGINE_IDS);
        assert_eq!(registry.accepted_engine_id_count(), 7);
        assert_eq!(
            registry.accepted_engine_ids(),
            vec![
                WARAQ_SHEET_ENGINE_ID,
                WARAQ_DOCS_ENGINE_ID,
                WARAQ_SLIDE_ENGINE_ID,
                WARAQ_CODE_ENGINE_ID,
                WARAQ_MAQAL_ENGINE_ID,
                WARAQ_CODE_LEGACY_ENGINE_ID,
                WARAQ_MAQAL_LEGACY_ENGINE_ID,
            ]
        );
    }

    #[test]
    fn family_engine_registry_snapshot_serializes_for_tooling() {
        let json = waraq_family_engine_registry_json().unwrap();
        let value: serde_json::Value = serde_json::from_str(&json).unwrap();

        assert_eq!(
            value["registry_version"],
            WARAQ_FAMILY_ENGINE_REGISTRY_VERSION
        );
        assert_eq!(value["decision"], WARAQ_ENGINE_BOUNDARY_DECISION);
        assert_eq!(value["canonical_engine_ids"][0], WARAQ_SHEET_ENGINE_ID);
        assert_eq!(value["legacy_engine_ids"][0], WARAQ_CODE_LEGACY_ENGINE_ID);
        assert_eq!(value["accepted_engine_id_count"], 7);
        assert_eq!(
            value["family_engines"][3]["canonical_engine_id"],
            WARAQ_CODE_ENGINE_ID
        );
    }

    #[test]
    fn engine_id_registry_resolves_canonical_ids() {
        for engine in WARAQ_FAMILY_ENGINES {
            let resolution = resolve_waraq_engine_id(engine.canonical_engine_id).unwrap();

            assert_eq!(resolution.family, engine.family);
            assert_eq!(resolution.crate_name, engine.crate_name);
            assert_eq!(resolution.canonical_engine_id, engine.canonical_engine_id);
            assert_eq!(resolution.matched_engine_id, engine.canonical_engine_id);
            assert_eq!(resolution.status, WaraqEngineIdStatus::Canonical);
            assert!(resolution.is_canonical());
            assert_eq!(
                canonical_waraq_engine_id(engine.canonical_engine_id),
                Some(engine.canonical_engine_id)
            );
            assert!(is_waraq_canonical_engine_id(engine.canonical_engine_id));
            assert!(is_waraq_family_engine_id(engine.canonical_engine_id));
        }
    }

    #[test]
    fn engine_id_registry_canonicalizes_legacy_ids() {
        let code = resolve_waraq_engine_id(WARAQ_CODE_LEGACY_ENGINE_ID).unwrap();
        let maqal = resolve_waraq_engine_id(WARAQ_MAQAL_LEGACY_ENGINE_ID).unwrap();

        assert_eq!(code.family, "Code");
        assert_eq!(code.canonical_engine_id, WARAQ_CODE_ENGINE_ID);
        assert_eq!(code.matched_engine_id, WARAQ_CODE_LEGACY_ENGINE_ID);
        assert_eq!(code.status, WaraqEngineIdStatus::Legacy);
        assert!(!code.is_canonical());
        assert_eq!(
            canonical_waraq_engine_id(WARAQ_CODE_LEGACY_ENGINE_ID),
            Some(WARAQ_CODE_ENGINE_ID)
        );
        assert!(is_waraq_legacy_engine_id(WARAQ_CODE_LEGACY_ENGINE_ID));
        assert!(is_waraq_family_engine_id(WARAQ_CODE_LEGACY_ENGINE_ID));

        assert_eq!(maqal.family, "Maqal");
        assert_eq!(maqal.canonical_engine_id, WARAQ_MAQAL_ENGINE_ID);
        assert_eq!(maqal.matched_engine_id, WARAQ_MAQAL_LEGACY_ENGINE_ID);
        assert_eq!(maqal.status, WaraqEngineIdStatus::Legacy);
        assert_eq!(
            canonical_waraq_engine_id(WARAQ_MAQAL_LEGACY_ENGINE_ID),
            Some(WARAQ_MAQAL_ENGINE_ID)
        );
    }

    #[test]
    fn engine_id_registry_rejects_unknown_and_empty_ids() {
        for engine_id in ["", "docs", "slides.engine", "unknown.engine"] {
            assert_eq!(resolve_waraq_engine_id(engine_id), None);
            assert_eq!(canonical_waraq_engine_id(engine_id), None);
            assert!(!is_waraq_canonical_engine_id(engine_id));
            assert!(!is_waraq_legacy_engine_id(engine_id));
            assert!(!is_waraq_family_engine_id(engine_id));
            assert!(waraq_family_engine_for_id(engine_id).is_none());
        }
    }

    #[test]
    fn family_engine_registry_validation_reports_current_registry() {
        let report = validate_waraq_family_engine_registry().unwrap();

        assert_eq!(
            report.registry_version,
            WARAQ_FAMILY_ENGINE_REGISTRY_VERSION
        );
        assert_eq!(report.decision, WARAQ_ENGINE_BOUNDARY_DECISION);
        assert_eq!(report.family_engine_count, WARAQ_FAMILY_ENGINES.len());
        assert_eq!(
            report.canonical_engine_count,
            WARAQ_CANONICAL_ENGINE_IDS.len()
        );
        assert_eq!(report.legacy_engine_count, WARAQ_LEGACY_ENGINE_IDS.len());
        assert_eq!(report.accepted_engine_id_count, 7);
        assert_eq!(
            report.canonical_engine_ids,
            WARAQ_CANONICAL_ENGINE_IDS.to_vec()
        );
        assert_eq!(report.legacy_engine_ids, WARAQ_LEGACY_ENGINE_IDS.to_vec());

        let value = serde_json::to_value(&report).unwrap();
        assert_eq!(value["canonical_engine_count"], 5);
        assert_eq!(value["legacy_engine_count"], 2);
    }

    #[test]
    fn family_engine_registry_validation_detects_drift_and_collisions() {
        const DUPLICATE_CANONICAL_ENGINES: &[WaraqFamilyEngine] = &[
            WaraqFamilyEngine {
                family: "One",
                crate_name: "one_engine",
                canonical_engine_id: "duplicate.engine",
                legacy_engine_id: None,
                domain_owns: "one domain",
            },
            WaraqFamilyEngine {
                family: "Two",
                crate_name: "two_engine",
                canonical_engine_id: "duplicate.engine",
                legacy_engine_id: None,
                domain_owns: "two domain",
            },
        ];
        const COLLIDING_LEGACY_ENGINES: &[WaraqFamilyEngine] = &[WaraqFamilyEngine {
            family: "Collision",
            crate_name: "collision_engine",
            canonical_engine_id: "collision.engine",
            legacy_engine_id: Some("collision.engine"),
            domain_owns: "collision domain",
        }];

        let duplicate = validate_waraq_family_engine_registry_parts(
            1,
            WARAQ_ENGINE_BOUNDARY_DECISION,
            &["duplicate.engine", "other.engine"],
            &[],
            DUPLICATE_CANONICAL_ENGINES,
        )
        .unwrap_err();
        assert_eq!(
            duplicate,
            WaraqFamilyEngineRegistryError::DuplicateCanonicalEngineId {
                engine_id: "duplicate.engine"
            }
        );

        let collision = validate_waraq_family_engine_registry_parts(
            1,
            WARAQ_ENGINE_BOUNDARY_DECISION,
            &["collision.engine"],
            &["collision.engine"],
            COLLIDING_LEGACY_ENGINES,
        )
        .unwrap_err();
        assert_eq!(
            collision,
            WaraqFamilyEngineRegistryError::LegacyEngineIdCollidesWithCanonicalId {
                engine_id: "collision.engine"
            }
        );

        let drift = validate_waraq_family_engine_registry_parts(
            1,
            WARAQ_ENGINE_BOUNDARY_DECISION,
            &[WARAQ_CODE_ENGINE_ID],
            WARAQ_LEGACY_ENGINE_IDS,
            WARAQ_FAMILY_ENGINES,
        )
        .unwrap_err();
        assert!(matches!(
            drift,
            WaraqFamilyEngineRegistryError::CanonicalEngineIdListDrift { .. }
        ));
    }

    #[test]
    fn engine_id_registry_serializes_resolution_for_tooling() {
        let json =
            serde_json::to_string(&resolve_waraq_engine_id(WARAQ_CODE_LEGACY_ENGINE_ID).unwrap())
                .unwrap();
        let value: serde_json::Value = serde_json::from_str(&json).unwrap();

        assert_eq!(WaraqEngineIdStatus::Canonical.as_str(), "canonical");
        assert_eq!(WaraqEngineIdStatus::Legacy.as_str(), "legacy");
        assert_eq!(value["family"], "Code");
        assert_eq!(value["crate_name"], "code_engine");
        assert_eq!(value["canonical_engine_id"], WARAQ_CODE_ENGINE_ID);
        assert_eq!(value["matched_engine_id"], WARAQ_CODE_LEGACY_ENGINE_ID);
        assert_eq!(value["status"], "legacy");
    }

    #[test]
    fn shared_core_boundary_manifest_has_unique_ids_and_complete_sections() {
        let boundary = waraq_shared_core_boundary();
        let canonical_ids = boundary
            .family_engines
            .iter()
            .map(|engine| engine.canonical_engine_id)
            .collect::<HashSet<_>>();

        assert_eq!(canonical_ids.len(), boundary.family_engines.len());
        assert_eq!(
            WARAQ_CANONICAL_ENGINE_IDS.len(),
            boundary.family_engines.len()
        );
        assert_eq!(WARAQ_LEGACY_ENGINE_IDS.len(), 2);
        for engine in boundary.family_engines {
            assert!(WARAQ_CANONICAL_ENGINE_IDS.contains(&engine.canonical_engine_id));
            if let Some(legacy_engine_id) = engine.legacy_engine_id {
                assert!(WARAQ_LEGACY_ENGINE_IDS.contains(&legacy_engine_id));
            }
        }
        assert!(boundary.ownership_matrix.len() >= 8);
        assert!(boundary.required_engine_checklist.len() >= 10);
        assert!(boundary
            .required_engine_checklist
            .iter()
            .any(|item| item.contains("readiness manifest")));
        assert!(boundary
            .required_engine_checklist
            .iter()
            .any(|item| item.contains("no-partial-mutation")));
        assert!(boundary
            .flutter_host_boundary
            .iter()
            .any(|item| item.contains("WaraqShellCommand")));
        assert!(boundary
            .anti_patterns
            .iter()
            .any(|item| item.contains("universal data structure")));
    }

    #[test]
    fn boundary_docs_include_manifest_decision_and_engine_ids() {
        for doc in [SHARED_BOUNDARY_DOC, WARAQ_README, CORE_README] {
            assert!(doc.contains(WARAQ_ENGINE_BOUNDARY_DECISION));
            assert!(doc.contains("waraq_family_engine_registry()"));
            assert!(doc.contains("validate_waraq_family_engine_registry()"));
        }

        for engine in WARAQ_FAMILY_ENGINES {
            assert!(SHARED_BOUNDARY_DOC.contains(engine.canonical_engine_id));
        }
    }

    #[test]
    fn boundary_manifest_serializes_for_host_tooling() {
        let json = waraq_shared_core_boundary_json().unwrap();
        let value: serde_json::Value = serde_json::from_str(&json).unwrap();

        assert_eq!(value["decision"], WARAQ_ENGINE_BOUNDARY_DECISION);
        assert_eq!(
            value["family_engines"][0]["canonical_engine_id"],
            "sheet.engine"
        );
        assert_eq!(value["family_engines"][3]["legacy_engine_id"], "code");
        assert!(value["ownership_matrix"].as_array().unwrap().len() >= 8);
        assert!(value["required_engine_checklist"]
            .as_array()
            .unwrap()
            .iter()
            .any(|item| item.as_str().unwrap().contains("conformance")));
    }
}
