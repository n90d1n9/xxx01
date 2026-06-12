use roxmltree::Node;
use std::collections::HashMap;
use crate::models::shape::*;
use crate::models::geometry::*;
use crate::models::image::ImageData;
use crate::parsers::relationships::RelationshipMap;
use crate::parsers::text::parse_text_frame;
use crate::parsers::color::parse_color_node;

/// Parse a `<p:sp>` shape node.
pub fn parse_sp(node: Node, rels: &RelationshipMap) -> Shape {
    let mut id = String::new();
    let mut name = String::new();
    let mut alt_text = None;
    let mut geometry = Geometry::default();
    let mut text_frame = None;
    let mut fill = None;
    let mut line_props = None;
    let mut preset_geom = None;
    let mut hidden = false;
    let mut placeholder = None;
    let mut locks = ShapeLocks::default();

    for child in node.children() {
        match child.tag_name().name() {
            "nvSpPr" => {
                let (cid, cname, calt, pholder, clock) = parse_nv_sp_pr(child);
                id = cid; name = cname; alt_text = calt;
                placeholder = pholder; locks = clock;
            }
            "spPr" => {
                let (xfrm, pgeom, cfill, cline) = parse_sp_pr(child);
                if let Some(x) = xfrm { geometry = x; }
                preset_geom = pgeom;
                fill = cfill;
                line_props = cline;
            }
            "txBody" => {
                text_frame = Some(parse_text_frame(child, rels));
            }
            _ => {}
        }
    }

    Shape {
        id, name, alt_text, geometry,
        shape_type: ShapeType::AutoShape,
        text_frame, fill, line: line_props, preset_geometry: preset_geom,
        hidden, z_order: 0, placeholder, group_id: None,
        hyperlink: None, locks, effect_3d: None, effects: Vec::new(),
    }
}

/// Parse a `<p:pic>` picture node.
pub fn parse_pic(
    node: Node,
    rels: &RelationshipMap,
    images_by_rid: &HashMap<String, ImageData>,
) -> Shape {
    let mut id = String::new();
    let mut name = String::new();
    let mut alt_text = None;
    let mut geometry = Geometry::default();
    let mut hidden = false;
    let mut placeholder = None;
    let mut locks = ShapeLocks::default();
    let mut image_data: Option<ImageData> = None;
    let mut frame_shape = None;

    for child in node.children() {
        match child.tag_name().name() {
            "nvPicPr" => {
                let (cid, cname, calt, pholder, clock) = parse_nv_sp_pr(child);
                id = cid; name = cname; alt_text = calt;
                placeholder = pholder; locks = clock;
            }
            "blipFill" => {
                // Find the relationship ID for the image
                for sub in child.descendants() {
                    if sub.tag_name().name() == "blip" {
                        let rid = sub.attribute_ns(
                            "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
                            "embed",
                        ).or_else(|| sub.attribute("r:embed"))
                         .or_else(|| sub.attribute("r:link"));
                        if let Some(rid) = rid {
                            image_data = images_by_rid.get(rid).cloned();
                        }
                    }
                }
            }
            "spPr" => {
                let (xfrm, pgeom, _, _) = parse_sp_pr(child);
                if let Some(x) = xfrm { geometry = x; }
                frame_shape = pgeom;
            }
            _ => {}
        }
    }

    let image = image_data.unwrap_or_else(|| ImageData {
        relationship_id: String::new(),
        filename: String::new(),
        mime_type: String::new(),
        extension: String::new(),
        data: Vec::new(),
        width_px: None, height_px: None, dpi: None,
        is_linked: false, external_url: None, crop: None, effects: Vec::new(),
    });

    Shape {
        id, name, alt_text, geometry,
        shape_type: ShapeType::Picture { image, frame_shape },
        text_frame: None, fill: None, line: None, preset_geometry: None,
        hidden, z_order: 0, placeholder, group_id: None,
        hyperlink: None, locks, effect_3d: None, effects: Vec::new(),
    }
}

/// Parse a `<p:graphicFrame>` (chart, table, smart art, etc.)
pub fn parse_graphic_frame(
    node: Node,
    rels: &RelationshipMap,
    charts: &HashMap<String, crate::models::chart::Chart>,
) -> Option<Shape> {
    let mut id = String::new();
    let mut name = String::new();
    let mut geometry = Geometry::default();

    for child in node.children() {
        match child.tag_name().name() {
            "nvGraphicFramePr" => {
                let (cid, cname, _, _, _) = parse_nv_sp_pr(child);
                id = cid; name = cname;
            }
            "xfrm" => {
                geometry = parse_xfrm(child);
            }
            "graphic" => {
                for data in child.children() {
                    if data.tag_name().name() == "graphicData" {
                        let uri = data.attribute("uri").unwrap_or("");
                        // Chart
                        if uri.contains("chart") || uri.contains("Chart") {
                            for chart_ref in data.descendants() {
                                if chart_ref.tag_name().name() == "chart" {
                                    let rid = chart_ref.attribute_ns(
                                        "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
                                        "id",
                                    ).or_else(|| chart_ref.attribute("r:id"));
                                    if let Some(rid) = rid {
                                        if let Some(chart) = charts.get(rid) {
                                            return Some(Shape {
                                                id, name, alt_text: None, geometry,
                                                shape_type: ShapeType::Chart(chart.clone()),
                                                text_frame: None, fill: None, line: None,
                                                preset_geometry: None, hidden: false,
                                                z_order: 0, placeholder: None, group_id: None,
                                                hyperlink: None, locks: ShapeLocks::default(),
                                                effect_3d: None, effects: Vec::new(),
                                            });
                                        }
                                    }
                                }
                            }
                        }
                        // Table
                        if uri.contains("drawingml/2006/table") {
                            for tbl_node in data.descendants() {
                                if tbl_node.tag_name().name() == "tbl" {
                                    let table = crate::parsers::table::parse_table(tbl_node, rels);
                                    return Some(Shape {
                                        id, name, alt_text: None, geometry,
                                        shape_type: ShapeType::Table(table),
                                        text_frame: None, fill: None, line: None,
                                        preset_geometry: None, hidden: false,
                                        z_order: 0, placeholder: None, group_id: None,
                                        hyperlink: None, locks: ShapeLocks::default(),
                                        effect_3d: None, effects: Vec::new(),
                                    });
                                }
                            }
                        }
                    }
                }
            }
            _ => {}
        }
    }
    None
}

/// Parse a `<p:grpSp>` group shape.
pub fn parse_group_sp(
    node: Node,
    rels: &RelationshipMap,
    images_by_rid: &HashMap<String, ImageData>,
    charts: &HashMap<String, crate::models::chart::Chart>,
) -> Shape {
    let mut id = String::new();
    let mut name = String::new();
    let mut geometry = Geometry::default();
    let mut children_shapes = Vec::new();

    for child in node.children() {
        match child.tag_name().name() {
            "nvGrpSpPr" => {
                let (cid, cname, _, _, _) = parse_nv_sp_pr(child);
                id = cid; name = cname;
            }
            "grpSpPr" => {
                if let Some(xfrm) = child.children().find(|c| c.tag_name().name() == "xfrm") {
                    geometry = parse_xfrm(xfrm);
                }
            }
            "sp" => children_shapes.push(parse_sp(child, rels)),
            "pic" => children_shapes.push(parse_pic(child, rels, images_by_rid)),
            "graphicFrame" => {
                if let Some(s) = parse_graphic_frame(child, rels, charts) {
                    children_shapes.push(s);
                }
            }
            "grpSp" => children_shapes.push(
                parse_group_sp(child, rels, images_by_rid, charts)
            ),
            _ => {}
        }
    }

    Shape {
        id, name, alt_text: None, geometry,
        shape_type: ShapeType::Group(children_shapes),
        text_frame: None, fill: None, line: None, preset_geometry: None,
        hidden: false, z_order: 0, placeholder: None, group_id: None,
        hyperlink: None, locks: ShapeLocks::default(),
        effect_3d: None, effects: Vec::new(),
    }
}

/// Parse a connector shape `<p:cxnSp>`.
pub fn parse_cxn_sp(node: Node, _rels: &RelationshipMap) -> Shape {
    let mut id = String::new();
    let mut name = String::new();
    let mut geometry = Geometry::default();

    for child in node.children() {
        match child.tag_name().name() {
            "nvCxnSpPr" => {
                let (cid, cname, _, _, _) = parse_nv_sp_pr(child);
                id = cid; name = cname;
            }
            "spPr" => {
                let (xfrm, _, _, _) = parse_sp_pr(child);
                if let Some(x) = xfrm { geometry = x; }
            }
            _ => {}
        }
    }

    Shape {
        id, name, alt_text: None, geometry,
        shape_type: ShapeType::Connector {
            connector_type: ConnectorType::Straight,
            start_shape: None, end_shape: None,
        },
        text_frame: None, fill: None, line: None, preset_geometry: None,
        hidden: false, z_order: 0, placeholder: None, group_id: None,
        hyperlink: None, locks: ShapeLocks::default(),
        effect_3d: None, effects: Vec::new(),
    }
}

// ── Non-visual properties ────────────────────────────────────────────────────

fn parse_nv_sp_pr(nv_node: Node) -> (String, String, Option<String>, Option<Placeholder>, ShapeLocks) {
    let mut id = String::new();
    let mut name = String::new();
    let mut alt_text = None;
    let mut placeholder = None;
    let mut locks = ShapeLocks::default();

    for child in nv_node.children() {
        match child.tag_name().name() {
            "cNvPr" => {
                id = child.attribute("id").unwrap_or("").to_string();
                name = child.attribute("name").unwrap_or("").to_string();
                alt_text = child.attribute("descr").map(str::to_string);
                alt_text = alt_text.filter(|s| !s.is_empty());
            }
            "nvPr" | "cNvSpPr" | "cNvPicPr" | "cNvGraphicFramePr" => {
                for sub in child.children() {
                    if sub.tag_name().name() == "ph" {
                        let ph_type = sub.attribute("type").unwrap_or("body");
                        let ph_idx = sub.attribute("idx").and_then(|v| v.parse().ok());
                        placeholder = Some(Placeholder {
                            placeholder_type: parse_placeholder_type(ph_type, ph_idx),
                            index: ph_idx,
                        });
                    }
                    if sub.tag_name().name() == "spLocks" {
                        locks.no_group = sub.attribute("noGrp").map(|v| v == "1").unwrap_or(false);
                        locks.no_select = sub.attribute("noSelect").map(|v| v == "1").unwrap_or(false);
                        locks.no_rotate = sub.attribute("noRot").map(|v| v == "1").unwrap_or(false);
                        locks.no_resize = sub.attribute("noResize").map(|v| v == "1").unwrap_or(false);
                    }
                }
            }
            _ => {}
        }
    }
    (id, name, alt_text, placeholder, locks)
}

// ── Shape properties ─────────────────────────────────────────────────────────

fn parse_sp_pr(sp_pr: Node) -> (Option<Geometry>, Option<PresetGeometry>, Option<FillType>, Option<LineProperties>) {
    let mut xfrm = None;
    let mut preset = None;
    let mut fill = None;
    let mut line = None;

    for child in sp_pr.children() {
        match child.tag_name().name() {
            "xfrm" => xfrm = Some(parse_xfrm(child)),
            "prstGeom" => {
                let prst = child.attribute("prst").unwrap_or("rect");
                preset = Some(PresetGeometry::from_str(prst));
            }
            "noFill" => fill = Some(FillType::None),
            "solidFill" => {
                if let Some(color) = parse_color_node(child) {
                    fill = Some(FillType::Solid { color });
                }
            }
            "gradFill" => {
                fill = Some(parse_grad_fill(child));
            }
            "blipFill" => {
                for blip in child.descendants() {
                    if blip.tag_name().name() == "blip" {
                        let rid = blip.attribute_ns(
                            "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
                            "embed",
                        ).or_else(|| blip.attribute("r:embed"))
                         .unwrap_or("")
                         .to_string();
                        fill = Some(FillType::Picture { relationship_id: rid });
                    }
                }
            }
            "ln" => line = Some(parse_line_props(child)),
            _ => {}
        }
    }

    (xfrm, preset, fill, line)
}

pub fn parse_xfrm(node: Node) -> Geometry {
    let rotation = node.attribute("rot")
        .and_then(|v| v.parse::<i64>().ok())
        .map(|v| v as f64 / 60000.0)
        .unwrap_or(0.0);
    let flip_h = node.attribute("flipH").map(|v| v == "1").unwrap_or(false);
    let flip_v = node.attribute("flipV").map(|v| v == "1").unwrap_or(false);

    let mut x = 0i64;
    let mut y = 0i64;
    let mut cx = 0i64;
    let mut cy = 0i64;

    for child in node.children() {
        match child.tag_name().name() {
            "off" => {
                x = child.attribute("x").and_then(|v| v.parse().ok()).unwrap_or(0);
                y = child.attribute("y").and_then(|v| v.parse().ok()).unwrap_or(0);
            }
            "ext" => {
                cx = child.attribute("cx").and_then(|v| v.parse().ok()).unwrap_or(0);
                cy = child.attribute("cy").and_then(|v| v.parse().ok()).unwrap_or(0);
            }
            _ => {}
        }
    }

    Geometry { x, y, width: cx, height: cy, rotation, flip_h, flip_v }
}

fn parse_grad_fill(node: Node) -> FillType {
    let mut stops = Vec::new();
    let mut angle = 0.0f64;

    for child in node.children() {
        match child.tag_name().name() {
            "gsLst" => {
                for gs in child.children().filter(|c| c.tag_name().name() == "gs") {
                    let pos = gs.attribute("pos")
                        .and_then(|v| v.parse::<f64>().ok())
                        .map(|v| v / 1000.0)
                        .unwrap_or(0.0);
                    if let Some(color) = parse_color_node(gs) {
                        stops.push(GradientStop { position: pos, color });
                    }
                }
            }
            "lin" => {
                angle = node.attribute("ang")
                    .and_then(|v| v.parse::<f64>().ok())
                    .map(|v| v / 60000.0)
                    .unwrap_or(0.0);
            }
            _ => {}
        }
    }

    FillType::Gradient { stops, angle }
}

fn parse_line_props(node: Node) -> LineProperties {
    let width = node.attribute("w").and_then(|v| v.parse().ok());
    let mut color = None;
    let mut dash_style = LineDashStyle::Solid;
    let cap_type = LineCapType::Flat;
    let join_type = LineJoinType::Round;

    for child in node.children() {
        match child.tag_name().name() {
            "solidFill" => { color = parse_color_node(child); }
            "noFill" => { color = None; }
            "prstDash" => {
                dash_style = child.attribute("val").map(|v| match v {
                    "dash" => LineDashStyle::Dash,
                    "dot" => LineDashStyle::Dot,
                    "dashDot" => LineDashStyle::DashDot,
                    "lgDash" => LineDashStyle::LongDash,
                    "lgDashDot" => LineDashStyle::LongDashDot,
                    _ => LineDashStyle::Solid,
                }).unwrap_or(LineDashStyle::Solid);
            }
            _ => {}
        }
    }

    LineProperties { width, color, dash_style, cap_type, join_type, head_arrow: None, tail_arrow: None }
}

fn parse_placeholder_type(type_str: &str, idx: Option<u32>) -> PlaceholderType {
    match type_str {
        "title" => PlaceholderType::Title,
        "ctrTitle" => PlaceholderType::CenteredTitle,
        "body" => PlaceholderType::Body,
        "subTitle" => PlaceholderType::SubTitle,
        "dt" => PlaceholderType::DateAndTime,
        "sldNum" => PlaceholderType::SlideNumber,
        "ftr" => PlaceholderType::Footer,
        "hdr" => PlaceholderType::Header,
        "obj" => PlaceholderType::Object,
        "chart" => PlaceholderType::Chart,
        "tbl" => PlaceholderType::Table,
        "clipArt" => PlaceholderType::ClipArt,
        "pic" => PlaceholderType::Picture,
        "media" => PlaceholderType::Media,
        "sldImg" => PlaceholderType::SlideImage,
        _ => idx.map(PlaceholderType::Custom).unwrap_or(PlaceholderType::Body),
    }
}
