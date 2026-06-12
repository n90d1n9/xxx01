// src/ext/providers.rs
//
// Language feature providers — the Monaco `languages.*` namespace in Rust.
//
// Each provider type maps directly to a Monaco registration function:
//   registerDocumentSymbolProvider  → DocumentSymbolProvider
//   registerDefinitionProvider      → DefinitionProvider
//   registerReferenceProvider       → ReferenceProvider
//   registerSignatureHelpProvider   → SignatureHelpProvider
//   registerInlayHintsProvider      → InlayHintProvider
//   registerDocumentHighlightProvider → DocumentHighlightProvider
//   registerFoldingRangeProvider    → FoldingRangeProvider
//   registerColorProvider           → ColorProvider
//   registerRenameProvider          → RenameProvider
//   registerLinkedEditingRangeProvider → LinkedEditingRangeProvider
//   setMonarchTokensProvider        → MonarchLanguage
//   setLanguageConfiguration        → LanguageConfiguration
//
// All providers are called with typed request objects and return typed results.
// The `LanguageFeatureRegistry` aggregates all providers per-language and
// dispatches requests to the right provider.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ── Common types ──────────────────────────────────────────────────────────────

/// A line+column position (1-based lines, 0-based columns — Monaco convention).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct Position {
    pub line: u32,   // 1-based
    pub column: u32, // 0-based
}

impl Position {
    pub fn new(line: u32, column: u32) -> Self {
        Self { line, column }
    }
}

/// A line+column range.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct LineRange {
    pub start: Position,
    pub end: Position,
}

impl LineRange {
    pub fn new(start: Position, end: Position) -> Self {
        Self { start, end }
    }
    pub fn point(line: u32, col: u32) -> Self {
        let p = Position::new(line, col);
        Self { start: p, end: p }
    }
}

/// A resource + range: used for cross-file navigation results.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Location {
    pub file_uri: String,
    pub range: LineRange,
}

impl Location {
    pub fn new(file_uri: &str, range: LineRange) -> Self {
        Self {
            file_uri: file_uri.to_owned(),
            range,
        }
    }
}

/// A set of text edits across one or more files.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct WorkspaceEdit {
    pub edits: HashMap<String, Vec<SingleEdit>>,
}

impl WorkspaceEdit {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn add(&mut self, file_uri: &str, range: LineRange, new_text: &str) {
        self.edits
            .entry(file_uri.to_owned())
            .or_default()
            .push(SingleEdit {
                range,
                new_text: new_text.to_owned(),
            });
    }

    pub fn is_empty(&self) -> bool {
        self.edits.is_empty()
    }

    pub fn file_count(&self) -> usize {
        self.edits.len()
    }
    pub fn total_edits(&self) -> usize {
        self.edits.values().map(|v| v.len()).sum()
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SingleEdit {
    pub range: LineRange,
    pub new_text: String,
}

// ── Document symbols ──────────────────────────────────────────────────────────

/// Monaco `SymbolKind`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[repr(u8)]
pub enum DocumentSymbolKind {
    File = 1,
    Module,
    Namespace,
    Package,
    Class,
    Method,
    Property,
    Field,
    Constructor,
    Enum,
    Interface,
    Function,
    Variable,
    Constant,
    String,
    Number,
    Boolean,
    Array,
    Object,
    Key,
    Null,
    EnumMember,
    Struct,
    Event,
    Operator,
    TypeParameter,
}

/// A symbol in the document outline (breadcrumbs / outline panel).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocumentSymbol {
    pub name: String,
    pub detail: Option<String>,
    pub kind: DocumentSymbolKind,
    pub range: LineRange,
    /// The range that should be selected when the symbol is activated.
    pub selection_range: LineRange,
    pub children: Vec<DocumentSymbol>,
    pub tags: Vec<SymbolTag>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum SymbolTag {
    Deprecated = 1,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocumentSymbolRequest {
    pub file_uri: String,
    pub content: String,
    pub language: String,
}

pub trait DocumentSymbolProvider: Send + Sync {
    fn provide_document_symbols(&self, req: DocumentSymbolRequest) -> Vec<DocumentSymbol>;
}

// ── References ────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReferenceContext {
    pub include_declaration: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReferenceRequest {
    pub file_uri: String,
    pub content: String,
    pub language: String,
    pub position: Position,
    pub context: ReferenceContext,
}

pub trait ReferenceProvider: Send + Sync {
    fn provide_references(&self, req: ReferenceRequest) -> Vec<Location>;
}

// ── Definitions ───────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DefinitionRequest {
    pub file_uri: String,
    pub content: String,
    pub language: String,
    pub position: Position,
}

pub trait DefinitionProvider: Send + Sync {
    fn provide_definition(&self, req: DefinitionRequest) -> Vec<Location>;
    fn provide_type_definition(&self, _req: DefinitionRequest) -> Vec<Location> {
        vec![]
    }
    fn provide_declaration(&self, _req: DefinitionRequest) -> Vec<Location> {
        vec![]
    }
    fn provide_implementation(&self, _req: DefinitionRequest) -> Vec<Location> {
        vec![]
    }
}

// ── Signature help ────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SignatureHelpRequest {
    pub file_uri: String,
    pub content: String,
    pub language: String,
    pub position: Position,
    pub trigger_char: Option<char>,
    pub trigger_kind: SignatureHelpTriggerKind,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum SignatureHelpTriggerKind {
    Invoke = 1,
    TriggerCharacter = 2,
    ContentChange = 3,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ParameterInformation {
    pub label: String,
    pub documentation: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SignatureInformation {
    pub label: String,
    pub documentation: Option<String>,
    pub parameters: Vec<ParameterInformation>,
    pub active_parameter: Option<u32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SignatureHelp {
    pub signatures: Vec<SignatureInformation>,
    pub active_signature: u32,
    pub active_parameter: u32,
}

pub trait SignatureHelpProvider: Send + Sync {
    fn trigger_characters(&self) -> Vec<char>;
    fn provide_signature_help(&self, req: SignatureHelpRequest) -> Option<SignatureHelp>;
}

// ── Inlay hints ───────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum InlayHintKind {
    Type = 1,
    Parameter = 2,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InlayHint {
    pub position: Position,
    pub label: InlayHintLabel,
    pub kind: InlayHintKind,
    pub tooltip: Option<String>,
    pub padding_left: bool,
    pub padding_right: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum InlayHintLabel {
    String(String),
    Parts(Vec<InlayHintLabelPart>),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InlayHintLabelPart {
    pub value: String,
    pub tooltip: Option<String>,
    pub location: Option<Location>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InlayHintRequest {
    pub file_uri: String,
    pub content: String,
    pub language: String,
    pub range: LineRange,
}

pub trait InlayHintProvider: Send + Sync {
    fn provide_inlay_hints(&self, req: InlayHintRequest) -> Vec<InlayHint>;
    fn resolve_inlay_hint(&self, hint: InlayHint) -> InlayHint {
        hint
    }
}

// ── Document highlight ────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum DocumentHighlightKind {
    Text = 1,
    Read = 2,
    Write = 3,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocumentHighlight {
    pub range: LineRange,
    pub kind: DocumentHighlightKind,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocumentHighlightRequest {
    pub file_uri: String,
    pub content: String,
    pub language: String,
    pub position: Position,
}

pub trait DocumentHighlightProvider: Send + Sync {
    fn provide_document_highlights(&self, req: DocumentHighlightRequest) -> Vec<DocumentHighlight>;
}

// ── Folding ranges ────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum FoldingRangeKind {
    Comment,
    Imports,
    Region,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FoldingRange {
    pub start_line: u32,
    pub end_line: u32,
    pub start_column: Option<u32>,
    pub end_column: Option<u32>,
    pub kind: Option<FoldingRangeKind>,
    pub collapsed_text: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FoldingRangeRequest {
    pub file_uri: String,
    pub content: String,
    pub language: String,
}

pub trait FoldingRangeProvider: Send + Sync {
    fn provide_folding_ranges(&self, req: FoldingRangeRequest) -> Vec<FoldingRange>;
}

// ── Color ─────────────────────────────────────────────────────────────────────

/// A floating-point RGBA color (0.0–1.0).
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct Color {
    pub red: f32,
    pub green: f32,
    pub blue: f32,
    pub alpha: f32,
}

impl Color {
    pub fn rgb(r: f32, g: f32, b: f32) -> Self {
        Self {
            red: r,
            green: g,
            blue: b,
            alpha: 1.0,
        }
    }
    pub fn to_hex(&self) -> String {
        format!(
            "#{:02X}{:02X}{:02X}",
            (self.red * 255.0) as u8,
            (self.green * 255.0) as u8,
            (self.blue * 255.0) as u8
        )
    }

    pub fn from_hex(s: &str) -> Option<Self> {
        let s = s.trim_start_matches('#');
        if s.len() < 6 {
            return None;
        }
        let r = u8::from_str_radix(&s[0..2], 16).ok()? as f32 / 255.0;
        let g = u8::from_str_radix(&s[2..4], 16).ok()? as f32 / 255.0;
        let b = u8::from_str_radix(&s[4..6], 16).ok()? as f32 / 255.0;
        Some(Self::rgb(r, g, b))
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ColorInformation {
    pub range: LineRange,
    pub color: Color,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ColorPresentation {
    pub label: String,
    pub text_edit: Option<SingleEdit>,
    pub additional_text_edits: Vec<SingleEdit>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ColorRequest {
    pub file_uri: String,
    pub content: String,
    pub language: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ColorPresentationRequest {
    pub file_uri: String,
    pub color: Color,
    pub range: LineRange,
}

pub trait ColorProvider: Send + Sync {
    fn provide_document_colors(&self, req: ColorRequest) -> Vec<ColorInformation>;
    fn provide_color_presentations(&self, req: ColorPresentationRequest) -> Vec<ColorPresentation>;
}

// ── Rename ────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RenameRequest {
    pub file_uri: String,
    pub content: String,
    pub language: String,
    pub position: Position,
    pub new_name: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PrepareRenameResult {
    pub range: LineRange,
    pub placeholder: String,
}

pub trait RenameProvider: Send + Sync {
    fn prepare_rename(&self, req: DefinitionRequest) -> Option<PrepareRenameResult>;
    fn provide_rename_edits(&self, req: RenameRequest) -> Option<WorkspaceEdit>;
}

// ── Linked editing ranges ─────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LinkedEditingRanges {
    pub ranges: Vec<LineRange>,
    pub word_pattern: Option<String>,
}

pub trait LinkedEditingRangeProvider: Send + Sync {
    fn provide_linked_editing_ranges(
        &self,
        req: DocumentHighlightRequest,
    ) -> Option<LinkedEditingRanges>;
}

// ── Monarch grammar rules ──────────────────────────────────────────────────────

/// A single rule in a Monarch grammar.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MonarchRule {
    /// Regex pattern string.
    pub regex: String,
    /// Token type or nested state transition.
    pub action: MonarchAction,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum MonarchAction {
    Token(String),
    Transition {
        token: String,
        next: Option<String>,
        bracket: Option<String>,
    },
    Cases(Vec<(String, String)>),
}

/// A complete Monarch tokenizer grammar (equivalent to `setMonarchTokensProvider`).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MonarchLanguage {
    /// Default token type.
    pub default_token: String,
    /// Map of state name → rules.
    pub tokenizer: HashMap<String, Vec<MonarchRule>>,
    pub ignore_case: bool,
    pub keywords: Vec<String>,
    pub operators: Vec<String>,
    pub brackets: Vec<(String, String, String)>, // (open, close, token)
}

impl MonarchLanguage {
    pub fn new() -> Self {
        Self {
            default_token: "source".into(),
            tokenizer: HashMap::new(),
            ignore_case: false,
            keywords: Vec::new(),
            operators: Vec::new(),
            brackets: Vec::new(),
        }
    }

    pub fn to_json(&self) -> String {
        serde_json::to_string_pretty(self).unwrap_or_default()
    }
}

impl Default for MonarchLanguage {
    fn default() -> Self {
        Self::new()
    }
}

// ── Language configuration ─────────────────────────────────────────────────────

/// Equivalent to Monaco's `ILanguageExtensionPoint` + `LanguageConfiguration`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LanguageConfiguration {
    pub comments: Option<CommentConfig>,
    pub brackets: Vec<(String, String)>,
    pub auto_closing_pairs: Vec<AutoClosingPair>,
    pub surrounding_pairs: Vec<(String, String)>,
    pub word_pattern: Option<String>,
    pub indentation_rules: Option<IndentationRules>,
    pub folding: Option<FoldingConfig>,
    pub on_enter_rules: Vec<OnEnterRule>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CommentConfig {
    pub line_comment: Option<String>,
    pub block_comment: Option<(String, String)>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AutoClosingPair {
    pub open: String,
    pub close: String,
    pub not_in: Vec<String>, // e.g. ["string", "comment"]
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IndentationRules {
    pub increase_indent_pattern: String,
    pub decrease_indent_pattern: String,
    pub indent_next_line_pattern: Option<String>,
    pub unindent_on_explicit_enter: Option<bool>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FoldingConfig {
    pub markers: Option<FoldingMarkers>,
    pub offset_based: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FoldingMarkers {
    pub start: String, // regex
    pub end: String,   // regex
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OnEnterRule {
    pub before_text: String, // regex
    pub after_text: Option<String>,
    pub previous_line_text: Option<String>,
    pub action: EnterAction,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EnterAction {
    pub indent_action: IndentAction,
    pub append_text: Option<String>,
    pub remove_text: Option<u32>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum IndentAction {
    None,
    Indent,
    IndentOutdent,
    Outdent,
}

// ── Language feature registry ─────────────────────────────────────────────────

/// Central registry for all language feature providers.
/// Mirrors the Monaco `languages.*` namespace.
#[derive(Default)]
pub struct LanguageFeatureRegistry {
    document_symbol: Vec<(String, Box<dyn DocumentSymbolProvider>)>,
    definition: Vec<(String, Box<dyn DefinitionProvider>)>,
    reference: Vec<(String, Box<dyn ReferenceProvider>)>,
    signature_help: Vec<(String, Box<dyn SignatureHelpProvider>)>,
    inlay_hint: Vec<(String, Box<dyn InlayHintProvider>)>,
    doc_highlight: Vec<(String, Box<dyn DocumentHighlightProvider>)>,
    folding_range: Vec<(String, Box<dyn FoldingRangeProvider>)>,
    color: Vec<(String, Box<dyn ColorProvider>)>,
    rename: Vec<(String, Box<dyn RenameProvider>)>,
    linked_editing: Vec<(String, Box<dyn LinkedEditingRangeProvider>)>,
    monarch_grammars: HashMap<String, MonarchLanguage>,
    language_configs: HashMap<String, LanguageConfiguration>,
}

impl LanguageFeatureRegistry {
    pub fn new() -> Self {
        Self::default()
    }

    // ── Registration ──────────────────────────────────────────────────────────

    pub fn register_document_symbol_provider(
        &mut self,
        lang: &str,
        p: Box<dyn DocumentSymbolProvider>,
    ) {
        self.document_symbol.push((lang.to_owned(), p));
    }
    pub fn register_definition_provider(&mut self, lang: &str, p: Box<dyn DefinitionProvider>) {
        self.definition.push((lang.to_owned(), p));
    }
    pub fn register_reference_provider(&mut self, lang: &str, p: Box<dyn ReferenceProvider>) {
        self.reference.push((lang.to_owned(), p));
    }
    pub fn register_signature_help_provider(
        &mut self,
        lang: &str,
        p: Box<dyn SignatureHelpProvider>,
    ) {
        self.signature_help.push((lang.to_owned(), p));
    }
    pub fn register_inlay_hint_provider(&mut self, lang: &str, p: Box<dyn InlayHintProvider>) {
        self.inlay_hint.push((lang.to_owned(), p));
    }
    pub fn register_document_highlight_provider(
        &mut self,
        lang: &str,
        p: Box<dyn DocumentHighlightProvider>,
    ) {
        self.doc_highlight.push((lang.to_owned(), p));
    }
    pub fn register_folding_range_provider(
        &mut self,
        lang: &str,
        p: Box<dyn FoldingRangeProvider>,
    ) {
        self.folding_range.push((lang.to_owned(), p));
    }
    pub fn register_color_provider(&mut self, lang: &str, p: Box<dyn ColorProvider>) {
        self.color.push((lang.to_owned(), p));
    }
    pub fn register_rename_provider(&mut self, lang: &str, p: Box<dyn RenameProvider>) {
        self.rename.push((lang.to_owned(), p));
    }
    pub fn register_linked_editing_range_provider(
        &mut self,
        lang: &str,
        p: Box<dyn LinkedEditingRangeProvider>,
    ) {
        self.linked_editing.push((lang.to_owned(), p));
    }

    /// Equivalent to `languages.setMonarchTokensProvider`.
    pub fn set_monarch_tokens_provider(&mut self, lang: &str, grammar: MonarchLanguage) {
        self.monarch_grammars.insert(lang.to_owned(), grammar);
    }

    /// Equivalent to `languages.setLanguageConfiguration`.
    pub fn set_language_configuration(&mut self, lang: &str, config: LanguageConfiguration) {
        self.language_configs.insert(lang.to_owned(), config);
    }

    // ── Dispatch ──────────────────────────────────────────────────────────────

    pub fn document_symbols(&self, req: DocumentSymbolRequest) -> Vec<DocumentSymbol> {
        let lang = req.language.clone();
        self.document_symbol
            .iter()
            .filter(|(l, _)| l == &lang || l == "*")
            .flat_map(|(_, p)| p.provide_document_symbols(req.clone()))
            .collect()
    }

    pub fn definition(&self, req: DefinitionRequest) -> Vec<Location> {
        let lang = req.language.clone();
        self.definition
            .iter()
            .filter(|(l, _)| l == &lang || l == "*")
            .flat_map(|(_, p)| p.provide_definition(req.clone()))
            .collect()
    }

    pub fn references(&self, req: ReferenceRequest) -> Vec<Location> {
        let lang = req.language.clone();
        self.reference
            .iter()
            .filter(|(l, _)| l == &lang || l == "*")
            .flat_map(|(_, p)| p.provide_references(req.clone()))
            .collect()
    }

    pub fn signature_help(&self, req: SignatureHelpRequest) -> Option<SignatureHelp> {
        let lang = req.language.clone();
        self.signature_help
            .iter()
            .filter(|(l, _)| l == &lang || l == "*")
            .find_map(|(_, p)| p.provide_signature_help(req.clone()))
    }

    pub fn inlay_hints(&self, req: InlayHintRequest) -> Vec<InlayHint> {
        let lang = req.language.clone();
        self.inlay_hint
            .iter()
            .filter(|(l, _)| l == &lang || l == "*")
            .flat_map(|(_, p)| p.provide_inlay_hints(req.clone()))
            .collect()
    }

    pub fn document_highlights(&self, req: DocumentHighlightRequest) -> Vec<DocumentHighlight> {
        let lang = req.language.clone();
        self.doc_highlight
            .iter()
            .filter(|(l, _)| l == &lang || l == "*")
            .flat_map(|(_, p)| p.provide_document_highlights(req.clone()))
            .collect()
    }

    pub fn folding_ranges(&self, req: FoldingRangeRequest) -> Vec<FoldingRange> {
        let lang = req.language.clone();
        self.folding_range
            .iter()
            .filter(|(l, _)| l == &lang || l == "*")
            .flat_map(|(_, p)| p.provide_folding_ranges(req.clone()))
            .collect()
    }

    pub fn rename_edits(&self, req: RenameRequest) -> Option<WorkspaceEdit> {
        let lang = req.language.clone();
        self.rename
            .iter()
            .filter(|(l, _)| l == &lang || l == "*")
            .find_map(|(_, p)| p.provide_rename_edits(req.clone()))
    }

    pub fn get_monarch_grammar(&self, lang: &str) -> Option<&MonarchLanguage> {
        self.monarch_grammars.get(lang)
    }

    pub fn get_language_config(&self, lang: &str) -> Option<&LanguageConfiguration> {
        self.language_configs.get(lang)
    }

    /// Remove all providers registered by an extension.
    pub fn unregister_extension(&mut self, _ext_id: &str) {
        // Note: extension_id is stored as the language key here so we use a separate map
        // In practice, use a wrapper that stores (ext_id, lang, provider)
        // For now, this is a placeholder
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // ── Position / Range ──────────────────────────────────────────────────────

    #[test]
    fn test_position_construction() {
        let p = Position::new(5, 3);
        assert_eq!(p.line, 5);
        assert_eq!(p.column, 3);
    }

    #[test]
    fn test_line_range_point() {
        let r = LineRange::point(10, 5);
        assert_eq!(r.start, r.end);
    }

    // ── WorkspaceEdit ─────────────────────────────────────────────────────────

    #[test]
    fn test_workspace_edit_add() {
        let mut edit = WorkspaceEdit::new();
        edit.add("file:///a.rs", LineRange::point(1, 0), "let x = 1;");
        edit.add("file:///a.rs", LineRange::point(2, 0), "let y = 2;");
        edit.add("file:///b.rs", LineRange::point(1, 0), "fn foo() {}");
        assert_eq!(edit.file_count(), 2);
        assert_eq!(edit.total_edits(), 3);
    }

    #[test]
    fn test_workspace_edit_is_empty() {
        let edit = WorkspaceEdit::new();
        assert!(edit.is_empty());
    }

    // ── Color ─────────────────────────────────────────────────────────────────

    #[test]
    fn test_color_to_hex() {
        let c = Color::rgb(1.0, 0.0, 0.0);
        assert_eq!(c.to_hex(), "#FF0000");
    }

    #[test]
    fn test_color_from_hex() {
        let c = Color::from_hex("#50FA7B").unwrap();
        assert!((c.red - 80.0 / 255.0).abs() < 0.01);
    }

    #[test]
    fn test_color_roundtrip() {
        let c = Color::rgb(0.5, 0.75, 0.25);
        let hex = c.to_hex();
        let restored = Color::from_hex(&hex).unwrap();
        assert!((c.red - restored.red).abs() < 0.01);
    }

    // ── Document symbol ───────────────────────────────────────────────────────

    #[test]
    fn test_document_symbol_construction() {
        let sym = DocumentSymbol {
            name: "main".into(),
            detail: Some("fn main() -> ()".into()),
            kind: DocumentSymbolKind::Function,
            range: LineRange::new(Position::new(1, 0), Position::new(10, 1)),
            selection_range: LineRange::new(Position::new(1, 3), Position::new(1, 7)),
            children: vec![],
            tags: vec![],
        };
        assert_eq!(sym.name, "main");
        assert_eq!(sym.kind, DocumentSymbolKind::Function);
    }

    #[test]
    fn test_document_symbol_with_children() {
        let child = DocumentSymbol {
            name: "helper".into(),
            detail: None,
            kind: DocumentSymbolKind::Method,
            range: LineRange::point(5, 0),
            selection_range: LineRange::point(5, 0),
            children: vec![],
            tags: vec![],
        };
        let parent = DocumentSymbol {
            name: "MyClass".into(),
            detail: None,
            kind: DocumentSymbolKind::Class,
            range: LineRange::point(1, 0),
            selection_range: LineRange::point(1, 0),
            children: vec![child],
            tags: vec![],
        };
        assert_eq!(parent.children.len(), 1);
        assert_eq!(parent.children[0].name, "helper");
    }

    // ── Signature help ────────────────────────────────────────────────────────

    #[test]
    fn test_signature_help_construction() {
        let sig = SignatureHelp {
            signatures: vec![SignatureInformation {
                label: "fn println!(format: &str, ...)".into(),
                documentation: None,
                parameters: vec![ParameterInformation {
                    label: "format: &str".into(),
                    documentation: None,
                }],
                active_parameter: Some(0),
            }],
            active_signature: 0,
            active_parameter: 0,
        };
        assert_eq!(sig.signatures.len(), 1);
        assert_eq!(sig.signatures[0].parameters.len(), 1);
    }

    // ── Inlay hints ───────────────────────────────────────────────────────────

    #[test]
    fn test_inlay_hint_construction() {
        let hint = InlayHint {
            position: Position::new(5, 10),
            label: InlayHintLabel::String(": i32".into()),
            kind: InlayHintKind::Type,
            tooltip: Some("Type annotation".into()),
            padding_left: true,
            padding_right: false,
        };
        assert_eq!(hint.kind, InlayHintKind::Type);
        if let InlayHintLabel::String(s) = &hint.label {
            assert_eq!(s, ": i32");
        }
    }

    // ── Folding range ─────────────────────────────────────────────────────────

    #[test]
    fn test_folding_range_construction() {
        let fr = FoldingRange {
            start_line: 0,
            end_line: 10,
            start_column: None,
            end_column: None,
            kind: Some(FoldingRangeKind::Region),
            collapsed_text: Some("...".into()),
        };
        assert_eq!(fr.end_line, 10);
        assert_eq!(fr.kind, Some(FoldingRangeKind::Region));
    }

    // ── Monarch grammar ───────────────────────────────────────────────────────

    #[test]
    fn test_monarch_language_json() {
        let mut lang = MonarchLanguage::new();
        lang.keywords = vec!["fn".into(), "let".into(), "mut".into()];
        lang.tokenizer.insert(
            "root".into(),
            vec![MonarchRule {
                regex: "[a-zA-Z_][a-zA-Z0-9_]*".into(),
                action: MonarchAction::Cases(vec![
                    ("@keywords".into(), "keyword".into()),
                    ("@default".into(), "identifier".into()),
                ]),
            }],
        );
        let json = lang.to_json();
        let restored: MonarchLanguage = serde_json::from_str(&json).unwrap();
        assert_eq!(restored.keywords.len(), 3);
        assert!(restored.tokenizer.contains_key("root"));
    }

    // ── Language feature registry ─────────────────────────────────────────────

    struct MockSymbolProvider;
    impl DocumentSymbolProvider for MockSymbolProvider {
        fn provide_document_symbols(&self, _req: DocumentSymbolRequest) -> Vec<DocumentSymbol> {
            vec![DocumentSymbol {
                name: "MockSymbol".into(),
                detail: None,
                kind: DocumentSymbolKind::Function,
                range: LineRange::point(1, 0),
                selection_range: LineRange::point(1, 0),
                children: vec![],
                tags: vec![],
            }]
        }
    }

    #[test]
    fn test_registry_document_symbols() {
        let mut reg = LanguageFeatureRegistry::new();
        reg.register_document_symbol_provider("rust", Box::new(MockSymbolProvider));
        let symbols = reg.document_symbols(DocumentSymbolRequest {
            file_uri: "file:///a.rs".into(),
            content: "fn main() {}".into(),
            language: "rust".into(),
        });
        assert_eq!(symbols.len(), 1);
        assert_eq!(symbols[0].name, "MockSymbol");
    }

    #[test]
    fn test_registry_wrong_language_no_results() {
        let mut reg = LanguageFeatureRegistry::new();
        reg.register_document_symbol_provider("rust", Box::new(MockSymbolProvider));
        let symbols = reg.document_symbols(DocumentSymbolRequest {
            file_uri: "file:///a.py".into(),
            content: "def foo(): pass".into(),
            language: "python".into(), // wrong language
        });
        assert!(symbols.is_empty());
    }

    #[test]
    fn test_registry_set_monarch_grammar() {
        let mut reg = LanguageFeatureRegistry::new();
        let mut g = MonarchLanguage::new();
        g.keywords = vec!["def".into()];
        reg.set_monarch_tokens_provider("python", g);
        assert!(reg.get_monarch_grammar("python").is_some());
        assert!(reg.get_monarch_grammar("rust").is_none());
    }

    #[test]
    fn test_registry_language_config() {
        let mut reg = LanguageFeatureRegistry::new();
        let cfg = LanguageConfiguration {
            comments: Some(CommentConfig {
                line_comment: Some("//".into()),
                block_comment: Some(("/*".into(), "*/".into())),
            }),
            brackets: vec![("{".into(), "}".into())],
            auto_closing_pairs: vec![],
            surrounding_pairs: vec![],
            word_pattern: None,
            indentation_rules: None,
            folding: None,
            on_enter_rules: vec![],
        };
        reg.set_language_configuration("rust", cfg);
        let loaded = reg.get_language_config("rust").unwrap();
        assert_eq!(loaded.brackets.len(), 1);
    }

    #[test]
    fn test_linked_editing_ranges_construction() {
        let ler = LinkedEditingRanges {
            ranges: vec![
                LineRange::new(Position::new(1, 4), Position::new(1, 7)),
                LineRange::new(Position::new(10, 2), Position::new(10, 5)),
            ],
            word_pattern: Some("[a-z]+".into()),
        };
        assert_eq!(ler.ranges.len(), 2);
    }
}
