/// Caching layer for chart rendering objects.
///
/// Charts call `ChartPaintCache.color()`, `ChartPaintCache.paint()` etc.
/// instead of allocating new objects on every `paint()` call.
///
/// Changes from v1:
/// - [PaintCache.fillMutable]: fixed mutation-of-cached-paint bug — now returns
///   a **new** Paint pre-seeded from the cached one instead of mutating it.
/// - [TextPainterCache]: replaced blunt clear-all eviction with a proper
///   bounded LRU (LinkedHashMap insertion-order tracking).
/// - [PathCache]: new cache for pre-computed [ui.Path] / [ui.Vertices] objects
///   that are expensive to build on every frame.
library chart_paint_cache;

import 'dart:collection';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Color cache
// ---------------------------------------------------------------------------

/// Parses and caches [Color] objects from string representations.
///
/// Supports: `#RGB`, `#RRGGBB`, `#RRGGBBAA`, `rgb(r,g,b)`,
/// `rgba(r,g,b,a)`, and common named colours.
class ColorCache {
  ColorCache._();
  static final ColorCache _instance = ColorCache._();
  factory ColorCache() => _instance;

  final HashMap<String, Color> _cache = HashMap();

  Color resolve(String raw) {
    return _cache.putIfAbsent(raw, () => _parse(raw.trim()));
  }

  void clear() => _cache.clear();

  // ---- parsers ----

  Color _parse(String s) {
    if (s.startsWith('#')) return _hex(s);
    final lower = s.toLowerCase();
    if (lower.startsWith('rgba(')) return _rgba(s);
    if (lower.startsWith('rgb(')) return _rgb(s);
    return _named(lower) ?? (throw FormatException('Unknown color: $s'));
  }

  Color _hex(String s) {
    var h = s.substring(1);
    if (h.length == 3) h = h.split('').map((c) => '$c$c').join();
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16) | 0xFF000000);
    if (h.length == 8) {
      final r = int.parse(h.substring(0, 6), radix: 16);
      final a = int.parse(h.substring(6), radix: 16);
      return Color.fromARGB(a, (r >> 16) & 0xFF, (r >> 8) & 0xFF, r & 0xFF);
    }
    throw FormatException('Bad hex: $s');
  }

  Color _rgb(String s) {
    final parts = s
        .replaceAll(RegExp(r'rgb\(|\)'), '')
        .split(',')
        .map((p) => int.parse(p.trim()).clamp(0, 255))
        .toList();
    return Color.fromARGB(255, parts[0], parts[1], parts[2]);
  }

  Color _rgba(String s) {
    final parts = s.replaceAll(RegExp(r'rgba\(|\)'), '').split(',');
    final r = int.parse(parts[0].trim()).clamp(0, 255);
    final g = int.parse(parts[1].trim()).clamp(0, 255);
    final b = int.parse(parts[2].trim()).clamp(0, 255);
    final a = (double.parse(parts[3].trim()) * 255).round().clamp(0, 255);
    return Color.fromARGB(a, r, g, b);
  }

  static const _named = _namedColors;
  static Color? _namedColors(String name) => const {
        'transparent': Color(0x00000000),
        'black': Color(0xFF000000),
        'white': Color(0xFFFFFFFF),
        'red': Color(0xFFF44336),
        'green': Color(0xFF4CAF50),
        'blue': Color(0xFF2196F3),
        'yellow': Color(0xFFFFEB3B),
        'orange': Color(0xFFFF9800),
        'purple': Color(0xFF9C27B0),
        'pink': Color(0xFFE91E63),
        'cyan': Color(0xFF00BCD4),
        'teal': Color(0xFF009688),
        'indigo': Color(0xFF3F51B5),
        'amber': Color(0xFFFFC107),
        'lime': Color(0xFFCDDC39),
        'brown': Color(0xFF795548),
        'grey': Color(0xFF9E9E9E),
        'gray': Color(0xFF9E9E9E),
        'navy': Color(0xFF0D1B4B),
        'maroon': Color(0xFF7B0000),
        'gold': Color(0xFFFFC200),
        'silver': Color(0xFFC0C0C0),
        'olive': Color(0xFF6D6D00),
      }[name];
}

// ---------------------------------------------------------------------------
// Paint cache — avoids allocating Paint objects inside paint() calls
// ---------------------------------------------------------------------------

class PaintCache {
  PaintCache._();
  static final PaintCache _instance = PaintCache._();
  factory PaintCache() => _instance;

  // Key: "AARRGGBB_style_strokeWidth"
  final HashMap<String, Paint> _cache = HashMap();

  Paint fill(Color color) => _get(color, PaintingStyle.fill, 0);
  Paint stroke(Color color, double width) =>
      _get(color, PaintingStyle.stroke, width);

  Paint _get(Color color, PaintingStyle style, double strokeWidth) {
    final key =
        '${color.value}_${style.index}_${strokeWidth.toStringAsFixed(1)}';
    return _cache.putIfAbsent(key, () {
      final p = Paint()
        ..color = color
        ..style = style
        ..isAntiAlias = true;
      if (style == PaintingStyle.stroke) p.strokeWidth = strokeWidth;
      return p;
    });
  }

  /// Returns a **new** Paint seeded from the cached fill paint.
  ///
  /// BUG FIX v2: the original implementation called `fill(color)..shader = null`
  /// which mutated the cached [Paint] object — any caller that previously set
  /// a shader on it would corrupt every subsequent use of that cache entry.
  /// Now we always return a fresh object so callers can safely mutate it.
  Paint fillMutable(Color color) {
    final cached = fill(color);
    return Paint()
      ..color = cached.color
      ..style = cached.style
      ..isAntiAlias = cached.isAntiAlias;
  }

  /// Returns a new mutable stroke paint seeded from the cache.
  Paint strokeMutable(Color color, double width) {
    final cached = stroke(color, width);
    return Paint()
      ..color = cached.color
      ..style = cached.style
      ..strokeWidth = cached.strokeWidth
      ..isAntiAlias = cached.isAntiAlias;
  }

  void clear() => _cache.clear();
}

// ---------------------------------------------------------------------------
// TextPainter LRU cache
// ---------------------------------------------------------------------------

/// Caches [TextPainter] layout results with bounded LRU eviction.
///
/// v2 change: uses [LinkedHashMap] with access-order tracking for true LRU
/// eviction instead of clearing the entire cache when the size limit is hit.
class TextPainterCache {
  TextPainterCache._({int maxSize = 400}) : _maxSize = maxSize;
  static final TextPainterCache _instance = TextPainterCache._();
  factory TextPainterCache() => _instance;

  final int _maxSize;

  // LinkedHashMap preserves insertion order; we use remove+re-insert on hit
  // to maintain access order (most-recently-used at the end).
  final LinkedHashMap<String, TextPainter> _cache =
      LinkedHashMap<String, TextPainter>();

  TextPainter get(
    String text,
    TextStyle style, {
    double maxWidth = double.infinity,
    TextAlign align = TextAlign.left,
  }) {
    final key = '${text}_${style.fontSize}_${style.color?.value}_'
        '${maxWidth.toStringAsFixed(0)}_${align.index}';

    // LRU: move hit entry to end.
    if (_cache.containsKey(key)) {
      final existing = _cache.remove(key)!;
      _cache[key] = existing;
      return existing;
    }

    // Evict LRU (first) entry when full.
    if (_cache.length >= _maxSize) {
      _cache.remove(_cache.keys.first);
    }

    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: maxWidth);

    _cache[key] = painter;
    return painter;
  }

  void clear() => _cache.clear();

  int get size => _cache.length;
}

// ---------------------------------------------------------------------------
// PathCache — cache expensive Path / geometry computations
// ---------------------------------------------------------------------------

/// Caches pre-computed [ui.Path] objects to avoid rebuilding them on every
/// `paint()` call when the underlying data has not changed.
///
/// Usage in a painter:
/// ```dart
/// final path = pathCache.getOrBuild('line_series_0_${hashCode}', () {
///   final p = ui.Path();
///   // ... build the path from data ...
///   return p;
/// });
/// canvas.drawPath(path, strokePaint(color, 2));
/// ```
class PathCache {
  PathCache._({int maxSize = 200}) : _maxSize = maxSize;
  static final PathCache _instance = PathCache._();
  factory PathCache() => _instance;

  final int _maxSize;
  final LinkedHashMap<String, ui.Path> _cache = LinkedHashMap();

  /// Returns cached path for [key], or builds and caches it via [builder].
  ui.Path getOrBuild(String key, ui.Path Function() builder) {
    if (_cache.containsKey(key)) {
      final hit = _cache.remove(key)!;
      _cache[key] = hit;
      return hit;
    }
    if (_cache.length >= _maxSize) {
      _cache.remove(_cache.keys.first);
    }
    final path = builder();
    _cache[key] = path;
    return path;
  }

  /// Invalidate a specific key (call when data changes).
  void invalidate(String key) => _cache.remove(key);

  /// Invalidate all keys with a given prefix (e.g., invalidate all paths for
  /// a series: `invalidatePrefix('series_0_')`).
  void invalidatePrefix(String prefix) {
    final toRemove = _cache.keys.where((k) => k.startsWith(prefix)).toList();
    for (final k in toRemove) {
      _cache.remove(k);
    }
  }

  void clear() => _cache.clear();

  int get size => _cache.length;
}

// ---------------------------------------------------------------------------
// Global convenience accessors
// ---------------------------------------------------------------------------

final colorCache = ColorCache();
final paintCache = PaintCache();
final textPainterCache = TextPainterCache();
final pathCache = PathCache();

/// Resolve a nullable color string with a fallback.
Color resolveColor(String? raw, Color fallback) {
  if (raw == null || raw.isEmpty) return fallback;
  try {
    return colorCache.resolve(raw);
  } catch (_) {
    return fallback;
  }
}
