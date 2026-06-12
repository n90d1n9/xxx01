//! Chart metadata extracted from `xl/charts/chart*.xml`.

use crate::xml_util::attr;
use quick_xml::events::Event;
use quick_xml::Reader;

#[cfg(feature = "serde-support")]
use serde::{Deserialize, Serialize};

// ── ChartType ─────────────────────────────────────────────────────────────────

/// High-level chart type classification.
#[derive(Debug, Clone, PartialEq, Eq)]
#[cfg_attr(feature = "serde-support", derive(Serialize, Deserialize))]
pub enum ChartType {
    // Column / Bar
    Bar,
    Bar3D,
    // Line
    Line,
    Line3D,
    // Pie
    Pie,
    Pie3D,
    DoughnutChart,
    // Area
    Area,
    Area3D,
    // Scatter / Bubble
    Scatter,
    Bubble,
    // Stock
    Stock,
    // Radar
    Radar,
    // Surface
    Surface,
    Surface3D,
    // Combo (multiple series types)
    Combo,
    // Unrecognised tag
    Unknown(String),
}

impl ChartType {
    /// Parse from the XML element name used inside `<c:plotArea>`.
    pub fn from_xml_tag(tag: &str) -> Self {
        match tag {
            "barChart" => Self::Bar,
            "bar3DChart" => Self::Bar3D,
            "lineChart" => Self::Line,
            "line3DChart" => Self::Line3D,
            "pieChart" => Self::Pie,
            "pie3DChart" => Self::Pie3D,
            "doughnutChart" => Self::DoughnutChart,
            "areaChart" => Self::Area,
            "area3DChart" => Self::Area3D,
            "scatterChart" => Self::Scatter,
            "bubbleChart" => Self::Bubble,
            "stockChart" => Self::Stock,
            "radarChart" => Self::Radar,
            "surfaceChart" => Self::Surface,
            "surface3DChart" => Self::Surface3D,
            other => Self::Unknown(other.to_owned()),
        }
    }

    /// Human-readable name.
    pub fn display_name(&self) -> &str {
        match self {
            Self::Bar => "Bar/Column",
            Self::Bar3D => "3-D Bar/Column",
            Self::Line => "Line",
            Self::Line3D => "3-D Line",
            Self::Pie => "Pie",
            Self::Pie3D => "3-D Pie",
            Self::DoughnutChart => "Doughnut",
            Self::Area => "Area",
            Self::Area3D => "3-D Area",
            Self::Scatter => "Scatter (XY)",
            Self::Bubble => "Bubble",
            Self::Stock => "Stock",
            Self::Radar => "Radar",
            Self::Surface => "Surface",
            Self::Surface3D => "3-D Surface",
            Self::Combo => "Combo",
            Self::Unknown(s) => s,
        }
    }
}

// ── AxisType / AxisPosition ───────────────────────────────────────────────────

/// Whether an axis is categorical, numeric or date-based.
#[derive(Debug, Clone, PartialEq, Eq)]
#[cfg_attr(feature = "serde-support", derive(Serialize, Deserialize))]
pub enum AxisType {
    Category,
    Value,
    Date,
    Series,
}

/// Where the axis is placed relative to the plot area.
#[derive(Debug, Clone, PartialEq, Eq)]
#[cfg_attr(feature = "serde-support", derive(Serialize, Deserialize))]
pub enum AxisPosition {
    Bottom,
    Top,
    Left,
    Right,
}

// ── ChartAxis ────────────────────────────────────────────────────────────────

/// A single chart axis.
#[derive(Debug, Clone, Default, PartialEq)]
#[cfg_attr(feature = "serde-support", derive(Serialize, Deserialize))]
pub struct ChartAxis {
    /// Axis ID (matches Excel's internal numbering).
    pub id: u32,
    /// Axis type.
    pub axis_type: Option<AxisType>,
    /// Axis title.
    pub title: Option<String>,
    /// Display position.
    pub position: Option<AxisPosition>,
    /// Number format code (e.g. `"0.00"`).
    pub number_format: Option<String>,
    /// Minimum scale value.
    pub min: Option<f64>,
    /// Maximum scale value.
    pub max: Option<f64>,
    /// Major unit.
    pub major_unit: Option<f64>,
    /// Minor unit.
    pub minor_unit: Option<f64>,
    /// Whether the axis is visible.
    pub visible: bool,
    /// Whether the axis is reversed.
    pub reversed: bool,
    /// Whether gridlines are shown for this axis.
    pub major_gridlines: bool,
    pub minor_gridlines: bool,
}

// ── SeriesDataRef ─────────────────────────────────────────────────────────────

/// A reference to data on a worksheet (e.g. `Sheet1!$A$1:$A$10`).
#[derive(Debug, Clone, Default, PartialEq)]
#[cfg_attr(feature = "serde-support", derive(Serialize, Deserialize))]
pub struct SeriesDataRef {
    /// The formula reference string.
    pub formula: String,
    /// Cached literal values (if present in the XML).
    pub cache: Vec<String>,
}

// ── ChartSeries ───────────────────────────────────────────────────────────────

/// A single data series in a chart.
#[derive(Debug, Clone, Default, PartialEq)]
#[cfg_attr(feature = "serde-support", derive(Serialize, Deserialize))]
pub struct ChartSeries {
    /// Series order index.
    pub order: u32,
    /// Series name (may be a cell reference or literal text).
    pub name: Option<String>,
    /// Cell reference for the series name.
    pub name_ref: Option<String>,
    /// Category (X-axis) data reference.
    pub categories: Option<SeriesDataRef>,
    /// Value (Y-axis) data reference.
    pub values: Option<SeriesDataRef>,
    /// Bubble-size data reference (bubble charts only).
    pub bubble_size: Option<SeriesDataRef>,
    /// Series colour (ARGB hex, e.g. `"FF4472C4"`).
    pub color: Option<String>,
    /// Marker style for line/scatter charts.
    pub marker_style: Option<String>,
    /// Whether a smooth line is used.
    pub smooth: bool,
    /// Whether data labels are shown.
    pub data_labels: bool,
    /// Trendline type if present.
    pub trendline: Option<String>,
}

// ── ChartLegend ───────────────────────────────────────────────────────────────

/// Chart legend settings.
#[derive(Debug, Clone, Default, PartialEq)]
#[cfg_attr(feature = "serde-support", derive(Serialize, Deserialize))]
pub struct ChartLegend {
    /// Position: `"b"`, `"t"`, `"l"`, `"r"`, `"tr"`.
    pub position: Option<String>,
    /// Whether the legend overlaps the plot area.
    pub overlay: bool,
}

// ── Chart ─────────────────────────────────────────────────────────────────────

/// Complete metadata for one chart object embedded in a worksheet.
#[derive(Debug, Clone, PartialEq)]
#[cfg_attr(feature = "serde-support", derive(Serialize, Deserialize))]
pub struct Chart {
    /// Archive path where this chart XML was read from.
    pub source_path: String,
    /// Primary chart type, or combo when multiple chart families are present.
    pub chart_type: ChartType,
    /// All chart types detected inside the plot area.
    pub chart_types: Vec<ChartType>,
    /// Optional chart title text.
    pub title: Option<String>,
    /// Data series described by the chart XML.
    pub series: Vec<ChartSeries>,
    /// Axes declared by the chart XML.
    pub axes: Vec<ChartAxis>,
    /// Optional legend settings.
    pub legend: Option<ChartLegend>,
    /// Whether the chart includes a data table.
    pub data_table: bool,
    /// Whether the chart uses a 3D chart family.
    pub has_3d: bool,
    /// Plot-area background color when present.
    pub plot_bg_color: Option<String>,
    /// Chart background color when present.
    pub chart_bg_color: Option<String>,
}

// ── XML parser ────────────────────────────────────────────────────────────────

impl Chart {
    /// Parse a `chart.xml` file content into a `Chart`.
    #[allow(dead_code)]
    pub(crate) fn from_xml(xml: &str, source_path: &str) -> Self {
        let mut reader = Reader::from_str(xml);
        reader.trim_text(true);

        let mut chart = Chart {
            source_path: source_path.to_owned(),
            chart_type: ChartType::Unknown(String::new()),
            chart_types: vec![],
            title: None,
            series: vec![],
            axes: vec![],
            legend: None,
            data_table: false,
            has_3d: false,
            plot_bg_color: None,
            chart_bg_color: None,
        };

        let mut buf = Vec::new();
        let mut in_title = false;
        let mut in_ser = false;
        let mut current_ser = ChartSeries::default();
        let mut in_axis = false;
        let mut current_axis = ChartAxis::default();
        let mut in_legend = false;
        let mut legend = ChartLegend::default();
        let mut title_buf = String::new();

        loop {
            match reader.read_event_into(&mut buf) {
                Ok(Event::Start(ref e)) => {
                    let name = String::from_utf8_lossy(e.name().as_ref()).into_owned();
                    match name.as_str() {
                        // Chart type detection
                        n if matches!(
                            n,
                            "c:barChart"
                                | "c:bar3DChart"
                                | "c:lineChart"
                                | "c:line3DChart"
                                | "c:pieChart"
                                | "c:pie3DChart"
                                | "c:doughnutChart"
                                | "c:areaChart"
                                | "c:area3DChart"
                                | "c:scatterChart"
                                | "c:bubbleChart"
                                | "c:stockChart"
                                | "c:radarChart"
                                | "c:surfaceChart"
                                | "c:surface3DChart"
                        ) =>
                        {
                            let tag = n.trim_start_matches("c:");
                            let ct = ChartType::from_xml_tag(tag);
                            if chart.chart_types.is_empty() {
                                chart.chart_type = ct.clone();
                            }
                            chart.chart_types.push(ct);
                            if n.contains("3D") {
                                chart.has_3d = true;
                            }
                        }
                        "c:title" => {
                            in_title = true;
                        }
                        "c:ser" => {
                            in_ser = true;
                            current_ser = ChartSeries::default();
                        }
                        "c:catAx" | "c:valAx" | "c:dateAx" | "c:serAx" => {
                            in_axis = true;
                            current_axis = ChartAxis {
                                visible: true,
                                ..Default::default()
                            };
                            current_axis.axis_type = Some(match name.trim_start_matches("c:") {
                                "catAx" => AxisType::Category,
                                "valAx" => AxisType::Value,
                                "dateAx" => AxisType::Date,
                                _ => AxisType::Series,
                            });
                        }
                        "c:legend" => {
                            in_legend = true;
                            legend = ChartLegend::default();
                        }
                        "c:dTable" => {
                            chart.data_table = true;
                        }
                        "c:smooth" if in_ser => {
                            current_ser.smooth = attr(e, "val").as_deref() != Some("0");
                        }
                        "c:dLbls" if in_ser => {
                            current_ser.data_labels = true;
                        }
                        "c:axId" if in_axis => {
                            if let Some(id) = attr(e, "val") {
                                current_axis.id = id.parse().unwrap_or(0);
                            }
                        }
                        "c:axPos" if in_axis => {
                            current_axis.position = attr(e, "val").map(|v| match v.as_str() {
                                "b" => AxisPosition::Bottom,
                                "t" => AxisPosition::Top,
                                "l" => AxisPosition::Left,
                                _ => AxisPosition::Right,
                            });
                        }
                        "c:delete" if in_axis => {
                            current_axis.visible = attr(e, "val").as_deref() != Some("1");
                        }
                        "c:majorGridlines" if in_axis => {
                            current_axis.major_gridlines = true;
                        }
                        "c:minorGridlines" if in_axis => {
                            current_axis.minor_gridlines = true;
                        }
                        "c:scaling" if in_axis => {}
                        "c:legendPos" if in_legend => {
                            legend.position = attr(e, "val");
                        }
                        "c:overlay" if in_legend => {
                            legend.overlay = attr(e, "val").as_deref() == Some("1");
                        }
                        "c:order" if in_ser => {
                            current_ser.order =
                                attr(e, "val").and_then(|v| v.parse().ok()).unwrap_or(0);
                        }
                        _ => {}
                    }
                }

                Ok(Event::Empty(ref e)) => {
                    let name = String::from_utf8_lossy(e.name().as_ref()).into_owned();
                    match name.as_str() {
                        "c:smooth" if in_ser => {
                            current_ser.smooth = attr(e, "val").as_deref() != Some("0");
                        }
                        "c:delete" if in_axis => {
                            current_axis.visible = attr(e, "val").as_deref() != Some("1");
                        }
                        "c:overlay" if in_legend => {
                            legend.overlay = attr(e, "val").as_deref() == Some("1");
                        }
                        "a:srgbClr" => {
                            if let Some(v) = attr(e, "val") {
                                if in_ser && current_ser.color.is_none() {
                                    current_ser.color = Some(v);
                                }
                            }
                        }
                        _ => {}
                    }
                }

                Ok(Event::End(ref e)) => {
                    let name = String::from_utf8_lossy(e.name().as_ref()).into_owned();
                    match name.as_str() {
                        "c:title" => {
                            in_title = false;
                            if !title_buf.is_empty() {
                                chart.title = Some(std::mem::take(&mut title_buf));
                            }
                        }
                        "c:ser" => {
                            in_ser = false;
                            chart.series.push(std::mem::take(&mut current_ser));
                        }
                        "c:catAx" | "c:valAx" | "c:dateAx" | "c:serAx" => {
                            in_axis = false;
                            chart.axes.push(std::mem::take(&mut current_axis));
                        }
                        "c:legend" => {
                            in_legend = false;
                            chart.legend = Some(std::mem::take(&mut legend));
                        }
                        _ => {}
                    }
                }

                Ok(Event::Text(t)) => {
                    let text = t.unescape().unwrap_or_default().into_owned();
                    if in_title {
                        title_buf.push_str(&text);
                    }
                }

                Ok(Event::Eof) | Err(_) => break,
                _ => {}
            }
            buf.clear();
        }

        // Detect combo (more than one unique chart type)
        if chart.chart_types.len() > 1 {
            chart.chart_type = ChartType::Combo;
        }

        chart
    }
}
