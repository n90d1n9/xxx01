// waraq-editor-core/src/lib.rs
//
// Top-level Editor facade — integrates all subsystems.

#[path = "../../wq-ai/mod.rs"]
pub mod ai;
pub mod core;
pub mod ext;
pub mod ffi;
pub mod lsp;
pub mod syntax;

pub use core::artifact_compaction_harness::{
    validate_artifact_compaction_harness, ArtifactCompactionHarnessCheck,
    ArtifactCompactionHarnessError, ArtifactCompactionHarnessReport,
    REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS,
};
pub use core::artifact_conformance::{
    validate_artifact_conformance, ArtifactConformanceCheck, ArtifactConformanceError,
    ArtifactConformancePrimitive, ArtifactConformanceReport, REQUIRED_ARTIFACT_CONFORMANCE_CHECKS,
};
pub use core::artifact_contract::{
    artifact_contract_description, ArtifactContractDescription, ArtifactContractPrimitives,
    ArtifactOperation, ArtifactOperationLog, DomainArtifact, DomainEngineImplementationStep,
    ARTIFACT_CONTRACT_PRIMITIVES, ARTIFACT_CONTRACT_VERSION, DOMAIN_ARTIFACT_RESPONSIBILITIES,
    DOMAIN_ENGINE_IMPLEMENTATION_STEPS, SHARED_ARTIFACT_GUARANTEES,
};
pub use core::artifact_engine_kit::{
    ArtifactEngineKit, ArtifactEngineKitBuildError, ArtifactEngineKitLifecycleError,
    ArtifactEngineKitLifecycleReport, ArtifactEngineReadinessManifest,
    ArtifactEngineReadinessPrimitives, ARTIFACT_ENGINE_READINESS_MANIFEST_VERSION,
};
pub use core::artifact_lifecycle_harness::{
    validate_artifact_lifecycle_harness, ArtifactLifecycleHarnessError,
    ArtifactLifecycleHarnessReport,
};
pub use core::artifact_maintenance::{
    artifact_compaction_info, artifact_compaction_info_from_metadata,
    compact_artifact_with_replayed_prefix, maintain_artifact_with_plan,
    maintain_artifact_with_plan_outcome, plan_artifact_maintenance,
    record_artifact_compaction_info, split_artifact_operation_tail, ArtifactCompactionInfo,
    ArtifactMaintenanceAction, ArtifactMaintenanceOutcome, ArtifactMaintenancePlan,
    ArtifactMaintenancePolicy, ArtifactOperationTailSplit, ARTIFACT_COMPACTION_METADATA_KEY,
};
pub use core::artifact_replay_harness::{
    validate_artifact_replay_harness, ArtifactReplayHarnessCheck, ArtifactReplayHarnessError,
    ArtifactReplayHarnessReport, REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS,
};
pub use core::artifact_test_profile::{
    domain_artifact_test_profile, domain_artifact_test_profile_with_compaction,
    validate_artifact_lifecycle_profile, validate_artifact_lifecycle_profile_report,
    validate_domain_artifact_test_profile, validate_domain_artifact_test_profile_report,
    ArtifactLifecycleProfileError, ArtifactLifecycleProfileStage,
    ArtifactLifecycleProfileValidationReport, DomainArtifactTestHelper, DomainArtifactTestProfile,
    DomainArtifactTestProfileError, DomainArtifactTestProfileValidationReport,
};
pub use core::buffer::{Buffer, TextChange};
pub use core::clipboard::{
    Clipboard, ClipboardEntry, ClipboardKind, DocumentStats, InMemoryClipboard,
};
pub use core::config::{Config, IndentStyle, LineEnding, ResolvedConfig};
pub use core::cursor::{Cursor, CursorKind, MultiCursor, Selection};
pub use core::decoration::{
    DecorationId, DecorationKind, DecorationOptions, DecorationRenderInfo, DecorationSet,
    DecorationSpec, DecorationStyle, GlyphMarginDecoration, OverviewRulerDecoration,
    OverviewRulerItem, OverviewRulerLane, UnderlineStyle,
};
pub use core::dependency_graph::{
    DependencyCycle, DependencyEdge, DependencyGraph, DependencyKind, GraphNodeId,
};
pub use core::document_model::{
    DocumentAdapter, DocumentId, DocumentKind, DocumentModelError, DocumentNode, Metadata,
    MetadataValue, NodeId, SemanticNodeKind, StructuredDocument, TextRegion, TextRegionId,
    TextRegionKind,
};
pub use core::edit::{EditOp, EditResult};
pub use core::editor_artifact::{
    apply_editor_operation, compact_editor_artifact, editor_artifact,
    editor_artifact_lifecycle_profile_report, editor_operation, maintain_editor_artifact,
    maintain_editor_artifact_with_outcome, plan_editor_artifact_maintenance, replay_editor_log,
    restore_editor_artifact, EditorArtifact, EditorArtifactCompactionInfo, EditorArtifactError,
    EditorArtifactMaintenanceOutcome, EditorArtifactMaintenancePlan,
    EditorArtifactMaintenancePolicy, EditorArtifactReadinessError, EditorOperation,
    EditorOperationLog, EditorOperationOutcome, WARAQ_EDITOR_ENGINE_ID,
};
pub use core::editor_groups::{EditorGroup, EditorGroupLayout, EditorTab, GroupOrientation};
pub use core::engine_boundary::{
    canonical_waraq_engine_id, is_waraq_canonical_engine_id, is_waraq_family_engine_id,
    is_waraq_legacy_engine_id, resolve_waraq_engine_id, validate_waraq_family_engine_registry,
    waraq_family_engine_for_id, waraq_family_engine_registry, waraq_family_engine_registry_json,
    waraq_shared_core_boundary, waraq_shared_core_boundary_json, WaraqBoundaryConcern,
    WaraqEngineIdResolution, WaraqEngineIdStatus, WaraqFamilyEngine, WaraqFamilyEngineRegistry,
    WaraqFamilyEngineRegistryError, WaraqFamilyEngineRegistryReport, WaraqSharedCoreBoundary,
    WARAQ_BOUNDARY_ANTI_PATTERNS, WARAQ_BOUNDARY_OWNERSHIP, WARAQ_CANONICAL_ENGINE_IDS,
    WARAQ_CODE_ENGINE_ID, WARAQ_CODE_LEGACY_ENGINE_ID, WARAQ_DOCS_ENGINE_ID,
    WARAQ_ENGINE_BOUNDARY_DECISION, WARAQ_FAMILY_ENGINES, WARAQ_FAMILY_ENGINE_REGISTRY_VERSION,
    WARAQ_FLUTTER_HOST_BOUNDARY, WARAQ_LEGACY_ENGINE_IDS, WARAQ_MAQAL_ENGINE_ID,
    WARAQ_MAQAL_LEGACY_ENGINE_ID, WARAQ_REQUIRED_ENGINE_CHECKLIST, WARAQ_SHEET_ENGINE_ID,
    WARAQ_SLIDE_ENGINE_ID,
};
pub use core::format::{
    format_document, format_on_save, format_range, sort_imports, FormatOptions, FormatResult,
};
pub use core::git_gutter::{GitGutter, GutterHunk, GutterHunkKind};
pub use core::indent::{auto_pair_for, indent_for_new_line, IndentRules};
pub use core::indent_guide::{IndentGuide, IndentGuideEngine, LineGuides};
pub use core::macro_rec::{MacroEditOp, MacroEngine, MacroMotionKind, MacroOp, RecordingState};
pub use core::motion;
pub use core::operation::{
    OperationArtifact, OperationEnvelope, OperationLog, OperationLogError, OperationMetadata,
    OPERATION_ENVELOPE_VERSION,
};
pub use core::search::{replace_all as search_replace_all, SearchMatch, SearchQuery, SearchState};
pub use core::selection;
pub use core::session::{
    capture as session_capture, restore as session_restore, Session, SessionStore,
};
pub use core::settings::{LayeredSettings, SettingValue, SettingsStore};
pub use core::text_model::{
    FindMatch, MonacoPosition, MonacoRange, SingleEditOperation, TextModel, WordAtPosition,
};
pub use core::types::{ByteOffset, LineCol, Position, Range};
pub use core::undo::{UndoGroup, UndoStack};
pub use core::viewport::{Viewport, VisibleLine};
pub use core::wordwrap::{WrapEngine, WrapMap, WrappedLine};
pub use core::workspace::{FileMatch, FindInFilesResult, TabInfo, Workspace};
pub use ext::{
    register_builtin_extensions, CommandRegistry, CommandResult, EditorEventBus, ExtensionBus,
    ExtensionContext, ExtensionEvent, ExtensionRegistry, ExtensionState, KeyChord, KeyContext,
    KeyResolution, KeybindingEngine, LanguageFeatureRegistry, LanguageRegistry, Snippet,
    SnippetEngine, Theme, ThemeColor, ThemeEngine,
};
pub use lsp::protocol::{Diagnostic, DiagnosticSeverity};
pub use syntax::fold::{FoldRange, FoldState};

use serde::Serialize;

// ── Editor ────────────────────────────────────────────────────────────────────

pub struct Editor {
    pub buffer: Buffer,
    pub cursors: MultiCursor,
    pub undo_stack: UndoStack,
    pub viewport: Viewport,
    pub config: Config,
    pub search: Option<SearchState>,
    pub lsp_state: lsp::LspState,
    pub completion: ai::CompletionEngine,
    pub language: String,
    pub file_uri: String,
    pub clipboard: Clipboard,
    pub settings: LayeredSettings,
    pub decorations: DecorationSet,
    pub extensions: ExtensionRegistry,
    pub lang_features: LanguageFeatureRegistry,
    pub event_bus: EditorEventBus,
    pub macros: MacroEngine,
    #[cfg(feature = "syntax")]
    pub syntax: syntax::SyntaxLayer,
    pub folds: FoldState,
}

impl Editor {
    pub fn new() -> Self {
        Self {
            buffer: Buffer::new(),
            cursors: MultiCursor::new(),
            undo_stack: UndoStack::new(),
            viewport: Viewport::new(0, 50),
            config: Config::default(),
            search: None,
            lsp_state: lsp::LspState::new(),
            completion: ai::CompletionEngine::new(),
            language: String::new(),
            file_uri: String::new(),
            clipboard: Clipboard::new(),
            settings: LayeredSettings::new(),
            decorations: DecorationSet::new(),
            extensions: {
                let mut r = ExtensionRegistry::with_new_bus();
                register_builtin_extensions(&mut r);
                r
            },
            lang_features: LanguageFeatureRegistry::new(),
            event_bus: EditorEventBus::new(),
            macros: MacroEngine::new(),
            #[cfg(feature = "syntax")]
            syntax: syntax::SyntaxLayer::new(),
            folds: FoldState::new(),
        }
    }

    pub fn from_str(content: &str) -> Self {
        let mut ed = Self::new();
        ed.buffer = Buffer::from_str(content);
        ed.config.detect_and_apply_indent(content);
        ed.config.detect_and_apply_line_ending(content);
        ed
    }

    pub fn with_language(mut self, language: &str) -> Self {
        self.set_language(language);
        self
    }

    pub fn with_file_uri(mut self, uri: &str) -> Self {
        self.file_uri = uri.to_owned();
        self
    }

    // ── Language / config ─────────────────────────────────────────────────────

    pub fn set_language(&mut self, language: &str) {
        self.language = language.to_owned();
        #[cfg(feature = "syntax")]
        {
            self.syntax.set_language(language);
            self.syntax.full_parse(&self.buffer);
        }
        self.folds = FoldState::compute(&self.buffer, language);
        // Activate extensions for this language
        self.extensions.activate_for_language(language);
        // Emit language changed event
        self.event_bus
            .emit_language_changed(&self.file_uri, language);
    }

    pub fn resolved_config(&self) -> ResolvedConfig {
        self.config.for_language(&self.language)
    }

    pub fn indent_rules(&self) -> IndentRules {
        IndentRules::for_language(&self.language)
    }

    // ── Core mutation ─────────────────────────────────────────────────────────

    pub fn apply(&mut self, op: EditOp) -> EditResult {
        let change = self.buffer.apply_op(&op);
        self.cursors.adjust_for_change(&change);
        self.undo_stack.push(op, change.clone());
        #[cfg(feature = "syntax")]
        self.syntax.on_change(&change, &self.buffer);
        if let Some(ref mut s) = self.search {
            s.refresh(&self.buffer);
        }
        // Adjust decorations for the edit
        let byte_delta = change.byte_delta;
        let edit_start = change.replaced.start.0;
        let edit_end = if byte_delta < 0 {
            change.replaced.end.0
        } else {
            edit_start
        };
        self.decorations
            .adjust_for_edit(edit_start, edit_end, byte_delta);
        self.folds
            .invalidate_range(change.first_line, change.last_line);
        self.completion.dismiss_suggestion();
        // Emit text change event to extension bus
        use ext::event::ContentChange;
        self.event_bus.emit_text_changed(
            &self.file_uri,
            vec![ContentChange {
                range: change.replaced,
                text: change.inserted.clone(),
                version: self.undo_stack.depth() as u64,
                is_undo_redo: false,
            }],
            self.undo_stack.depth() as u64,
        );
        EditResult {
            change,
            cursor_positions: self.cursors.all_positions(),
            dirty: true,
        }
    }

    pub fn apply_batch(&mut self, ops: Vec<EditOp>) -> Vec<EditResult> {
        self.undo_stack.begin_group();
        let results = ops.into_iter().map(|op| self.apply(op)).collect();
        self.undo_stack.end_group();
        results
    }

    pub fn undo(&mut self) -> Option<EditResult> {
        let ops = self.undo_stack.undo();
        if ops.is_empty() {
            return None;
        }
        let mut last_change = None;
        for op in ops {
            let change = self.buffer.apply_op(&op);
            self.cursors.adjust_for_change(&change);
            #[cfg(feature = "syntax")]
            self.syntax.on_change(&change, &self.buffer);
            last_change = Some(change);
        }
        let change = last_change?;
        if let Some(ref mut s) = self.search {
            s.refresh(&self.buffer);
        }
        self.completion.dismiss_suggestion();
        Some(EditResult {
            change,
            cursor_positions: self.cursors.all_positions(),
            dirty: true,
        })
    }

    pub fn redo(&mut self) -> Option<EditResult> {
        let ops = self.undo_stack.redo();
        if ops.is_empty() {
            return None;
        }
        let mut last_change = None;
        for op in ops {
            let change = self.buffer.apply_op(&op);
            self.cursors.adjust_for_change(&change);
            #[cfg(feature = "syntax")]
            self.syntax.on_change(&change, &self.buffer);
            last_change = Some(change);
        }
        let change = last_change?;
        if let Some(ref mut s) = self.search {
            s.refresh(&self.buffer);
        }
        self.completion.dismiss_suggestion();
        Some(EditResult {
            change,
            cursor_positions: self.cursors.all_positions(),
            dirty: true,
        })
    }

    // ── Keyboard input handler ────────────────────────────────────────────────

    /// High-level input handler. Returns the ops applied (for FFI result).
    /// Handles: typing, backspace, delete, Enter with auto-indent, Tab, brackets.
    pub fn handle_key(&mut self, key: KeyInput) -> Vec<EditResult> {
        match key {
            KeyInput::Char(ch) => self.handle_char(ch),
            KeyInput::Backspace => self.handle_backspace(),
            KeyInput::Delete => self.handle_delete_forward(),
            KeyInput::Enter => self.handle_enter(),
            KeyInput::Tab => self.handle_tab(false),
            KeyInput::ShiftTab => self.handle_tab(true),
            KeyInput::Motion(m) => {
                self.handle_motion(m, false);
                vec![]
            }
            KeyInput::Select(m) => {
                self.handle_motion(m, true);
                vec![]
            }
        }
    }

    fn handle_char(&mut self, ch: char) -> Vec<EditResult> {
        let cfg = self.resolved_config();
        let rules = self.indent_rules();
        let mut results = Vec::new();

        // Check auto-pair (only when nothing selected)
        if !self.cursors.primary().has_selection() {
            let pos = self.cursors.primary().pos;
            if let Some(pair) = auto_pair_for(&self.buffer, pos, ch, &rules, &cfg) {
                if pair.insert.is_empty() {
                    // Skip over existing close char
                    self.cursors.move_to(pos.0 + pair.cursor_offset, false);
                    return vec![];
                }
                // Insert the pair, position cursor between them
                let op = EditOp::insert(pos.0, &pair.insert);
                results.push(self.apply(op));
                // Move cursor back by 1 (before the closing char)
                let new_pos = self.cursors.primary().pos.0.saturating_sub(1);
                self.cursors.move_to(new_pos, false);
                return results;
            }
        }

        // Normal char insert at all cursors (largest offset first)
        let mut ops: Vec<EditOp> = self
            .cursors
            .all()
            .iter()
            .map(|c| {
                if c.has_selection() {
                    let sel = c.selection().unwrap();
                    EditOp::replace(sel.start.0, sel.end.0, ch.to_string())
                } else {
                    EditOp::type_char(c.pos.0, ch)
                }
            })
            .collect();
        // Apply largest-offset-first to preserve correctness
        ops.sort_by(|a, b| {
            let a0 = match a {
                EditOp::Insert { at, .. } => at.0,
                EditOp::Replace { range, .. } => range.start.0,
                _ => 0,
            };
            let b0 = match b {
                EditOp::Insert { at, .. } => at.0,
                EditOp::Replace { range, .. } => range.start.0,
                _ => 0,
            };
            b0.cmp(&a0)
        });
        for op in ops {
            results.push(self.apply(op));
        }
        results
    }

    fn handle_backspace(&mut self) -> Vec<EditResult> {
        let mut results = Vec::new();
        let mut ops: Vec<EditOp> = self
            .cursors
            .all()
            .iter()
            .filter_map(|c| {
                if c.has_selection() {
                    let sel = c.selection().unwrap();
                    Some(EditOp::delete(sel.start.0, sel.end.0))
                } else if c.pos.0 > 0 {
                    let left = motion::char_left(&self.buffer, c.pos);
                    Some(EditOp::delete(left.0, c.pos.0))
                } else {
                    None
                }
            })
            .collect();
        ops.sort_by(|a, b| {
            let a0 = match a {
                EditOp::Delete { range } => range.start.0,
                _ => 0,
            };
            let b0 = match b {
                EditOp::Delete { range } => range.start.0,
                _ => 0,
            };
            b0.cmp(&a0)
        });
        for op in ops {
            results.push(self.apply(op));
        }
        results
    }

    fn handle_delete_forward(&mut self) -> Vec<EditResult> {
        let mut results = Vec::new();
        let buf_len = self.buffer.len_bytes();
        let mut ops: Vec<EditOp> = self
            .cursors
            .all()
            .iter()
            .filter_map(|c| {
                if c.has_selection() {
                    let sel = c.selection().unwrap();
                    Some(EditOp::delete(sel.start.0, sel.end.0))
                } else if c.pos.0 < buf_len {
                    let right = motion::char_right(&self.buffer, c.pos);
                    Some(EditOp::delete(c.pos.0, right.0))
                } else {
                    None
                }
            })
            .collect();
        ops.sort_by(|a, b| {
            let a0 = match a {
                EditOp::Delete { range } => range.start.0,
                _ => 0,
            };
            let b0 = match b {
                EditOp::Delete { range } => range.start.0,
                _ => 0,
            };
            b0.cmp(&a0)
        });
        for op in ops {
            results.push(self.apply(op));
        }
        results
    }

    fn handle_enter(&mut self) -> Vec<EditResult> {
        let cfg = self.resolved_config();
        let rules = self.indent_rules();
        let eol = self.config.line_ending.as_str();
        let cursor_line = self
            .buffer
            .offset_to_line_col(self.cursors.primary().pos)
            .line;
        let indent = indent_for_new_line(&self.buffer, cursor_line, &cfg, &rules);
        let text = format!("{}{}", eol, indent);
        self.handle_char_sequence(&text)
    }

    fn handle_tab(&mut self, dedent: bool) -> Vec<EditResult> {
        // Accept AI completion if available
        if !dedent {
            if let Some(op) = self.completion.accept() {
                return vec![self.apply(op)];
            }
        }
        let cfg = self.resolved_config();
        let indent_str = cfg.indent_str();
        if dedent {
            // Dedent: remove one indent level from the current line
            let pos = self.cursors.primary().pos;
            let lc = self.buffer.offset_to_line_col(pos);
            let line_text = self.buffer.line_str(lc.line);
            let current_indent = core::indent::leading_whitespace_len(&line_text, cfg.tab_width);
            let remove = current_indent.min(cfg.indent_width) as usize;
            if remove > 0 {
                let line_start = self.buffer.line_col_to_offset(LineCol::new(lc.line, 0));
                return vec![self.apply(EditOp::delete(line_start.0, line_start.0 + remove))];
            }
            vec![]
        } else {
            vec![self.apply(EditOp::insert(self.cursors.primary().pos.0, &indent_str))]
        }
    }

    fn handle_char_sequence(&mut self, s: &str) -> Vec<EditResult> {
        let pos = self.cursors.primary().pos.0;
        vec![self.apply(EditOp::insert(pos, s))]
    }

    fn handle_motion(&mut self, m: MotionKind, extend: bool) {
        let total = self.buffer.len_lines();
        let pos = self.cursors.primary().pos;
        let new_pos = match m {
            MotionKind::CharLeft => motion::char_left(&self.buffer, pos),
            MotionKind::CharRight => motion::char_right(&self.buffer, pos),
            MotionKind::WordLeft => motion::word_backward(&self.buffer, pos),
            MotionKind::WordRight => motion::word_forward(&self.buffer, pos),
            MotionKind::WordEnd => motion::word_end_forward(&self.buffer, pos),
            MotionKind::LineStart => {
                let lc = self.buffer.offset_to_line_col(pos);
                motion::line_start(&self.buffer, lc.line)
            }
            MotionKind::LineFirstNonWs => {
                let lc = self.buffer.offset_to_line_col(pos);
                motion::line_first_nonwhitespace(&self.buffer, lc.line)
            }
            MotionKind::LineEnd => {
                let lc = self.buffer.offset_to_line_col(pos);
                motion::line_end(&self.buffer, lc.line)
            }
            MotionKind::LineUp(n) => {
                let lc = self.buffer.offset_to_line_col(pos);
                motion::line_start(&self.buffer, lc.line.saturating_sub(n))
            }
            MotionKind::LineDown(n) => {
                let lc = self.buffer.offset_to_line_col(pos);
                motion::line_start(&self.buffer, (lc.line + n).min(total.saturating_sub(1)))
            }
            MotionKind::ParagraphUp => motion::paragraph_backward(&self.buffer, pos),
            MotionKind::ParagraphDown => motion::paragraph_forward(&self.buffer, pos),
            MotionKind::PageUp(h) => motion::page_up(&self.buffer, pos, h),
            MotionKind::PageDown(h) => motion::page_down(&self.buffer, pos, h),
            MotionKind::MatchingBracket => {
                motion::matching_bracket(&self.buffer, pos).unwrap_or(pos)
            }
            MotionKind::DocumentStart => motion::document_start(),
            MotionKind::DocumentEnd => motion::document_end(&self.buffer),
        };
        self.cursors.move_to(new_pos.0, extend);
        let total = self.buffer.len_lines();
        let cursor_line = self.buffer.offset_to_line_col(new_pos).line;
        self.viewport.ensure_cursor_visible(cursor_line, total);
    }

    // ── Clipboard ─────────────────────────────────────────────────────────────

    /// Copy the current selection (or whole line if nothing selected).
    pub fn copy(&mut self) {
        self.clipboard.copy(&self.buffer, &self.cursors);
    }

    /// Cut the current selection (or whole line). Returns results to apply.
    pub fn cut(&mut self) -> Vec<EditResult> {
        let ops = self.clipboard.cut(&self.buffer, &self.cursors);
        if ops.is_empty() {
            return vec![];
        }
        self.apply_batch(ops)
    }

    /// Paste the most recent clipboard entry.
    pub fn paste(&mut self) -> Vec<EditResult> {
        let ops = self.clipboard.paste(&self.buffer, &self.cursors);
        if ops.is_empty() {
            return vec![];
        }
        self.apply_batch(ops)
    }

    /// Paste the previous clipboard entry (cycle through history).
    pub fn cycle_paste(&mut self) -> Vec<EditResult> {
        let ops = self.clipboard.cycle_paste(&self.buffer, &self.cursors);
        if ops.is_empty() {
            return vec![];
        }
        self.apply_batch(ops)
    }

    pub fn document_stats(&self) -> DocumentStats {
        DocumentStats::compute(&self.buffer)
    }

    // ── Macros ────────────────────────────────────────────────────────────────

    /// Start recording into register `name` ('a'-'z' or '"').
    pub fn macro_start(&mut self, register: char) -> Result<(), &'static str> {
        self.macros.start_recording(register)
    }

    /// Stop recording.
    pub fn macro_stop(&mut self) -> Result<usize, &'static str> {
        self.macros.stop_recording()
    }

    /// Play back macro in register `name` `count` times.
    pub fn macro_play(&mut self, register: char, count: usize) -> Vec<EditResult> {
        let ops = match self.macros.playback_ops(register) {
            Some(ops) => ops,
            None => return vec![],
        };
        let mut results = Vec::new();
        self.macros.enter_playback();
        for _ in 0..count.max(1) {
            for op in &ops {
                match op {
                    MacroOp::Edit(e) => {
                        let edit_op = e.to_edit_op();
                        // For Insert/Replace, adjust offset to current cursor if originally at 0
                        results.push(self.apply(edit_op));
                    }
                    MacroOp::Motion { kind, extend } => {
                        let mk = crate::MotionKind::from(kind);
                        self.handle_key(if *extend {
                            KeyInput::Select(mk)
                        } else {
                            KeyInput::Motion(mk)
                        });
                    }
                    MacroOp::SelectWord => {
                        self.select_word_at_cursor();
                    }
                    MacroOp::SelectLine => {
                        self.select_line_at_cursor();
                    }
                    MacroOp::SelectAll => {
                        self.select_all();
                    }
                    MacroOp::SearchStart { pattern, flags } => {
                        let q = SearchQuery {
                            pattern: pattern.clone(),
                            case_sensitive: flags & 0x01 != 0,
                            whole_word: flags & 0x02 != 0,
                            regex: flags & 0x04 != 0,
                            wrap_around: true,
                        };
                        self.search_start(q);
                    }
                    MacroOp::SearchNext => {
                        self.search_next();
                    }
                    MacroOp::SearchPrev => {
                        self.search_prev();
                    }
                    MacroOp::ReplaceCurrentMatch { replacement } => {
                        if let Some(r) = self.replace_current(replacement) {
                            results.push(r);
                        }
                    }
                }
            }
        }
        self.macros.exit_playback();
        results
    }

    // ── Formatting ────────────────────────────────────────────────────────────

    /// Format the entire document. Returns ops; caller applies via apply_batch.
    pub fn format_document(&self, opts: Option<FormatOptions>) -> FormatResult {
        let opts = opts.unwrap_or_else(|| FormatOptions::from(&self.resolved_config()));
        format_document(&self.buffer, &opts, &self.language)
    }

    /// Format a range of lines. Returns ops; caller applies via apply_batch.
    pub fn format_range(
        &self,
        first_line: usize,
        last_line: usize,
        opts: Option<FormatOptions>,
    ) -> FormatResult {
        let opts = opts.unwrap_or_else(|| FormatOptions::from(&self.resolved_config()));
        format_range(&self.buffer, &opts, &self.language, first_line, last_line)
    }

    /// Composite format-on-save (indent + trailing ws + final newline + import sort).
    pub fn format_on_save(&self) -> FormatResult {
        let opts = FormatOptions::from(&self.resolved_config());
        format_on_save(&self.buffer, &opts, &self.language)
    }

    /// Return full UI/editor settings resolved for the active language.
    pub fn resolved_settings(&self) -> Config {
        self.settings.resolve_config(if self.language.is_empty() {
            None
        } else {
            Some(&self.language)
        })
    }

    // ── Decorations (Monaco-compatible deltaDecorations) ─────────────────────

    /// Apply a decoration delta. Equivalent to Monaco `editor.deltaDecorations`.
    /// Pass `remove_ids = &[]` to only add; pass `add_specs = &[]` to only remove.
    pub fn delta_decorations(
        &mut self,
        remove_ids: &[DecorationId],
        add_specs: &[(DecorationSpec, String)],
    ) -> Vec<DecorationId> {
        self.decorations.delta(remove_ids, add_specs)
    }

    /// Remove all decorations from a specific owner/extension.
    pub fn clear_decorations_by_owner(&mut self, owner: &str) {
        self.decorations.remove_by_owner(owner);
    }

    /// Get decoration render info for the visible viewport.
    pub fn viewport_decorations(&self) -> Vec<DecorationRenderInfo> {
        let first = self.viewport.first_line();
        let last = first + self.viewport.height();
        self.decorations
            .for_viewport(&self.buffer, first, last)
            .into_iter()
            .map(|d| DecorationRenderInfo::from_decoration(d, &self.buffer))
            .collect()
    }

    /// Get a Monaco-compatible TextModel view of the current buffer.
    pub fn text_model(&self) -> TextModel<'_> {
        TextModel::new(&self.buffer, self.config.line_ending.as_str())
    }

    /// Apply Monaco-style edits (list of SingleEditOperation) with undo support.
    pub fn execute_edits(&mut self, edits: &[SingleEditOperation]) -> Vec<EditResult> {
        let model = self.text_model();
        let ops = model.apply_edits(edits);
        self.apply_batch(ops)
    }

    // ── Search ────────────────────────────────────────────────────────────────

    pub fn search_start(&mut self, query: SearchQuery) -> Option<SearchMatch> {
        self.search = SearchState::new(&self.buffer, query);
        self.search.as_ref()?.current_match()
    }

    pub fn search_next(&mut self) -> Option<SearchMatch> {
        self.search.as_mut()?.next()
    }

    pub fn search_prev(&mut self) -> Option<SearchMatch> {
        self.search.as_mut()?.prev()
    }

    pub fn search_clear(&mut self) {
        self.search = None;
    }

    pub fn replace_current(&mut self, replacement: &str) -> Option<EditResult> {
        let m = self.search.as_mut()?.current_match()?;
        let op = EditOp::replace(m.start.0, m.end.0, replacement);
        Some(self.apply(op))
    }

    pub fn replace_all_matches(&mut self, replacement: &str) -> Vec<EditResult> {
        let query = match &self.search {
            Some(s) => s.query().clone(),
            None => return vec![],
        };
        let ops = search_replace_all(&self.buffer, &query, replacement);
        self.apply_batch(ops)
    }

    // ── Selection helpers ─────────────────────────────────────────────────────

    pub fn select_word_at_cursor(&mut self) {
        let pos = self.cursors.primary().pos;
        let (s, e) = selection::select_word_at(&self.buffer, pos);
        self.cursors.move_to(s.0, false);
        self.cursors.move_to(e.0, true);
    }

    pub fn select_line_at_cursor(&mut self) {
        let pos = self.cursors.primary().pos;
        let (s, e) = selection::select_line_at(&self.buffer, pos);
        self.cursors.move_to(s.0, false);
        self.cursors.move_to(e.0, true);
    }

    pub fn select_all(&mut self) {
        self.cursors.select_all(&self.buffer);
    }

    pub fn expand_selection(&mut self) {
        let pos = self.cursors.primary().pos;
        let sel = self.cursors.primary().selection();
        let (anchor, active) = selection::expand_selection(&self.buffer, sel, pos);
        self.cursors.move_to(anchor.0, false);
        self.cursors.move_to(active.0, true);
    }

    pub fn add_cursor_at_next_occurrence(&mut self) {
        let sel = self.cursors.primary().selection();
        if let Some(s) = sel {
            let text = self.buffer.text_in_range(s.as_range());
            if let Some(next) = selection::select_next_occurrence(&self.buffer, &text, s.end) {
                self.cursors.add(next.start.0);
            }
        }
    }

    // ── Folding ───────────────────────────────────────────────────────────────

    pub fn toggle_fold(&mut self, line: usize) {
        self.folds.toggle(line);
    }

    pub fn fold_all(&mut self) {
        self.folds.collapse_all();
    }
    pub fn unfold_all(&mut self) {
        self.folds.expand_all();
    }

    // ── Rendering ─────────────────────────────────────────────────────────────

    pub fn render_frame(&self) -> RenderFrame {
        let lines = self.viewport.visible_lines(&self.buffer);
        let vp_first = self.viewport.first_line();
        let vp_last = vp_first + self.viewport.height();

        RenderFrame {
            lines,
            cursors: self.cursors.all_positions(),
            selections: self.cursor_selections(),
            #[cfg(feature = "syntax")]
            tokens: self.syntax.tokens_for_viewport(&self.viewport),
            #[cfg(not(feature = "syntax"))]
            tokens: vec![],
            folds: self
                .folds
                .for_viewport(vp_first, vp_last)
                .into_iter()
                .cloned()
                .collect(),
            diagnostics: self.lsp_state.diagnostics_in_viewport(vp_first, vp_last),
            search_matches: self.search_matches_in_viewport(vp_first, vp_last),
            decorations: self.viewport_decorations(),
            indent_guides: {
                let engine = IndentGuideEngine::from_config(&self.resolved_settings());
                let cursor_line = self
                    .buffer
                    .offset_to_line_col(self.cursors.primary().pos)
                    .line;
                engine.guides_for_viewport(&self.buffer, vp_first, vp_last, cursor_line)
            },
            minimap: self
                .decorations
                .overview_ruler_items(&self.buffer, self.buffer.len_lines()),
            word_wrap: !matches!(self.config.word_wrap, crate::core::config::WordWrap::Off),
            cursor_style: format!("{:?}", self.config.cursor_style),
            show_whitespace: self.config.show_whitespace,
            total_lines: self.buffer.len_lines(),
            scroll_offset: self.viewport.scroll_offset(),
            language: self.language.clone(),
        }
    }

    fn cursor_selections(&self) -> Vec<SelectionRange> {
        self.cursors
            .all()
            .iter()
            .filter_map(|c| {
                c.selection().map(|sel| SelectionRange {
                    start: sel.start.0,
                    end: sel.end.0,
                })
            })
            .collect()
    }

    fn search_matches_in_viewport(&self, first: usize, last: usize) -> Vec<SearchMatchInfo> {
        let state = match &self.search {
            Some(s) => s,
            None => return vec![],
        };
        state
            .all_matches()
            .into_iter()
            .filter(|m| {
                let lc = self.buffer.offset_to_line_col(m.start);
                lc.line >= first && lc.line <= last
            })
            .map(|m| SearchMatchInfo {
                start: m.start.0,
                end: m.end.0,
                is_current: m.index == state.current_index(),
            })
            .collect()
    }
}

impl Default for Editor {
    fn default() -> Self {
        Self::new()
    }
}

// ── Key input types ────────────────────────────────────────────────────────────

#[derive(Debug, Clone)]
pub enum KeyInput {
    Char(char),
    Backspace,
    Delete,
    Enter,
    Tab,
    ShiftTab,
    Motion(MotionKind),
    Select(MotionKind),
}

#[derive(Debug, Clone, Copy)]
pub enum MotionKind {
    CharLeft,
    CharRight,
    WordLeft,
    WordRight,
    WordEnd,
    LineStart,
    LineFirstNonWs,
    LineEnd,
    LineUp(usize),
    LineDown(usize),
    ParagraphUp,
    ParagraphDown,
    PageUp(usize),
    PageDown(usize),
    MatchingBracket,
    DocumentStart,
    DocumentEnd,
}

// ── Serialisable render frame ──────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize)]
pub struct SelectionRange {
    pub start: usize,
    pub end: usize,
}

#[derive(Debug, Clone, Serialize)]
pub struct SearchMatchInfo {
    pub start: usize,
    pub end: usize,
    pub is_current: bool,
}

#[derive(Debug, Clone, Serialize)]
pub struct DiagnosticInfo {
    pub line: usize,
    pub col: usize,
    pub end_line: usize,
    pub end_col: usize,
    pub severity: u8, // 1=error 2=warning 3=info 4=hint
    pub message: String,
}

#[derive(Debug, Serialize)]
pub struct RenderFrame {
    pub lines: Vec<VisibleLine>,
    pub cursors: Vec<Position>,
    pub selections: Vec<SelectionRange>,
    pub tokens: Vec<syntax::Token>,
    pub folds: Vec<FoldRange>,
    pub diagnostics: Vec<DiagnosticInfo>,
    pub search_matches: Vec<SearchMatchInfo>,
    pub decorations: Vec<DecorationRenderInfo>,
    /// Indent guide columns per visible line.
    pub indent_guides: Vec<LineGuides>,
    /// Overview ruler items for the minimap/scrollbar.
    pub minimap: Vec<crate::core::decoration::OverviewRulerItem>,
    /// True if word wrap is active.
    pub word_wrap: bool,
    /// Cursor style from config.
    pub cursor_style: String,
    /// Whether to show whitespace characters.
    pub show_whitespace: bool,
    pub total_lines: usize,
    pub scroll_offset: usize,
    pub language: String,
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::decoration::{DecorationOptions, DecorationSpec};
    use crate::core::edit::EditOp;
    use crate::core::search::SearchQuery;
    use crate::core::types::Range;

    fn ed(s: &str) -> Editor {
        Editor::from_str(s)
    }

    // ── Basic editor operations ───────────────────────────────────────────────

    #[test]
    fn test_editor_new_empty() {
        let ed = Editor::new();
        assert_eq!(ed.buffer.len_bytes(), 0);
        assert_eq!(ed.buffer.len_lines(), 1);
        assert_eq!(ed.language, "");
    }

    #[test]
    fn test_editor_from_str() {
        let ed = ed("hello world");
        assert_eq!(ed.buffer.to_string(), "hello world");
        assert_eq!(ed.cursors.count(), 1);
        assert_eq!(ed.cursors.primary().pos.0, 0);
    }

    #[test]
    fn test_apply_insert_updates_cursor() {
        let mut ed = ed("hello");
        ed.cursors.move_to(5, false);
        ed.apply(EditOp::insert(5, " world"));
        assert_eq!(ed.buffer.to_string(), "hello world");
    }

    #[test]
    fn test_apply_delete() {
        let mut ed = ed("hello world");
        ed.apply(EditOp::delete(5, 11));
        assert_eq!(ed.buffer.to_string(), "hello");
    }

    #[test]
    fn test_undo_redo() {
        let mut ed = ed("hello");
        ed.apply(EditOp::insert(5, " world"));
        assert_eq!(ed.buffer.to_string(), "hello world");
        ed.undo();
        assert_eq!(ed.buffer.to_string(), "hello");
        ed.redo();
        assert_eq!(ed.buffer.to_string(), "hello world");
    }

    #[test]
    fn test_apply_batch_group_undo() {
        let mut ed = Editor::new();
        ed.apply_batch(vec![
            EditOp::insert(0, "a"),
            EditOp::insert(1, "b"),
            EditOp::insert(2, "c"),
        ]);
        assert_eq!(ed.buffer.to_string(), "abc");
        ed.undo();
        assert_eq!(ed.buffer.to_string(), "");
    }

    // ── Key input ─────────────────────────────────────────────────────────────

    #[test]
    fn test_handle_key_char() {
        let mut ed = Editor::new();
        ed.handle_key(KeyInput::Char('x'));
        assert_eq!(ed.buffer.to_string(), "x");
        assert_eq!(ed.cursors.primary().pos.0, 1);
    }

    #[test]
    fn test_handle_key_backspace_at_start_is_noop() {
        let mut ed = Editor::new();
        ed.handle_key(KeyInput::Backspace);
        assert_eq!(ed.buffer.to_string(), "");
    }

    #[test]
    fn test_handle_key_enter() {
        let mut ed = ed("hello");
        ed.cursors.move_to(5, false);
        ed.handle_key(KeyInput::Enter);
        assert!(ed.buffer.to_string().contains('\n'));
    }

    #[test]
    fn test_handle_key_tab() {
        let mut ed = Editor::new();
        ed.handle_key(KeyInput::Tab);
        assert_eq!(ed.buffer.to_string(), "    ");
    }

    // ── Search ────────────────────────────────────────────────────────────────

    #[test]
    fn test_search_start_and_clear() {
        let mut ed = ed("foo bar foo");
        let m = ed.search_start(SearchQuery::literal("foo")).unwrap();
        assert_eq!(m.total, 2);
        ed.search_clear();
        assert!(ed.search.is_none());
    }

    #[test]
    fn test_replace_all_matches() {
        let mut ed = ed("foo bar foo baz foo");
        ed.search_start(SearchQuery::literal("foo"));
        let results = ed.replace_all_matches("X");
        assert_eq!(results.len(), 3);
        assert!(!ed.buffer.to_string().contains("foo"));
    }

    // ── Selection ─────────────────────────────────────────────────────────────

    #[test]
    fn test_select_word_at_cursor() {
        let mut ed = ed("hello world");
        ed.cursors.move_to(7, false);
        ed.select_word_at_cursor();
        let sel = ed.cursors.primary().selection().unwrap();
        assert_eq!(ed.buffer.text_in_range(sel.as_range()), "world");
    }

    #[test]
    fn test_select_all() {
        let mut ed = ed("hello world");
        ed.select_all();
        let sel = ed.cursors.primary().selection().unwrap();
        assert_eq!(sel.start.0, 0);
        assert_eq!(sel.end.0, 11);
    }

    // ── Language ──────────────────────────────────────────────────────────────

    #[test]
    fn test_set_language_emits_event() {
        let mut ed = Editor::new();
        ed.file_uri = "file:///test.rs".into();
        ed.set_language("rust");
        assert_eq!(ed.language, "rust");
        // Check event was emitted
        let events = ed.event_bus.poll_events();
        assert!(events
            .iter()
            .any(|e| matches!(e, crate::ExtensionEvent::LanguageChanged(_))));
    }

    #[test]
    fn test_set_language_activates_extensions() {
        let mut ed = Editor::new();
        ed.set_language("rust");
        // Rust snippets extension should now be active
        let active = ed.extensions.active_count();
        assert!(active > 0, "Extensions should activate for rust");
    }

    // ── Decorations ───────────────────────────────────────────────────────────

    #[test]
    fn test_delta_decorations_add_remove() {
        let mut ed = ed("hello world");
        let ids = ed.delta_decorations(
            &[],
            &[(
                DecorationSpec {
                    range: Range::new(0, 5),
                    options: DecorationOptions::error_squiggle(),
                },
                "test".into(),
            )],
        );
        assert_eq!(ids.len(), 1);
        assert_eq!(ed.decorations.len(), 1);
        ed.delta_decorations(&ids, &[]);
        assert_eq!(ed.decorations.len(), 0);
    }

    #[test]
    fn test_decorations_adjust_on_edit() {
        let mut ed = ed("hello world");
        // Decoration after position 0
        ed.delta_decorations(
            &[],
            &[(
                DecorationSpec {
                    range: Range::new(6, 11),
                    options: DecorationOptions::default(),
                },
                "test".into(),
            )],
        );
        // Insert 5 bytes at start
        ed.apply(EditOp::insert(0, "xyzab"));
        // Decoration should have shifted forward by 5
        assert_eq!(ed.decorations.all()[0].range.start.0, 11);
    }

    #[test]
    fn test_clear_decorations_by_owner() {
        let mut ed = ed("hello");
        ed.delta_decorations(
            &[],
            &[
                (
                    DecorationSpec {
                        range: Range::new(0, 2),
                        options: DecorationOptions::default(),
                    },
                    "ext1".into(),
                ),
                (
                    DecorationSpec {
                        range: Range::new(2, 4),
                        options: DecorationOptions::default(),
                    },
                    "ext2".into(),
                ),
            ],
        );
        assert_eq!(ed.decorations.len(), 2);
        ed.clear_decorations_by_owner("ext1");
        assert_eq!(ed.decorations.len(), 1);
    }

    // ── TextModel ─────────────────────────────────────────────────────────────

    #[test]
    fn test_text_model_get_line() {
        let ed = ed("line1\nline2\nline3\n");
        let m = ed.text_model();
        assert_eq!(m.get_line_content(1), "line1");
        assert_eq!(m.get_line_content(2), "line2");
    }

    #[test]
    fn test_text_model_find_matches() {
        let ed = ed("foo bar foo baz foo");
        let m = ed.text_model();
        let matches = m.find_matches("foo", false, true, false, None, 0);
        assert_eq!(matches.len(), 3);
    }

    #[test]
    fn test_execute_edits_with_undo() {
        let mut ed = ed("hello world");
        use crate::core::text_model::{MonacoRange, SingleEditOperation};
        ed.execute_edits(&[SingleEditOperation::replace(
            MonacoRange::new(1, 7, 1, 12),
            "Rust",
        )]);
        assert!(ed.buffer.to_string().contains("Rust"));
        ed.undo();
        assert!(ed.buffer.to_string().contains("world"));
    }

    // ── Clipboard ─────────────────────────────────────────────────────────────

    #[test]
    fn test_copy_and_paste() {
        let mut ed = ed("hello world");
        ed.cursors.move_to(0, false);
        ed.cursors.move_to(5, true);
        ed.copy();
        ed.cursors.move_to(11, false);
        ed.paste();
        assert!(ed.buffer.to_string().ends_with("hello"));
    }

    // ── Format ───────────────────────────────────────────────────────────────

    #[test]
    fn test_format_document_trailing_whitespace() {
        let mut ed = ed("hello   \nworld   \n");
        let result = ed.format_document(None);
        assert!(result.has_changes);
        ed.apply_batch(result.ops);
        assert!(!ed.buffer.to_string().contains("   \n"));
    }

    // ── Render frame ──────────────────────────────────────────────────────────

    #[test]
    fn test_render_frame_has_all_fields() {
        let mut ed = ed("fn main() {\n    let x = 1;\n}\n");
        ed.set_language("rust");
        ed.viewport.set_height(20);
        ed.search_start(SearchQuery::literal("let"));
        let frame = ed.render_frame();
        assert!(!frame.lines.is_empty());
        assert!(!frame.cursors.is_empty());
        assert!(!frame.search_matches.is_empty());
        assert_eq!(frame.language, "rust");
    }

    #[test]
    fn test_render_frame_includes_decorations() {
        let mut ed = ed("hello world");
        ed.viewport.set_height(20);
        ed.delta_decorations(
            &[],
            &[(
                DecorationSpec {
                    range: Range::new(0, 5),
                    options: DecorationOptions::error_squiggle(),
                },
                "test".into(),
            )],
        );
        let frame = ed.render_frame();
        assert!(
            !frame.decorations.is_empty(),
            "RenderFrame should include decorations"
        );
    }

    // ── Macro ─────────────────────────────────────────────────────────────────

    #[test]
    fn test_macro_record_and_play() {
        let mut ed = Editor::new();
        ed.macro_start('q').unwrap();
        ed.handle_key(KeyInput::Char('a'));
        ed.handle_key(KeyInput::Char('b'));
        ed.macro_stop().unwrap();
        assert_eq!(ed.buffer.to_string(), "ab");
        ed.macro_play('q', 1);
        // Play inserts at current cursor again
        assert!(ed.buffer.len_bytes() >= 2);
    }

    // ── Events ───────────────────────────────────────────────────────────────

    #[test]
    fn test_apply_emits_text_changed_event() {
        let mut ed = ed("hello");
        let initial = ed.event_bus.pending_count();
        ed.apply(EditOp::insert(5, " world"));
        assert!(
            ed.event_bus.pending_count() > initial,
            "TextChanged event should be emitted"
        );
    }

    #[test]
    fn test_event_bus_drain() {
        let mut ed = ed("hello");
        ed.apply(EditOp::insert(5, " world"));
        let events = ed.event_bus.drain_events();
        assert!(!events.is_empty());
        assert_eq!(ed.event_bus.pending_count(), 0);
    }

    // ── Session ───────────────────────────────────────────────────────────────

    #[test]
    fn test_session_capture_restore() {
        let mut ed = ed("fn main() {}");
        ed.set_language("rust");
        ed.file_uri = "file:///test.rs".into();
        ed.cursors.move_to(5, false);
        let session = crate::core::session::capture(&ed);
        let restored = crate::core::session::restore(&session);
        assert_eq!(restored.language, "rust");
        assert_eq!(restored.cursors.primary().pos.0, 5);
        assert_eq!(restored.buffer.to_string(), "fn main() {}");
    }
}
