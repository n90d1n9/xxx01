// src/notebook/cell.rs
//
// Notebook cell — the fundamental unit of a Jupyter notebook.
//
// Each cell has:
//   • A unique ID (UUID v4 style)
//   • A type: Code | Markdown | Raw
//   • Source text (editable)
//   • Outputs (code cells only)
//   • Execution state and count
//   • Metadata (collapsed, trusted, tags, custom)
//   • An embedded `Editor` for its source text (our full editor engine)

use super::output::{CellOutput, OutputBuffer};
use crate::core::edit::EditOp;
use crate::Editor;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ── Cell ID ───────────────────────────────────────────────────────────────────

/// A stable unique identifier for a cell (survives reorder and undo).
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct CellId(pub String);

impl CellId {
    pub fn new() -> Self {
        // Simple deterministic UUID-like ID without external deps
        use std::time::{SystemTime, UNIX_EPOCH};
        let t = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map(|d| d.as_nanos())
            .unwrap_or(0);
        static COUNTER: std::sync::atomic::AtomicU64 = std::sync::atomic::AtomicU64::new(0);
        let c = COUNTER.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
        CellId(format!("{:016x}{:016x}", t, c))
    }

    pub fn from_str(s: &str) -> Self {
        CellId(s.to_owned())
    }
    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl Default for CellId {
    fn default() -> Self {
        Self::new()
    }
}

// ── Cell type ─────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum CellType {
    /// Executable code — runs against the kernel.
    Code,
    /// Markdown prose — rendered in the UI.
    Markdown,
    /// Raw source — not executed, not rendered.
    Raw,
}

impl CellType {
    pub fn is_executable(&self) -> bool {
        *self == CellType::Code
    }
}

// ── Execution state ───────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum CellExecutionState {
    /// Not yet run / outputs cleared.
    Idle,
    /// Waiting in the execution queue.
    Queued,
    /// Currently executing.
    Running,
    /// Execution completed successfully.
    Done,
    /// Execution raised an exception.
    Error,
    /// Execution was interrupted by the user.
    Interrupted,
}

impl CellExecutionState {
    pub fn is_terminal(&self) -> bool {
        matches!(self, Self::Done | Self::Error | Self::Interrupted)
    }
    pub fn is_running(&self) -> bool {
        *self == Self::Running
    }
}

// ── Cell metadata ─────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CellMetadata {
    /// Whether the cell's output is collapsed in the UI.
    pub collapsed: bool,
    /// Whether the cell is scrollable (long output).
    pub scrolled: bool,
    /// Whether the cell is trusted (can render HTML/JS safely).
    pub trusted: bool,
    /// User-defined tags: "parameters", "skip", "solution", etc.
    pub tags: Vec<String>,
    /// JupyterLab cell name (for papermill parameter injection).
    pub name: Option<String>,
    /// Custom metadata from external tools.
    pub custom: HashMap<String, serde_json::Value>,
}

impl Default for CellMetadata {
    fn default() -> Self {
        Self {
            collapsed: false,
            scrolled: false,
            trusted: false,
            tags: Vec::new(),
            name: None,
            custom: HashMap::new(),
        }
    }
}

impl CellMetadata {
    pub fn with_tag(mut self, tag: &str) -> Self {
        self.tags.push(tag.to_owned());
        self
    }

    pub fn with_name(mut self, name: &str) -> Self {
        self.name = Some(name.to_owned());
        self
    }

    pub fn is_parameters_cell(&self) -> bool {
        self.tags.iter().any(|t| t == "parameters")
    }

    pub fn is_injected_parameters(&self) -> bool {
        self.tags.iter().any(|t| t == "injected-parameters")
    }
}

// ── Execution timing ──────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecutionTiming {
    /// ISO-8601 timestamp when execution started.
    pub start_time: Option<String>,
    /// ISO-8601 timestamp when execution ended.
    pub end_time: Option<String>,
    /// Elapsed milliseconds.
    pub elapsed_ms: Option<u64>,
}

// ── Cell ──────────────────────────────────────────────────────────────────────

pub struct Cell {
    pub id: CellId,
    pub cell_type: CellType,
    /// The embedded editor for this cell's source.
    pub editor: Editor,
    /// Execution outputs (code cells only).
    pub outputs: OutputBuffer,
    /// Execution counter shown as `[N]:`.
    pub execution_count: Option<u32>,
    pub execution_state: CellExecutionState,
    pub execution_timing: ExecutionTiming,
    pub metadata: CellMetadata,
}

impl Clone for Cell {
    fn clone(&self) -> Self {
        let mut editor = Editor::from_str(&self.source());
        editor.set_language(&self.editor.language);
        Self {
            id: self.id.clone(),
            cell_type: self.cell_type,
            editor,
            outputs: self.outputs.clone(),
            execution_count: self.execution_count,
            execution_state: self.execution_state,
            execution_timing: self.execution_timing.clone(),
            metadata: self.metadata.clone(),
        }
    }
}

impl Cell {
    // ── Constructors ──────────────────────────────────────────────────────────

    pub fn code(source: &str, language: &str) -> Self {
        let mut editor = Editor::from_str(source);
        editor.set_language(language);
        Self {
            id: CellId::new(),
            cell_type: CellType::Code,
            editor,
            outputs: OutputBuffer::new(),
            execution_count: None,
            execution_state: CellExecutionState::Idle,
            execution_timing: ExecutionTiming {
                start_time: None,
                end_time: None,
                elapsed_ms: None,
            },
            metadata: CellMetadata::default(),
        }
    }

    pub fn markdown(source: &str) -> Self {
        let mut editor = Editor::from_str(source);
        editor.set_language("markdown");
        Self {
            id: CellId::new(),
            cell_type: CellType::Markdown,
            editor,
            outputs: OutputBuffer::new(),
            execution_count: None,
            execution_state: CellExecutionState::Idle,
            execution_timing: ExecutionTiming {
                start_time: None,
                end_time: None,
                elapsed_ms: None,
            },
            metadata: CellMetadata::default(),
        }
    }

    pub fn raw(source: &str) -> Self {
        let mut cell = Self::code(source, "");
        cell.cell_type = CellType::Raw;
        cell
    }

    // ── Source access ──────────────────────────────────────────────────────────

    pub fn source(&self) -> String {
        self.editor.buffer.to_string()
    }

    pub fn set_source(&mut self, source: &str) {
        let len = self.editor.buffer.len_bytes();
        if len > 0 {
            self.editor.apply(EditOp::delete(0, len));
        }
        if !source.is_empty() {
            self.editor.apply(EditOp::insert(0, source));
        }
        self.outputs.clear();
    }

    pub fn is_empty(&self) -> bool {
        self.source().trim().is_empty()
    }

    // ── Execution API ──────────────────────────────────────────────────────────

    pub fn mark_queued(&mut self) {
        self.execution_state = CellExecutionState::Queued;
    }

    pub fn mark_running(&mut self) {
        self.execution_state = CellExecutionState::Running;
        self.outputs.clear();
    }

    pub fn mark_done(&mut self, count: u32, elapsed_ms: u64) {
        self.execution_state = CellExecutionState::Done;
        self.execution_count = Some(count);
        self.execution_timing.elapsed_ms = Some(elapsed_ms);
    }

    pub fn mark_error(&mut self, count: u32) {
        self.execution_state = CellExecutionState::Error;
        self.execution_count = Some(count);
    }

    pub fn mark_interrupted(&mut self) {
        self.execution_state = CellExecutionState::Interrupted;
    }

    pub fn add_output(&mut self, output: CellOutput) {
        self.outputs.push(output);
    }

    pub fn clear_outputs(&mut self) {
        self.outputs.clear();
        self.execution_count = None;
        self.execution_state = CellExecutionState::Idle;
    }

    // ── Queries ───────────────────────────────────────────────────────────────

    pub fn is_executable(&self) -> bool {
        self.cell_type.is_executable()
    }

    pub fn execution_label(&self) -> String {
        match self.execution_count {
            Some(n) => format!("[{}]:", n),
            None => "[*]:".to_owned(),
        }
    }

    pub fn has_error(&self) -> bool {
        self.execution_state == CellExecutionState::Error || self.outputs.has_error()
    }

    pub fn line_count(&self) -> usize {
        self.editor.buffer.len_lines()
    }
}

// ── Serialisable snapshot (for .ipynb) ────────────────────────────────────────

/// A serialisable snapshot of a cell — used for .ipynb read/write.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CellSnapshot {
    pub id: String,
    pub cell_type: CellType,
    pub source: Vec<String>, // lines (nbformat convention)
    pub outputs: Vec<CellOutput>,
    pub execution_count: Option<u32>,
    pub metadata: CellMetadata,
}

impl CellSnapshot {
    pub fn from_cell(cell: &Cell) -> Self {
        let source = cell.source();
        let lines: Vec<String> = if source.is_empty() {
            vec![]
        } else {
            source
                .lines()
                .enumerate()
                .map(|(i, line)| {
                    let total = source.lines().count();
                    if i < total - 1 || source.ends_with('\n') {
                        format!("{}\n", line)
                    } else {
                        line.to_owned()
                    }
                })
                .collect()
        };
        Self {
            id: cell.id.0.clone(),
            cell_type: cell.cell_type,
            source: lines,
            outputs: cell.outputs.outputs.clone(),
            execution_count: cell.execution_count,
            metadata: cell.metadata.clone(),
        }
    }

    pub fn source_text(&self) -> String {
        self.source.join("")
    }

    pub fn to_cell(&self, language: &str) -> Cell {
        let source = self.source_text();
        let mut cell = match self.cell_type {
            CellType::Code => Cell::code(&source, language),
            CellType::Markdown => Cell::markdown(&source),
            CellType::Raw => Cell::raw(&source),
        };
        cell.id = CellId(self.id.clone());
        cell.execution_count = self.execution_count;
        cell.metadata = self.metadata.clone();
        for output in &self.outputs {
            cell.outputs.outputs.push(output.clone());
        }
        if self.execution_count.is_some() {
            cell.execution_state = CellExecutionState::Done;
        }
        cell
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::notebook::output::CellOutput;

    #[test]
    fn test_cell_id_unique() {
        let a = CellId::new();
        let b = CellId::new();
        assert_ne!(a, b);
    }

    #[test]
    fn test_code_cell_basic() {
        let cell = Cell::code("print('hello')", "python");
        assert_eq!(cell.cell_type, CellType::Code);
        assert!(cell.is_executable());
        assert_eq!(cell.source(), "print('hello')");
        assert_eq!(cell.editor.language, "python");
    }

    #[test]
    fn test_markdown_cell() {
        let cell = Cell::markdown("# Heading\nSome text");
        assert_eq!(cell.cell_type, CellType::Markdown);
        assert!(!cell.is_executable());
    }

    #[test]
    fn test_set_source_clears_outputs() {
        let mut cell = Cell::code("x = 1", "python");
        cell.add_output(CellOutput::stdout("old output\n"));
        assert!(!cell.outputs.is_empty());
        cell.set_source("x = 2");
        assert_eq!(cell.source(), "x = 2");
        assert!(
            cell.outputs.is_empty(),
            "Outputs should be cleared on source change"
        );
    }

    #[test]
    fn test_execution_lifecycle() {
        let mut cell = Cell::code("1 + 1", "python");
        assert_eq!(cell.execution_state, CellExecutionState::Idle);

        cell.mark_queued();
        assert_eq!(cell.execution_state, CellExecutionState::Queued);

        cell.mark_running();
        assert_eq!(cell.execution_state, CellExecutionState::Running);
        assert!(cell.outputs.is_empty(), "Outputs cleared on running");

        cell.add_output(CellOutput::stdout("2\n"));
        cell.mark_done(1, 42);
        assert_eq!(cell.execution_state, CellExecutionState::Done);
        assert_eq!(cell.execution_count, Some(1));
        assert_eq!(cell.execution_timing.elapsed_ms, Some(42));
    }

    #[test]
    fn test_execution_error_state() {
        let mut cell = Cell::code("1/0", "python");
        cell.mark_running();
        cell.add_output(CellOutput::error(
            "ZeroDivisionError",
            "division by zero",
            vec!["Traceback...".into()],
        ));
        cell.mark_error(2);
        assert!(cell.has_error());
        assert_eq!(cell.execution_count, Some(2));
    }

    #[test]
    fn test_clear_outputs() {
        let mut cell = Cell::code("x = 1", "python");
        cell.execution_count = Some(5);
        cell.add_output(CellOutput::stdout("5\n"));
        cell.clear_outputs();
        assert!(cell.outputs.is_empty());
        assert!(cell.execution_count.is_none());
        assert_eq!(cell.execution_state, CellExecutionState::Idle);
    }

    #[test]
    fn test_execution_label() {
        let mut cell = Cell::code("1+1", "python");
        assert_eq!(cell.execution_label(), "[*]:");
        cell.execution_count = Some(3);
        assert_eq!(cell.execution_label(), "[3]:");
    }

    #[test]
    fn test_cell_metadata_tags() {
        let meta = CellMetadata::default()
            .with_tag("parameters")
            .with_name("input_cell");
        assert!(meta.is_parameters_cell());
        assert_eq!(meta.name.unwrap(), "input_cell");
    }

    #[test]
    fn test_cell_snapshot_roundtrip() {
        let mut cell = Cell::code("x = 42\nprint(x)", "python");
        cell.execution_count = Some(1);
        cell.add_output(CellOutput::stdout("42\n"));

        let snap = CellSnapshot::from_cell(&cell);
        assert_eq!(snap.source_text(), "x = 42\nprint(x)");
        assert_eq!(snap.outputs.len(), 1);
        assert_eq!(snap.execution_count, Some(1));

        let restored = snap.to_cell("python");
        assert_eq!(restored.source(), "x = 42\nprint(x)");
        assert_eq!(restored.execution_count, Some(1));
    }

    #[test]
    fn test_snapshot_source_lines_format() {
        let cell = Cell::code("line1\nline2\nline3", "python");
        let snap = CellSnapshot::from_cell(&cell);
        // All but the last line should end with \n
        assert_eq!(snap.source.len(), 3);
        assert!(snap.source[0].ends_with('\n'));
        assert!(snap.source[1].ends_with('\n'));
    }

    #[test]
    fn test_cell_is_empty() {
        let cell = Cell::code("", "python");
        assert!(cell.is_empty());
        let cell2 = Cell::code("   \n  ", "python");
        assert!(cell2.is_empty());
        let cell3 = Cell::code("x = 1", "python");
        assert!(!cell3.is_empty());
    }
}
