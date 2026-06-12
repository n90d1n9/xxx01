// src/notebook/document.rs
//
// Notebook document — a list of cells plus notebook-level metadata.
//
// Equivalent to an `.ipynb` file in memory:
//   • Ordered list of `Cell` objects
//   • Notebook metadata (kernel, language, nbformat version)
//   • Format version (nbformat 4.x)
//   • Dirty tracking for save prompts
//   • Cell movement / insertion / deletion
//   • Clipboard for cut/copy/paste cells

use super::cell::{Cell, CellId, CellSnapshot, CellType};
use super::kernel::KernelSpec;
use super::output::CellOutput;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ── Notebook metadata ─────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NotebookKernelspec {
    pub display_name: String,
    pub language: String,
    pub name: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NotebookLanguageInfo {
    pub name: String,
    pub version: String,
    pub file_extension: String,
    pub mimetype: Option<String>,
    pub pygments_lexer: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NotebookMetadata {
    pub kernelspec: Option<NotebookKernelspec>,
    pub language_info: Option<NotebookLanguageInfo>,
    pub orig_nbformat: Option<u32>,
    pub title: Option<String>,
    pub authors: Vec<String>,
    pub custom: HashMap<String, serde_json::Value>,
}

impl Default for NotebookMetadata {
    fn default() -> Self {
        Self {
            kernelspec: None,
            language_info: None,
            orig_nbformat: None,
            title: None,
            authors: Vec::new(),
            custom: HashMap::new(),
        }
    }
}

impl NotebookMetadata {
    pub fn for_kernel(spec: &KernelSpec) -> Self {
        Self {
            kernelspec: Some(NotebookKernelspec {
                display_name: spec.display_name.clone(),
                language: spec.language.clone(),
                name: spec.kernel_name.clone(),
            }),
            language_info: Some(NotebookLanguageInfo {
                name: spec.language.clone(),
                version: String::new(),
                file_extension: spec.metadata.file_extension.clone().unwrap_or_default(),
                mimetype: spec.metadata.mimetype.clone(),
                pygments_lexer: spec.metadata.pygments_lexer.clone(),
            }),
            ..Self::default()
        }
    }

    pub fn language(&self) -> &str {
        self.kernelspec
            .as_ref()
            .map(|k| k.language.as_str())
            .or_else(|| self.language_info.as_ref().map(|l| l.name.as_str()))
            .unwrap_or("python")
    }

    pub fn kernel_name(&self) -> &str {
        self.kernelspec
            .as_ref()
            .map(|k| k.name.as_str())
            .unwrap_or("python3")
    }
}

// ── Notebook document ─────────────────────────────────────────────────────────

#[derive(Clone)]
pub struct NotebookDocument {
    /// File URI (empty for untitled notebooks).
    pub uri: String,
    pub metadata: NotebookMetadata,
    /// nbformat major version (always 4 for modern notebooks).
    pub nbformat: u32,
    /// nbformat minor version.
    pub nbformat_minor: u32,
    cells: Vec<Cell>,
    /// Index of the "active" cell (cursor is here).
    pub active_cell: usize,
    /// Whether the notebook has unsaved changes.
    pub dirty: bool,
    /// Cell clipboard (for cut/copy/paste cells).
    cell_clipboard: Vec<CellSnapshot>,
    /// Monotonic execution counter.
    exec_counter: u32,
}

impl NotebookDocument {
    // ── Constructors ──────────────────────────────────────────────────────────

    pub fn new(language: &str) -> Self {
        let mut doc = Self {
            uri: String::new(),
            metadata: NotebookMetadata::default(),
            nbformat: 4,
            nbformat_minor: 5,
            cells: Vec::new(),
            active_cell: 0,
            dirty: false,
            cell_clipboard: Vec::new(),
            exec_counter: 0,
        };
        // Start with one empty code cell
        doc.cells.push(Cell::code("", language));
        doc
    }

    pub fn for_kernel(spec: &KernelSpec) -> Self {
        let mut doc = Self::new(&spec.language);
        doc.metadata = NotebookMetadata::for_kernel(spec);
        doc
    }

    pub fn with_uri(mut self, uri: &str) -> Self {
        self.uri = uri.to_owned();
        self
    }

    // ── Cell access ───────────────────────────────────────────────────────────

    pub fn cells(&self) -> &[Cell] {
        &self.cells
    }
    pub fn cells_mut(&mut self) -> &mut [Cell] {
        &mut self.cells
    }
    pub fn cell_count(&self) -> usize {
        self.cells.len()
    }

    pub fn active(&self) -> Option<&Cell> {
        self.cells.get(self.active_cell)
    }

    pub fn active_mut(&mut self) -> Option<&mut Cell> {
        self.cells.get_mut(self.active_cell)
    }

    pub fn cell_by_id(&self, id: &CellId) -> Option<&Cell> {
        self.cells.iter().find(|c| &c.id == id)
    }

    pub fn cell_by_id_mut(&mut self, id: &CellId) -> Option<&mut Cell> {
        self.cells.iter_mut().find(|c| &c.id == id)
    }

    pub fn index_of(&self, id: &CellId) -> Option<usize> {
        self.cells.iter().position(|c| &c.id == id)
    }

    pub fn language(&self) -> &str {
        self.metadata.language()
    }

    // ── Cell operations ───────────────────────────────────────────────────────

    /// Insert a new code cell below the active cell.
    pub fn insert_cell_below(&mut self, cell_type: CellType) -> &Cell {
        let lang = self.language().to_owned();
        let cell = match cell_type {
            CellType::Code => Cell::code("", &lang),
            CellType::Markdown => Cell::markdown(""),
            CellType::Raw => Cell::raw(""),
        };
        let insert_at = (self.active_cell + 1).min(self.cells.len());
        self.cells.insert(insert_at, cell);
        self.active_cell = insert_at;
        self.dirty = true;
        &self.cells[insert_at]
    }

    /// Insert a new cell above the active cell.
    pub fn insert_cell_above(&mut self, cell_type: CellType) -> &Cell {
        let lang = self.language().to_owned();
        let cell = match cell_type {
            CellType::Code => Cell::code("", &lang),
            CellType::Markdown => Cell::markdown(""),
            CellType::Raw => Cell::raw(""),
        };
        let insert_at = self.active_cell;
        self.cells.insert(insert_at, cell);
        self.dirty = true;
        &self.cells[insert_at]
    }

    /// Delete the active cell. Returns false if it was the last cell.
    pub fn delete_active_cell(&mut self) -> bool {
        if self.cells.len() <= 1 {
            return false;
        }
        self.cells.remove(self.active_cell);
        if self.active_cell >= self.cells.len() {
            self.active_cell = self.cells.len() - 1;
        }
        self.dirty = true;
        true
    }

    /// Move the active cell up by one position.
    pub fn move_cell_up(&mut self) -> bool {
        if self.active_cell == 0 {
            return false;
        }
        self.cells.swap(self.active_cell, self.active_cell - 1);
        self.active_cell -= 1;
        self.dirty = true;
        true
    }

    /// Move the active cell down by one position.
    pub fn move_cell_down(&mut self) -> bool {
        if self.active_cell + 1 >= self.cells.len() {
            return false;
        }
        self.cells.swap(self.active_cell, self.active_cell + 1);
        self.active_cell += 1;
        self.dirty = true;
        true
    }

    /// Split the active cell at the cursor position.
    pub fn split_cell_at_cursor(&mut self) {
        let lang = self.language().to_owned();
        if let Some(cell) = self.cells.get(self.active_cell) {
            let cursor = cell.editor.cursors.primary().pos.0;
            let source = cell.source();
            let (before, after) = (&source[..cursor], &source[cursor..]);
            let before = before.to_owned();
            let after = after.to_owned();
            let ct = cell.cell_type;
            self.cells[self.active_cell].set_source(&before);
            let new_cell = match ct {
                CellType::Code => Cell::code(&after, &lang),
                CellType::Markdown => Cell::markdown(&after),
                CellType::Raw => Cell::raw(&after),
            };
            let insert_at = self.active_cell + 1;
            self.cells.insert(insert_at, new_cell);
            self.active_cell = insert_at;
            self.dirty = true;
        }
    }

    /// Merge the active cell with the cell above it.
    pub fn merge_with_above(&mut self) -> bool {
        if self.active_cell == 0 {
            return false;
        }
        let above_src = self.cells[self.active_cell - 1].source();
        let curr_src = self.cells[self.active_cell].source();
        let merged = format!("{}\n{}", above_src.trim_end_matches('\n'), curr_src);
        self.cells[self.active_cell - 1].set_source(&merged);
        self.cells.remove(self.active_cell);
        self.active_cell -= 1;
        self.dirty = true;
        true
    }

    /// Change the type of the active cell.
    pub fn change_cell_type(&mut self, cell_type: CellType) {
        if let Some(cell) = self.cells.get_mut(self.active_cell) {
            cell.cell_type = cell_type;
            if cell_type != CellType::Code {
                cell.clear_outputs();
            }
            self.dirty = true;
        }
    }

    // ── Navigation ────────────────────────────────────────────────────────────

    pub fn focus_next_cell(&mut self) -> bool {
        if self.active_cell + 1 < self.cells.len() {
            self.active_cell += 1;
            true
        } else {
            false
        }
    }

    pub fn focus_prev_cell(&mut self) -> bool {
        if self.active_cell > 0 {
            self.active_cell -= 1;
            true
        } else {
            false
        }
    }

    pub fn focus_cell_at(&mut self, idx: usize) -> bool {
        if idx < self.cells.len() {
            self.active_cell = idx;
            true
        } else {
            false
        }
    }

    pub fn focus_first_cell(&mut self) {
        self.active_cell = 0;
    }

    pub fn focus_last_cell(&mut self) {
        if !self.cells.is_empty() {
            self.active_cell = self.cells.len() - 1;
        }
    }

    // ── Cell clipboard ────────────────────────────────────────────────────────

    pub fn copy_cell(&mut self) {
        if let Some(cell) = self.cells.get(self.active_cell) {
            self.cell_clipboard = vec![CellSnapshot::from_cell(cell)];
        }
    }

    pub fn cut_cell(&mut self) {
        self.copy_cell();
        self.delete_active_cell();
    }

    pub fn paste_cell_below(&mut self) {
        let lang = self.language().to_owned();
        for snap in self.cell_clipboard.iter().rev() {
            let cell = snap.to_cell(&lang);
            let insert_at = (self.active_cell + 1).min(self.cells.len());
            self.cells.insert(insert_at, cell);
            self.active_cell = insert_at;
        }
        self.dirty = true;
    }

    // ── Execution helpers ──────────────────────────────────────────────────────

    pub fn next_execution_count(&mut self) -> u32 {
        self.exec_counter += 1;
        self.exec_counter
    }

    pub fn reset_execution_counter(&mut self) {
        self.exec_counter = 0;
    }

    pub fn execution_counter(&self) -> u32 {
        self.exec_counter
    }

    /// Clear all outputs in the notebook.
    pub fn clear_all_outputs(&mut self) {
        for cell in &mut self.cells {
            cell.clear_outputs();
        }
        self.exec_counter = 0;
        self.dirty = true;
    }

    /// Cells that need execution (have source and are code cells).
    pub fn executable_cells(&self) -> Vec<usize> {
        self.cells
            .iter()
            .enumerate()
            .filter(|(_, c)| c.is_executable() && !c.is_empty())
            .map(|(i, _)| i)
            .collect()
    }

    /// Add an output to a cell identified by index.
    pub fn add_output_to(&mut self, cell_idx: usize, output: CellOutput) {
        if let Some(cell) = self.cells.get_mut(cell_idx) {
            cell.add_output(output);
        }
    }

    // ── Save state ────────────────────────────────────────────────────────────

    pub fn mark_clean(&mut self) {
        self.dirty = false;
    }
    pub fn mark_dirty(&mut self) {
        self.dirty = true;
    }

    // ── Statistics ────────────────────────────────────────────────────────────

    pub fn code_cell_count(&self) -> usize {
        self.cells
            .iter()
            .filter(|c| c.cell_type == CellType::Code)
            .count()
    }

    pub fn total_lines(&self) -> usize {
        self.cells.iter().map(|c| c.line_count()).sum()
    }
}

// ── .ipynb serialisation ──────────────────────────────────────────────────────

/// The nbformat v4 notebook JSON structure.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IpynbDocument {
    pub nbformat: u32,
    pub nbformat_minor: u32,
    pub metadata: NotebookMetadata,
    pub cells: Vec<CellSnapshot>,
}

impl IpynbDocument {
    pub fn from_notebook(nb: &NotebookDocument) -> Self {
        Self {
            nbformat: nb.nbformat,
            nbformat_minor: nb.nbformat_minor,
            metadata: nb.metadata.clone(),
            cells: nb.cells.iter().map(CellSnapshot::from_cell).collect(),
        }
    }

    pub fn to_json_pretty(&self) -> String {
        serde_json::to_string_pretty(self).unwrap_or_default()
    }

    pub fn to_notebook(&self) -> NotebookDocument {
        let lang = self.metadata.language().to_owned();
        let mut doc = NotebookDocument {
            uri: String::new(),
            metadata: self.metadata.clone(),
            nbformat: self.nbformat,
            nbformat_minor: self.nbformat_minor,
            cells: self.cells.iter().map(|s| s.to_cell(&lang)).collect(),
            active_cell: 0,
            dirty: false,
            cell_clipboard: Vec::new(),
            exec_counter: 0,
        };
        // Restore exec counter from highest execution_count
        doc.exec_counter = doc
            .cells
            .iter()
            .filter_map(|c| c.execution_count)
            .max()
            .unwrap_or(0);
        // If no cells, add a starter cell
        if doc.cells.is_empty() {
            doc.cells.push(Cell::code("", &lang));
        }
        doc
    }

    pub fn from_json(json: &str) -> anyhow::Result<Self> {
        let doc: IpynbDocument = serde_json::from_str(json)?;
        if doc.nbformat < 4 {
            return Err(anyhow::anyhow!(
                "Only nbformat >= 4 is supported (got {})",
                doc.nbformat
            ));
        }
        Ok(doc)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::notebook::cell::CellType;
    use crate::notebook::kernel::KernelRegistry;
    use crate::notebook::output::CellOutput;

    fn python_notebook() -> NotebookDocument {
        let reg = KernelRegistry::new();
        let spec = reg.get("python3").unwrap();
        NotebookDocument::for_kernel(spec)
    }

    #[test]
    fn test_new_notebook_has_one_cell() {
        let nb = NotebookDocument::new("python");
        assert_eq!(nb.cell_count(), 1);
        assert_eq!(nb.active_cell, 0);
    }

    #[test]
    fn test_insert_cell_below() {
        let mut nb = python_notebook();
        let initial = nb.cell_count();
        nb.insert_cell_below(CellType::Code);
        assert_eq!(nb.cell_count(), initial + 1);
        assert_eq!(nb.active_cell, 1);
        assert!(nb.dirty);
    }

    #[test]
    fn test_insert_cell_above() {
        let mut nb = python_notebook();
        nb.insert_cell_above(CellType::Markdown);
        assert_eq!(nb.cell_count(), 2);
        assert_eq!(nb.active_cell, 0); // active stays at 0 (the new cell)
        assert_eq!(nb.cells()[0].cell_type, CellType::Markdown);
    }

    #[test]
    fn test_delete_cell() {
        let mut nb = python_notebook();
        nb.insert_cell_below(CellType::Code);
        assert_eq!(nb.cell_count(), 2);
        nb.delete_active_cell();
        assert_eq!(nb.cell_count(), 1);
    }

    #[test]
    fn test_cannot_delete_last_cell() {
        let mut nb = python_notebook();
        assert!(!nb.delete_active_cell());
        assert_eq!(nb.cell_count(), 1);
    }

    #[test]
    fn test_move_cell_up_down() {
        let mut nb = python_notebook();
        nb.cells_mut()[0].set_source("cell 0");
        nb.insert_cell_below(CellType::Code);
        nb.cells_mut()[1].set_source("cell 1");
        // Move cell 1 up
        assert!(nb.move_cell_up());
        assert_eq!(nb.active_cell, 0);
        assert_eq!(nb.cells()[0].source(), "cell 1");
        assert_eq!(nb.cells()[1].source(), "cell 0");
    }

    #[test]
    fn test_move_cell_up_at_top_fails() {
        let mut nb = python_notebook();
        assert!(!nb.move_cell_up());
    }

    #[test]
    fn test_merge_with_above() {
        let mut nb = python_notebook();
        nb.cells_mut()[0].set_source("line 1");
        nb.insert_cell_below(CellType::Code);
        nb.cells_mut()[1].set_source("line 2");
        nb.merge_with_above();
        assert_eq!(nb.cell_count(), 1);
        assert!(nb.cells()[0].source().contains("line 1"));
        assert!(nb.cells()[0].source().contains("line 2"));
    }

    #[test]
    fn test_change_cell_type() {
        let mut nb = python_notebook();
        nb.cells_mut()[0].set_source("x = 1");
        nb.change_cell_type(CellType::Markdown);
        assert_eq!(nb.cells()[0].cell_type, CellType::Markdown);
    }

    #[test]
    fn test_navigation() {
        let mut nb = python_notebook();
        nb.insert_cell_below(CellType::Code);
        nb.insert_cell_below(CellType::Code);
        assert_eq!(nb.active_cell, 2);
        nb.focus_first_cell();
        assert_eq!(nb.active_cell, 0);
        nb.focus_last_cell();
        assert_eq!(nb.active_cell, 2);
        nb.focus_prev_cell();
        assert_eq!(nb.active_cell, 1);
    }

    #[test]
    fn test_copy_paste_cell() {
        let mut nb = python_notebook();
        nb.cells_mut()[0].set_source("x = 42");
        nb.copy_cell();
        nb.paste_cell_below();
        assert_eq!(nb.cell_count(), 2);
        assert_eq!(nb.cells()[1].source(), "x = 42");
    }

    #[test]
    fn test_cut_cell() {
        let mut nb = python_notebook();
        nb.cells_mut()[0].set_source("first cell");
        nb.insert_cell_below(CellType::Code);
        nb.cells_mut()[1].set_source("second cell");
        nb.focus_cell_at(0);
        nb.cut_cell();
        assert_eq!(nb.cell_count(), 1);
        nb.paste_cell_below();
        assert!(nb.cells().iter().any(|c| c.source() == "first cell"));
    }

    #[test]
    fn test_execution_counter() {
        let mut nb = python_notebook();
        assert_eq!(nb.next_execution_count(), 1);
        assert_eq!(nb.next_execution_count(), 2);
        nb.reset_execution_counter();
        assert_eq!(nb.next_execution_count(), 1);
    }

    #[test]
    fn test_clear_all_outputs() {
        let mut nb = python_notebook();
        nb.cells_mut()[0].add_output(CellOutput::stdout("hello\n"));
        nb.exec_counter = 5;
        nb.clear_all_outputs();
        assert!(nb.cells()[0].outputs.is_empty());
        assert_eq!(nb.exec_counter, 0);
    }

    #[test]
    fn test_executable_cells() {
        let mut nb = python_notebook();
        nb.cells_mut()[0].set_source("x = 1");
        nb.insert_cell_below(CellType::Markdown);
        nb.cells_mut()[1].set_source("# heading");
        nb.insert_cell_below(CellType::Code);
        nb.cells_mut()[2].set_source("print(x)");
        let exec = nb.executable_cells();
        assert_eq!(exec.len(), 2);
        assert!(exec.contains(&0));
        assert!(exec.contains(&2));
        assert!(!exec.contains(&1));
    }

    #[test]
    fn test_ipynb_roundtrip() {
        let mut nb = python_notebook();
        nb.cells_mut()[0].set_source("x = 42");
        nb.cells_mut()[0].add_output(CellOutput::stdout("42\n"));
        nb.cells_mut()[0].execution_count = Some(1);
        nb.insert_cell_below(CellType::Markdown);
        nb.cells_mut()[1].set_source("# Analysis");

        let ipynb = IpynbDocument::from_notebook(&nb);
        let json = ipynb.to_json_pretty();
        assert!(json.contains("nbformat"));
        assert!(json.contains("x = 42"));
        assert!(json.contains("Analysis"));

        let restored_ipynb = IpynbDocument::from_json(&json).unwrap();
        let restored_nb = restored_ipynb.to_notebook();
        assert_eq!(restored_nb.cell_count(), 2);
        assert_eq!(restored_nb.cells()[0].source(), "x = 42");
        assert_eq!(restored_nb.cells()[1].cell_type, CellType::Markdown);
        assert_eq!(restored_nb.exec_counter, 1);
    }

    #[test]
    fn test_notebook_metadata_language() {
        let nb = python_notebook();
        assert_eq!(nb.language(), "python");
        assert_eq!(nb.metadata.kernel_name(), "python3");
    }

    #[test]
    fn test_notebook_statistics() {
        let mut nb = python_notebook();
        nb.cells_mut()[0].set_source("x = 1\ny = 2\nz = 3");
        nb.insert_cell_below(CellType::Markdown);
        nb.cells_mut()[1].set_source("# Heading");
        assert_eq!(nb.code_cell_count(), 1);
        assert_eq!(nb.total_lines(), 4); // 3 code + 1 markdown
    }

    #[test]
    fn test_ipynb_rejects_old_format() {
        let old_json = r#"{"nbformat":3,"nbformat_minor":0,"metadata":{},"worksheets":[]}"#;
        assert!(IpynbDocument::from_json(old_json).is_err());
    }
}
