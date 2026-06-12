// src/core/decoration.rs
//
// Decoration engine — inline visual markers in the editor gutter and text.
//
// Mirrors Monaco's `editor.deltaDecorations` API:
//   const ids = editor.deltaDecorations([], [
//     { range: new monaco.Range(1,1,1,1), options: { isWholeLine: true,
//       className: 'myContentClass', glyphMarginClassName: 'myGlyphClass' }},
//   ]);
//   editor.deltaDecorations(ids, []); // remove
//
// Decorations are used by extensions and the core editor for:
//   • Diagnostic squiggles (error/warning/info)
//   • Breakpoints and debug cursor (glyph margin)
//   • Find-match highlights
//   • Test pass/fail indicators
//   • Git blame / diff markers (added/modified/deleted lines)
//   • Current-word highlights (DocumentHighlight provider)
//   • Custom extension-provided highlights
//
// Design:
//   • Each decoration has a unique `DecorationId` (u64 counter)
//   • Stored in a flat Vec; queried by range intersection
//   • `delta(remove_ids, add_specs)` is the single mutation API — matches Monaco
//   • After buffer edits, decorations are adjusted via `adjust_for_change`

use crate::core::buffer::Buffer;
use crate::core::types::{ByteOffset, Range};
use serde::{Deserialize, Serialize};

// ── Decoration ID ─────────────────────────────────────────────────────────────

pub type DecorationId = u64;

// ── Styling options ────────────────────────────────────────────────────────────

/// How thick an underline should be.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum UnderlineStyle {
    None,
    Solid,
    Dotted,
    Dashed,
    Wavy,
}

/// Overridden character (full-line) decoration styling.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DecorationStyle {
    /// CSS class name or theme token for text background.
    pub background_color: Option<String>,
    /// Foreground color override.
    pub foreground_color: Option<String>,
    /// Underline style for squiggly error/warning lines.
    pub underline: UnderlineStyle,
    pub underline_color: Option<String>,
    /// Bold / italic for the decorated range.
    pub bold: bool,
    pub italic: bool,
    /// Draw a box around the range (e.g. matching brackets).
    pub outline: bool,
    pub outline_color: Option<String>,
}

impl DecorationStyle {
    pub fn squiggly_error() -> Self {
        Self {
            background_color: None,
            foreground_color: None,
            underline: UnderlineStyle::Wavy,
            underline_color: Some("var(--error)".into()),
            bold: false,
            italic: false,
            outline: false,
            outline_color: None,
        }
    }
    pub fn squiggly_warning() -> Self {
        Self {
            underline_color: Some("var(--warning)".into()),
            ..Self::squiggly_error()
        }
    }
    pub fn squiggly_info() -> Self {
        Self {
            underline_color: Some("var(--info)".into()),
            ..Self::squiggly_error()
        }
    }
    pub fn highlight(color: &str) -> Self {
        Self {
            background_color: Some(color.to_owned()),
            foreground_color: None,
            underline: UnderlineStyle::None,
            underline_color: None,
            bold: false,
            italic: false,
            outline: false,
            outline_color: None,
        }
    }
    pub fn bracket_match() -> Self {
        Self {
            outline: true,
            outline_color: Some("var(--bracket-match)".into()),
            background_color: Some("var(--bracket-match-bg)".into()),
            underline: UnderlineStyle::None,
            ..Default::default()
        }
    }
}

impl Default for DecorationStyle {
    fn default() -> Self {
        Self {
            background_color: None,
            foreground_color: None,
            underline: UnderlineStyle::None,
            underline_color: None,
            bold: false,
            italic: false,
            outline: false,
            outline_color: None,
        }
    }
}

// ── Glyph margin icon ─────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GlyphMarginDecoration {
    /// Icon identifier: "circle-filled", "debug-breakpoint", "testing-passed", etc.
    pub icon: String,
    pub tooltip: Option<String>,
    pub color: Option<String>,
}

// ── Overview ruler ────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum OverviewRulerLane {
    Left,
    Center,
    Right,
    Full,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OverviewRulerDecoration {
    pub color: String,
    pub lane: OverviewRulerLane,
}

// ── Decoration options ────────────────────────────────────────────────────────

/// Full specification for one decoration. Equivalent to Monaco's
/// `IModelDecorationOptions`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DecorationOptions {
    /// Apply this style to the entire line (ignores range column).
    pub is_whole_line: bool,
    /// Inline text style.
    pub inline_style: Option<DecorationStyle>,
    /// Gutter line number style.
    pub line_number_style: Option<DecorationStyle>,
    /// Glyph in the left margin (breakpoints, test results, etc.).
    pub glyph_margin: Option<GlyphMarginDecoration>,
    /// Mark in the overview ruler (minimap-style scrollbar).
    pub overview_ruler: Option<OverviewRulerDecoration>,
    /// Inline text appended after the line (e.g. git blame, parameter hints).
    pub after_content_text: Option<String>,
    pub after_content_color: Option<String>,
    /// Inline text prepended before the content.
    pub before_content_text: Option<String>,
    pub before_content_color: Option<String>,
    /// Hover message shown in tooltip.
    pub hover_message: Option<String>,
    /// Stacking order — higher z-index decorations render on top.
    pub z_index: i32,
    /// Decoration kind for grouping and filtering.
    pub kind: DecorationKind,
}

impl DecorationOptions {
    pub fn error_squiggle() -> Self {
        Self {
            inline_style: Some(DecorationStyle::squiggly_error()),
            kind: DecorationKind::Diagnostic,
            ..Self::default()
        }
    }
    pub fn warning_squiggle() -> Self {
        Self {
            inline_style: Some(DecorationStyle::squiggly_warning()),
            kind: DecorationKind::Diagnostic,
            ..Self::default()
        }
    }
    pub fn info_squiggle() -> Self {
        Self {
            inline_style: Some(DecorationStyle::squiggly_info()),
            kind: DecorationKind::Diagnostic,
            ..Self::default()
        }
    }
    pub fn current_word_highlight() -> Self {
        Self {
            inline_style: Some(DecorationStyle::highlight("var(--word-highlight)")),
            kind: DecorationKind::Highlight,
            ..Self::default()
        }
    }
    pub fn selection_highlight() -> Self {
        Self {
            inline_style: Some(DecorationStyle::highlight("var(--selection-highlight)")),
            kind: DecorationKind::Highlight,
            ..Self::default()
        }
    }
    pub fn git_added_line() -> Self {
        Self {
            is_whole_line: true,
            inline_style: Some(DecorationStyle::highlight("var(--git-added)")),
            overview_ruler: Some(OverviewRulerDecoration {
                color: "#4CAF50".into(),
                lane: OverviewRulerLane::Left,
            }),
            kind: DecorationKind::Diff,
            ..Self::default()
        }
    }
    pub fn git_modified_line() -> Self {
        Self {
            is_whole_line: true,
            inline_style: Some(DecorationStyle::highlight("var(--git-modified)")),
            overview_ruler: Some(OverviewRulerDecoration {
                color: "#2196F3".into(),
                lane: OverviewRulerLane::Left,
            }),
            kind: DecorationKind::Diff,
            ..Self::default()
        }
    }
    pub fn breakpoint() -> Self {
        Self {
            glyph_margin: Some(GlyphMarginDecoration {
                icon: "debug-breakpoint".into(),
                tooltip: Some("Breakpoint".into()),
                color: Some("#E51400".into()),
            }),
            kind: DecorationKind::Breakpoint,
            ..Self::default()
        }
    }
    pub fn test_pass() -> Self {
        Self {
            glyph_margin: Some(GlyphMarginDecoration {
                icon: "testing-passed-icon".into(),
                tooltip: Some("Test passed".into()),
                color: Some("#4CAF50".into()),
            }),
            kind: DecorationKind::TestResult,
            ..Self::default()
        }
    }
    pub fn test_fail() -> Self {
        Self {
            glyph_margin: Some(GlyphMarginDecoration {
                icon: "testing-failed-icon".into(),
                tooltip: Some("Test failed".into()),
                color: Some("#E51400".into()),
            }),
            kind: DecorationKind::TestResult,
            ..Self::default()
        }
    }
}

impl Default for DecorationOptions {
    fn default() -> Self {
        Self {
            is_whole_line: false,
            inline_style: None,
            line_number_style: None,
            glyph_margin: None,
            overview_ruler: None,
            after_content_text: None,
            after_content_color: None,
            before_content_text: None,
            before_content_color: None,
            hover_message: None,
            z_index: 0,
            kind: DecorationKind::Custom,
        }
    }
}

// ── Decoration kind ───────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum DecorationKind {
    Diagnostic,  // error/warning/info squiggles
    Highlight,   // current word / selection occurrences
    SearchMatch, // find matches (also in RenderFrame)
    Diff,        // git added/modified/deleted
    Breakpoint,  // debug breakpoints
    TestResult,  // test pass/fail indicators
    InlayHint,   // type/parameter annotations
    Custom,      // extension-provided
}

// ── Decoration entry ──────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Decoration {
    pub id: DecorationId,
    /// Byte range this decoration covers.
    pub range: Range,
    pub options: DecorationOptions,
    /// Which extension/owner set this decoration.
    pub owner: String,
}

impl Decoration {
    pub fn start_line_for_buffer(&self, buf: &Buffer) -> usize {
        buf.offset_to_line_col(self.range.start).line
    }
}

// ── Decoration specification (input to delta) ─────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DecorationSpec {
    pub range: Range,
    pub options: DecorationOptions,
}

// ── Decoration set ────────────────────────────────────────────────────────────

pub struct DecorationSet {
    decorations: Vec<Decoration>,
    next_id: DecorationId,
}

impl DecorationSet {
    pub fn new() -> Self {
        Self {
            decorations: Vec::new(),
            next_id: 1,
        }
    }

    // ── Monaco-compatible deltaDecorations ────────────────────────────────────

    /// Apply a delta: remove the listed IDs, add the new specs.
    /// Returns the IDs of the newly added decorations.
    pub fn delta(
        &mut self,
        remove_ids: &[DecorationId],
        add_specs: &[(DecorationSpec, String)], // (spec, owner)
    ) -> Vec<DecorationId> {
        // Remove
        self.decorations.retain(|d| !remove_ids.contains(&d.id));

        // Add
        let mut new_ids = Vec::new();
        for (spec, owner) in add_specs {
            let id = self.next_id;
            self.next_id += 1;
            self.decorations.push(Decoration {
                id,
                range: spec.range,
                options: spec.options.clone(),
                owner: owner.clone(),
            });
            new_ids.push(id);
        }
        new_ids
    }

    /// Remove all decorations owned by `owner`.
    pub fn remove_by_owner(&mut self, owner: &str) {
        self.decorations.retain(|d| d.owner != owner);
    }

    /// Remove decorations of a specific kind.
    pub fn remove_by_kind(&mut self, kind: DecorationKind) {
        self.decorations.retain(|d| d.options.kind != kind);
    }

    /// Remove a single decoration by ID.
    pub fn remove(&mut self, id: DecorationId) {
        self.decorations.retain(|d| d.id != id);
    }

    // ── Query ─────────────────────────────────────────────────────────────────

    pub fn all(&self) -> &[Decoration] {
        &self.decorations
    }

    /// Get decorations that overlap with the given line range.
    pub fn for_viewport(
        &self,
        buf: &Buffer,
        first_line: usize,
        last_line: usize,
    ) -> Vec<&Decoration> {
        self.decorations
            .iter()
            .filter(|d| {
                let start_line = buf.offset_to_line_col(d.range.start).line;
                let end_line = buf.offset_to_line_col(d.range.end).line;
                start_line <= last_line && end_line >= first_line
            })
            .collect()
    }

    /// Get decorations at a specific byte offset (for hover tooltip).
    pub fn at_offset(&self, offset: ByteOffset) -> Vec<&Decoration> {
        self.decorations
            .iter()
            .filter(|d| d.range.start.0 <= offset.0 && d.range.end.0 >= offset.0)
            .collect()
    }

    /// Get decorations with glyph margin on a specific line.
    pub fn glyph_margin_for_line(&self, buf: &Buffer, line: usize) -> Vec<&Decoration> {
        self.decorations
            .iter()
            .filter(|d| {
                d.options.glyph_margin.is_some()
                    && buf.offset_to_line_col(d.range.start).line == line
            })
            .collect()
    }

    /// Get overview ruler positions for the scrollbar minimap.
    pub fn overview_ruler_items(&self, buf: &Buffer, total_lines: usize) -> Vec<OverviewRulerItem> {
        self.decorations
            .iter()
            .filter_map(|d| {
                let ruler = d.options.overview_ruler.as_ref()?;
                let line = buf.offset_to_line_col(d.range.start).line;
                Some(OverviewRulerItem {
                    line,
                    position: if total_lines > 0 {
                        line * 100 / total_lines
                    } else {
                        0
                    },
                    color: ruler.color.clone(),
                    lane: ruler.lane,
                })
            })
            .collect()
    }

    pub fn len(&self) -> usize {
        self.decorations.len()
    }
    pub fn is_empty(&self) -> bool {
        self.decorations.is_empty()
    }

    // ── Adjustment after buffer edits ─────────────────────────────────────────

    /// Shift decoration ranges after an edit at `edit_start` with a byte delta.
    /// Decorations that overlap the edit are removed; others are shifted.
    pub fn adjust_for_edit(&mut self, edit_start: usize, edit_end: usize, delta: i64) {
        let mut to_remove = Vec::new();
        for dec in &mut self.decorations {
            let s = dec.range.start.0;
            let e = dec.range.end.0;

            if s > edit_end {
                // Entirely after the edit — shift both endpoints
                dec.range = Range::new(
                    (s as i64 + delta).max(0) as usize,
                    (e as i64 + delta).max(0) as usize,
                );
            } else if e < edit_start {
                // Entirely before — no change
            } else {
                // Overlaps the edit — remove unless it is a whole-line decoration
                if !dec.options.is_whole_line {
                    to_remove.push(dec.id);
                }
            }
        }
        self.decorations.retain(|d| !to_remove.contains(&d.id));
    }
}

impl Default for DecorationSet {
    fn default() -> Self {
        Self::new()
    }
}

// ── Overview ruler item ───────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OverviewRulerItem {
    pub line: usize,
    /// 0-100 position in the scrollbar.
    pub position: usize,
    pub color: String,
    pub lane: OverviewRulerLane,
}

// ── Serialisable snapshot for the RenderFrame ──────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DecorationRenderInfo {
    pub id: DecorationId,
    pub start_byte: usize,
    pub end_byte: usize,
    pub start_line: usize,
    pub start_col: usize,
    pub end_line: usize,
    pub end_col: usize,
    pub is_whole_line: bool,
    pub kind: DecorationKind,
    /// Inline style (background, underline, etc.).
    pub style: Option<DecorationStyle>,
    pub glyph_icon: Option<String>,
    pub hover_message: Option<String>,
    pub after_text: Option<String>,
    pub before_text: Option<String>,
}

impl DecorationRenderInfo {
    pub fn from_decoration(dec: &Decoration, buf: &Buffer) -> Self {
        let start_lc = buf.offset_to_line_col(dec.range.start);
        let end_lc = buf.offset_to_line_col(dec.range.end);
        Self {
            id: dec.id,
            start_byte: dec.range.start.0,
            end_byte: dec.range.end.0,
            start_line: start_lc.line,
            start_col: start_lc.col,
            end_line: end_lc.line,
            end_col: end_lc.col,
            is_whole_line: dec.options.is_whole_line,
            kind: dec.options.kind,
            style: dec.options.inline_style.clone(),
            glyph_icon: dec.options.glyph_margin.as_ref().map(|g| g.icon.clone()),
            hover_message: dec.options.hover_message.clone(),
            after_text: dec.options.after_content_text.clone(),
            before_text: dec.options.before_content_text.clone(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;
    use crate::core::types::Range;

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }

    fn spec(start: usize, end: usize) -> DecorationSpec {
        DecorationSpec {
            range: Range::new(start, end),
            options: DecorationOptions::default(),
        }
    }

    #[test]
    fn test_delta_add() {
        let mut ds = DecorationSet::new();
        let ids = ds.delta(
            &[],
            &[(spec(0, 5), "owner".into()), (spec(10, 15), "owner".into())],
        );
        assert_eq!(ids.len(), 2);
        assert_eq!(ds.len(), 2);
    }

    #[test]
    fn test_delta_remove() {
        let mut ds = DecorationSet::new();
        let ids = ds.delta(&[], &[(spec(0, 5), "owner".into())]);
        ds.delta(&ids, &[]);
        assert_eq!(ds.len(), 0);
    }

    #[test]
    fn test_delta_replace() {
        let mut ds = DecorationSet::new();
        let ids = ds.delta(&[], &[(spec(0, 5), "owner".into())]);
        let new_ids = ds.delta(&ids, &[(spec(6, 10), "owner".into())]);
        assert_eq!(ds.len(), 1);
        assert_ne!(new_ids[0], ids[0]);
    }

    #[test]
    fn test_remove_by_owner() {
        let mut ds = DecorationSet::new();
        ds.delta(
            &[],
            &[(spec(0, 5), "ext1".into()), (spec(10, 15), "ext2".into())],
        );
        ds.remove_by_owner("ext1");
        assert_eq!(ds.len(), 1);
        assert_eq!(ds.all()[0].owner, "ext2");
    }

    #[test]
    fn test_remove_by_kind() {
        let mut ds = DecorationSet::new();
        let s1 = DecorationSpec {
            range: Range::new(0, 5),
            options: DecorationOptions::error_squiggle(),
        };
        let s2 = DecorationSpec {
            range: Range::new(10, 15),
            options: DecorationOptions::breakpoint(),
        };
        ds.delta(&[], &[(s1, "diag".into()), (s2, "debug".into())]);
        ds.remove_by_kind(DecorationKind::Diagnostic);
        assert_eq!(ds.len(), 1);
        assert_eq!(ds.all()[0].options.kind, DecorationKind::Breakpoint);
    }

    #[test]
    fn test_for_viewport() {
        let b = buf("hello\nworld\nfoo\n");
        let mut ds = DecorationSet::new();
        // Decoration on line 0 (bytes 0-5)
        ds.delta(&[], &[(spec(0, 5), "owner".into())]);
        // Decoration on line 2 (bytes 12-15)
        ds.delta(&[], &[(spec(12, 15), "owner".into())]);
        // Only viewport lines 0-1
        let in_vp = ds.for_viewport(&b, 0, 1);
        assert_eq!(in_vp.len(), 1);
    }

    #[test]
    fn test_at_offset() {
        let _b = buf("hello world");
        let mut ds = DecorationSet::new();
        ds.delta(&[], &[(spec(0, 5), "owner".into())]);
        ds.delta(&[], &[(spec(6, 11), "owner".into())]);
        let at_3 = ds.at_offset(ByteOffset(3));
        assert_eq!(at_3.len(), 1);
        let at_8 = ds.at_offset(ByteOffset(8));
        assert_eq!(at_8.len(), 1);
    }

    #[test]
    fn test_adjust_for_edit_shift() {
        let mut ds = DecorationSet::new();
        // Decoration after the edit point
        ds.delta(&[], &[(spec(10, 15), "owner".into())]);
        // Insert 5 bytes at position 0
        ds.adjust_for_edit(0, 0, 5);
        assert_eq!(ds.all()[0].range.start.0, 15);
        assert_eq!(ds.all()[0].range.end.0, 20);
    }

    #[test]
    fn test_adjust_for_edit_before_unchanged() {
        let mut ds = DecorationSet::new();
        // Decoration before the edit point — unchanged
        ds.delta(&[], &[(spec(0, 5), "owner".into())]);
        ds.adjust_for_edit(10, 15, -5);
        assert_eq!(ds.all()[0].range.start.0, 0);
    }

    #[test]
    fn test_adjust_for_edit_overlap_removes() {
        let mut ds = DecorationSet::new();
        // Decoration overlaps the edit
        ds.delta(&[], &[(spec(5, 15), "owner".into())]);
        ds.adjust_for_edit(8, 12, -4);
        assert_eq!(ds.len(), 0, "Overlapping decoration should be removed");
    }

    #[test]
    fn test_overview_ruler_items() {
        let b = buf("line0\nline1\nline2\nline3\nline4\n");
        let mut ds = DecorationSet::new();
        let mut opts = DecorationOptions::default();
        opts.overview_ruler = Some(OverviewRulerDecoration {
            color: "#FF0000".into(),
            lane: OverviewRulerLane::Left,
        });
        ds.delta(
            &[],
            &[(
                DecorationSpec {
                    range: Range::new(6, 11),
                    options: opts,
                },
                "o".into(),
            )],
        );
        let items = ds.overview_ruler_items(&b, 5);
        assert_eq!(items.len(), 1);
        assert_eq!(items[0].color, "#FF0000");
    }

    #[test]
    fn test_preset_decoration_styles() {
        let err = DecorationOptions::error_squiggle();
        assert_eq!(err.kind, DecorationKind::Diagnostic);
        let hl = DecorationOptions::current_word_highlight();
        assert_eq!(hl.kind, DecorationKind::Highlight);
        let bp = DecorationOptions::breakpoint();
        assert!(bp.glyph_margin.is_some());
        let git = DecorationOptions::git_added_line();
        assert!(git.is_whole_line);
        assert!(git.overview_ruler.is_some());
    }

    #[test]
    fn test_decoration_render_info() {
        let b = buf("hello\nworld\n");
        let mut ds = DecorationSet::new();
        ds.delta(&[], &[(spec(6, 11), "owner".into())]);
        let info = DecorationRenderInfo::from_decoration(&ds.all()[0], &b);
        assert_eq!(info.start_line, 1);
        assert_eq!(info.start_col, 0);
        assert_eq!(info.end_line, 1);
    }
}
