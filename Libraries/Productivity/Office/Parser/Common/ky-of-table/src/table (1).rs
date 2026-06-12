use roxmltree::Node;
use crate::models::table::*;
use crate::parsers::text::parse_text_frame;
use crate::parsers::relationships::RelationshipMap;

/// Parse a `<a:tbl>` table node into a Table model.
pub fn parse_table(node: Node, rels: &RelationshipMap) -> Table {
    let mut rows = Vec::new();
    let mut columns = Vec::new();
    let mut style = None;

    let mut band_row = false;
    let mut band_col = false;
    let mut first_row = false;
    let mut last_row = false;
    let mut first_col = false;
    let mut last_col = false;

    for child in node.children() {
        match child.tag_name().name() {
            "tblPr" => {
                band_row = child.attribute("bandRow").map(|v| v == "1").unwrap_or(false);
                band_col = child.attribute("bandCol").map(|v| v == "1").unwrap_or(false);
                first_row = child.attribute("firstRow").map(|v| v == "1").unwrap_or(false);
                last_row = child.attribute("lastRow").map(|v| v == "1").unwrap_or(false);
                first_col = child.attribute("firstCol").map(|v| v == "1").unwrap_or(false);
                last_col = child.attribute("lastCol").map(|v| v == "1").unwrap_or(false);

                for style_child in child.children() {
                    if style_child.tag_name().name() == "tableStyleId" {
                        style = style_child.text().map(|s| TableStyle {
                            style_id: s.to_string(),
                            name: None,
                        });
                    }
                }
            }
            "tblGrid" => {
                for grid_col in child.children().filter(|c| c.tag_name().name() == "gridCol") {
                    let w: i64 = grid_col.attribute("w").and_then(|v| v.parse().ok()).unwrap_or(0);
                    columns.push(TableColumn { width: w });
                }
            }
            "tr" => {
                rows.push(parse_table_row(child, rels));
            }
            _ => {}
        }
    }

    Table { rows, columns, style, band_row, band_col, first_row, last_row, first_col, last_col }
}

fn parse_table_row(node: Node, rels: &RelationshipMap) -> TableRow {
    let height = node.attribute("h").and_then(|v| v.parse().ok());
    let mut cells = Vec::new();

    for child in node.children() {
        if child.tag_name().name() == "tc" {
            cells.push(parse_table_cell(child, rels));
        }
    }

    TableRow { cells, height }
}

fn parse_table_cell(node: Node, rels: &RelationshipMap) -> TableCell {
    let row_span: u32 = node.attribute("rowSpan").and_then(|v| v.parse().ok()).unwrap_or(1);
    let col_span: u32 = node.attribute("gridSpan").and_then(|v| v.parse().ok()).unwrap_or(1);
    let is_merged = node.attribute("hMerge").map(|v| v == "1").unwrap_or(false)
        || node.attribute("vMerge").map(|v| v == "1").unwrap_or(false);

    let mut text_frame = None;
    let mut fill = None;
    let borders = TableCellBorders::default();
    let mut margins = CellMargins::default();
    let mut anchor = crate::models::text::VerticalAnchor::Top;

    for child in node.children() {
        match child.tag_name().name() {
            "txBody" => {
                text_frame = Some(parse_text_frame(child, rels));
            }
            "tcPr" => {
                // Cell properties
                margins.top = child.attribute("marT").and_then(|v| v.parse().ok());
                margins.bottom = child.attribute("marB").and_then(|v| v.parse().ok());
                margins.left = child.attribute("marL").and_then(|v| v.parse().ok());
                margins.right = child.attribute("marR").and_then(|v| v.parse().ok());
                anchor = child.attribute("anchor").map(|v| match v {
                    "ctr" => crate::models::text::VerticalAnchor::Middle,
                    "b" => crate::models::text::VerticalAnchor::Bottom,
                    _ => crate::models::text::VerticalAnchor::Top,
                }).unwrap_or(crate::models::text::VerticalAnchor::Top);

                fill = parse_cell_fill(child);
            }
            _ => {}
        }
    }

    TableCell { text_frame, row_span, col_span, is_merged, fill, borders, margins, anchor }
}

fn parse_cell_fill(tc_pr: Node) -> Option<TableCellFill> {
    for child in tc_pr.children() {
        match child.tag_name().name() {
            "noFill" => return Some(TableCellFill { fill_type: CellFillType::None }),
            "solidFill" => {
                if let Some(color) = crate::parsers::color::parse_color_node(child) {
                    return Some(TableCellFill { fill_type: CellFillType::Solid(color) });
                }
            }
            _ => {}
        }
    }
    None
}
