use crate::core::buffer::Buffer;
use crate::core::types::{ByteOffset, LineCol};

fn is_word_char(ch: char) -> bool {
    ch.is_alphanumeric() || ch == '_'
}

fn chars_with_offsets(text: &str) -> Vec<(usize, char)> {
    text.char_indices().collect()
}

fn char_index_at_or_after(chars: &[(usize, char)], offset: usize) -> usize {
    chars
        .iter()
        .position(|(byte, _)| *byte >= offset)
        .unwrap_or(chars.len())
}

fn char_index_before(chars: &[(usize, char)], offset: usize) -> usize {
    chars.partition_point(|(byte, _)| *byte < offset)
}

fn byte_at_char_index(chars: &[(usize, char)], text_len: usize, index: usize) -> ByteOffset {
    chars
        .get(index)
        .map(|(byte, _)| ByteOffset(*byte))
        .unwrap_or(ByteOffset(text_len))
}

fn byte_after_char(chars: &[(usize, char)], text_len: usize, index: usize) -> ByteOffset {
    chars
        .get(index)
        .map(|(byte, ch)| ByteOffset(byte + ch.len_utf8()))
        .unwrap_or(ByteOffset(text_len))
}

fn line_len_chars_without_newline(buf: &Buffer, line: usize) -> usize {
    buf.line_str(line).chars().count()
}

pub fn char_left(buf: &Buffer, pos: ByteOffset) -> ByteOffset {
    if pos.0 == 0 {
        return ByteOffset(0);
    }

    let text = buf.to_string();
    let offset = pos.0.min(text.len());
    text[..offset]
        .char_indices()
        .last()
        .map(|(byte, _)| ByteOffset(byte))
        .unwrap_or(ByteOffset(0))
}

pub fn char_right(buf: &Buffer, pos: ByteOffset) -> ByteOffset {
    let text = buf.to_string();
    if pos.0 >= text.len() {
        return ByteOffset(text.len());
    }

    let offset = pos.0.min(text.len());
    text[offset..]
        .chars()
        .next()
        .map(|ch| ByteOffset(offset + ch.len_utf8()))
        .unwrap_or(ByteOffset(text.len()))
}

pub fn word_forward(buf: &Buffer, pos: ByteOffset) -> ByteOffset {
    let text = buf.to_string();
    let chars = chars_with_offsets(&text);
    let mut index = char_index_at_or_after(&chars, pos.0.min(text.len()));

    while index < chars.len() && is_word_char(chars[index].1) {
        index += 1;
    }
    while index < chars.len() && !is_word_char(chars[index].1) {
        index += 1;
    }

    byte_at_char_index(&chars, text.len(), index)
}

pub fn word_backward(buf: &Buffer, pos: ByteOffset) -> ByteOffset {
    let text = buf.to_string();
    let chars = chars_with_offsets(&text);
    let mut index = char_index_before(&chars, pos.0.min(text.len()));

    while index > 0 && !is_word_char(chars[index - 1].1) {
        index -= 1;
    }
    while index > 0 && is_word_char(chars[index - 1].1) {
        index -= 1;
    }

    byte_at_char_index(&chars, text.len(), index)
}

pub fn word_end_forward(buf: &Buffer, pos: ByteOffset) -> ByteOffset {
    let text = buf.to_string();
    let chars = chars_with_offsets(&text);
    let mut index = char_index_at_or_after(&chars, pos.0.min(text.len()));

    while index < chars.len() && !is_word_char(chars[index].1) {
        index += 1;
    }
    while index < chars.len() && is_word_char(chars[index].1) {
        index += 1;
    }

    if index == 0 {
        ByteOffset(0)
    } else {
        byte_after_char(&chars, text.len(), index - 1)
    }
}

pub fn line_start(buf: &Buffer, line: usize) -> ByteOffset {
    buf.line_col_to_offset(LineCol::new(line.min(buf.len_lines().saturating_sub(1)), 0))
}

pub fn line_first_nonwhitespace(buf: &Buffer, line: usize) -> ByteOffset {
    let line = line.min(buf.len_lines().saturating_sub(1));
    let col = buf
        .line_str(line)
        .chars()
        .position(|ch| !ch.is_whitespace())
        .unwrap_or(0);
    buf.line_col_to_offset(LineCol::new(line, col))
}

pub fn line_end(buf: &Buffer, line: usize) -> ByteOffset {
    let line = line.min(buf.len_lines().saturating_sub(1));
    buf.line_col_to_offset(LineCol::new(
        line,
        line_len_chars_without_newline(buf, line),
    ))
}

pub fn paragraph_backward(buf: &Buffer, pos: ByteOffset) -> ByteOffset {
    let lc = buf.offset_to_line_col(pos);
    if lc.line == 0 {
        return document_start();
    }

    let mut line = lc.line.saturating_sub(1);
    while line > 0 && buf.line_str(line).trim().is_empty() {
        line -= 1;
    }
    while line > 0 && !buf.line_str(line - 1).trim().is_empty() {
        line -= 1;
    }

    line_start(buf, line)
}

pub fn paragraph_forward(buf: &Buffer, pos: ByteOffset) -> ByteOffset {
    let lc = buf.offset_to_line_col(pos);
    let total = buf.len_lines();
    if lc.line + 1 >= total {
        return document_end(buf);
    }

    let mut line = lc.line + 1;
    while line < total && !buf.line_str(line).trim().is_empty() {
        line += 1;
    }
    while line < total && buf.line_str(line).trim().is_empty() {
        line += 1;
    }

    if line >= total {
        document_end(buf)
    } else {
        line_start(buf, line)
    }
}

pub fn page_up(buf: &Buffer, pos: ByteOffset, height: usize) -> ByteOffset {
    let lc = buf.offset_to_line_col(pos);
    let target_line = lc.line.saturating_sub(height.max(1));
    let target_col = lc.col.min(line_len_chars_without_newline(buf, target_line));
    buf.line_col_to_offset(LineCol::new(target_line, target_col))
}

pub fn page_down(buf: &Buffer, pos: ByteOffset, height: usize) -> ByteOffset {
    let lc = buf.offset_to_line_col(pos);
    let target_line = (lc.line + height.max(1)).min(buf.len_lines().saturating_sub(1));
    let target_col = lc.col.min(line_len_chars_without_newline(buf, target_line));
    buf.line_col_to_offset(LineCol::new(target_line, target_col))
}

pub fn matching_bracket(buf: &Buffer, pos: ByteOffset) -> Option<ByteOffset> {
    let bracket_match = crate::syntax::bracket::find_matching_bracket(buf, pos, 4096)?;
    if pos == bracket_match.open {
        Some(bracket_match.close)
    } else if pos == bracket_match.close {
        Some(bracket_match.open)
    } else {
        None
    }
}

pub fn document_start() -> ByteOffset {
    ByteOffset(0)
}

pub fn document_end(buf: &Buffer) -> ByteOffset {
    ByteOffset(buf.len_bytes())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn char_motion_respects_utf8_boundaries() {
        let buf = Buffer::from_str("aéb");
        let after_e = ByteOffset("aé".len());

        assert_eq!(char_left(&buf, after_e), ByteOffset(1));
        assert_eq!(char_right(&buf, ByteOffset(1)), after_e);
    }

    #[test]
    fn word_motion_moves_between_word_starts_and_ends() {
        let buf = Buffer::from_str("hello, world");

        assert_eq!(word_forward(&buf, ByteOffset(0)), ByteOffset(7));
        assert_eq!(word_backward(&buf, ByteOffset(12)), ByteOffset(7));
        assert_eq!(word_end_forward(&buf, ByteOffset(0)), ByteOffset(5));
    }

    #[test]
    fn line_motion_uses_non_newline_line_end() {
        let buf = Buffer::from_str("  first\nsecond");

        assert_eq!(line_start(&buf, 1), ByteOffset(8));
        assert_eq!(line_first_nonwhitespace(&buf, 0), ByteOffset(2));
        assert_eq!(line_end(&buf, 0), ByteOffset(7));
    }

    #[test]
    fn bracket_motion_returns_partner() {
        let buf = Buffer::from_str("fn(a)");

        assert_eq!(matching_bracket(&buf, ByteOffset(2)), Some(ByteOffset(4)));
        assert_eq!(matching_bracket(&buf, ByteOffset(4)), Some(ByteOffset(2)));
    }
}
