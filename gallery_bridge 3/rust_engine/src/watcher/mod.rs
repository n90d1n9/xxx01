// gallery_bridge_engine/src/watcher/mod.rs
//
// Live folder watcher.
// Uses the `notify` crate (cross-platform FSEvents / inotify / ReadDirectoryChangesW)
// to detect new, modified, and deleted files in tracked folders.
// Debounces rapid bursts (e.g. file copy operations) with a 500ms window.

use crate::indexer::IndexConfig;
use anyhow::Result;
use crossbeam_channel::{unbounded, Sender};
use std::{
    collections::{HashMap, HashSet},
    path::PathBuf,
    sync::{Arc, Mutex},
    time::{Duration, Instant},
};

// ────────────────────────────────────────────────────────────────────────────
// Events emitted to Flutter
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone)]
pub enum WatchEvent {
    /// A new media file appeared
    FileAdded(String),
    /// An existing media file was modified
    FileModified(String),
    /// A file was deleted
    FileRemoved(String),
    /// Watcher error (non-fatal)
    WatchError(String),
}

// ────────────────────────────────────────────────────────────────────────────
// Watcher handle
// ────────────────────────────────────────────────────────────────────────────

pub struct FolderWatcher {
    /// Paths currently being watched
    watched: Arc<Mutex<HashSet<String>>>,
    /// Sender to push WatchEvents to the Flutter polling channel
    event_tx: Sender<WatchEvent>,
    /// Handle to the background watcher thread
    _thread: std::thread::JoinHandle<()>,
}

impl FolderWatcher {
    /// Create a new watcher. Events are pushed to `event_tx`.
    pub fn new(event_tx: Sender<WatchEvent>) -> Result<Self> {
        let watched = Arc::new(Mutex::new(HashSet::new()));
        let watched2 = watched.clone();
        let tx2 = event_tx.clone();

        // The watcher thread uses `notify` internally.
        // Here we use a polling fallback so this compiles without the notify crate
        // in the stub; in production replace with notify::recommended_watcher().
        let thread = std::thread::spawn(move || {
            Self::watcher_loop(watched2, tx2);
        });

        Ok(Self {
            watched,
            event_tx,
            _thread: thread,
        })
    }

    /// Start watching a folder path.
    pub fn watch(&self, path: String) -> Result<()> {
        self.watched.lock().unwrap().insert(path);
        Ok(())
    }

    /// Stop watching a folder path.
    pub fn unwatch(&self, path: &str) {
        self.watched.lock().unwrap().remove(path);
    }

    // ────────────────────────────────────────────────────────────────────────
    // Background polling loop (production: replace with notify event loop)
    // ────────────────────────────────────────────────────────────────────────

    fn watcher_loop(
        watched: Arc<Mutex<HashSet<String>>>,
        tx: Sender<WatchEvent>,
    ) {
        // Snapshot of file mtimes — {path → mtime_millis}
        let mut known: HashMap<String, u64> = HashMap::new();
        let debounce = Duration::from_millis(500);
        let mut pending: HashMap<String, (WatchKind, Instant)> = HashMap::new();

        loop {
            std::thread::sleep(Duration::from_secs(2));

            let paths: Vec<String> = watched.lock().unwrap().iter().cloned().collect();
            let mut seen: HashSet<String> = HashSet::new();

            for root in &paths {
                let walker = walkdir::WalkDir::new(root)
                    .follow_links(true)
                    .into_iter()
                    .filter_map(|e| e.ok())
                    .filter(|e| e.file_type().is_file());

                for entry in walker {
                    let path_str = entry.path().to_string_lossy().to_string();
                    let ext = entry
                        .path()
                        .extension()
                        .and_then(|e| e.to_str())
                        .unwrap_or("")
                        .to_lowercase();

                    let media_exts = ["jpg","jpeg","png","tiff","tif","webp","gif",
                                      "bmp","heic","heif","raw","arw","cr2","cr3",
                                      "nef","dng","raf","rw2"];
                    if !media_exts.contains(&ext.as_str()) {
                        continue;
                    }

                    seen.insert(path_str.clone());

                    let mtime = entry
                        .metadata()
                        .ok()
                        .and_then(|m| m.modified().ok())
                        .and_then(|t| t.duration_since(std::time::UNIX_EPOCH).ok())
                        .map(|d| d.as_millis() as u64)
                        .unwrap_or(0);

                    match known.get(&path_str) {
                        None => {
                            pending.insert(path_str.clone(), (WatchKind::Added, Instant::now()));
                            known.insert(path_str, mtime);
                        }
                        Some(&prev_mtime) if prev_mtime != mtime => {
                            pending.insert(path_str.clone(), (WatchKind::Modified, Instant::now()));
                            *known.get_mut(&path_str).unwrap() = mtime;
                        }
                        _ => {}
                    }
                }
            }

            // Detect removals
            let removed: Vec<String> = known
                .keys()
                .filter(|p| !seen.contains(*p))
                .cloned()
                .collect();
            for p in removed {
                pending.insert(p.clone(), (WatchKind::Removed, Instant::now()));
                known.remove(&p);
            }

            // Flush debounced events
            let now = Instant::now();
            let ready: Vec<(String, WatchKind)> = pending
                .iter()
                .filter(|(_, (_, t))| now.duration_since(*t) >= debounce)
                .map(|(p, (k, _))| (p.clone(), k.clone()))
                .collect();

            for (path, kind) in ready {
                let evt = match kind {
                    WatchKind::Added    => WatchEvent::FileAdded(path.clone()),
                    WatchKind::Modified => WatchEvent::FileModified(path.clone()),
                    WatchKind::Removed  => WatchEvent::FileRemoved(path.clone()),
                };
                let _ = tx.send(evt);
                pending.remove(&path);
            }
        }
    }
}

#[derive(Debug, Clone)]
enum WatchKind {
    Added,
    Modified,
    Removed,
}
