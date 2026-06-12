use roxmltree::{Document, Node};
use crate::error::{PptxError, Result};
use crate::models::chart::*;

/// Parse a chart XML file (ppt/charts/chartN.xml) into a Chart model.
pub fn parse_chart(xml: &str) -> Result<Chart> {
    let doc = Document::parse(xml)
        .map_err(|e| PptxError::ChartParse(e.to_string()))?;

    let root = doc.root_element();

    // Navigate: c:chartSpace > c:chart > c:plotArea
    let chart_node = find_descendant(root, "chart")
        .ok_or_else(|| PptxError::ChartParse("Missing <c:chart> element".into()))?;

    let title = extract_chart_title(chart_node);
    let auto_title_deleted = chart_node.children()
        .find(|n| n.tag_name().name() == "autoTitleDeleted")
        .and_then(|n| n.attribute("val"))
        .map(|v| v == "1")
        .unwrap_or(false);

    let plot_area = chart_node.children()
        .find(|n| n.tag_name().name() == "plotArea")
        .ok_or_else(|| PptxError::ChartParse("Missing <c:plotArea>".into()))?;

    let (chart_type, series, is_3d) = parse_plot_area(plot_area)?;

    let axes = parse_axes(plot_area);

    let legend = chart_node.children()
        .find(|n| n.tag_name().name() == "legend")
        .map(parse_legend);

    let show_data_labels = false;
    let style = root.children()
        .find(|n| n.tag_name().name() == "style")
        .and_then(|n| n.attribute("val"))
        .and_then(|v| v.parse().ok());

    let show_grid_lines = plot_area.children()
        .any(|n| n.tag_name().name() == "valAx" && n.children()
            .any(|c| c.tag_name().name() == "majorGridlines"));

    Ok(Chart {
        chart_type,
        title: if auto_title_deleted { None } else { title },
        series,
        axes,
        legend,
        plot_area: PlotArea::default(),
        is_3d,
        show_data_labels,
        data_labels: None,
        style,
        show_grid_lines,
    })
}

/// Extract chart title text.
fn extract_chart_title(chart_node: Node) -> Option<String> {
    let title_node = chart_node.children().find(|n| n.tag_name().name() == "title")?;

    // Try <c:tx><c:rich> first (rich text title)
    if let Some(tx) = title_node.children().find(|n| n.tag_name().name() == "tx") {
        if let Some(rich) = tx.children().find(|n| n.tag_name().name() == "rich") {
            let text: String = rich.descendants()
                .filter(|n| n.tag_name().name() == "t")
                .filter_map(|n| n.text())
                .collect();
            if !text.is_empty() { return Some(text); }
        }
        // Try string reference
        if let Some(str_ref) = tx.descendants().find(|n| n.tag_name().name() == "f") {
            return str_ref.text().map(str::to_string);
        }
    }
    None
}

/// Parse the plot area into chart type, series, and 3D flag.
fn parse_plot_area(plot_area: Node) -> Result<(ChartType, Vec<ChartSeries>, bool)> {
    let mut chart_type = ChartType::Unknown("unknown".into());
    let mut series = Vec::new();
    let mut is_3d = false;

    for child in plot_area.children() {
        let tag = child.tag_name().name();
        let (ct, ser, d3) = match tag {
            "barChart" => parse_bar_chart(child, false),
            "bar3DChart" => { is_3d = true; parse_bar_chart(child, true) }
            "lineChart" => parse_line_chart(child, false),
            "line3DChart" => { is_3d = true; parse_line_chart(child, true) }
            "pieChart" => parse_pie_chart(child, false),
            "pie3DChart" => { is_3d = true; parse_pie_chart(child, true) }
            "doughnutChart" => parse_doughnut_chart(child),
            "areaChart" => parse_area_chart(child, false),
            "area3DChart" => { is_3d = true; parse_area_chart(child, true) }
            "scatterChart" => parse_scatter_chart(child),
            "bubbleChart" => parse_bubble_chart(child),
            "radarChart" => parse_radar_chart(child),
            "surfaceChart" | "surface3DChart" => {
                is_3d = tag == "surface3DChart";
                (ChartType::Surface3D, parse_series_generic(child), is_3d)
            }
            "stockChart" => parse_stock_chart(child),
            _ => continue,
        };
        chart_type = ct;
        series = ser;
    }

    Ok((chart_type, series, is_3d))
}

fn parse_bar_chart(node: Node, is_3d: bool) -> (ChartType, Vec<ChartSeries>, bool) {
    let bar_dir = node.children()
        .find(|n| n.tag_name().name() == "barDir")
        .and_then(|n| n.attribute("val"))
        .unwrap_or("col");
    let grouping = node.children()
        .find(|n| n.tag_name().name() == "grouping")
        .and_then(|n| n.attribute("val"))
        .unwrap_or("clustered");

    let chart_type = if is_3d {
        match (bar_dir, grouping) {
            ("bar", "clustered") => ChartType::Bar3DClustered,
            ("bar", "stacked") => ChartType::Bar3DStacked,
            ("bar", "percentStacked") => ChartType::Bar3DStacked100,
            ("col", "clustered") => ChartType::Column3DClustered,
            ("col", "stacked") => ChartType::Column3DStacked,
            ("col", "percentStacked") => ChartType::Column3DStacked100,
            _ => ChartType::Column3DClustered,
        }
    } else {
        match (bar_dir, grouping) {
            ("bar", "clustered") => ChartType::BarClustered,
            ("bar", "stacked") => ChartType::BarStacked,
            ("bar", "percentStacked") => ChartType::BarStacked100,
            ("col", "clustered") => ChartType::ColumnClustered,
            ("col", "stacked") => ChartType::ColumnStacked,
            ("col", "percentStacked") => ChartType::ColumnStacked100,
            _ => ChartType::ColumnClustered,
        }
    };

    (chart_type, parse_series_generic(node), is_3d)
}

fn parse_line_chart(node: Node, is_3d: bool) -> (ChartType, Vec<ChartSeries>, bool) {
    if is_3d {
        return (ChartType::Line3D, parse_series_generic(node), true);
    }
    let grouping = node.children()
        .find(|n| n.tag_name().name() == "grouping")
        .and_then(|n| n.attribute("val"))
        .unwrap_or("standard");

    let has_markers = node.descendants()
        .any(|n| n.tag_name().name() == "marker" && n.children()
            .any(|c| c.tag_name().name() == "symbol" && c.attribute("val") != Some("none")));

    let chart_type = match grouping {
        "stacked" => if has_markers { ChartType::LineMarkerStacked } else { ChartType::LineStacked },
        "percentStacked" => if has_markers { ChartType::LineMarkerStacked100 } else { ChartType::LineStacked100 },
        _ => if has_markers { ChartType::LineMarker } else { ChartType::Line },
    };
    (chart_type, parse_series_generic(node), false)
}

fn parse_pie_chart(node: Node, is_3d: bool) -> (ChartType, Vec<ChartSeries>, bool) {
    let exploded = node.descendants()
        .any(|n| n.tag_name().name() == "explosion" &&
            n.attribute("val").and_then(|v| v.parse::<u32>().ok()).unwrap_or(0) > 0);
    let ct = match (is_3d, exploded) {
        (true, true) => ChartType::PieExploded3D,
        (true, false) => ChartType::Pie3D,
        (false, true) => ChartType::PieExploded,
        (false, false) => ChartType::Pie,
    };
    (ct, parse_series_generic(node), is_3d)
}

fn parse_doughnut_chart(node: Node) -> (ChartType, Vec<ChartSeries>, bool) {
    (ChartType::DoughnutChart, parse_series_generic(node), false)
}

fn parse_area_chart(node: Node, is_3d: bool) -> (ChartType, Vec<ChartSeries>, bool) {
    let grouping = node.children()
        .find(|n| n.tag_name().name() == "grouping")
        .and_then(|n| n.attribute("val"))
        .unwrap_or("standard");
    let ct = if is_3d {
        match grouping {
            "stacked" => ChartType::Area3DStacked,
            "percentStacked" => ChartType::Area3DStacked100,
            _ => ChartType::Area3D,
        }
    } else {
        match grouping {
            "stacked" => ChartType::AreaStacked,
            "percentStacked" => ChartType::AreaStacked100,
            _ => ChartType::Area,
        }
    };
    (ct, parse_series_generic(node), is_3d)
}

fn parse_scatter_chart(node: Node) -> (ChartType, Vec<ChartSeries>, bool) {
    let style = node.children()
        .find(|n| n.tag_name().name() == "scatterStyle")
        .and_then(|n| n.attribute("val"))
        .unwrap_or("marker");
    let ct = match style {
        "line" => ChartType::ScatterStraightLines,
        "lineMarker" => ChartType::ScatterStraightLinesMarkers,
        "smooth" => ChartType::ScatterSmoothLines,
        "smoothMarker" => ChartType::ScatterSmoothLinesMarkers,
        _ => ChartType::ScatterMarkers,
    };
    (ct, parse_scatter_series(node), false)
}

fn parse_bubble_chart(node: Node) -> (ChartType, Vec<ChartSeries>, bool) {
    let is_3d = node.children()
        .any(|n| n.tag_name().name() == "bubble3D" && n.attribute("val") == Some("1"));
    let ct = if is_3d { ChartType::Bubble3D } else { ChartType::Bubble };
    (ct, parse_bubble_series(node), false)
}

fn parse_radar_chart(node: Node) -> (ChartType, Vec<ChartSeries>, bool) {
    let style = node.children()
        .find(|n| n.tag_name().name() == "radarStyle")
        .and_then(|n| n.attribute("val"))
        .unwrap_or("standard");
    let ct = match style {
        "marker" => ChartType::RadarMarkers,
        "filled" => ChartType::RadarFilled,
        _ => ChartType::Radar,
    };
    (ct, parse_series_generic(node), false)
}

fn parse_stock_chart(node: Node) -> (ChartType, Vec<ChartSeries>, bool) {
    // Determine stock chart sub-type by number of series
    let ser_count = node.children().filter(|n| n.tag_name().name() == "ser").count();
    let ct = match ser_count {
        3 => ChartType::StockHLC,
        4 => ChartType::StockOHLC,
        5 => ChartType::StockVHLC,
        6 => ChartType::StockVOHLC,
        _ => ChartType::StockHLC,
    };
    (ct, parse_series_generic(node), false)
}

/// Parse series nodes generically (used by bar, line, pie, area, radar, etc.)
pub fn parse_series_generic(chart_node: Node) -> Vec<ChartSeries> {
    let mut series = Vec::new();
    for ser_node in chart_node.children().filter(|n| n.tag_name().name() == "ser") {
        let index = ser_node.children()
            .find(|n| n.tag_name().name() == "idx")
            .and_then(|n| n.attribute("val"))
            .and_then(|v| v.parse().ok())
            .unwrap_or(0);
        let order = ser_node.children()
            .find(|n| n.tag_name().name() == "order")
            .and_then(|n| n.attribute("val"))
            .and_then(|v| v.parse().ok())
            .unwrap_or(0);
        let name = extract_series_name(ser_node);
        let categories = extract_cat_labels(ser_node);
        let values = extract_numeric_values(ser_node, "val");
        let smooth = ser_node.children()
            .find(|n| n.tag_name().name() == "smooth")
            .and_then(|n| n.attribute("val"))
            .map(|v| v == "1" || v == "true")
            .unwrap_or(false);

        series.push(ChartSeries {
            name,
            index,
            order,
            categories,
            values,
            bubble_sizes: None,
            x_values: None,
            fill: None,
            line_color: None,
            marker: None,
            data_labels: None,
            smooth,
        });
    }
    series
}

/// Parse scatter series (has xVal and yVal instead of cat/val).
fn parse_scatter_series(chart_node: Node) -> Vec<ChartSeries> {
    let mut series = Vec::new();
    for ser_node in chart_node.children().filter(|n| n.tag_name().name() == "ser") {
        let index = get_attr_u32(ser_node, "idx");
        let order = get_attr_u32(ser_node, "order");
        let name = extract_series_name(ser_node);
        let x_values = Some(extract_numeric_values(ser_node, "xVal"));
        let values = extract_numeric_values(ser_node, "yVal");

        series.push(ChartSeries {
            name, index, order,
            categories: None, values, bubble_sizes: None, x_values,
            fill: None, line_color: None, marker: None, data_labels: None, smooth: false,
        });
    }
    series
}

/// Parse bubble chart series (has xVal, yVal, bubbleSize).
fn parse_bubble_series(chart_node: Node) -> Vec<ChartSeries> {
    let mut series = Vec::new();
    for ser_node in chart_node.children().filter(|n| n.tag_name().name() == "ser") {
        let index = get_attr_u32(ser_node, "idx");
        let order = get_attr_u32(ser_node, "order");
        let name = extract_series_name(ser_node);
        let x_values = Some(extract_numeric_values(ser_node, "xVal"));
        let values = extract_numeric_values(ser_node, "yVal");
        let bubble_sizes = Some(extract_numeric_values(ser_node, "bubbleSize"));

        series.push(ChartSeries {
            name, index, order,
            categories: None, values, bubble_sizes, x_values,
            fill: None, line_color: None, marker: None, data_labels: None, smooth: false,
        });
    }
    series
}

/// Extract series name (from <c:tx> or its string ref).
fn extract_series_name(ser_node: Node) -> Option<String> {
    let tx = ser_node.children().find(|n| n.tag_name().name() == "tx")?;
    // Try strRef first
    if let Some(str_ref) = tx.children().find(|n| n.tag_name().name() == "strRef") {
        if let Some(cache) = str_ref.children().find(|n| n.tag_name().name() == "strCache") {
            let text: String = cache.descendants()
                .filter(|n| n.tag_name().name() == "v")
                .filter_map(|n| n.text())
                .collect();
            if !text.is_empty() { return Some(text); }
        }
    }
    // Try numRef
    if let Some(num_ref) = tx.children().find(|n| n.tag_name().name() == "numRef") {
        if let Some(f) = num_ref.children().find(|n| n.tag_name().name() == "f") {
            return f.text().map(str::to_string);
        }
    }
    None
}

/// Extract category labels from a series.
fn extract_cat_labels(ser_node: Node) -> Option<Vec<String>> {
    let cat = ser_node.children().find(|n| n.tag_name().name() == "cat")?;
    let mut labels = Vec::new();

    // String reference cache
    if let Some(str_ref) = cat.children().find(|n| n.tag_name().name() == "strRef") {
        if let Some(cache) = str_ref.children().find(|n| n.tag_name().name() == "strCache") {
            for pt in cache.children().filter(|n| n.tag_name().name() == "pt") {
                if let Some(text) = pt.children().find(|n| n.tag_name().name() == "v").and_then(|n| n.text()) {
                    labels.push(text.to_string());
                }
            }
            if !labels.is_empty() { return Some(labels); }
        }
    }

    // Numeric reference cache (convert numbers to strings)
    if let Some(num_ref) = cat.children().find(|n| n.tag_name().name() == "numRef") {
        if let Some(cache) = num_ref.children().find(|n| n.tag_name().name() == "numCache") {
            for pt in cache.children().filter(|n| n.tag_name().name() == "pt") {
                if let Some(text) = pt.children().find(|n| n.tag_name().name() == "v").and_then(|n| n.text()) {
                    labels.push(text.to_string());
                }
            }
            if !labels.is_empty() { return Some(labels); }
        }
    }

    None
}

/// Extract numeric data values for a named element (val, yVal, xVal, bubbleSize).
fn extract_numeric_values(ser_node: Node, elem_name: &str) -> Vec<Option<f64>> {
    let val_node = match ser_node.children().find(|n| n.tag_name().name() == elem_name) {
        Some(n) => n,
        None => return Vec::new(),
    };

    let num_ref = match val_node.children().find(|n| n.tag_name().name() == "numRef") {
        Some(n) => n,
        None => return Vec::new(),
    };

    let cache = match num_ref.children().find(|n| n.tag_name().name() == "numCache") {
        Some(n) => n,
        None => return Vec::new(),
    };

    let pt_count = cache.children()
        .find(|n| n.tag_name().name() == "ptCount")
        .and_then(|n| n.attribute("val"))
        .and_then(|v| v.parse::<usize>().ok())
        .unwrap_or(0);

    let mut values: Vec<Option<f64>> = vec![None; pt_count];
    for pt in cache.children().filter(|n| n.tag_name().name() == "pt") {
        let idx: usize = pt.attribute("idx").and_then(|v| v.parse().ok()).unwrap_or(0);
        let val = pt.children()
            .find(|n| n.tag_name().name() == "v")
            .and_then(|n| n.text())
            .and_then(|v| v.parse().ok());
        if idx < values.len() {
            values[idx] = val;
        } else {
            values.push(val);
        }
    }
    values
}

/// Parse chart axes.
fn parse_axes(plot_area: Node) -> Vec<ChartAxis> {
    let mut axes = Vec::new();
    for child in plot_area.children() {
        let axis_type = match child.tag_name().name() {
            "catAx" => AxisType::Category,
            "valAx" => AxisType::Value,
            "dateAx" => AxisType::Date,
            "serAx" => AxisType::Series,
            _ => continue,
        };

        let axis_id = child.children()
            .find(|n| n.tag_name().name() == "axId")
            .and_then(|n| n.attribute("val"))
            .and_then(|v| v.parse().ok())
            .unwrap_or(0);
        let title = child.children()
            .find(|n| n.tag_name().name() == "title")
            .and_then(|n| extract_axis_title(n));
        let position = child.children()
            .find(|n| n.tag_name().name() == "axPos")
            .and_then(|n| n.attribute("val"))
            .map(|v| match v {
                "r" => AxisPosition::Right,
                "t" => AxisPosition::Top,
                "b" => AxisPosition::Bottom,
                _ => AxisPosition::Left,
            })
            .unwrap_or(AxisPosition::Left);
        let reverse_order = child.children()
            .find(|n| n.tag_name().name() == "scaling")
            .and_then(|n| n.children().find(|c| c.tag_name().name() == "orientation"))
            .and_then(|n| n.attribute("val"))
            .map(|v| v == "maxMin")
            .unwrap_or(false);
        let visible = child.children()
            .find(|n| n.tag_name().name() == "delete")
            .and_then(|n| n.attribute("val"))
            .map(|v| v != "1")
            .unwrap_or(true);
        let major_grid_lines = child.children()
            .any(|n| n.tag_name().name() == "majorGridlines");
        let minor_grid_lines = child.children()
            .any(|n| n.tag_name().name() == "minorGridlines");
        let number_format = child.children()
            .find(|n| n.tag_name().name() == "numFmt")
            .and_then(|n| n.attribute("formatCode"))
            .map(str::to_string);

        let (min, max, major_unit, minor_unit) = parse_axis_scaling(child);

        axes.push(ChartAxis {
            axis_id, axis_type, title,
            min, max, major_unit, minor_unit, number_format,
            position, crosses: AxisCrosses::AutoZero,
            reverse_order, log_scale: None,
            major_grid_lines, minor_grid_lines, visible,
        });
    }
    axes
}

fn extract_axis_title(node: Node) -> Option<String> {
    let text: String = node.descendants()
        .filter(|n| n.tag_name().name() == "t")
        .filter_map(|n| n.text())
        .collect();
    if text.is_empty() { None } else { Some(text) }
}

fn parse_axis_scaling(axis_node: Node) -> (Option<f64>, Option<f64>, Option<f64>, Option<f64>) {
    let scaling = axis_node.children().find(|n| n.tag_name().name() == "scaling");
    let (min, max) = scaling.map(|s| {
        let min = s.children().find(|n| n.tag_name().name() == "min")
            .and_then(|n| n.attribute("val")).and_then(|v| v.parse().ok());
        let max = s.children().find(|n| n.tag_name().name() == "max")
            .and_then(|n| n.attribute("val")).and_then(|v| v.parse().ok());
        (min, max)
    }).unwrap_or((None, None));

    let major_unit = axis_node.children().find(|n| n.tag_name().name() == "majorUnit")
        .and_then(|n| n.attribute("val")).and_then(|v| v.parse().ok());
    let minor_unit = axis_node.children().find(|n| n.tag_name().name() == "minorUnit")
        .and_then(|n| n.attribute("val")).and_then(|v| v.parse().ok());

    (min, max, major_unit, minor_unit)
}

fn parse_legend(node: Node) -> ChartLegend {
    let position = node.children()
        .find(|n| n.tag_name().name() == "legendPos")
        .and_then(|n| n.attribute("val"))
        .map(|v| match v {
            "l" => LegendPosition::Left,
            "r" => LegendPosition::Right,
            "t" => LegendPosition::Top,
            "tr" => LegendPosition::TopRight,
            _ => LegendPosition::Bottom,
        })
        .unwrap_or(LegendPosition::Bottom);
    let overlay = node.children()
        .find(|n| n.tag_name().name() == "overlay")
        .and_then(|n| n.attribute("val"))
        .map(|v| v == "1")
        .unwrap_or(false);
    ChartLegend { position, overlay }
}

// --- Helpers ---

fn find_descendant<'a>(node: Node<'a, 'a>, name: &str) -> Option<Node<'a, 'a>> {
    for child in node.descendants() {
        if child.tag_name().name() == name {
            return Some(child);
        }
    }
    None
}

fn get_attr_u32(node: Node, child_name: &str) -> u32 {
    node.children()
        .find(|n| n.tag_name().name() == child_name)
        .and_then(|n| n.attribute("val"))
        .and_then(|v| v.parse().ok())
        .unwrap_or(0)
}
