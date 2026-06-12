//! Code editor engine facade.
//!
//! The code editor domain currently uses the canonical text, syntax, LSP,
//! workspace, extension, and AI primitives from `waraq-core`. Keep
//! code-specific behavior in this crate as it grows, but avoid forking shared
//! core modules here.

pub mod ops;

pub use ops::{
    apply_code_edit, apply_code_operation, code_artifact, code_operation, compact_code_artifact,
    maintain_code_artifact, maintain_code_artifact_with_outcome, plan_code_artifact_maintenance,
    replay_code_log, restore_code_artifact, CodeArtifact, CodeArtifactCompactionInfo,
    CodeArtifactMaintenanceOutcome, CodeArtifactMaintenancePlan, CodeArtifactMaintenancePolicy,
    CodeEdit, CodeEditError, CodeEditOutcome, CodeEditorOps, CodeOperation, CodeOperationLog,
    CodeSnapshot, CodeTextEdit, CODE_ENGINE_ID,
};

pub use waraq_core::{
    ai, core, ext, lsp, syntax, Buffer, ByteOffset, Config, Cursor, Diagnostic, DiagnosticSeverity,
    EditOp, Editor, FoldRange, FoldState, LineCol, MultiCursor, Position, Range, SearchMatch,
    SearchQuery, SearchState, TextChange, TextModel, UndoStack, Viewport,
};
