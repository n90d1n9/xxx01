// src/notebook/inspector.rs
//
// Variable inspector, kernel completion bridge, and notebook diff.
//
// Variable inspector:
//   Parses the JSON response from `%who_ls` / `inspect_request` to build
//   a typed variable table for the UI sidebar.
//
// Kernel completion bridge:
//   Maps Jupyter `complete_reply` to our `CompletionItem` format so the
//   cell editor's AI/LSP completion can be augmented with live kernel
//   completions.
//
// Notebook diff:
//   Compares two .ipynb documents cell-by-cell using the Myers diff
//   algorithm (same as our ai/diff.rs but at cell granularity).

use super::cell::CellSnapshot;
use super::document::{IpynbDocument, NotebookDocument};
use super::kernel::{CompleteReply, InspectReply};
use crate::ext::CompletionItemKind;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ═══════════════════════════════════════════════════════════════════════════════
// VARIABLE INSPECTOR
// ═══════════════════════════════════════════════════════════════════════════════

/// The type category of a variable in the kernel namespace.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum VarKind {
    Int,
    Float,
    Complex,
    Bool,
    Str,
    Bytes,
    List,
    Tuple,
    Set,
    Dict,
    NdArray,   // numpy array
    DataFrame, // pandas DataFrame
    Series,    // pandas Series
    Function,  // callable
    Class,     // type/class
    Module,    // imported module
    Other,
}

impl VarKind {
    fn from_type_name(type_name: &str) -> Self {
        match type_name {
            "int" => Self::Int,
            "float" => Self::Float,
            "complex" => Self::Complex,
            "bool" => Self::Bool,
            "str" => Self::Str,
            "bytes" | "bytearray" => Self::Bytes,
            "list" => Self::List,
            "tuple" => Self::Tuple,
            "set" | "frozenset" => Self::Set,
            "dict" => Self::Dict,
            "ndarray" => Self::NdArray,
            "DataFrame" => Self::DataFrame,
            "Series" => Self::Series,
            "function" | "builtin_function_or_method" | "method" | "lambda" => Self::Function,
            "type" => Self::Class,
            "module" => Self::Module,
            _ => Self::Other,
        }
    }

    pub fn icon(&self) -> &'static str {
        match self {
            Self::Int | Self::Float | Self::Complex => "$(symbol-number)",
            Self::Bool => "$(symbol-boolean)",
            Self::Str => "$(symbol-string)",
            Self::Bytes => "$(symbol-key)",
            Self::List | Self::Tuple | Self::Set => "$(symbol-array)",
            Self::Dict => "$(symbol-object)",
            Self::NdArray => "$(table)",
            Self::DataFrame => "$(table)",
            Self::Series => "$(graph-line)",
            Self::Function => "$(symbol-function)",
            Self::Class => "$(symbol-class)",
            Self::Module => "$(package)",
            Self::Other => "$(symbol-variable)",
        }
    }
}

/// A single variable in the kernel namespace.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KernelVariable {
    pub name: String,
    pub type_name: String,
    pub kind: VarKind,
    /// String representation (repr).
    pub repr: String,
    /// Shape for arrays/DataFrames: "(100, 5)"
    pub shape: Option<String>,
    /// Size in bytes (if known).
    pub size_bytes: Option<u64>,
    /// Number of elements for containers.
    pub num_elements: Option<u64>,
    /// Data type for numeric arrays.
    pub dtype: Option<String>,
}

impl KernelVariable {
    pub fn new(name: &str, type_name: &str, repr: &str) -> Self {
        Self {
            name: name.to_owned(),
            type_name: type_name.to_owned(),
            kind: VarKind::from_type_name(type_name),
            repr: repr.to_owned(),
            shape: None,
            size_bytes: None,
            num_elements: None,
            dtype: None,
        }
    }

    pub fn with_shape(mut self, shape: &str) -> Self {
        self.shape = Some(shape.to_owned());
        self
    }

    pub fn with_dtype(mut self, dtype: &str) -> Self {
        self.dtype = Some(dtype.to_owned());
        self
    }

    pub fn short_repr(&self) -> &str {
        let r = self.repr.as_str();
        if r.len() > 80 {
            &r[..80]
        } else {
            r
        }
    }
}

/// The variable inspector state.
#[derive(Debug, Default, Serialize, Deserialize)]
pub struct VariableInspector {
    pub variables: Vec<KernelVariable>,
    pub last_updated: u64, // epoch ms
    pub kernel_session: String,
}

impl VariableInspector {
    pub fn new() -> Self {
        Self::default()
    }

    /// Build the kernel code to inspect the namespace.
    /// Returns Python code that, when executed, prints JSON variable info.
    pub fn inspector_code() -> &'static str {
        r#"
import json as _json
_vars = {}
for _k, _v in list(vars().items()):
    if _k.startswith('_'): continue
    _t = type(_v).__name__
    _r = repr(_v)[:200]
    _info = {"type": _t, "repr": _r}
    try:
        import numpy as _np
        if isinstance(_v, _np.ndarray):
            _info["shape"] = str(_v.shape)
            _info["dtype"] = str(_v.dtype)
            _info["size"]  = int(_v.nbytes)
    except ImportError: pass
    try:
        import pandas as _pd
        if isinstance(_v, (_pd.DataFrame, _pd.Series)):
            _info["shape"] = str(_v.shape)
            _info["dtype"] = str(_v.dtypes.to_dict() if hasattr(_v, 'dtypes') else _v.dtype)
    except ImportError: pass
    if hasattr(_v, '__len__'):
        try: _info["len"] = len(_v)
        except: pass
    _vars[_k] = _info
print(_json.dumps(_vars))
"#
    }

    /// Parse the JSON output of inspector_code() into variable list.
    pub fn parse_json_output(&mut self, json_output: &str, now_ms: u64) {
        let trimmed = json_output.trim();
        if trimmed.is_empty() {
            return;
        }
        let parsed: HashMap<String, serde_json::Value> = match serde_json::from_str(trimmed) {
            Ok(v) => v,
            Err(_) => return,
        };

        self.variables = parsed
            .into_iter()
            .map(|(name, info)| {
                let type_name = info["type"].as_str().unwrap_or("unknown").to_owned();
                let repr = info["repr"].as_str().unwrap_or("").to_owned();
                let mut var = KernelVariable::new(&name, &type_name, &repr);
                if let Some(shape) = info["shape"].as_str() {
                    var.shape = Some(shape.to_owned());
                }
                if let Some(dtype) = info["dtype"].as_str() {
                    var.dtype = Some(dtype.to_owned());
                }
                if let Some(size) = info["size"].as_u64() {
                    var.size_bytes = Some(size);
                }
                if let Some(len) = info["len"].as_u64() {
                    var.num_elements = Some(len);
                }
                var
            })
            .collect();

        self.variables.sort_by(|a, b| a.name.cmp(&b.name));
        self.last_updated = now_ms;
    }

    /// Parse the `%whos` text output (fallback for non-Python kernels).
    pub fn parse_whos_output(&mut self, text: &str, now_ms: u64) {
        let mut vars = Vec::new();
        for line in text.lines().skip(1) {
            // skip header
            let parts: Vec<&str> = line
                .splitn(3, char::is_whitespace)
                .filter(|s| !s.is_empty())
                .collect();
            if parts.len() >= 2 {
                let name = parts[0];
                let type_name = parts[1];
                let repr = parts.get(2).map(|s| s.trim()).unwrap_or("");
                vars.push(KernelVariable::new(name, type_name, repr));
            }
        }
        self.variables = vars;
        self.last_updated = now_ms;
    }

    pub fn get(&self, name: &str) -> Option<&KernelVariable> {
        self.variables.iter().find(|v| v.name == name)
    }

    pub fn filter_by_kind(&self, kind: VarKind) -> Vec<&KernelVariable> {
        self.variables.iter().filter(|v| v.kind == kind).collect()
    }

    pub fn dataframes(&self) -> Vec<&KernelVariable> {
        self.filter_by_kind(VarKind::DataFrame)
    }
    pub fn arrays(&self) -> Vec<&KernelVariable> {
        self.filter_by_kind(VarKind::NdArray)
    }

    pub fn to_json(&self) -> String {
        serde_json::to_string_pretty(self).unwrap_or_default()
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// KERNEL COMPLETION BRIDGE
// ═══════════════════════════════════════════════════════════════════════════════

/// Converts a Jupyter `complete_reply` into our completion item format.
pub struct KernelCompletionBridge;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KernelCompletionItem {
    pub label: String,
    pub kind: CompletionItemKind,
    pub detail: Option<String>,
    pub documentation: Option<String>,
    pub insert_text: String,
    pub sort_text: Option<String>,
    pub filter_text: Option<String>,
    pub is_multiline: bool,
    pub source: String,
}

impl KernelCompletionBridge {
    /// Convert a `CompleteReply` into editor-facing completion items.
    pub fn to_completion_items(reply: &CompleteReply, source: &str) -> Vec<KernelCompletionItem> {
        if reply.status != "ok" {
            return vec![];
        }

        let _prefix: String = source
            .chars()
            .rev()
            .take_while(|&c| c.is_alphanumeric() || c == '_' || c == '.')
            .collect::<String>()
            .chars()
            .rev()
            .collect();

        reply
            .matches
            .iter()
            .map(|label| {
                let kind = Self::infer_kind(label);
                KernelCompletionItem {
                    label: label.clone(),
                    insert_text: label.clone(),
                    kind,
                    detail: Self::detail_from_kind(kind),
                    documentation: None,
                    sort_text: Some(format!("z_{}", label)), // after AI suggestions
                    filter_text: Some(label.clone()),
                    is_multiline: false,
                    source: "kernel".into(),
                }
            })
            .collect()
    }

    fn infer_kind(label: &str) -> CompletionItemKind {
        if label.ends_with("()") || label.ends_with("(") {
            CompletionItemKind::Function
        } else if label.starts_with(|c: char| c.is_uppercase()) {
            CompletionItemKind::Class
        } else if label.contains('.') {
            CompletionItemKind::Property
        } else {
            CompletionItemKind::Variable
        }
    }

    fn detail_from_kind(kind: CompletionItemKind) -> Option<String> {
        match kind {
            CompletionItemKind::Function => Some("(kernel)".into()),
            CompletionItemKind::Class => Some("class (kernel)".into()),
            _ => None,
        }
    }

    /// Build the `complete_request` content JSON for a given source + cursor.
    pub fn build_request_content(source: &str, cursor_pos: usize) -> serde_json::Value {
        serde_json::json!({
            "code":       source,
            "cursor_pos": cursor_pos,
        })
    }

    /// Build an `inspect_request` for the word at cursor.
    pub fn build_inspect_content(source: &str, cursor_pos: usize, detail: u8) -> serde_json::Value {
        serde_json::json!({
            "code":         source,
            "cursor_pos":   cursor_pos,
            "detail_level": detail,
        })
    }

    /// Convert an `InspectReply` to hover documentation Markdown.
    pub fn inspect_to_hover(reply: &InspectReply) -> Option<String> {
        if !reply.found {
            return None;
        }
        reply
            .data
            .get("text/plain")
            .and_then(|v| v.as_str())
            .map(|s| s.to_owned())
            .or_else(|| {
                reply
                    .data
                    .get("text/html")
                    .and_then(|v| v.as_str())
                    .map(|s| s.to_owned())
            })
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTEBOOK DIFF
// ═══════════════════════════════════════════════════════════════════════════════

/// A diff operation on a sequence of cells.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum CellDiffOp {
    /// Cell exists in both notebooks, unchanged.
    Equal { idx_a: usize, idx_b: usize },
    /// Cell exists only in notebook B (inserted).
    Insert { idx_b: usize },
    /// Cell exists only in notebook A (deleted).
    Delete { idx_a: usize },
    /// Cell exists in both but content changed.
    Replace { idx_a: usize, idx_b: usize },
}

/// A diff between two notebooks.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NotebookDiff {
    pub ops: Vec<CellDiffOp>,
    pub cells_added: usize,
    pub cells_deleted: usize,
    pub cells_changed: usize,
    pub identical: bool,
}

impl NotebookDiff {
    pub fn summary(&self) -> String {
        if self.identical {
            "Notebooks are identical".to_owned()
        } else {
            format!(
                "+{} cells, -{} cells, ~{} cells changed",
                self.cells_added, self.cells_deleted, self.cells_changed
            )
        }
    }
}

/// Compare two notebooks cell by cell.
pub struct NotebookDiffer;

impl NotebookDiffer {
    pub fn diff(a: &NotebookDocument, b: &NotebookDocument) -> NotebookDiff {
        let snaps_a: Vec<CellSnapshot> = a.cells().iter().map(CellSnapshot::from_cell).collect();
        let snaps_b: Vec<CellSnapshot> = b.cells().iter().map(CellSnapshot::from_cell).collect();
        Self::diff_snapshots(&snaps_a, &snaps_b)
    }

    pub fn diff_ipynb(json_a: &str, json_b: &str) -> anyhow::Result<NotebookDiff> {
        let a = IpynbDocument::from_json(json_a)?.to_notebook();
        let b = IpynbDocument::from_json(json_b)?.to_notebook();
        Ok(Self::diff(&a, &b))
    }

    fn diff_snapshots(a: &[CellSnapshot], b: &[CellSnapshot]) -> NotebookDiff {
        let _n = a.len();
        let _m = b.len();

        // LCS-based diff (classic Myers O(nd))
        let lcs = Self::lcs(a, b);
        let ops = Self::build_ops(a, b, &lcs);

        let cells_added = ops
            .iter()
            .filter(|op| matches!(op, CellDiffOp::Insert { .. }))
            .count();
        let cells_deleted = ops
            .iter()
            .filter(|op| matches!(op, CellDiffOp::Delete { .. }))
            .count();
        let cells_changed = ops
            .iter()
            .filter(|op| matches!(op, CellDiffOp::Replace { .. }))
            .count();
        let identical = cells_added == 0 && cells_deleted == 0 && cells_changed == 0;

        NotebookDiff {
            ops,
            cells_added,
            cells_deleted,
            cells_changed,
            identical,
        }
    }

    /// Compute the LCS table between cell sequences.
    fn lcs(a: &[CellSnapshot], b: &[CellSnapshot]) -> Vec<Vec<usize>> {
        let n = a.len();
        let m = b.len();
        let mut dp = vec![vec![0usize; m + 1]; n + 1];
        for i in 1..=n {
            for j in 1..=m {
                if Self::cells_equal(&a[i - 1], &b[j - 1]) {
                    dp[i][j] = dp[i - 1][j - 1] + 1;
                } else {
                    dp[i][j] = dp[i - 1][j].max(dp[i][j - 1]);
                }
            }
        }
        dp
    }

    fn build_ops(a: &[CellSnapshot], b: &[CellSnapshot], dp: &[Vec<usize>]) -> Vec<CellDiffOp> {
        enum RawOp {
            Equal { idx_a: usize, idx_b: usize },
            Insert { idx_b: usize },
            Delete { idx_a: usize },
        }

        let mut ops = Vec::new();
        let (mut i, mut j) = (a.len(), b.len());

        while i > 0 || j > 0 {
            if i > 0 && j > 0 && Self::cells_equal(&a[i - 1], &b[j - 1]) {
                ops.push(RawOp::Equal {
                    idx_a: i - 1,
                    idx_b: j - 1,
                });
                i -= 1;
                j -= 1;
            } else if j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j]) {
                ops.push(RawOp::Insert { idx_b: j - 1 });
                j -= 1;
            } else {
                ops.push(RawOp::Delete { idx_a: i - 1 });
                i -= 1;
            }
        }

        ops.reverse();
        let mut out = Vec::new();
        let mut ops = ops.into_iter().peekable();
        while let Some(op) = ops.next() {
            match op {
                RawOp::Equal { idx_a, idx_b } => out.push(CellDiffOp::Equal { idx_a, idx_b }),
                RawOp::Delete { idx_a } => {
                    if let Some(RawOp::Insert { idx_b }) = ops.peek() {
                        let idx_b = *idx_b;
                        ops.next();
                        out.push(CellDiffOp::Replace { idx_a, idx_b });
                    } else {
                        out.push(CellDiffOp::Delete { idx_a });
                    }
                }
                RawOp::Insert { idx_b } => out.push(CellDiffOp::Insert { idx_b }),
            }
        }
        out
    }

    /// Two cells are "equal" if they have the same type and source text.
    fn cells_equal(a: &CellSnapshot, b: &CellSnapshot) -> bool {
        a.cell_type == b.cell_type && a.source_text() == b.source_text()
    }

    /// Generate a unified diff text representation.
    pub fn to_text(diff: &NotebookDiff, a: &NotebookDocument, b: &NotebookDocument) -> String {
        let snaps_a: Vec<CellSnapshot> = a.cells().iter().map(CellSnapshot::from_cell).collect();
        let snaps_b: Vec<CellSnapshot> = b.cells().iter().map(CellSnapshot::from_cell).collect();
        let mut out = String::from("--- notebook a\n+++ notebook b\n");

        for op in &diff.ops {
            match op {
                CellDiffOp::Equal { idx_a, .. } => {
                    let src = snaps_a[*idx_a].source_text();
                    for line in src.lines().take(2) {
                        out.push_str(&format!(" {}\n", line));
                    }
                    if src.lines().count() > 2 {
                        out.push_str(" ...\n");
                    }
                }
                CellDiffOp::Insert { idx_b } => {
                    let src = snaps_b[*idx_b].source_text();
                    out.push_str(&format!("@@ +cell[{}] @@\n", idx_b));
                    for line in src.lines() {
                        out.push_str(&format!("+{}\n", line));
                    }
                }
                CellDiffOp::Delete { idx_a } => {
                    let src = snaps_a[*idx_a].source_text();
                    out.push_str(&format!("@@ -cell[{}] @@\n", idx_a));
                    for line in src.lines() {
                        out.push_str(&format!("-{}\n", line));
                    }
                }
                CellDiffOp::Replace { idx_a, idx_b } => {
                    let src_a = snaps_a[*idx_a].source_text();
                    let src_b = snaps_b[*idx_b].source_text();
                    out.push_str(&format!("@@ ~cell[{}→{}] @@\n", idx_a, idx_b));
                    for line in src_a.lines() {
                        out.push_str(&format!("-{}\n", line));
                    }
                    for line in src_b.lines() {
                        out.push_str(&format!("+{}\n", line));
                    }
                }
            }
        }
        out
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::notebook::cell::CellType;
    use crate::notebook::document::NotebookDocument;
    use crate::notebook::kernel::{CompleteReply, InspectReply, KernelRegistry};

    // ── Variable inspector ────────────────────────────────────────────────────

    #[test]
    fn test_parse_json_output() {
        let mut inspector = VariableInspector::new();
        let json = r#"{"x": {"type": "int", "repr": "42"},
                        "df": {"type": "DataFrame", "repr": "...", "shape": "(100, 5)"},
                        "arr": {"type": "ndarray", "repr": "array([1,2,3])", "dtype": "float64"}}"#;
        inspector.parse_json_output(json, 1000);
        assert_eq!(inspector.variables.len(), 3);
        let x = inspector.get("x").unwrap();
        assert_eq!(x.kind, VarKind::Int);
        assert_eq!(x.repr, "42");
        let df = inspector.get("df").unwrap();
        assert_eq!(df.kind, VarKind::DataFrame);
        assert_eq!(df.shape.as_deref(), Some("(100, 5)"));
        let arr = inspector.get("arr").unwrap();
        assert_eq!(arr.kind, VarKind::NdArray);
        assert_eq!(arr.dtype.as_deref(), Some("float64"));
    }

    #[test]
    fn test_parse_whos_output() {
        let mut inspector = VariableInspector::new();
        let whos = "Variable   Type    Data/Info\n\
                    x          int     42\n\
                    name       str     'Alice'\n";
        inspector.parse_whos_output(whos, 0);
        assert!(!inspector.variables.is_empty());
    }

    #[test]
    fn test_filter_by_kind() {
        let mut inspector = VariableInspector::new();
        let json = r#"{"x":{"type":"int","repr":"1"},"y":{"type":"float","repr":"2.0"},"df":{"type":"DataFrame","repr":"..."}}"#;
        inspector.parse_json_output(json, 0);
        assert_eq!(inspector.dataframes().len(), 1);
        assert_eq!(inspector.dataframes()[0].name, "df");
    }

    #[test]
    fn test_var_kind_from_type_name() {
        assert_eq!(VarKind::from_type_name("int"), VarKind::Int);
        assert_eq!(VarKind::from_type_name("float"), VarKind::Float);
        assert_eq!(VarKind::from_type_name("ndarray"), VarKind::NdArray);
        assert_eq!(VarKind::from_type_name("DataFrame"), VarKind::DataFrame);
        assert_eq!(VarKind::from_type_name("function"), VarKind::Function);
        assert_eq!(VarKind::from_type_name("module"), VarKind::Module);
    }

    #[test]
    fn test_var_kind_icons() {
        assert!(!VarKind::Int.icon().is_empty());
        assert!(!VarKind::DataFrame.icon().is_empty());
        assert!(!VarKind::Function.icon().is_empty());
    }

    #[test]
    fn test_inspector_json_roundtrip() {
        let mut inspector = VariableInspector::new();
        let json = r#"{"x":{"type":"int","repr":"42"}}"#;
        inspector.parse_json_output(json, 1234);
        let out = inspector.to_json();
        assert!(out.contains("\"variables\""));
        assert!(out.contains("1234")); // timestamp preserved
    }

    #[test]
    fn test_inspector_code_is_valid_python_structure() {
        let code = VariableInspector::inspector_code();
        assert!(code.contains("import json"));
        assert!(code.contains("print(_json.dumps"));
        assert!(code.contains("vars()"));
    }

    // ── Kernel completion bridge ───────────────────────────────────────────────

    #[test]
    fn test_completion_bridge_basic() {
        let reply = CompleteReply {
            status: "ok".into(),
            matches: vec!["print".into(), "print_function".into(), "property".into()],
            cursor_start: 0,
            cursor_end: 5,
            metadata: serde_json::Value::Null,
        };
        let items = KernelCompletionBridge::to_completion_items(&reply, "prin");
        assert_eq!(items.len(), 3);
        assert_eq!(items[0].label, "print");
        assert_eq!(items[0].source, "kernel");
    }

    #[test]
    fn test_completion_bridge_infers_kind() {
        let reply = CompleteReply {
            status: "ok".into(),
            matches: vec!["DataFrame".into(), "my_func()".into(), "my_var".into()],
            cursor_start: 0,
            cursor_end: 0,
            metadata: serde_json::Value::Null,
        };
        let items = KernelCompletionBridge::to_completion_items(&reply, "");
        let df = items.iter().find(|i| i.label == "DataFrame").unwrap();
        assert_eq!(df.kind, CompletionItemKind::Class);
        let f = items.iter().find(|i| i.label == "my_func()").unwrap();
        assert_eq!(f.kind, CompletionItemKind::Function);
    }

    #[test]
    fn test_completion_bridge_error_status_returns_empty() {
        let reply = CompleteReply {
            status: "error".into(),
            matches: vec!["x".into()],
            cursor_start: 0,
            cursor_end: 0,
            metadata: serde_json::Value::Null,
        };
        assert!(KernelCompletionBridge::to_completion_items(&reply, "").is_empty());
    }

    #[test]
    fn test_inspect_to_hover() {
        let reply = InspectReply {
            status: "ok".into(),
            found: true,
            data: [(
                "text/plain".to_owned(),
                serde_json::json!("print(value, ...)\nPrint to stdout"),
            )]
            .into_iter()
            .collect(),
            metadata: serde_json::Value::Null,
        };
        let hover = KernelCompletionBridge::inspect_to_hover(&reply).unwrap();
        assert!(hover.contains("print"));
    }

    #[test]
    fn test_inspect_not_found_returns_none() {
        let reply = InspectReply {
            status: "ok".into(),
            found: false,
            data: HashMap::new(),
            metadata: serde_json::Value::Null,
        };
        assert!(KernelCompletionBridge::inspect_to_hover(&reply).is_none());
    }

    // ── Notebook diff ─────────────────────────────────────────────────────────

    fn make_nb(cells: &[(&str, CellType)]) -> NotebookDocument {
        let reg = KernelRegistry::new();
        let spec = reg.get("python3").unwrap();
        let mut nb = NotebookDocument::for_kernel(spec);
        // Set first cell
        if let Some((src, ct)) = cells.first() {
            nb.cells_mut()[0].set_source(src);
            nb.cells_mut()[0].cell_type = *ct;
        }
        for (src, ct) in cells.iter().skip(1) {
            nb.insert_cell_below(*ct);
            let n = nb.cell_count();
            nb.cells_mut()[n - 1].set_source(src);
        }
        nb
    }

    #[test]
    fn test_diff_identical_notebooks() {
        let a = make_nb(&[("x = 1", CellType::Code), ("# heading", CellType::Markdown)]);
        let b = make_nb(&[("x = 1", CellType::Code), ("# heading", CellType::Markdown)]);
        let diff = NotebookDiffer::diff(&a, &b);
        assert!(diff.identical);
        assert_eq!(diff.summary(), "Notebooks are identical");
    }

    #[test]
    fn test_diff_insertion() {
        let a = make_nb(&[("x = 1", CellType::Code)]);
        let b = make_nb(&[("x = 1", CellType::Code), ("y = 2", CellType::Code)]);
        let diff = NotebookDiffer::diff(&a, &b);
        assert!(!diff.identical);
        assert_eq!(diff.cells_added, 1);
        assert_eq!(diff.cells_deleted, 0);
    }

    #[test]
    fn test_diff_deletion() {
        let a = make_nb(&[("x = 1", CellType::Code), ("y = 2", CellType::Code)]);
        let b = make_nb(&[("x = 1", CellType::Code)]);
        let diff = NotebookDiffer::diff(&a, &b);
        assert_eq!(diff.cells_deleted, 1);
        assert_eq!(diff.cells_added, 0);
    }

    #[test]
    fn test_diff_replacement() {
        let a = make_nb(&[("x = 1", CellType::Code)]);
        let b = make_nb(&[("x = 999", CellType::Code)]);
        let diff = NotebookDiffer::diff(&a, &b);
        assert!(!diff.identical);
        assert!(diff.cells_changed > 0 || diff.cells_added > 0 || diff.cells_deleted > 0);
    }

    #[test]
    fn test_diff_to_text() {
        let a = make_nb(&[("x = 1", CellType::Code)]);
        let b = make_nb(&[("x = 1", CellType::Code), ("y = 2", CellType::Code)]);
        let diff = NotebookDiffer::diff(&a, &b);
        let text = NotebookDiffer::to_text(&diff, &a, &b);
        assert!(text.contains("---"));
        assert!(text.contains("+++"));
        assert!(text.contains("+y = 2"));
    }

    #[test]
    fn test_diff_empty_notebooks() {
        let a = make_nb(&[("", CellType::Code)]);
        let b = make_nb(&[("", CellType::Code)]);
        let diff = NotebookDiffer::diff(&a, &b);
        assert!(diff.identical);
    }

    #[test]
    fn test_diff_ops_structure() {
        let a = make_nb(&[("a", CellType::Code), ("b", CellType::Code)]);
        let b = make_nb(&[("a", CellType::Code), ("c", CellType::Code)]);
        let diff = NotebookDiffer::diff(&a, &b);
        assert!(diff
            .ops
            .iter()
            .any(|op| matches!(op, CellDiffOp::Equal { .. })));
    }
}
