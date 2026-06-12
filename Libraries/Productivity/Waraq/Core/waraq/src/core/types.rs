// src/core/types.rs
//
// Fundamental coordinate types used throughout the engine.
// Kept separate so FFI layer can derive C representations.

use serde::{Deserialize, Serialize};

/// Absolute byte offset within the buffer.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub struct ByteOffset(pub usize);

/// Zero-based (line, column) coordinate.
/// Column is measured in Unicode scalar values (not bytes, not grapheme clusters).
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub struct LineCol {
    pub line: usize,
    pub col: usize,
}

impl LineCol {
    #[inline]
    pub fn new(line: usize, col: usize) -> Self {
        Self { line, col }
    }
    pub const ORIGIN: Self = Self { line: 0, col: 0 };
}

/// Display position — what the renderer sees.
/// Column here is in grapheme clusters (visual width).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct Position {
    pub line: usize,
    pub col: usize,
}

impl From<LineCol> for Position {
    fn from(lc: LineCol) -> Self {
        Position {
            line: lc.line,
            col: lc.col,
        }
    }
}

/// A half-open byte range [start, end).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct Range {
    pub start: ByteOffset,
    pub end: ByteOffset,
}

impl Range {
    pub fn new(start: usize, end: usize) -> Self {
        Self {
            start: ByteOffset(start),
            end: ByteOffset(end),
        }
    }

    pub fn is_empty(&self) -> bool {
        self.start == self.end
    }

    pub fn len(&self) -> usize {
        self.end.0.saturating_sub(self.start.0)
    }

    pub fn contains(&self, offset: ByteOffset) -> bool {
        offset >= self.start && offset < self.end
    }

    pub fn overlaps(&self, other: Range) -> bool {
        self.start < other.end && other.start < self.end
    }

    pub fn intersect(&self, other: Range) -> Option<Range> {
        let start = self.start.max(other.start);
        let end = self.end.min(other.end);
        (start < end).then_some(Range { start, end })
    }
}

/// Line-column range.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct LcRange {
    pub start: LineCol,
    pub end: LineCol,
}

impl LcRange {
    pub fn new(start: LineCol, end: LineCol) -> Self {
        Self { start, end }
    }
    pub fn is_empty(&self) -> bool {
        self.start == self.end
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_byte_offset_ordering() {
        assert!(ByteOffset(5) < ByteOffset(10));
        assert_eq!(ByteOffset(5), ByteOffset(5));
    }

    #[test]
    fn test_range_new() {
        let r = Range::new(3, 10);
        assert_eq!(r.start, ByteOffset(3));
        assert_eq!(r.end, ByteOffset(10));
    }

    #[test]
    fn test_range_is_empty() {
        assert!(Range::new(5, 5).is_empty());
        assert!(!Range::new(5, 6).is_empty());
    }

    #[test]
    fn test_range_len() {
        assert_eq!(Range::new(3, 10).len(), 7);
        assert_eq!(Range::new(0, 0).len(), 0);
    }

    #[test]
    fn test_range_contains() {
        let r = Range::new(5, 15);
        assert!(r.contains(ByteOffset(10)));
        assert!(!r.contains(ByteOffset(4)));
        assert!(!r.contains(ByteOffset(15)));
    }

    #[test]
    fn test_range_overlaps() {
        let a = Range::new(0, 10);
        let b = Range::new(5, 15);
        let c = Range::new(10, 20);
        assert!(a.overlaps(b));
        assert!(!a.overlaps(c)); // touching but not overlapping
    }

    #[test]
    fn test_line_col_new() {
        let lc = LineCol::new(5, 12);
        assert_eq!(lc.line, 5);
        assert_eq!(lc.col, 12);
    }

    #[test]
    fn test_position_from_byte_offset() {
        // ByteOffset is just a newtype
        let offset = ByteOffset(42);
        assert_eq!(offset.0, 42);
    }

    #[test]
    fn test_range_intersect() {
        let a = Range::new(0, 10);
        let b = Range::new(5, 20);
        let i = a.intersect(b).unwrap();
        assert_eq!(i.start.0, 5);
        assert_eq!(i.end.0, 10);
    }

    #[test]
    fn test_range_no_intersect() {
        let a = Range::new(0, 5);
        let b = Range::new(10, 20);
        assert!(a.intersect(b).is_none());
    }
}
