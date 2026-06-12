use serde::{Deserialize, Serialize};
use crate::models::{color::ColorSpec, geometry::LineProperties, text::TextFrame};

/// A table shape on a slide.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Table {
    pub rows: Vec<TableRow>,
    pub columns: Vec<TableColumn>,
    pub style: Option<TableStyle>,
    pub band_row: bool,
    pub band_col: bool,
    pub first_row: bool,
    pub last_row: bool,
    pub first_col: bool,
    pub last_col: bool,
}

impl Table {
    /// Get total number of rows.
    pub fn row_count(&self) -> usize { self.rows.len() }

    /// Get total number of columns.
    pub fn col_count(&self) -> usize {
        self.rows.first().map(|r| r.cells.len()).unwrap_or(0)
    }

    /// Get a specific cell by row/col index (0-based).
    pub fn cell(&self, row: usize, col: usize) -> Option<&TableCell> {
        self.rows.get(row)?.cells.get(col)
    }

    /// Extract all text content as a 2D Vec<Vec<String>>.
    pub fn to_text_matrix(&self) -> Vec<Vec<String>> {
        self.rows.iter()
            .map(|r| r.cells.iter().map(|c| c.plain_text()).collect())
            .collect()
    }

    /// Convert to CSV string.
    pub fn to_csv(&self) -> String {
        self.to_text_matrix()
            .iter()
            .map(|row| {
                row.iter()
                    .map(|cell| {
                        if cell.contains(',') || cell.contains('"') || cell.contains('\n') {
                            format!("\"{}\"", cell.replace('"', "\"\""))
                        } else {
                            cell.clone()
                        }
                    })
                    .collect::<Vec<_>>()
                    .join(",")
            })
            .collect::<Vec<_>>()
            .join("\n")
    }
}

/// A row in a table.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TableRow {
    pub cells: Vec<TableCell>,
    /// Row height in EMU.
    pub height: Option<i64>,
}

/// A column descriptor in a table.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TableColumn {
    /// Column width in EMU.
    pub width: i64,
}

/// A single cell in a table.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TableCell {
    pub text_frame: Option<TextFrame>,
    /// Number of rows this cell spans.
    pub row_span: u32,
    /// Number of columns this cell spans.
    pub col_span: u32,
    /// Whether this cell is hidden (part of a merged cell).
    pub is_merged: bool,
    pub fill: Option<TableCellFill>,
    pub borders: TableCellBorders,
    pub margins: CellMargins,
    pub anchor: crate::models::text::VerticalAnchor,
}

impl TableCell {
    /// Extract plain text from the cell.
    pub fn plain_text(&self) -> String {
        self.text_frame.as_ref().map(|tf| tf.plain_text()).unwrap_or_default()
    }
}

/// Fill for a table cell.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TableCellFill {
    pub fill_type: CellFillType,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum CellFillType {
    None,
    Solid(ColorSpec),
    Gradient { stops: Vec<(f64, ColorSpec)>, angle: f64 },
}

/// Borders of a table cell.
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct TableCellBorders {
    pub top: Option<LineProperties>,
    pub bottom: Option<LineProperties>,
    pub left: Option<LineProperties>,
    pub right: Option<LineProperties>,
    pub top_left_to_bottom_right: Option<LineProperties>,
    pub top_right_to_bottom_left: Option<LineProperties>,
}

/// Cell content margins.
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct CellMargins {
    pub top: Option<i32>,    // EMU
    pub bottom: Option<i32>, // EMU
    pub left: Option<i32>,   // EMU
    pub right: Option<i32>,  // EMU
}

/// Table style definition.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TableStyle {
    pub style_id: String,
    pub name: Option<String>,
}
