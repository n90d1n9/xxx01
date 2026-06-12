use serde::{Deserialize, Serialize};
use crate::models::color::ColorSpec;

/// A chart embedded in a slide.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Chart {
    pub chart_type: ChartType,
    pub title: Option<String>,
    pub series: Vec<ChartSeries>,
    pub axes: Vec<ChartAxis>,
    pub legend: Option<ChartLegend>,
    pub plot_area: PlotArea,
    /// Whether the chart has 3D perspective.
    pub is_3d: bool,
    /// Whether data labels are shown.
    pub show_data_labels: bool,
    pub data_labels: Option<DataLabels>,
    /// Chart style index (1-48 in OOXML).
    pub style: Option<u8>,
    /// Whether to show grid lines.
    pub show_grid_lines: bool,
}

impl Chart {
    /// Extract all categories (X-axis labels) if available.
    pub fn categories(&self) -> Vec<String> {
        self.series.first()
            .and_then(|s| s.categories.as_ref())
            .cloned()
            .unwrap_or_default()
    }

    /// Get the number of data series.
    pub fn series_count(&self) -> usize {
        self.series.len()
    }

    /// Convert chart data to a 2D matrix for easy consumption.
    /// Rows = series, columns = data points.
    pub fn to_matrix(&self) -> Vec<Vec<f64>> {
        self.series.iter()
            .map(|s| s.values.iter().map(|v| v.unwrap_or(0.0)).collect())
            .collect()
    }
}

/// Chart type enumeration covering all DrawingML chart types.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum ChartType {
    // Bar / Column charts
    BarClustered,
    BarStacked,
    BarStacked100,
    ColumnClustered,
    ColumnStacked,
    ColumnStacked100,
    // Bar 3D
    Bar3DClustered,
    Bar3DStacked,
    Bar3DStacked100,
    Column3DClustered,
    Column3DStacked,
    Column3DStacked100,
    // Line charts
    Line,
    LineStacked,
    LineStacked100,
    LineMarker,
    LineMarkerStacked,
    LineMarkerStacked100,
    Line3D,
    // Pie charts
    Pie,
    Pie3D,
    PieExploded,
    PieExploded3D,
    DoughnutChart,
    DoughnutExploded,
    // Area charts
    Area,
    AreaStacked,
    AreaStacked100,
    Area3D,
    Area3DStacked,
    Area3DStacked100,
    // Scatter / Bubble
    ScatterMarkers,
    ScatterStraightLines,
    ScatterStraightLinesMarkers,
    ScatterSmoothLines,
    ScatterSmoothLinesMarkers,
    Bubble,
    Bubble3D,
    // Stock / Financial
    StockHLC,   // High-Low-Close
    StockOHLC,  // Open-High-Low-Close
    StockVHLC,  // Volume-High-Low-Close
    StockVOHLC, // Volume-Open-High-Low-Close
    // Radar / Spider
    Radar,
    RadarMarkers,
    RadarFilled,
    // Surface
    Surface3D,
    SurfaceWireframe,
    Surface3DWireframe,
    // Combo chart
    Combo,
    // Unknown
    Unknown(String),
}

/// A single data series in a chart.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChartSeries {
    pub name: Option<String>,
    pub index: u32,
    pub order: u32,
    /// Category labels (shared across series, usually only on series[0]).
    pub categories: Option<Vec<String>>,
    /// Numeric data values (None = missing/empty cell).
    pub values: Vec<Option<f64>>,
    /// For bubble charts: bubble sizes.
    pub bubble_sizes: Option<Vec<Option<f64>>>,
    /// For scatter charts: X values.
    pub x_values: Option<Vec<Option<f64>>>,
    pub fill: Option<ColorSpec>,
    pub line_color: Option<ColorSpec>,
    pub marker: Option<DataMarker>,
    pub data_labels: Option<DataLabels>,
    pub smooth: bool,
}

/// Data point marker.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DataMarker {
    pub symbol: MarkerSymbol,
    pub size: u32,
    pub fill: Option<ColorSpec>,
    pub line_color: Option<ColorSpec>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum MarkerSymbol {
    Circle, Square, Diamond, Triangle, Star, X, Plus, Dash, Dot, Auto, None,
}

/// Chart axis definition.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChartAxis {
    pub axis_id: u32,
    pub axis_type: AxisType,
    pub title: Option<String>,
    pub min: Option<f64>,
    pub max: Option<f64>,
    pub major_unit: Option<f64>,
    pub minor_unit: Option<f64>,
    pub number_format: Option<String>,
    pub position: AxisPosition,
    pub crosses: AxisCrosses,
    pub reverse_order: bool,
    pub log_scale: Option<f64>,
    pub major_grid_lines: bool,
    pub minor_grid_lines: bool,
    pub visible: bool,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum AxisType { Category, Value, Date, Series }

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum AxisPosition { Left, Right, Top, Bottom }

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum AxisCrosses { AutoZero, Max, Min, CrossesAt(f64) }

/// Chart legend.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChartLegend {
    pub position: LegendPosition,
    pub overlay: bool,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum LegendPosition { Bottom, Left, Right, Top, TopRight }

/// Data labels configuration.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DataLabels {
    pub show_value: bool,
    pub show_series_name: bool,
    pub show_category_name: bool,
    pub show_percentage: bool,
    pub show_leader_lines: bool,
    pub position: DataLabelPosition,
    pub number_format: Option<String>,
    pub separator: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum DataLabelPosition {
    BestFit, Center, InsideBase, InsideEnd, Left, OutsideEnd,
    Right, Top, Bottom,
}

/// Chart plot area configuration.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlotArea {
    pub fill: Option<crate::models::geometry::FillType>,
    pub border: Option<crate::models::geometry::LineProperties>,
}

impl Default for PlotArea {
    fn default() -> Self { PlotArea { fill: None, border: None } }
}
