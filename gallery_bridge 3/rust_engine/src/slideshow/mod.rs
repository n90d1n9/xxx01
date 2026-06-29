// gallery_bridge_engine/src/slideshow/mod.rs
//
// Slideshow sequencer.
//
// Responsibilities:
//   - Build an ordered playlist from a selection, collection, or smart filter
//   - Store timing and transition settings per slide or globally
//   - Export playlists as JSON (importable by the Flutter player)
//   - Shuffle / sort with various strategies
//   - Auto-select "best" slides from a folder (highest rated, no rejected)

use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::time::Duration;

// ────────────────────────────────────────────────────────────────────────────
// Types
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum Transition {
    None,
    Fade,
    CrossFade,
    SlideLeft,
    SlideRight,
    ZoomIn,
    ZoomOut,
    Ken Burns { zoom_start: f32, zoom_end: f32, pan_x: f32, pan_y: f32 },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SlideConfig {
    pub item_id: i64,
    pub file_path: String,
    pub thumbnail_path: Option<String>,
    pub file_name: String,
    /// Duration this slide is shown (milliseconds).
    pub duration_ms: u64,
    /// Transition INTO this slide (from the previous).
    pub transition: Transition,
    /// Transition duration in milliseconds.
    pub transition_ms: u64,
    /// Caption to overlay (empty = none).
    pub caption: String,
    /// Show EXIF info overlay.
    pub show_exif: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SlideshowConfig {
    pub title: String,
    pub slides: Vec<SlideConfig>,
    /// Loop when the last slide is reached.
    pub loop_playback: bool,
    /// Global default slide duration (ms). Individual slides can override.
    pub default_duration_ms: u64,
    /// Global default transition.
    pub default_transition: Transition,
    /// Default transition duration (ms).
    pub default_transition_ms: u64,
    /// Shuffle order on each playback.
    pub shuffle: bool,
    /// Show filename caption by default.
    pub show_captions: bool,
    /// Show EXIF overlay by default.
    pub show_exif: bool,
    /// Background music file path (optional).
    pub music_path: Option<String>,
    /// Background colour as hex string (e.g. "#000000").
    pub background_color: String,
}

impl Default for SlideshowConfig {
    fn default() -> Self {
        Self {
            title: "Slideshow".to_string(),
            slides: vec![],
            loop_playback: false,
            default_duration_ms: 4000,
            default_transition: Transition::CrossFade,
            default_transition_ms: 800,
            shuffle: false,
            show_captions: false,
            show_exif: false,
            music_path: None,
            background_color: "#000000".to_string(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum SortStrategy {
    /// By EXIF date ascending.
    DateAscending,
    /// By EXIF date descending.
    DateDescending,
    /// By star rating descending (5★ first).
    RatingDescending,
    /// By filename A→Z.
    FileName,
    /// Random shuffle (seeded for reproducibility).
    Random(u64),
    /// Preserve the order items were added to the playlist.
    Manual,
}

// ────────────────────────────────────────────────────────────────────────────
// Builder
// ────────────────────────────────────────────────────────────────────────────

pub struct SlideshowBuilder {
    config: SlideshowConfig,
}

impl SlideshowBuilder {
    pub fn new() -> Self {
        Self { config: SlideshowConfig::default() }
    }

    pub fn title(mut self, t: impl Into<String>) -> Self {
        self.config.title = t.into(); self
    }
    pub fn loop_playback(mut self, v: bool) -> Self {
        self.config.loop_playback = v; self
    }
    pub fn duration(mut self, ms: u64) -> Self {
        self.config.default_duration_ms = ms; self
    }
    pub fn transition(mut self, t: Transition, ms: u64) -> Self {
        self.config.default_transition = t;
        self.config.default_transition_ms = ms;
        self
    }
    pub fn show_captions(mut self, v: bool) -> Self {
        self.config.show_captions = v; self
    }
    pub fn show_exif(mut self, v: bool) -> Self {
        self.config.show_exif = v; self
    }
    pub fn music(mut self, path: impl Into<String>) -> Self {
        self.config.music_path = Some(path.into()); self
    }

    /// Add slides from a list of (item_id, file_path, thumbnail_path, file_name).
    pub fn add_slides(
        mut self,
        items: &[(i64, String, Option<String>, String)],
        sort: SortStrategy,
    ) -> Self {
        let mut slides: Vec<SlideConfig> = items
            .iter()
            .map(|(id, path, thumb, name)| SlideConfig {
                item_id: *id,
                file_path: path.clone(),
                thumbnail_path: thumb.clone(),
                file_name: name.clone(),
                duration_ms: self.config.default_duration_ms,
                transition: self.config.default_transition.clone(),
                transition_ms: self.config.default_transition_ms,
                caption: String::new(),
                show_exif: self.config.show_exif,
            })
            .collect();

        match sort {
            SortStrategy::FileName => slides.sort_by(|a, b| a.file_name.cmp(&b.file_name)),
            SortStrategy::RatingDescending => {} // ratings not available here; preserve order
            SortStrategy::Random(seed) => shuffle_seeded(&mut slides, seed),
            _ => {} // DateAscending/Descending requires caller to pre-sort
        }

        self.config.slides.extend(slides);
        self
    }

    pub fn build(self) -> SlideshowConfig {
        self.config
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Serialisation
// ────────────────────────────────────────────────────────────────────────────

/// Serialize a slideshow config to JSON.
pub fn to_json(config: &SlideshowConfig) -> Result<String> {
    serde_json::to_string_pretty(config).map_err(Into::into)
}

/// Deserialize a slideshow config from JSON.
pub fn from_json(json: &str) -> Result<SlideshowConfig> {
    serde_json::from_str(json).map_err(Into::into)
}

// ────────────────────────────────────────────────────────────────────────────
// Playback helpers
// ────────────────────────────────────────────────────────────────────────────

/// Total duration of a slideshow in milliseconds.
pub fn total_duration_ms(config: &SlideshowConfig) -> u64 {
    config.slides.iter().map(|s| s.duration_ms + s.transition_ms).sum()
}

/// Format total duration as "M:SS".
pub fn format_duration(ms: u64) -> String {
    let total_secs = ms / 1000;
    let mins = total_secs / 60;
    let secs = total_secs % 60;
    format!("{}:{:02}", mins, secs)
}

/// Filter a slideshow to only include flagged/high-rated slides.
/// Useful for "best of" auto-selection.
pub fn filter_best(
    config: &mut SlideshowConfig,
    min_rating: i64,
    ratings: &std::collections::HashMap<i64, i64>,
) {
    config.slides.retain(|s| {
        ratings.get(&s.item_id).copied().unwrap_or(0) >= min_rating
    });
}

// ────────────────────────────────────────────────────────────────────────────
// Shuffle (seeded for reproducibility)
// ────────────────────────────────────────────────────────────────────────────

fn shuffle_seeded<T>(items: &mut Vec<T>, seed: u64) {
    // Simple LCG shuffle
    let mut rng = seed;
    let n = items.len();
    for i in (1..n).rev() {
        rng = rng.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
        let j = (rng >> 33) as usize % (i + 1);
        items.swap(i, j);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn builder_creates_correct_slide_count() {
        let items = vec![
            (1, "/a.jpg".to_string(), None, "a.jpg".to_string()),
            (2, "/b.jpg".to_string(), None, "b.jpg".to_string()),
            (3, "/c.jpg".to_string(), None, "c.jpg".to_string()),
        ];
        let config = SlideshowBuilder::new()
            .duration(5000)
            .add_slides(&items, SortStrategy::Manual)
            .build();
        assert_eq!(config.slides.len(), 3);
        assert_eq!(config.slides[0].duration_ms, 5000);
    }

    #[test]
    fn total_duration_calculation() {
        let items = vec![
            (1, "/a.jpg".to_string(), None, "a.jpg".to_string()),
            (2, "/b.jpg".to_string(), None, "b.jpg".to_string()),
        ];
        let config = SlideshowBuilder::new()
            .duration(3000)
            .transition(Transition::Fade, 1000)
            .add_slides(&items, SortStrategy::Manual)
            .build();
        // 2 slides × (3000 + 1000) = 8000 ms
        assert_eq!(total_duration_ms(&config), 8000);
        assert_eq!(format_duration(8000), "0:08");
    }

    #[test]
    fn format_duration_minutes() {
        assert_eq!(format_duration(125_000), "2:05");
    }
}
