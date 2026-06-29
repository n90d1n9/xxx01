// gallery_bridge_engine/src/lib.rs
// Root — all modules registered here, api re-exported.

pub mod analytics;
pub mod api;
pub mod collections;
pub mod contact_sheet;
pub mod db;
pub mod duplicate;
pub mod edits;
pub mod export;
pub mod gps;
pub mod indexer;
pub mod metadata;
pub mod print_layout;
pub mod rename;
pub mod search;
pub mod slideshow;
pub mod thumbnail;
pub mod watcher;
pub mod xmp;

pub use api::*;
