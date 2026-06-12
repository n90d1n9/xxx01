import 'dart:convert';
import 'dart:math' as math;

import 'package:tenun/tenun_core.dart';

abstract final class ShapeAwareSwitchDiff {
  static const List<String> pinnedPathPrefixes = [
    'type',
    'dataMode',
    'sampling',
    'series',
    'xAxis.data',
    'yAxis',
    'legend',
    'tooltip',
    'grid',
  ];

  static String truncateJson(
    Map<String, dynamic> value, {
    required int maxChars,
  }) {
    final pretty = const JsonEncoder.withIndent('  ').convert(value);
    if (pretty.length <= maxChars) return pretty;
    return '${pretty.substring(0, maxChars)}\n… (truncated)';
  }

  static List<String> collectPaths(
    dynamic before,
    dynamic after, {
    int maxPaths = 32,
  }) {
    final paths = <String>[];

    void walk(dynamic a, dynamic b, String prefix) {
      if (paths.length >= maxPaths) return;

      if (a is Map && b is Map) {
        final keys = <Object?>{...a.keys, ...b.keys};
        for (final rawKey in keys) {
          final key = rawKey.toString();
          final nextPrefix = prefix.isEmpty ? key : '$prefix.$key';
          walk(a[rawKey], b[rawKey], nextPrefix);
          if (paths.length >= maxPaths) return;
        }
        return;
      }

      if (a is List && b is List) {
        if (a.length != b.length) {
          paths.add(prefix.isEmpty ? 'length' : '$prefix.length');
          if (paths.length >= maxPaths) return;
        }
        final count = math.min(a.length, b.length);
        for (int i = 0; i < count; i++) {
          final nextPrefix = prefix.isEmpty ? '[$i]' : '$prefix[$i]';
          walk(a[i], b[i], nextPrefix);
          if (paths.length >= maxPaths) return;
        }
        return;
      }

      if (a != b) {
        paths.add(prefix.isEmpty ? '<root>' : prefix);
      }
    }

    walk(before, after, '');
    return paths;
  }

  static List<String> visiblePaths(
    List<String> paths, {
    required bool pinnedOnly,
  }) {
    final ranked = rankPaths(paths);
    if (!pinnedOnly) return ranked;
    return ranked.where(isPinnedPath).toList();
  }

  static List<String> rankPaths(List<String> paths) {
    final unique = paths.toSet().toList();
    unique.sort((a, b) {
      final scoreCmp = _pinScore(a).compareTo(_pinScore(b));
      if (scoreCmp != 0) return scoreCmp;
      final depthCmp = _pathDepth(a).compareTo(_pathDepth(b));
      if (depthCmp != 0) return depthCmp;
      return a.compareTo(b);
    });
    return unique;
  }

  static bool isPinnedPath(String path) => _pinScore(path) < 1000;

  static String? semanticSummary(
    Map<String, dynamic> before,
    Map<String, dynamic> after,
  ) {
    final parts = <String>[];

    final beforeType = (before['type'] ?? 'line').toString();
    final afterType = (after['type'] ?? 'line').toString();
    if (beforeType != afterType) {
      parts.add('type: $beforeType → $afterType');
    }

    final beforeShape = inferSeriesDataShape(before).name;
    final afterShape = inferSeriesDataShape(after).name;
    if (beforeShape != afterShape) {
      parts.add('shape: $beforeShape → $afterShape');
    }

    final beforeMode = before['dataMode'];
    final afterMode = after['dataMode'];
    if (!_deepEquals(beforeMode, afterMode) &&
        (beforeMode != null || afterMode != null)) {
      parts.add('mode: ${_asLabel(beforeMode)} → ${_asLabel(afterMode)}');
    }

    final beforeSampling = before['sampling'];
    final afterSampling = after['sampling'];
    if (!_deepEquals(beforeSampling, afterSampling) &&
        (beforeSampling != null || afterSampling != null)) {
      parts.add(
        'sampling: ${_samplingLabel(beforeSampling)} → '
        '${_samplingLabel(afterSampling)}',
      );
    }

    final beforeSeriesCount = _seriesCount(before);
    final afterSeriesCount = _seriesCount(after);
    if (beforeSeriesCount != afterSeriesCount) {
      parts.add('series: $beforeSeriesCount → $afterSeriesCount');
    }

    if (parts.isEmpty) return null;
    return parts.join(' | ');
  }

  static int _pinScore(String path) {
    for (int i = 0; i < pinnedPathPrefixes.length; i++) {
      final prefix = pinnedPathPrefixes[i];
      if (_matchesPathPrefix(path, prefix)) {
        return i;
      }
    }
    return 1000;
  }

  static bool _matchesPathPrefix(String path, String prefix) {
    return path == prefix ||
        path.startsWith('$prefix.') ||
        path.startsWith('$prefix[');
  }

  static int _pathDepth(String path) {
    final dotCount = '.'.allMatches(path).length;
    final bracketCount = '['.allMatches(path).length;
    return dotCount + bracketCount;
  }

  static int _seriesCount(Map<String, dynamic> json) {
    final raw = json['series'];
    if (raw is List) return raw.length;
    return 0;
  }

  static String _samplingLabel(dynamic sampling) {
    if (sampling is! Map) return _asLabel(sampling);
    final enabled = sampling['enabled'];
    final threshold = sampling['threshold'];
    final strategy = sampling['strategy'];
    return 'enabled=${_asLabel(enabled)}, '
        'threshold=${_asLabel(threshold)}, '
        'strategy=${_asLabel(strategy)}';
  }

  static String _asLabel(dynamic value) {
    if (value == null) return 'null';
    return value.toString();
  }

  static bool _deepEquals(dynamic a, dynamic b) {
    if (identical(a, b)) return true;
    return jsonEncode(a) == jsonEncode(b);
  }
}
