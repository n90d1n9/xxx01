// src/lsp/protocol.rs
//
// LSP protocol types (subset — extend as needed).
// Based on LSP spec 3.17.

use serde::{de, Deserialize, Deserializer, Serialize, Serializer};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LspPosition {
    pub line: u32,
    pub character: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LspRange {
    pub start: LspPosition,
    pub end: LspPosition,
}

// ── Diagnostics ──────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DiagnosticSeverity {
    Error = 1,
    Warning = 2,
    Information = 3,
    Hint = 4,
}

impl Serialize for DiagnosticSeverity {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.serialize_u8(*self as u8)
    }
}

impl<'de> Deserialize<'de> for DiagnosticSeverity {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        let value = serde_json::Value::deserialize(deserializer)?;
        match value {
            serde_json::Value::Number(n) => match n.as_u64() {
                Some(1) => Ok(Self::Error),
                Some(2) => Ok(Self::Warning),
                Some(3) => Ok(Self::Information),
                Some(4) => Ok(Self::Hint),
                _ => Err(de::Error::custom("invalid diagnostic severity")),
            },
            serde_json::Value::String(s) => match s.as_str() {
                "Error" | "error" => Ok(Self::Error),
                "Warning" | "warning" => Ok(Self::Warning),
                "Information" | "information" | "Info" | "info" => Ok(Self::Information),
                "Hint" | "hint" => Ok(Self::Hint),
                _ => Err(de::Error::custom("invalid diagnostic severity")),
            },
            _ => Err(de::Error::custom("invalid diagnostic severity")),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Diagnostic {
    pub range: LspRange,
    pub severity: DiagnosticSeverity,
    pub message: String,
    pub source: Option<String>,
    pub code: Option<String>,
}

// ── Completion ───────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum CompletionKind {
    Text = 1,
    Method = 2,
    Function = 3,
    Constructor = 4,
    Field = 5,
    Variable = 6,
    Class = 7,
    Interface = 8,
    Module = 9,
    Property = 10,
    Unit = 11,
    Value = 12,
    Enum = 13,
    Keyword = 14,
    Snippet = 15,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompletionItem {
    pub label: String,
    pub kind: Option<CompletionKind>,
    pub detail: Option<String>,
    pub documentation: Option<String>,
    pub insert_text: Option<String>,
    pub sort_text: Option<String>,
}

// ── Hover ─────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HoverResult {
    pub contents: String,
    pub range: Option<LspRange>,
}

// ── Go-to-definition ─────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Location {
    pub uri: String,
    pub range: LspRange,
}

// ── Workspace edit ────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TextEdit {
    pub range: LspRange,
    pub new_text: String,
}

// ── JSON-RPC message wrappers ─────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct JsonRpcRequest {
    pub jsonrpc: String,
    pub id: u64,
    pub method: String,
    pub params: serde_json::Value,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct JsonRpcResponse {
    pub jsonrpc: String,
    pub id: u64,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub result: Option<serde_json::Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<JsonRpcError>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct JsonRpcError {
    pub code: i64,
    pub message: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct JsonRpcNotification {
    pub jsonrpc: String,
    pub method: String,
    pub params: serde_json::Value,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_diagnostic_severity_values() {
        assert_eq!(DiagnosticSeverity::Error as u8, 1);
        assert_eq!(DiagnosticSeverity::Warning as u8, 2);
        assert_eq!(DiagnosticSeverity::Information as u8, 3);
        assert_eq!(DiagnosticSeverity::Hint as u8, 4);
    }

    #[test]
    fn test_diagnostic_json_roundtrip() {
        let diag = Diagnostic {
            range: LspRange {
                start: LspPosition {
                    line: 0,
                    character: 5,
                },
                end: LspPosition {
                    line: 0,
                    character: 10,
                },
            },
            severity: DiagnosticSeverity::Error,
            message: "undefined variable".into(),
            source: Some("rustc".into()),
            code: Some("E0425".into()),
        };
        let json = serde_json::to_string(&diag).unwrap();
        let restored: Diagnostic = serde_json::from_str(&json).unwrap();
        assert_eq!(restored.severity, DiagnosticSeverity::Error);
        assert_eq!(restored.message, "undefined variable");
        assert_eq!(restored.range.start.line, 0);
        assert_eq!(restored.range.start.character, 5);
    }

    #[test]
    fn test_completion_item_json_roundtrip() {
        let item = CompletionItem {
            label: "println".into(),
            kind: Some(CompletionKind::Function),
            detail: Some("macro_rules! println".into()),
            documentation: None,
            insert_text: Some("println!(\"$1\")".into()),
            sort_text: None,
        };
        let json = serde_json::to_string(&item).unwrap();
        let restored: CompletionItem = serde_json::from_str(&json).unwrap();
        assert_eq!(restored.label, "println");
        assert_eq!(restored.kind, Some(CompletionKind::Function));
    }

    #[test]
    fn test_hover_result_json_roundtrip() {
        let hover = HoverResult {
            contents: "fn foo() -> i32".into(),
            range: Some(LspRange {
                start: LspPosition {
                    line: 5,
                    character: 4,
                },
                end: LspPosition {
                    line: 5,
                    character: 7,
                },
            }),
        };
        let json = serde_json::to_string(&hover).unwrap();
        let restored: HoverResult = serde_json::from_str(&json).unwrap();
        assert_eq!(restored.contents, "fn foo() -> i32");
        assert!(restored.range.is_some());
    }

    #[test]
    fn test_json_rpc_request_json() {
        let req = JsonRpcRequest {
            jsonrpc: "2.0".into(),
            id: 42,
            method: "textDocument/hover".into(),
            params: serde_json::json!({"textDocument": {"uri": "file:///foo.rs"}}),
        };
        let json = serde_json::to_string(&req).unwrap();
        assert!(json.contains("\"jsonrpc\":\"2.0\""));
        assert!(json.contains("\"id\":42"));
        assert!(json.contains("textDocument/hover"));
    }

    #[test]
    fn test_text_edit_json() {
        let edit = TextEdit {
            range: LspRange {
                start: LspPosition {
                    line: 0,
                    character: 0,
                },
                end: LspPosition {
                    line: 0,
                    character: 5,
                },
            },
            new_text: "hello".into(),
        };
        let json = serde_json::to_string(&edit).unwrap();
        let restored: TextEdit = serde_json::from_str(&json).unwrap();
        assert_eq!(restored.new_text, "hello");
    }
}
