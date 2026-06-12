// src/lsp/mod.rs

pub mod client;
pub mod protocol;
pub mod transport;

pub use client::LspClient;
pub use protocol::{
    CompletionItem, CompletionKind, Diagnostic, DiagnosticSeverity, HoverResult, Location, TextEdit,
};

use crate::DiagnosticInfo;

/// Aggregated LSP state held inside the Editor.
pub struct LspState {
    pub diagnostics: Vec<Diagnostic>,
    pub completions_cache: Vec<CompletionItem>,
    /// Version counter — incremented on every didChange notification.
    pub version: i32,
}

impl LspState {
    pub fn new() -> Self {
        Self {
            diagnostics: vec![],
            completions_cache: vec![],
            version: 0,
        }
    }

    pub fn update_diagnostics(&mut self, diagnostics: Vec<Diagnostic>) {
        self.diagnostics = diagnostics;
    }

    pub fn diagnostics(&self) -> &[Diagnostic] {
        &self.diagnostics
    }

    pub fn diagnostics_at_line(&self, line: usize) -> Vec<&Diagnostic> {
        self.diagnostics
            .iter()
            .filter(|d| d.range.start.line as usize == line)
            .collect()
    }

    pub fn diagnostics_in_viewport(
        &self,
        first_line: usize,
        last_line: usize,
    ) -> Vec<DiagnosticInfo> {
        self.diagnostics
            .iter()
            .filter(|d| {
                let l = d.range.start.line as usize;
                l >= first_line && l <= last_line
            })
            .map(|d| DiagnosticInfo {
                line: d.range.start.line as usize,
                col: d.range.start.character as usize,
                end_line: d.range.end.line as usize,
                end_col: d.range.end.character as usize,
                severity: d.severity as u8,
                message: d.message.clone(),
            })
            .collect()
    }

    pub fn error_count(&self) -> usize {
        self.diagnostics
            .iter()
            .filter(|d| d.severity == DiagnosticSeverity::Error)
            .count()
    }

    pub fn warning_count(&self) -> usize {
        self.diagnostics
            .iter()
            .filter(|d| d.severity == DiagnosticSeverity::Warning)
            .count()
    }

    pub fn next_version(&mut self) -> i32 {
        self.version += 1;
        self.version
    }
}

impl Default for LspState {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::lsp::protocol::{Diagnostic, DiagnosticSeverity, LspPosition, LspRange};

    #[test]
    fn test_lsp_state_update_diagnostics() {
        let mut state = LspState::new();
        state.update_diagnostics(vec![
            Diagnostic {
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
                code: None,
            },
            Diagnostic {
                range: LspRange {
                    start: LspPosition {
                        line: 2,
                        character: 0,
                    },
                    end: LspPosition {
                        line: 2,
                        character: 3,
                    },
                },
                severity: DiagnosticSeverity::Warning,
                message: "unused variable".into(),
                source: None,
                code: None,
            },
        ]);
        assert_eq!(state.error_count(), 1);
        assert_eq!(state.warning_count(), 1);
        assert_eq!(state.diagnostics().len(), 2);
    }

    #[test]
    fn test_lsp_state_diagnostics_in_viewport() {
        let mut state = LspState::new();
        state.update_diagnostics(vec![
            Diagnostic {
                range: LspRange {
                    start: LspPosition {
                        line: 5,
                        character: 0,
                    },
                    end: LspPosition {
                        line: 5,
                        character: 10,
                    },
                },
                severity: DiagnosticSeverity::Error,
                message: "error on line 5".into(),
                source: None,
                code: None,
            },
            Diagnostic {
                range: LspRange {
                    start: LspPosition {
                        line: 50,
                        character: 0,
                    },
                    end: LspPosition {
                        line: 50,
                        character: 10,
                    },
                },
                severity: DiagnosticSeverity::Warning,
                message: "warning on line 50".into(),
                source: None,
                code: None,
            },
        ]);
        let in_vp = state.diagnostics_in_viewport(0, 10);
        assert_eq!(in_vp.len(), 1);
        assert_eq!(in_vp[0].message, "error on line 5");
    }

    #[test]
    fn test_lsp_state_clear_diagnostics() {
        let mut state = LspState::new();
        state.update_diagnostics(vec![Diagnostic {
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
            severity: DiagnosticSeverity::Error,
            message: "err".into(),
            source: None,
            code: None,
        }]);
        assert_eq!(state.error_count(), 1);
        state.update_diagnostics(vec![]); // clear
        assert_eq!(state.error_count(), 0);
    }

    #[test]
    fn test_lsp_state_empty() {
        let state = LspState::new();
        assert_eq!(state.error_count(), 0);
        assert_eq!(state.warning_count(), 0);
        assert!(state.diagnostics().is_empty());
    }

    #[test]
    fn test_version_counter() {
        let mut state = LspState::new();
        let v1 = state.next_version();
        let v2 = state.next_version();
        assert!(v2 > v1);
    }
}
