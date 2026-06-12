use crate::scene::{Rect, Transform};
use serde::{Deserialize, Serialize};

// ── Fill / Stroke styles ──────────────────────────────────────────────────────

/// A CSS-style colour string (e.g. "#RRGGBB", "rgba(…)", named colours).
pub type Color = String;

/// Convert a hex colour string (e.g. "#ff00aa") to a `Color`.
pub fn color_from_hex(hex: &str) -> Color {
    // In a full implementation we would validate the format.
    hex.to_string()
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum Fill {
    None,
    Solid(Color),
    LinearGradient {
        angle_deg: f64,
        stops: Vec<(f64, Color)>, // (offset 0..1, color)
    },
    RadialGradient {
        stops: Vec<(f64, Color)>,
    },
    Image {
        src: String,
        fit: ImageFit,
    },
}

impl Default for Fill {
    fn default() -> Self {
        Fill::None
    }
}

#[derive(Debug, Clone, PartialEq, Default, Serialize, Deserialize)]
pub enum ImageFit {
    #[default]
    Cover,
    Contain,
    Fill,
    None,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Stroke {
    pub color: Color,
    pub width: f64,
    pub dash: StrokeDash,
}

impl Default for Stroke {
    fn default() -> Self {
        Self {
            color: "#000000".into(),
            width: 1.0,
            dash: StrokeDash::Solid,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Default, Serialize, Deserialize)]
pub enum StrokeDash {
    #[default]
    Solid,
    Dashed,
    Dotted,
}

// ── Text content inside a shape ───────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TextRun {
    pub text: String,
    pub bold: bool,
    pub italic: bool,
    pub underline: bool,
    pub font_size: f64,
    pub font_family: String,
    pub color: Color,
}

impl Default for TextRun {
    fn default() -> Self {
        Self {
            text: String::new(),
            bold: false,
            italic: false,
            underline: false,
            font_size: 18.0,
            font_family: "Inter".into(),
            color: "#000000".into(),
        }
    }
}

#[derive(Debug, Clone, PartialEq, Default, Serialize, Deserialize)]
pub enum TextAlign {
    #[default]
    Left,
    Center,
    Right,
    Justify,
}

#[derive(Debug, Clone, PartialEq, Default, Serialize, Deserialize)]
pub struct TextBox {
    pub runs: Vec<TextRun>,
    pub align: TextAlign,
    pub vertical_align: VerticalAlign,
    pub padding: f64,
}

impl TextBox {
    pub fn plain(text: impl Into<String>) -> Self {
        Self {
            runs: vec![TextRun {
                text: text.into(),
                ..Default::default()
            }],
            ..Default::default()
        }
    }

    /// Append a new text run.
    pub fn push_run(&mut self, run: TextRun) {
        self.runs.push(run);
    }

    /// Return the full plain-text content.
    pub fn plain_text(&self) -> String {
        self.runs.iter().map(|r| r.text.as_str()).collect()
    }
}

#[derive(Debug, Clone, PartialEq, Default, Serialize, Deserialize)]
pub enum VerticalAlign {
    #[default]
    Top,
    Middle,
    Bottom,
}

// ── Shape geometry variant ────────────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum Geometry {
    /// Simple rectangle (may have rounded corners).
    Rectangle { corner_radius: f64 },
    /// Ellipse / circle.
    Ellipse,
    /// Straight line from (bounds.origin) to (origin + size).
    Line,
    /// A polygon defined by relative points (0..1 of bounds).
    Polygon { points: Vec<(f64, f64)> },
    /// An SVG path string.
    Path(String),
}

impl Default for Geometry {
    fn default() -> Self {
        Geometry::Rectangle { corner_radius: 0.0 }
    }
}

// ── The Shape itself ──────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Shape {
    pub id: String,
    pub geometry: Geometry,
    pub bounds: Rect,
    /// Local transform applied on top of bounds (e.g. rotation about centre).
    pub transform: Transform,
    pub fill: Fill,
    pub stroke: Option<Stroke>,
    pub opacity: f64,
    /// Optional rich text overlaid on top of the shape.
    pub text: Option<TextBox>,
    /// Whether this shape is locked (not interactive in the editor).
    pub locked: bool,
}

impl Default for Shape {
    fn default() -> Self {
        Self {
            id: String::new(),
            geometry: Geometry::default(),
            bounds: Rect::default(),
            transform: Transform::identity(),
            fill: Fill::default(),
            stroke: None,
            opacity: 1.0,
            text: None,
            locked: false,
        }
    }
}

impl Shape {
    pub fn new(id: impl Into<String>, geometry: Geometry, bounds: Rect) -> Self {
        Self {
            id: id.into(),
            geometry,
            bounds,
            ..Default::default()
        }
    }

    /// Convenience: rectangle with solid fill.
    pub fn rect(id: impl Into<String>, bounds: Rect, color: impl Into<Color>) -> Self {
        Self {
            id: id.into(),
            geometry: Geometry::Rectangle { corner_radius: 0.0 },
            bounds,
            fill: Fill::Solid(color.into()),
            ..Default::default()
        }
    }

    /// Convenience: text box with plain text.
    pub fn text_box(id: impl Into<String>, bounds: Rect, text: impl Into<String>) -> Self {
        Self {
            id: id.into(),
            geometry: Geometry::Rectangle { corner_radius: 4.0 },
            bounds,
            text: Some(TextBox::plain(text)),
            ..Default::default()
        }
    }

    /// Apply a rotation (degrees) about the shape's centre.
    pub fn set_rotation(&mut self, degrees: f64) {
        // Build: translate to origin → rotate → translate back
        let c = self.bounds.centre();
        let to_origin = Transform::translation(-c.x, -c.y);
        let rot = Transform::rotation_degrees(degrees);
        let back = Transform::translation(c.x, c.y);
        self.transform = to_origin.then(&rot).then(&back);
    }

    /// Hit-test a point in slide coordinates (ignores rotation for simplicity).
    pub fn hit_test(&self, pt: crate::scene::Point) -> bool {
        self.bounds.contains(pt)
    }
}
