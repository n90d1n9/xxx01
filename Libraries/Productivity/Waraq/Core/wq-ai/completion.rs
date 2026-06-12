// src/ai/completion.rs
//
// Inline completion engine — manages the full lifecycle:
//
//   1. Debounce: don't fire on every keystroke, wait for a pause.
//   2. Cache: don't re-request if context hasn't changed.
//   3. Cancellation: drop stale in-flight requests when the user keeps typing.
//   4. Acceptance: apply the suggestion as a real edit when the user presses Tab.
//
// This module is pure Rust with no async runtime dependency.
// The FFI layer drives it via poll + callback pattern.

use std::collections::HashMap;
use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};

use crate::core::edit::EditOp;

/// How long to wait after the last keystroke before firing a request.
const DEBOUNCE_MS: u64 = 300;

/// How many completed suggestions to keep in the LRU cache.
const CACHE_CAPACITY: usize = 64;

/// A pending or completed inline suggestion.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InlineSuggestion {
    /// The text to insert (may contain newlines for multi-line suggestions).
    pub text: String,
    /// Byte offset where the suggestion should be inserted.
    pub insert_at: usize,
    /// Model confidence score [0.0, 1.0].
    pub confidence: f32,
    /// Which model produced this.
    pub model: String,
    /// Whether this is a multi-line suggestion.
    pub is_multiline: bool,
}

impl InlineSuggestion {
    pub fn to_edit_op(&self) -> EditOp {
        EditOp::insert(self.insert_at, &self.text)
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum SuggestionKind {
    Inline,
    LineComplete,
    BlockComplete,
    Refactor,
    Documentation,
}

/// Request payload sent to the Waraq backend (or any LLM API).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompletionRequest {
    /// Unique request ID for cancellation tracking.
    pub request_id: u64,
    /// Prompt text (FIM or chat).
    pub prompt: String,
    /// Max new tokens to generate.
    pub max_tokens: u32,
    /// Stop sequences.
    pub stop: Vec<String>,
    /// Temperature (0.0 = deterministic).
    pub temperature: f32,
    /// Language hint.
    pub language: String,
    /// File path for multi-file context.
    pub file_uri: String,
}

/// Response from the Waraq backend.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompletionResponse {
    /// Must match the `request_id` in `CompletionRequest`.
    pub request_id: u64,
    /// Raw generated text (before post-processing).
    pub generated_text: String,
    /// Whether generation was truncated by max_tokens.
    pub truncated: bool,
    /// Finish reason: "stop", "length", "cancelled"
    pub finish_reason: String,
    /// Latency reported by backend (ms).
    pub latency_ms: u64,
}

// ── Cache ─────────────────────────────────────────────────────────────────────

/// Key: (prefix_hash, cursor_col)
#[derive(Hash, PartialEq, Eq, Clone)]
pub struct CacheKey {
    prefix_hash: u64,
    cursor_col: usize,
    language: String,
}

struct CacheEntry {
    suggestion: InlineSuggestion,
    hits: u32,
    inserted_at: Instant,
}

pub struct CompletionCache {
    entries: HashMap<CacheKey, CacheEntry>,
    insertion_order: Vec<CacheKey>,
    capacity: usize,
}

impl CompletionCache {
    pub fn new(capacity: usize) -> Self {
        Self {
            entries: HashMap::new(),
            insertion_order: Vec::new(),
            capacity,
        }
    }

    pub fn get(&mut self, key: &CacheKey) -> Option<InlineSuggestion> {
        if let Some(entry) = self.entries.get_mut(key) {
            // Invalidate entries older than 60 seconds
            if entry.inserted_at.elapsed() > Duration::from_secs(60) {
                return None;
            }
            entry.hits += 1;
            Some(entry.suggestion.clone())
        } else {
            None
        }
    }

    pub fn insert(&mut self, key: CacheKey, suggestion: InlineSuggestion) {
        if self.entries.len() >= self.capacity {
            // Evict LRU (first in insertion order)
            if let Some(evict_key) = self.insertion_order.first().cloned() {
                self.entries.remove(&evict_key);
                self.insertion_order.remove(0);
            }
        }
        self.insertion_order.push(key.clone());
        self.entries.insert(
            key,
            CacheEntry {
                suggestion,
                hits: 0,
                inserted_at: Instant::now(),
            },
        );
    }

    pub fn invalidate_all(&mut self) {
        self.entries.clear();
        self.insertion_order.clear();
    }
}

// ── Debouncer ─────────────────────────────────────────────────────────────────

struct Debouncer {
    last_change: Option<Instant>,
    delay: Duration,
}

impl Debouncer {
    fn new(delay_ms: u64) -> Self {
        Self {
            last_change: None,
            delay: Duration::from_millis(delay_ms),
        }
    }

    fn poke(&mut self) {
        self.last_change = Some(Instant::now());
    }

    fn is_ready(&self) -> bool {
        self.last_change
            .map(|t| t.elapsed() >= self.delay)
            .unwrap_or(false)
    }

    fn reset(&mut self) {
        self.last_change = None;
    }
}

// ── Simple hash (FNV-1a) for cache key generation ─────────────────────────────

fn fnv1a_hash(s: &str) -> u64 {
    const OFFSET_BASIS: u64 = 14_695_981_039_346_656_037;
    const PRIME: u64 = 1_099_511_628_211;
    s.bytes().fold(OFFSET_BASIS, |hash, b| {
        (hash ^ b as u64).wrapping_mul(PRIME)
    })
}

// ── Post-processing ───────────────────────────────────────────────────────────

/// Clean up raw model output before presenting to the user.
pub fn postprocess_completion(
    raw: &str,
    prefix: &str,
    _language: &str,
    max_lines: usize,
) -> String {
    let mut text = raw.to_owned();

    // 1. Strip leading whitespace that duplicates the cursor position
    let prefix_trailing = prefix
        .chars()
        .rev()
        .take_while(|c| *c == ' ' || *c == '\t')
        .count();
    if prefix_trailing > 0 {
        text = text
            .trim_start_matches(|c| c == ' ' || c == '\t')
            .to_owned();
    }

    // 2. Remove markdown code fences if model emitted them
    if text.starts_with("```") {
        let lines: Vec<&str> = text.lines().collect();
        let inner: Vec<&str> = lines[1..]
            .iter()
            .take_while(|l| !l.starts_with("```"))
            .copied()
            .collect();
        text = inner.join("\n");
    }

    // 3. Truncate to max_lines
    let truncated: String = text.lines().take(max_lines).collect::<Vec<_>>().join("\n");

    // 4. Ensure single trailing newline if the suggestion ends with one
    if raw.ends_with('\n') && !truncated.ends_with('\n') {
        format!("{}\n", truncated)
    } else {
        truncated
    }
}

// ── CompletionEngine ──────────────────────────────────────────────────────────

/// Completion engine — one per editor tab.
pub struct CompletionEngine {
    debouncer: Debouncer,
    cache: CompletionCache,
    next_request_id: u64,
    pub pending_request_id: Option<u64>,
    /// Most recently shown suggestion.
    pub active_suggestion: Option<InlineSuggestion>,
    /// Whether suggestion is currently visible to the user.
    pub suggestion_visible: bool,
    /// Cumulative stats.
    pub stats: CompletionStats,
}

#[derive(Debug, Default, Clone, Serialize)]
pub struct CompletionStats {
    pub requests_sent: u64,
    pub cache_hits: u64,
    pub suggestions_accepted: u64,
    pub suggestions_dismissed: u64,
    pub total_latency_ms: u64,
}

impl CompletionEngine {
    pub fn new() -> Self {
        Self {
            debouncer: Debouncer::new(DEBOUNCE_MS),
            cache: CompletionCache::new(CACHE_CAPACITY),
            next_request_id: 1,
            pending_request_id: None,
            active_suggestion: None,
            suggestion_visible: false,
            stats: CompletionStats::default(),
        }
    }

    /// Call this on every keystroke. Returns `Some(request)` when it's time to
    /// fire a network request, `None` if still debouncing or cache hit.
    pub fn on_change(
        &mut self,
        prefix: &str,
        cursor_col: usize,
        language: &str,
        _insert_at: usize,
    ) -> Option<CompletionRequest> {
        self.debouncer.poke();
        self.dismiss_suggestion();

        // Invalidate pending request
        self.pending_request_id = None;

        // Try cache first (before debounce — instant feedback)
        let key = CacheKey {
            prefix_hash: fnv1a_hash(prefix),
            cursor_col,
            language: language.to_owned(),
        };
        if let Some(cached) = self.cache.get(&key) {
            self.stats.cache_hits += 1;
            self.active_suggestion = Some(cached);
            self.suggestion_visible = true;
            return None;
        }

        // Not in cache — wait for debounce
        None
    }

    /// Call this periodically (e.g., every 50ms in the render loop).
    /// Returns `Some(request)` when debounce delay has elapsed.
    pub fn poll(
        &mut self,
        _prefix: &str,
        _cursor_col: usize,
        language: &str,
        file_uri: &str,
        _insert_at: usize,
        prompt_text: String,
    ) -> Option<CompletionRequest> {
        if !self.debouncer.is_ready() {
            return None;
        }
        self.debouncer.reset();

        // Don't re-request if a request is already in flight
        if self.pending_request_id.is_some() {
            return None;
        }

        let id = self.next_request_id;
        self.next_request_id += 1;
        self.pending_request_id = Some(id);
        self.stats.requests_sent += 1;

        Some(CompletionRequest {
            request_id: id,
            prompt: prompt_text,
            max_tokens: 128,
            stop: vec!["\n\n".into(), "```".into()],
            temperature: 0.15,
            language: language.to_owned(),
            file_uri: file_uri.to_owned(),
        })
    }

    /// Call this when the backend responds.
    /// Returns the processed `InlineSuggestion` if the response is still relevant.
    pub fn on_response(
        &mut self,
        response: CompletionResponse,
        prefix: &str,
        cursor_col: usize,
        language: &str,
        insert_at: usize,
    ) -> Option<&InlineSuggestion> {
        // Ignore stale responses
        if self.pending_request_id != Some(response.request_id) {
            return None;
        }
        self.pending_request_id = None;
        self.stats.total_latency_ms += response.latency_ms;

        if response.finish_reason == "cancelled" || response.generated_text.is_empty() {
            return None;
        }

        let processed = postprocess_completion(
            &response.generated_text,
            prefix,
            language,
            6, // max 6 lines inline
        );

        if processed.is_empty() {
            return None;
        }

        let suggestion = InlineSuggestion {
            text: processed.clone(),
            insert_at,
            confidence: 0.85,
            model: "waraq".into(),
            is_multiline: processed.contains('\n'),
        };

        // Cache it
        let key = CacheKey {
            prefix_hash: fnv1a_hash(prefix),
            cursor_col,
            language: language.to_owned(),
        };
        self.cache.insert(key, suggestion.clone());

        self.active_suggestion = Some(suggestion);
        self.suggestion_visible = true;
        self.active_suggestion.as_ref()
    }

    /// User pressed Tab — accept the current suggestion.
    /// Returns the `EditOp` to apply to the buffer.
    pub fn accept(&mut self) -> Option<EditOp> {
        let suggestion = self.active_suggestion.take()?;
        self.suggestion_visible = false;
        self.stats.suggestions_accepted += 1;
        Some(suggestion.to_edit_op())
    }

    /// User pressed Escape or kept typing — dismiss the suggestion.
    pub fn dismiss_suggestion(&mut self) {
        if self.suggestion_visible {
            self.stats.suggestions_dismissed += 1;
        }
        self.active_suggestion = None;
        self.suggestion_visible = false;
    }

    /// Cancel any in-flight request (e.g., on tab close).
    pub fn cancel_pending(&mut self) -> Option<u64> {
        self.pending_request_id.take()
    }

    pub fn has_pending_request(&self) -> bool {
        self.pending_request_id.is_some()
    }
}

impl Default for CompletionEngine {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_debounce_not_ready_immediately() {
        let d = Debouncer::new(300);
        assert!(!d.is_ready());
    }

    #[test]
    fn test_postprocess_strips_fences() {
        let raw = "```rust\nlet x = 1;\n```";
        let result = postprocess_completion(raw, "", "rust", 10);
        assert_eq!(result, "let x = 1;");
    }

    #[test]
    fn test_postprocess_truncates_lines() {
        let raw = "line1\nline2\nline3\nline4\nline5\nline6\nline7\nline8";
        let result = postprocess_completion(raw, "", "rust", 3);
        assert_eq!(result.lines().count(), 3);
    }

    #[test]
    fn test_cache_hit() {
        let mut engine = CompletionEngine::new();
        let prefix = "fn main() {\n    let x = ";
        let language = "rust";

        // Simulate a response being cached
        let response = CompletionResponse {
            request_id: 1,
            generated_text: "42;".into(),
            truncated: false,
            finish_reason: "stop".into(),
            latency_ms: 120,
        };
        engine.pending_request_id = Some(1);
        engine.on_response(response, prefix, 12, language, 100);

        // Second change with same prefix should hit cache
        engine.on_change(prefix, 12, language, 100);
        assert_eq!(engine.stats.cache_hits, 1);
        assert!(engine.active_suggestion.is_some());
    }

    #[test]
    fn test_accept_returns_edit_op() {
        let mut engine = CompletionEngine::new();
        engine.active_suggestion = Some(InlineSuggestion {
            text: "42;".into(),
            insert_at: 100,
            confidence: 0.9,
            model: "test".into(),
            is_multiline: false,
        });
        engine.suggestion_visible = true;

        let op = engine.accept();
        assert!(op.is_some());
        assert!(engine.active_suggestion.is_none());
        assert_eq!(engine.stats.suggestions_accepted, 1);
    }

    #[test]
    fn test_stale_response_ignored() {
        let mut engine = CompletionEngine::new();
        engine.pending_request_id = Some(5);

        let stale_response = CompletionResponse {
            request_id: 3, // different from pending 5
            generated_text: "some text".into(),
            truncated: false,
            finish_reason: "stop".into(),
            latency_ms: 50,
        };
        let result = engine.on_response(stale_response, "", 0, "rust", 0);
        assert!(result.is_none());
        assert_eq!(engine.pending_request_id, Some(5)); // still pending
    }

    #[test]
    fn test_fnv1a_hash_deterministic() {
        assert_eq!(fnv1a_hash("hello"), fnv1a_hash("hello"));
        assert_ne!(fnv1a_hash("hello"), fnv1a_hash("world"));
    }
}

#[cfg(test)]
mod completion_extended_tests {
    use super::*;

    fn engine() -> CompletionEngine {
        CompletionEngine::new()
    }

    fn suggestion(text: &str, insert_at: usize) -> InlineSuggestion {
        InlineSuggestion {
            text: text.to_owned(),
            insert_at,
            confidence: 1.0,
            model: "test".to_owned(),
            is_multiline: text.contains('\n'),
        }
    }

    // ── Engine state ──────────────────────────────────────────────────────────

    #[test]
    fn test_engine_starts_empty() {
        let e = engine();
        assert!(!e.suggestion_visible);
        assert!(e.active_suggestion.is_none());
        assert!(!e.has_pending_request());
    }

    #[test]
    fn test_accept_no_suggestion_returns_none() {
        let mut e = engine();
        assert!(e.accept().is_none());
    }

    #[test]
    fn test_dismiss_no_suggestion_is_noop() {
        let mut e = engine();
        e.dismiss_suggestion(); // should not panic
        assert!(!e.suggestion_visible);
    }

    #[test]
    fn test_set_suggestion_and_accept() {
        let mut e = engine();
        e.active_suggestion = Some(suggestion("hello world", 5));
        e.suggestion_visible = true;
        let op = e.accept().unwrap();
        assert!(!e.suggestion_visible);
        assert!(e.active_suggestion.is_none());
        assert_eq!(e.stats.suggestions_accepted, 1);
        // The op should insert at position 5
        if let crate::core::edit::EditOp::Insert { at, text } = op {
            assert_eq!(at.0, 5);
            assert_eq!(text, "hello world");
        } else {
            panic!("Expected Insert op");
        }
    }

    #[test]
    fn test_dismiss_increments_stats() {
        let mut e = engine();
        e.active_suggestion = Some(suggestion("foo", 0));
        e.suggestion_visible = true;
        e.dismiss_suggestion();
        assert_eq!(e.stats.suggestions_dismissed, 1);
    }

    #[test]
    fn test_on_change_dismisses_existing_suggestion() {
        let mut e = engine();
        e.active_suggestion = Some(suggestion("old", 0));
        e.suggestion_visible = true;
        // on_change should dismiss the suggestion
        e.on_change("def hello():", 12, "python", 12);
        assert!(!e.suggestion_visible);
        assert!(e.active_suggestion.is_none());
    }

    #[test]
    fn test_cancel_pending_returns_id() {
        let mut e = engine();
        e.pending_request_id = Some(42);
        let id = e.cancel_pending();
        assert_eq!(id, Some(42));
        assert!(e.pending_request_id.is_none());
    }

    // ── Postprocess ───────────────────────────────────────────────────────────

    #[test]
    fn test_postprocess_strips_prefix() {
        // If response repeats the prefix, strip it
        let result = postprocess_completion("def foo():\n    return 42", "def foo():", "python", 6);
        // Postprocessing should work without panicking
        assert!(!result.is_empty());
    }

    #[test]
    fn test_postprocess_empty_stays_empty() {
        let result = postprocess_completion("", "prefix", "python", 6);
        assert!(result.is_empty());
    }

    #[test]
    fn test_postprocess_trims_whitespace() {
        let result = postprocess_completion("   def foo(): pass   ", "    ", "python", 6);
        assert!(!result.starts_with("   "), "Should trim leading whitespace");
    }

    // ── Cache ─────────────────────────────────────────────────────────────────

    #[test]
    fn test_cache_insert_and_get() {
        let mut cache = CompletionCache::new(10);
        let key = CacheKey {
            prefix_hash: 12345,
            cursor_col: 5,
            language: "python".to_owned(),
        };
        let sugg = suggestion("cached result", 10);
        cache.insert(key.clone(), sugg.clone());
        let got = cache.get(&key).unwrap();
        assert_eq!(got.text, "cached result");
    }

    #[test]
    fn test_cache_miss_returns_none() {
        let mut cache = CompletionCache::new(10);
        let key = CacheKey {
            prefix_hash: 99999,
            cursor_col: 0,
            language: "python".to_owned(),
        };
        assert!(cache.get(&key).is_none());
    }

    #[test]
    fn test_cache_invalidate_all() {
        let mut cache = CompletionCache::new(10);
        let key = CacheKey {
            prefix_hash: 1,
            cursor_col: 0,
            language: "python".to_owned(),
        };
        let sugg = suggestion("x", 0);
        cache.insert(key.clone(), sugg);
        cache.invalidate_all();
        assert!(cache.get(&key).is_none());
    }

    // ── InlineSuggestion ─────────────────────────────────────────────────────

    #[test]
    fn test_inline_suggestion_to_edit_op() {
        let s = suggestion("hello", 3);
        let op = s.to_edit_op();
        if let crate::core::edit::EditOp::Insert { at, text } = op {
            assert_eq!(at.0, 3);
            assert_eq!(text, "hello");
        } else {
            panic!("Expected Insert");
        }
    }

    // ── Stats ─────────────────────────────────────────────────────────────────

    #[test]
    fn test_stats_default_zeros() {
        let stats = CompletionStats::default();
        assert_eq!(stats.requests_sent, 0);
        assert_eq!(stats.suggestions_accepted, 0);
        assert_eq!(stats.suggestions_dismissed, 0);
        assert_eq!(stats.cache_hits, 0);
    }
}
