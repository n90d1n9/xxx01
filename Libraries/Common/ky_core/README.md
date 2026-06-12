<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

Core utilities and infrastructure for Miku Flutter apps. Provides opinionated
networking, secure storage, local persistence helpers, websocket and notification
services, and shared config/models.

## Features

- `RestClientService` with token refresh, structured error logging, and optional retries
- JSON parsing helpers (`requestJson`, `parseJsonMap`, `parseJsonList`)
- Typed JSON helpers (`requestJsonParsed`, `requestJsonListParsed`)
- Optional offline fail-fast (`NetworkConfig.failFastOffline`)
- Retry respects `Retry-After` on HTTP 429 responses
- Retry jitter + in-flight request deduplication
- Circuit breaker support for transient backend outages
- Cached JSON fetch with ETag/Last-Modified revalidation
- Stale-while-revalidate + stale-on-error cache fallback
- Cache key builder (`RestCacheKey`)
- Local DB cache helpers (`cacheJson`, `getCachedJson`, JSON preferences)
- Cache clear by key prefix
- `LocalDBService.initializeIfNeeded` and corrupt encrypted cache cleanup
- Cache stats and `touchCache` helpers
- Cache migration + DB health check helpers
- Cache schema versioning and periodic cleanup scheduler
- Cache namespaces, size guardrails, and namespace clearing
- Cache entry metadata and per-namespace stats
- Cache hit/miss counters
- Namespace size budgets with LRU eviction
- Global cache size budget with LRU eviction
- Cache entry pinning (exclude from eviction)
- Eviction priority tiers (lower priority evicted first)
- Optional auto-cleanup of expired entries on read
- Cache warm-up helper
- Typed cache wrapper with `CacheOptions`
- Configured Dio provider and network status stream
- Network status provider (`networkStatusProvider`)
- Detailed network status stream (`NetworkChecker.onStatusChangeDetailed`)
- RestClientService request IDs + download retries
- Download persistence for completed files
- Download resume support (range requests)
- Download integrity checks (SHA-256)
- In-progress download state persistence
- Auto-resume and download error history
- Download error lookup helpers
- Download queue status helpers
- Route registry deduping and configurable public routes/guards
- Route registry snapshot helpers (paths + names)
- Route diagnostics snapshot and named route helper
- Route diagnostics screen widget
- Guard pipeline with priorities and named groups
- Optional diagnostics route registration (`/__routes__`)
- Download queue with concurrency limits
- Secure storage and local DB helpers
- Websocket services and notification utilities
- Shared config models and theme helpers

## Getting started

This package is used internally by Miku apps. Import `miku_core` and wire
`appConfigProvider` in your app entrypoint.

## Usage

Example: request with automatic auth header + retries.

```dart
final client = ref.read(restClientProvider);
final response = await client.get(
  '/crm/api/quotes',
  maxRetries: 2,
);
if (response.statusCode == 200) {
  // handle response.data
}
```

Example: parse JSON list safely (String or already-decoded).

```dart
final client = ref.read(restClientProvider);
final response = await client.get('/crm/api/new-info');
final items = client.parseJsonList(response.data);
```

Example: parse and map to models in one step.

```dart
final client = ref.read(restClientProvider);
final quotes = await client.requestJsonListParsed(
  '/crm/api/quotes',
  parser: (json) => Quote.fromJson(json),
);
```

Example: cached JSON request with ETag revalidation.

```dart
final client = ref.read(restClientProvider);
final result = await client.requestJsonCached(
  '/crm/api/quotes',
  parser: (json) => QuotesResponse.fromJson(json),
  cacheOptions: const CacheOptions(expiration: Duration(minutes: 30)),
  staleWhileRevalidate: true,
);
```

Example: cached JSON list parsing.

```dart
final client = ref.read(restClientProvider);
final result = await client.requestJsonCachedListParsed(
  '/crm/api/quotes',
  parser: (json) => Quote.fromJson(json),
  cacheOptions: const CacheOptions(expiration: Duration(minutes: 15)),
);
```

## Additional information

- Prefer `package:miku_core/rest/rest_services.dart` over the legacy
  `core/network/rest` client. The legacy client remains for backward compatibility.
