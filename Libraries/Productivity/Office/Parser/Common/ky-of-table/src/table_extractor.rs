//! Heuristic table detection from rich text spans via Y-axis clustering.

use crate::models::{RichSpan, TableCell, TableRow, TextTable};

/// Attempt to detect tables on each page from a flat list of rich spans.
/// Uses Y-clustering to find rows, then X-bucketing to assign columns.
pub fn detect_tables(spans: &[RichSpan], page_count: usize) -> Vec<TextTable> {
    let mut tables = Vec::new();
    for page_index in 0..page_count {
        let page_spans: Vec<&RichSpan> = spans
            .iter()
            .filter(|s| s.page_index == page_index)
            .collect();
        if let Some(t) = try_extract_table(&page_spans, page_index) {
            if t.rows.len() > 1 && t.col_count > 1 {
                tables.push(t);
            }
        }
    }
    tables
}

fn try_extract_table(spans: &[&RichSpan], page_index: usize) -> Option<TextTable> {
    if spans.is_empty() {
        return None;
    }

    // Round Y values to buckets of font_size width → rows
    let font_size = spans
        .iter()
        .map(|s| s.font_size)
        .fold(f64::INFINITY, f64::min)
        .max(1.0);
    let tolerance = font_size * 0.6;

    // Collect unique Y buckets (rows)
    let mut ys: Vec<f64> = spans.iter().map(|s| s.y).collect();
    ys.sort_by(|a, b| b.partial_cmp(a).unwrap()); // top-to-bottom (PDF y grows up)
    ys.dedup_by(|a, b| (*a - *b).abs() < tolerance);

    // Collect unique X buckets (columns)
    let mut xs: Vec<f64> = spans.iter().map(|s| s.x).collect();
    xs.sort_by(|a, b| a.partial_cmp(b).unwrap());
    xs.dedup_by(|a, b| (*a - *b).abs() < font_size * 4.0);

    let col_count = xs.len();
    if col_count < 2 || ys.len() < 2 {
        return None;
    }

    let rows: Vec<TableRow> = ys
        .iter()
        .enumerate()
        .map(|(row_idx, &row_y)| {
            let mut cells: Vec<TableCell> = xs
                .iter()
                .enumerate()
                .map(|(col_idx, &col_x)| {
                    // Collect all spans close to this (x, y)
                    let text: String = spans
                        .iter()
                        .filter(|s| {
                            (s.y - row_y).abs() < tolerance && (s.x - col_x).abs() < font_size * 4.0
                        })
                        .map(|s| s.text.as_str())
                        .collect::<Vec<_>>()
                        .join(" ");
                    TableCell {
                        text: text.trim().to_owned(),
                        col: col_idx,
                        row: row_idx,
                    }
                })
                .collect();
            // Remove trailing empty cells
            while cells.last().map(|c| c.text.is_empty()).unwrap_or(false) {
                cells.pop();
            }
            TableRow { cells }
        })
        .collect();

    // Only keep as a table if >50% of rows have >1 non-empty cell
    let populated = rows
        .iter()
        .filter(|r| r.cells.iter().filter(|c| !c.text.is_empty()).count() > 1)
        .count();
    if populated * 2 < rows.len() {
        return None;
    }

    Some(TextTable {
        page_index,
        rows,
        col_count,
    })
}
