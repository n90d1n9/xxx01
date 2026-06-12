//! Numeric conversion helpers for fixed-width artifact FFI parameters.
//!
//! The artifact C ABI uses `uint64_t` for host-facing offsets, counters, and
//! timestamps. Waraq internals still use `usize` where they index in-memory
//! buffers, so conversions must be checked instead of platform-dependent.

use super::error_codes::code;
use super::result::ArtifactApiError;

/// Convert a host-provided `uint64_t` into a platform `usize` without truncation.
pub(super) fn usize_from_u64(field: &'static str, value: u64) -> Result<usize, ArtifactApiError> {
    usize::try_from(value).map_err(|_| {
        ArtifactApiError::new(
            code::INTEGER_OUT_OF_RANGE,
            format!("{field} value {value} exceeds this platform's usize range"),
        )
    })
}
