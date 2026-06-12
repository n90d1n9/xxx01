## 0.0.1

* Add retry-capable `RestClientService` request helpers and single-flight token refresh.
* Align legacy `core/network/rest` error logging with structured diagnostics.
* Add configurable retry defaults to `NetworkConfig`.
* Add JSON parsing helpers to normalize String vs decoded responses.
* Move AuthNotifier networking to `RestClientService` (deprecate legacy RestClient usage).
* Add typed JSON request helpers for model mapping.
* Add optional offline fail-fast support in RestClientService.
* Respect `Retry-After` when retrying 429 responses.
* Add retry jitter and request deduplication.
* Add circuit breaker support for transient backend outages.
* Add cached JSON requests with ETag/Last-Modified revalidation.
* Add stale-while-revalidate and stale-on-error cache fallback.
* Add cached JSON list parsing helper.
* Add RestCacheKey helper for stable cache/dedupe keys.
* Add detailed network status stream helper.
* Add cache clear by key prefix helper.
* Fix cache encryption key usage and add JSON cache/preference helpers.
* Add `initializeIfNeeded` and encrypted cache cleanup utilities.
* Add cache stats and touch helpers.
* Add cache migration and DB health check utilities.
* Add cache schema versioning and cleanup scheduler.
* Add cache namespaces, size limits, and namespace clearing.
* Add cache entry metadata and per-namespace stats.
* Add cache hit/miss counters.
* Add namespace size budgets with LRU eviction.
* Add global cache size budget with LRU eviction.
* Add cache pinning to exclude entries from eviction.
* Add priority tiers for eviction ordering.
* Add optional auto-cleanup of expired cache entries on read.
* Add cache warm-up helper.
* Add typed cache wrapper with `CacheOptions`.
* Add configured Dio provider and network status stream.
* Add request IDs + timing interceptor and network status provider.
* Add request IDs for RestClientService and download retry support.
* Add download persistence and restoration helpers.
* Add resumable downloads with byte tracking.
* Add SHA-256 integrity checks for downloads.
* Add in-progress download state persistence.
* Add auto-resume and download error history.
* Add download error lookup helpers.
* Add download queue status helpers.
* Add route registry deduping, public-route config, and guard hooks.
* Add route registry snapshot helpers.
* Add route diagnostics snapshot and named route helper.
* Add route diagnostics screen widget.
* Add guard pipeline with priorities and named groups.
* Add optional diagnostics route registration.
* Add download queue with concurrency limits.
* Update README with usage guidance.
