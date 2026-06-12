use roxmltree::Node;
use crate::models::text::*;
use crate::models::hyperlink::{Hyperlink, HyperlinkTarget};
use crate::parsers::color::parse_color_node;
use crate::parsers::relationships::RelationshipMap;

/// Parse a `<a:txBody>` or `<p:txBody>` node into a TextFrame.
pub fn parse_text_frame(node: Node, rels: &RelationshipMap) -> TextFrame {
    let mut paragraphs = Vec::new();
    let mut body_props = BodyProperties::default();
    let mut word_wrap = true;
    let mut autofit = AutofitType::None;

    for child in node.children() {
        match child.tag_name().name() {
            "bodyPr" => {
                body_props = parse_body_properties(child);
                // Extract autofit from bodyPr children
                for bp_child in child.children() {
                    match bp_child.tag_name().name() {
                        "noAutofit" => autofit = AutofitType::None,
                        "spAutoFit" => autofit = AutofitType::ShapeAutofit,
                        "normAutofit" => {
                            let font_scale = bp_child.attribute("fontScale")
                                .and_then(|v| v.parse::<f32>().ok())
                                .unwrap_or(100000.0) / 100000.0;
                            let line_space_reduction = bp_child.attribute("lnSpcReduction")
                                .and_then(|v| v.parse::<f32>().ok())
                                .unwrap_or(0.0) / 100000.0;
                            autofit = AutofitType::NormAutofit { font_scale, line_space_reduction };
                        }
                        _ => {}
                    }
                }
                word_wrap = child.attribute("wrap").map(|v| v != "none").unwrap_or(true);
            }
            "p" => {
                paragraphs.push(parse_paragraph(child, rels));
            }
            _ => {}
        }
    }

    TextFrame { paragraphs, word_wrap, autofit, body_properties: body_props }
}

/// Parse a `<a:p>` paragraph node.
pub fn parse_paragraph(node: Node, rels: &RelationshipMap) -> Paragraph {
    let mut runs = Vec::new();
    let mut properties = ParagraphProperties::default();
    let mut list_level: u8 = 0;

    for child in node.children() {
        match child.tag_name().name() {
            "pPr" => {
                properties = parse_paragraph_properties(child);
                list_level = child.attribute("lvl")
                    .and_then(|v| v.parse().ok())
                    .unwrap_or(0);
            }
            "r" => {
                runs.push(parse_run(child, rels));
            }
            "br" => {
                // Line break within a paragraph
                runs.push(Run {
                    text: "\n".to_string(),
                    properties: parse_run_properties_from_parent(child),
                    hyperlink: None,
                    field: None,
                });
            }
            "fld" => {
                // Field (slide number, date, etc.)
                let field_type = parse_field_type(child);
                let text = child.children()
                    .find(|c| c.tag_name().name() == "r")
                    .and_then(|r| r.children().find(|c| c.tag_name().name() == "t"))
                    .and_then(|t| t.text())
                    .unwrap_or("")
                    .to_string();
                runs.push(Run {
                    text,
                    properties: TextProperties::default(),
                    hyperlink: None,
                    field: Some(field_type),
                });
            }
            _ => {}
        }
    }

    Paragraph { runs, properties, list_level }
}

/// Parse a `<a:r>` run node.
fn parse_run(node: Node, rels: &RelationshipMap) -> Run {
    let mut text = String::new();
    let mut properties = TextProperties::default();
    let mut hyperlink = None;

    for child in node.children() {
        match child.tag_name().name() {
            "rPr" => {
                properties = parse_run_properties(child);
                // Check for hyperlink inside rPr
                hyperlink = parse_hyperlink_from_rpr(child, rels);
            }
            "t" => {
                text = child.text().unwrap_or("").to_string();
            }
            _ => {}
        }
    }

    Run { text, properties, hyperlink, field: None }
}

/// Parse `<a:rPr>` run properties.
pub fn parse_run_properties(node: Node) -> TextProperties {
    let bold = node.attribute("b").map(|v| v == "1" || v == "true");
    let italic = node.attribute("i").map(|v| v == "1" || v == "true");
    let strikethrough = node.attribute("strike").map(|v| v != "noStrike");
    let underline = node.attribute("u").map(|v| parse_underline_style(v));
    let font_size = node.attribute("sz").and_then(|v| v.parse().ok());
    let baseline = node.attribute("baseline").and_then(|v| v.parse().ok());
    let language = node.attribute("lang").map(str::to_string);
    let alt_language = node.attribute("altLang").map(str::to_string);
    let kerning = node.attribute("kern").and_then(|v| v.parse().ok());
    let spacing = node.attribute("spc").and_then(|v| v.parse().ok());
    let caps = node.attribute("cap").map(|v| match v {
        "sng" | "small" => CapsStyle::Small,
        "all" => CapsStyle::All,
        _ => CapsStyle::None,
    });

    let mut font_family = None;
    let mut color = None;
    let mut highlight_color = None;

    for child in node.children() {
        match child.tag_name().name() {
            "solidFill" => {
                color = parse_color_node(child);
            }
            "latin" => {
                font_family = child.attribute("typeface").map(str::to_string);
            }
            "cs" => {
                if font_family.is_none() {
                    font_family = child.attribute("typeface").map(str::to_string);
                }
            }
            "highlight" => {
                highlight_color = parse_color_node(child);
            }
            _ => {}
        }
    }

    TextProperties {
        font_family,
        font_size,
        bold,
        italic,
        underline,
        strikethrough,
        baseline,
        color,
        highlight_color,
        language,
        alt_language,
        kerning,
        spacing,
        caps,
        shadow: None,
        glow: None,
        soft_edge: None,
        reflection: None,
    }
}

fn parse_run_properties_from_parent(node: Node) -> TextProperties {
    node.children()
        .find(|c| c.tag_name().name() == "rPr")
        .map(|n| parse_run_properties(n))
        .unwrap_or_default()
}

/// Parse paragraph properties `<a:pPr>`.
pub fn parse_paragraph_properties(node: Node) -> ParagraphProperties {
    let alignment = node.attribute("algn").map(|v| match v {
        "ctr" => TextAlignment::Center,
        "r" => TextAlignment::Right,
        "just" => TextAlignment::Justify,
        "justLow" => TextAlignment::JustifyLow,
        "dist" => TextAlignment::Distributed,
        "thaiDist" => TextAlignment::ThaiDistributed,
        _ => TextAlignment::Left,
    }).unwrap_or(TextAlignment::Left);

    let indent = node.attribute("indent").and_then(|v| v.parse().ok());
    let margin_left = node.attribute("marL").and_then(|v| v.parse().ok());
    let margin_right = node.attribute("marR").and_then(|v| v.parse().ok());
    let rtl = node.attribute("rtl").map(|v| v == "1" || v == "true").unwrap_or(false);

    let mut space_before = None;
    let mut space_after = None;
    let mut line_spacing = None;
    let mut bullet = None;
    let mut default_run_props = None;

    for child in node.children() {
        match child.tag_name().name() {
            "spcBef" => space_before = parse_spacing(child),
            "spcAft" => space_after = parse_spacing(child),
            "lnSpc" => line_spacing = parse_spacing(child),
            "buNone" => bullet = Some(BulletStyle::None),
            "buChar" => {
                let c = child.attribute("char").unwrap_or("•").to_string();
                bullet = Some(BulletStyle::Char {
                    char: c,
                    color: None,
                    size: None,
                    font: None,
                });
            }
            "buAutoNum" => {
                let type_str = child.attribute("type").unwrap_or("arabicPeriod");
                let start_at = child.attribute("startAt").and_then(|v| v.parse().ok());
                bullet = Some(BulletStyle::Auto {
                    type_: parse_numbering_type(type_str),
                    start_at,
                    color: None,
                    size: None,
                });
            }
            "buClr" => {
                // Color for preceding bullet
                if let Some(BulletStyle::Char { ref mut color, .. })
                    | Some(BulletStyle::Auto { ref mut color, .. }) = bullet
                {
                    *color = parse_color_node(child);
                }
            }
            "buSzPct" => {
                let pct = child.attribute("val").and_then(|v| v.parse::<i32>().ok());
                if let Some(pct_val) = pct {
                    if let Some(BulletStyle::Char { ref mut size, .. })
                        | Some(BulletStyle::Auto { ref mut size, .. }) = bullet
                    {
                        *size = Some(BulletSize::Percent(pct_val));
                    }
                }
            }
            "defRPr" => default_run_props = Some(parse_run_properties(child)),
            _ => {}
        }
    }

    ParagraphProperties {
        alignment,
        indent,
        margin_left,
        margin_right,
        space_before,
        space_after,
        line_spacing,
        bullet,
        tab_stops: Vec::new(),
        default_run_props,
        rtl,
    }
}

/// Parse body properties `<a:bodyPr>`.
fn parse_body_properties(node: Node) -> BodyProperties {
    let anchor = node.attribute("anchor").map(|v| match v {
        "ctr" => VerticalAnchor::Middle,
        "b" => VerticalAnchor::Bottom,
        "just" => VerticalAnchor::MiddleCentered,
        _ => VerticalAnchor::Top,
    }).unwrap_or(VerticalAnchor::Top);

    let anchor_ctr = node.attribute("anchorCtr").map(|v| v == "1").unwrap_or(false);
    let margin_top = node.attribute("insTfm").and_then(|v| v.parse().ok())
        .or_else(|| node.attribute("insT").and_then(|v| v.parse().ok()));
    let margin_bottom = node.attribute("insBm").and_then(|v| v.parse().ok())
        .or_else(|| node.attribute("insB").and_then(|v| v.parse().ok()));
    let margin_left = node.attribute("insLft").and_then(|v| v.parse().ok())
        .or_else(|| node.attribute("insL").and_then(|v| v.parse().ok()));
    let margin_right = node.attribute("insRt").and_then(|v| v.parse().ok())
        .or_else(|| node.attribute("insR").and_then(|v| v.parse().ok()));
    let columns = node.attribute("numCol").and_then(|v| v.parse().ok());
    let column_spacing = node.attribute("spcCol").and_then(|v| v.parse().ok());
    let text_direction = node.attribute("vert").map(|v| match v {
        "vert" => TextDirection::Vertical90,
        "vert270" => TextDirection::Vertical270,
        "wordArtVert" => TextDirection::WordArtVertical,
        "eaVert" => TextDirection::EastAsianVertical,
        "mongolianVert" => TextDirection::MongolianVertical,
        "wordArtVertRtl" => TextDirection::WordArtVerticalRtl,
        _ => TextDirection::Horizontal,
    }).unwrap_or(TextDirection::Horizontal);

    BodyProperties {
        anchor,
        anchor_ctr,
        margin_top,
        margin_bottom,
        margin_left,
        margin_right,
        columns,
        column_spacing,
        text_direction,
    }
}

/// Parse a spacing element (`<a:spcBef>`, `<a:spcAft>`, `<a:lnSpc>`).
fn parse_spacing(node: Node) -> Option<SpacingSpec> {
    for child in node.children() {
        match child.tag_name().name() {
            "spcPts" => {
                if let Some(v) = child.attribute("val").and_then(|v| v.parse().ok()) {
                    return Some(SpacingSpec::Points(v));
                }
            }
            "spcPct" => {
                if let Some(v) = child.attribute("val").and_then(|v| v.parse().ok()) {
                    return Some(SpacingSpec::Percent(v));
                }
            }
            _ => {}
        }
    }
    None
}

fn parse_underline_style(s: &str) -> UnderlineStyle {
    match s {
        "sng" => UnderlineStyle::Single,
        "dbl" => UnderlineStyle::Double,
        "heavy" | "thick" => UnderlineStyle::Thick,
        "dotted" => UnderlineStyle::Dotted,
        "dottedHeavy" => UnderlineStyle::DottedHeavy,
        "dash" => UnderlineStyle::Dash,
        "dashHeavy" => UnderlineStyle::DashHeavy,
        "dashLong" => UnderlineStyle::DashLong,
        "dashLongHeavy" => UnderlineStyle::DashLongHeavy,
        "dotDash" => UnderlineStyle::DotDash,
        "dotDashHeavy" => UnderlineStyle::DotDashHeavy,
        "dotDotDash" => UnderlineStyle::DotDotDash,
        "dotDotDashHeavy" => UnderlineStyle::DotDotDashHeavy,
        "wavy" => UnderlineStyle::Wavy,
        "wavyHeavy" => UnderlineStyle::WavyHeavy,
        "wavyDbl" => UnderlineStyle::WavyDouble,
        "words" => UnderlineStyle::Words,
        _ => UnderlineStyle::None,
    }
}

fn parse_numbering_type(s: &str) -> crate::models::text::NumberingType {
    use crate::models::text::NumberingType;
    match s {
        "arabicPeriod" => NumberingType::ArabicPeriod,
        "arabicParenR" => NumberingType::ArabicParenR,
        "romanUcPeriod" => NumberingType::RomanUcPeriod,
        "romanLcPeriod" => NumberingType::RomanLcPeriod,
        "alphaUcPeriod" => NumberingType::AlphaUcPeriod,
        "alphaLcPeriod" => NumberingType::AlphaLcPeriod,
        _ => NumberingType::ArabicPeriod,
    }
}

/// Extract hyperlink from an `<a:rPr>` node (via hlinkClick or hlinkMouseOver).
fn parse_hyperlink_from_rpr(node: Node, rels: &RelationshipMap) -> Option<Hyperlink> {
    for child in node.children() {
        let name = child.tag_name().name();
        if name == "hlinkClick" || name == "hlinkMouseOver" {
            let rid = child.attribute_ns(
                "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
                "id",
            ).or_else(|| child.attribute("r:id"))?;
            let tooltip = child.attribute("tooltip").map(str::to_string);
            let rel = rels.get(rid)?;
            let target = parse_hyperlink_target(&rel.target, rel.rel_type.ends_with("hyperlink"));
            return Some(Hyperlink { target, tooltip, highlight_click: false, end_sound: None });
        }
    }
    None
}

/// Parse a hyperlink target string into a typed HyperlinkTarget.
pub fn parse_hyperlink_target(target: &str, is_external: bool) -> HyperlinkTarget {
    if is_external {
        return HyperlinkTarget::Url(target.to_string());
    }
    match target {
        "ppaction://hlinksldjump" => HyperlinkTarget::NextSlide,
        "ppaction://hlinkprevslide" => HyperlinkTarget::PreviousSlide,
        "ppaction://hlinknextslide" => HyperlinkTarget::NextSlide,
        "ppaction://hlinkfirstslide" => HyperlinkTarget::FirstSlide,
        "ppaction://hlinklastslide" => HyperlinkTarget::LastSlide,
        "ppaction://hlinkendshow" => HyperlinkTarget::EndShow,
        other if other.starts_with("http") => HyperlinkTarget::Url(other.to_string()),
        other => HyperlinkTarget::File(other.to_string()),
    }
}

/// Parse a field type from a `<a:fld>` node.
fn parse_field_type(node: Node) -> FieldType {
    let type_str = node.attribute("type").unwrap_or("");
    match type_str {
        "slidenum" | "SLIDENUM" => FieldType::SlideNumber,
        "slidename" | "SLIDENAME" => FieldType::SlideName,
        t if t.contains("date") || t.contains("DATE") || t.contains("time") || t.contains("TIME") => {
            FieldType::DateTime { format: t.to_string() }
        }
        other => FieldType::Custom(other.to_string()),
    }
}
