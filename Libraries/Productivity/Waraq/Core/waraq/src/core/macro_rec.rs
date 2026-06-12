// src/core/macro_rec.rs
//
// Keyboard macro engine — record a sequence of key events and replay them.
//
// Supports:
//   • Multiple named registers (@a through @z, plus unnamed @")
//   • Record start/stop with visual indicator
//   • Playback with repeat count (10@q = play macro q ten times)
//   • Nested macro recording prevention (records are flat)
//   • Serialisation for session persistence
//
// Design: a macro is a Vec<MacroOp> — a superset of EditOp that also
// includes motion and selection commands.  On playback, each op is fed
// back through Editor::apply / handle_key.  This keeps playback 100%
// consistent with live editing.

use crate::core::edit::EditOp;
use crate::{KeyInput, MotionKind};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ── Macro operation ────────────────────────────────────────────────────────────

/// A single recorded action.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum MacroOp {
    Edit(MacroEditOp),
    Motion { kind: MacroMotionKind, extend: bool },
    SelectWord,
    SelectLine,
    SelectAll,
    SearchStart { pattern: String, flags: u32 },
    SearchNext,
    SearchPrev,
    ReplaceCurrentMatch { replacement: String },
}

/// Serialisable mirror of EditOp (avoids re-exporting non-Serialize types).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum MacroEditOp {
    Insert {
        at: usize,
        text: String,
    },
    Delete {
        start: usize,
        end: usize,
    },
    Replace {
        start: usize,
        end: usize,
        text: String,
    },
    Undo,
    Redo,
}

impl From<&EditOp> for MacroEditOp {
    fn from(op: &EditOp) -> Self {
        match op {
            EditOp::Insert { at, text } => MacroEditOp::Insert {
                at: at.0,
                text: text.clone(),
            },
            EditOp::Delete { range } => MacroEditOp::Delete {
                start: range.start.0,
                end: range.end.0,
            },
            EditOp::Replace { range, text } => MacroEditOp::Replace {
                start: range.start.0,
                end: range.end.0,
                text: text.clone(),
            },
        }
    }
}

/// Serialisable motion kind.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum MacroMotionKind {
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

impl From<MotionKind> for MacroMotionKind {
    fn from(m: MotionKind) -> Self {
        match m {
            MotionKind::CharLeft => Self::CharLeft,
            MotionKind::CharRight => Self::CharRight,
            MotionKind::WordLeft => Self::WordLeft,
            MotionKind::WordRight => Self::WordRight,
            MotionKind::WordEnd => Self::WordEnd,
            MotionKind::LineStart => Self::LineStart,
            MotionKind::LineFirstNonWs => Self::LineFirstNonWs,
            MotionKind::LineEnd => Self::LineEnd,
            MotionKind::LineUp(n) => Self::LineUp(n),
            MotionKind::LineDown(n) => Self::LineDown(n),
            MotionKind::ParagraphUp => Self::ParagraphUp,
            MotionKind::ParagraphDown => Self::ParagraphDown,
            MotionKind::PageUp(n) => Self::PageUp(n),
            MotionKind::PageDown(n) => Self::PageDown(n),
            MotionKind::MatchingBracket => Self::MatchingBracket,
            MotionKind::DocumentStart => Self::DocumentStart,
            MotionKind::DocumentEnd => Self::DocumentEnd,
        }
    }
}

impl From<&MacroMotionKind> for MotionKind {
    fn from(m: &MacroMotionKind) -> Self {
        match m {
            MacroMotionKind::CharLeft => MotionKind::CharLeft,
            MacroMotionKind::CharRight => MotionKind::CharRight,
            MacroMotionKind::WordLeft => MotionKind::WordLeft,
            MacroMotionKind::WordRight => MotionKind::WordRight,
            MacroMotionKind::WordEnd => MotionKind::WordEnd,
            MacroMotionKind::LineStart => MotionKind::LineStart,
            MacroMotionKind::LineFirstNonWs => MotionKind::LineFirstNonWs,
            MacroMotionKind::LineEnd => MotionKind::LineEnd,
            MacroMotionKind::LineUp(n) => MotionKind::LineUp(*n),
            MacroMotionKind::LineDown(n) => MotionKind::LineDown(*n),
            MacroMotionKind::ParagraphUp => MotionKind::ParagraphUp,
            MacroMotionKind::ParagraphDown => MotionKind::ParagraphDown,
            MacroMotionKind::PageUp(n) => MotionKind::PageUp(*n),
            MacroMotionKind::PageDown(n) => MotionKind::PageDown(*n),
            MacroMotionKind::MatchingBracket => MotionKind::MatchingBracket,
            MacroMotionKind::DocumentStart => MotionKind::DocumentStart,
            MacroMotionKind::DocumentEnd => MotionKind::DocumentEnd,
        }
    }
}

// ── Named macro register ───────────────────────────────────────────────────────

/// A named register (`a`–`z` or `"` for the unnamed register).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MacroRegister {
    pub name: char,
    pub ops: Vec<MacroOp>,
    /// How many times this macro has been played back (stats).
    pub play_count: u32,
}

impl MacroRegister {
    fn new(name: char) -> Self {
        Self {
            name,
            ops: Vec::new(),
            play_count: 0,
        }
    }

    pub fn len(&self) -> usize {
        self.ops.len()
    }
    pub fn is_empty(&self) -> bool {
        self.ops.is_empty()
    }
}

// ── Macro engine ──────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RecordingState {
    Idle,
    Recording(char),
}

pub struct MacroEngine {
    registers: HashMap<char, MacroRegister>,
    pub state: RecordingState,
    /// Buffer for the currently-recording macro.
    current_ops: Vec<MacroOp>,
    current_register: char,
    /// Prevent infinite recursion when a macro calls another macro.
    playback_depth: usize,
    pub max_playback_depth: usize,
}

impl MacroEngine {
    pub fn new() -> Self {
        Self {
            registers: HashMap::new(),
            state: RecordingState::Idle,
            current_ops: Vec::new(),
            current_register: '"',
            playback_depth: 0,
            max_playback_depth: 8,
        }
    }

    // ── Recording ─────────────────────────────────────────────────────────────

    /// Start recording into register `name`.
    /// Returns Err if already recording.
    pub fn start_recording(&mut self, name: char) -> Result<(), &'static str> {
        if self.state != RecordingState::Idle {
            return Err("already recording");
        }
        self.state = RecordingState::Recording(name);
        self.current_register = name;
        self.current_ops.clear();
        Ok(())
    }

    /// Stop recording. Saves the macro to the register.
    /// Returns the number of ops recorded, or Err if not recording.
    pub fn stop_recording(&mut self) -> Result<usize, &'static str> {
        if self.state == RecordingState::Idle {
            return Err("not recording");
        }
        let count = self.current_ops.len();
        let name = self.current_register;
        let reg = MacroRegister {
            name,
            ops: self.current_ops.drain(..).collect(),
            play_count: 0,
        };
        self.registers.insert(name, reg);
        self.state = RecordingState::Idle;
        Ok(count)
    }

    pub fn is_recording(&self) -> bool {
        self.state != RecordingState::Idle
    }

    pub fn recording_register(&self) -> Option<char> {
        match self.state {
            RecordingState::Recording(c) => Some(c),
            _ => None,
        }
    }

    // ── Op recording ──────────────────────────────────────────────────────────

    /// Record an edit op during an active recording session.
    pub fn record_edit(&mut self, op: &EditOp) {
        if !self.is_recording() {
            return;
        }
        self.current_ops.push(MacroOp::Edit(MacroEditOp::from(op)));
    }

    /// Record a motion during recording.
    pub fn record_motion(&mut self, kind: MotionKind, extend: bool) {
        if !self.is_recording() {
            return;
        }
        self.current_ops.push(MacroOp::Motion {
            kind: MacroMotionKind::from(kind),
            extend,
        });
    }

    /// Record a search during recording.
    pub fn record_search(&mut self, pattern: &str, flags: u32) {
        if !self.is_recording() {
            return;
        }
        self.current_ops.push(MacroOp::SearchStart {
            pattern: pattern.to_owned(),
            flags,
        });
    }

    /// Record a selection op.
    pub fn record_select_word(&mut self) {
        if !self.is_recording() {
            return;
        }
        self.current_ops.push(MacroOp::SelectWord);
    }

    pub fn record_select_line(&mut self) {
        if !self.is_recording() {
            return;
        }
        self.current_ops.push(MacroOp::SelectLine);
    }

    // ── Playback ──────────────────────────────────────────────────────────────

    /// Get the ops for register `name` to play back.
    /// Returns None if register is empty or doesn't exist.
    pub fn playback_ops(&mut self, name: char) -> Option<Vec<MacroOp>> {
        if self.playback_depth >= self.max_playback_depth {
            return None;
        }
        let reg = self.registers.get_mut(&name)?;
        if reg.is_empty() {
            return None;
        }
        reg.play_count += 1;
        Some(reg.ops.clone())
    }

    pub fn enter_playback(&mut self) {
        self.playback_depth += 1;
    }
    pub fn exit_playback(&mut self) {
        self.playback_depth = self.playback_depth.saturating_sub(1);
    }

    // ── Register management ───────────────────────────────────────────────────

    pub fn register(&self, name: char) -> Option<&MacroRegister> {
        self.registers.get(&name)
    }

    pub fn all_registers(&self) -> Vec<&MacroRegister> {
        let mut regs: Vec<_> = self.registers.values().collect();
        regs.sort_by_key(|r| r.name);
        regs
    }

    /// Set a register programmatically (e.g. from session restore).
    pub fn set_register(&mut self, name: char, ops: Vec<MacroOp>) {
        let mut reg = MacroRegister::new(name);
        reg.ops = ops;
        self.registers.insert(name, reg);
    }

    pub fn clear_register(&mut self, name: char) {
        self.registers.remove(&name);
    }

    pub fn clear_all(&mut self) {
        self.registers.clear();
        self.current_ops.clear();
        self.state = RecordingState::Idle;
    }

    // ── Serialisation ─────────────────────────────────────────────────────────

    pub fn to_json(&self) -> String {
        let regs: Vec<_> = self.all_registers().into_iter().cloned().collect();
        serde_json::to_string(&regs).unwrap_or_default()
    }

    pub fn from_json(&mut self, json: &str) -> anyhow::Result<()> {
        let regs: Vec<MacroRegister> = serde_json::from_str(json)?;
        for reg in regs {
            self.registers.insert(reg.name, reg);
        }
        Ok(())
    }
}

impl Default for MacroEngine {
    fn default() -> Self {
        Self::new()
    }
}

// ── MacroOp → KeyInput / EditOp conversion ────────────────────────────────────

impl MacroOp {
    /// Convert a `MacroOp` back to the types the Editor understands.
    pub fn to_edit_op(&self) -> Option<EditOp> {
        match self {
            MacroOp::Edit(e) => Some(e.to_edit_op()),
            _ => None,
        }
    }

    pub fn to_key_input(&self) -> Option<KeyInput> {
        match self {
            MacroOp::Motion { kind, extend } => {
                let mk = MotionKind::from(kind);
                Some(if *extend {
                    KeyInput::Select(mk)
                } else {
                    KeyInput::Motion(mk)
                })
            }
            MacroOp::Edit(_) => None, // handled via to_edit_op
            _ => None,
        }
    }
}

impl MacroEditOp {
    pub fn to_edit_op(&self) -> EditOp {
        match self {
            MacroEditOp::Insert { at, text } => EditOp::insert(*at, text),
            MacroEditOp::Delete { start, end } => EditOp::delete(*start, *end),
            MacroEditOp::Replace { start, end, text } => EditOp::replace(*start, *end, text),
            MacroEditOp::Undo => EditOp::insert(0, ""), // handled specially
            MacroEditOp::Redo => EditOp::insert(0, ""), // handled specially
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::edit::EditOp;

    fn engine() -> MacroEngine {
        MacroEngine::new()
    }

    #[test]
    fn test_start_stop_recording() {
        let mut eng = engine();
        assert!(eng.start_recording('q').is_ok());
        assert!(eng.is_recording());
        assert_eq!(eng.recording_register(), Some('q'));
        assert!(eng.start_recording('w').is_err()); // can't start while recording
        let count = eng.stop_recording().unwrap();
        assert_eq!(count, 0); // no ops recorded
        assert!(!eng.is_recording());
    }

    #[test]
    fn test_record_edit_ops() {
        let mut eng = engine();
        eng.start_recording('q').unwrap();
        eng.record_edit(&EditOp::insert(0, "hello"));
        eng.record_edit(&EditOp::insert(5, " world"));
        let count = eng.stop_recording().unwrap();
        assert_eq!(count, 2);
        assert_eq!(eng.register('q').unwrap().len(), 2);
    }

    #[test]
    fn test_record_motion() {
        let mut eng = engine();
        eng.start_recording('a').unwrap();
        eng.record_motion(MotionKind::WordRight, false);
        eng.record_motion(MotionKind::LineEnd, false);
        let count = eng.stop_recording().unwrap();
        assert_eq!(count, 2);
    }

    #[test]
    fn test_playback_returns_ops() {
        let mut eng = engine();
        eng.start_recording('q').unwrap();
        eng.record_edit(&EditOp::insert(0, "x"));
        eng.stop_recording().unwrap();

        let ops = eng.playback_ops('q').unwrap();
        assert_eq!(ops.len(), 1);
        assert_eq!(eng.register('q').unwrap().play_count, 1);
    }

    #[test]
    fn test_playback_nonexistent_register() {
        let mut eng = engine();
        assert!(eng.playback_ops('z').is_none());
    }

    #[test]
    fn test_playback_depth_limit() {
        let mut eng = engine();
        eng.start_recording('q').unwrap();
        eng.record_edit(&EditOp::insert(0, "x"));
        eng.stop_recording().unwrap();

        // Exceed depth limit
        for _ in 0..eng.max_playback_depth {
            eng.enter_playback();
        }
        assert!(eng.playback_ops('q').is_none()); // depth exceeded
    }

    #[test]
    fn test_set_register_programmatically() {
        let mut eng = engine();
        eng.set_register(
            'x',
            vec![MacroOp::Edit(MacroEditOp::Insert {
                at: 0,
                text: "hello".into(),
            })],
        );
        assert_eq!(eng.register('x').unwrap().len(), 1);
    }

    #[test]
    fn test_clear_register() {
        let mut eng = engine();
        eng.start_recording('q').unwrap();
        eng.record_edit(&EditOp::insert(0, "x"));
        eng.stop_recording().unwrap();
        eng.clear_register('q');
        assert!(eng.register('q').is_none());
    }

    #[test]
    fn test_all_registers_sorted() {
        let mut eng = engine();
        for c in ['z', 'a', 'm'] {
            eng.start_recording(c).unwrap();
            eng.stop_recording().unwrap();
        }
        let names: Vec<char> = eng.all_registers().iter().map(|r| r.name).collect();
        assert_eq!(names, vec!['a', 'm', 'z']);
    }

    #[test]
    fn test_json_roundtrip() {
        let mut eng = engine();
        eng.start_recording('q').unwrap();
        eng.record_edit(&EditOp::insert(0, "hello world"));
        eng.record_motion(MotionKind::WordRight, false);
        eng.stop_recording().unwrap();

        let json = eng.to_json();
        let mut eng2 = engine();
        eng2.from_json(&json).unwrap();
        assert_eq!(eng2.register('q').unwrap().len(), 2);
    }

    #[test]
    fn test_macro_op_to_edit_op() {
        let op = MacroOp::Edit(MacroEditOp::Insert {
            at: 5,
            text: "abc".into(),
        });
        let edit_op = op.to_edit_op().unwrap();
        match edit_op {
            EditOp::Insert { at, text } => {
                assert_eq!(at.0, 5);
                assert_eq!(text, "abc");
            }
            _ => panic!(),
        }
    }

    #[test]
    fn test_stop_when_not_recording_is_err() {
        let mut eng = engine();
        assert!(eng.stop_recording().is_err());
    }
}
