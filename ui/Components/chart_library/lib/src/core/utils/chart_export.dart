/// Chart export utilities — PNG, SVG, and CSV.
///
/// Export any chart widget to:
///   - [ChartExporter.toPng] — raw PNG bytes via [RenderRepaintBoundary]
///   - [ChartExporter.toCsv] — tabular CSV string from series data
///   - [SvgChartExporter] — basic SVG export for line/bar/pie charts
///
/// Usage:
/// ```dart
/// // 1. Wrap chart in a GlobalKey-ed RepaintBoundary (or use ExportableChart):
/// final _exportKey = GlobalKey();
///
/// RepaintBoundary(
///   key: _exportKey,
///   child: TenunChart(config: myConfig),
/// )
///
/// // 2. Export:
/// final bytes = await ChartExporter.toPng(_exportKey);
/// // then save bytes with path_provider or share with share_plus
///
/// // CSV:
/// final csv = ChartExporter.toCsv(myConfig);
/// ```
library chart_export;

import 'dart:typed_data' show Uint8List;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../config/base_config.dart';

// ---------------------------------------------------------------------------
// ChartExporter
// ---------------------------------------------------------------------------

class ChartExporter {
  // ---- PNG ----

  /// Capture the widget attached to [key] as PNG bytes.
  ///
  /// [pixelRatio] controls resolution (1.0 = screen pixels, 2.0 = 2× for retina).
  static Future<Uint8List?> toPng(
    GlobalKey key, {
    double pixelRatio = 2.0,
  }) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('ChartExporter.toPng error: $e');
      return null;
    }
  }

  /// Capture as a [ui.Image] (useful for in-app display / compositing).
  static Future<ui.Image?> toImage(
    GlobalKey key, {
    double pixelRatio = 2.0,
  }) async {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    return boundary?.toImage(pixelRatio: pixelRatio);
  }

  // ---- CSV ----

  /// Serialise series data in [config] to a CSV string.
  ///
  /// Format:
  /// ```
  /// Category,Series A,Series B
  /// Jan,120,95
  /// Feb,145,110
  /// ```
  static String toCsv(
    BaseChartConfig config, {
    List<String>? categoryLabels,
    String delimiter = ',',
    String lineEnding = '\r\n',
  }) {
    final series = config.series;
    if (series.isEmpty) return '';

    // Header row.
    final headers = <String>['Category'];
    for (final s in series) {
      headers.add(_csvEscape(s.name ?? 'Series', delimiter));
    }

    // Determine row count.
    int maxLen = 0;
    for (final s in series) {
      if ((s.data?.length ?? 0) > maxLen) maxLen = s.data!.length;
    }

    final rows = <String>[headers.join(delimiter)];

    for (int i = 0; i < maxLen; i++) {
      final cells = <String>[
        categoryLabels != null && i < categoryLabels.length
            ? _csvEscape(categoryLabels[i], delimiter)
            : i.toString(),
      ];
      for (final s in series) {
        final v = s.data != null && i < s.data!.length ? s.data![i] : '';
        cells.add(v?.toString() ?? '');
      }
      rows.add(cells.join(delimiter));
    }

    return rows.join(lineEnding);
  }

  static String _csvEscape(String s, String delimiter) {
    if (s.contains(delimiter) || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}

// ---------------------------------------------------------------------------
// ExportableChart widget
// ---------------------------------------------------------------------------

/// Wraps a chart widget in a [RepaintBoundary] with a managed [GlobalKey].
///
/// Call [ExportableChartController.capture()] to get PNG bytes.
///
/// ```dart
/// final ctrl = ExportableChartController();
///
/// ExportableChart(
///   controller: ctrl,
///   child: TenunChart(config: myConfig),
/// )
///
/// // Later:
/// final bytes = await ctrl.capture();
/// ```
class ExportableChartController {
  final GlobalKey _key = GlobalKey();

  Future<Uint8List?> capture({double pixelRatio = 2.0}) =>
      ChartExporter.toPng(_key, pixelRatio: pixelRatio);

  Future<ui.Image?> captureImage({double pixelRatio = 2.0}) =>
      ChartExporter.toImage(_key, pixelRatio: pixelRatio);
}

class ExportableChart extends StatelessWidget {
  final ExportableChartController controller;
  final Widget child;

  const ExportableChart({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(key: controller._key, child: child);
  }
}

// ---------------------------------------------------------------------------
// SvgChartExporter — lightweight SVG generation (no external dependency)
// ---------------------------------------------------------------------------

/// Generates a minimal SVG string for simple chart types.
///
/// Intended for:
/// - Server-side chart thumbnails
/// - PDF embedding (via flutter_svg or webview)
/// - Email reports
///
/// Only covers bar, line, and pie. Complex charts (sankey, treemap) require
/// a full render-to-canvas → PNG pipeline instead.
class SvgChartExporter {
  /// Generate a bar chart SVG.
  static String barChart({
    required List<double> values,
    required List<String> labels,
    double width = 400,
    double height = 250,
    List<String>? colors,
    String title = '',
  }) {
    if (values.isEmpty) return _emptySvg(width, height);
    final buf = StringBuffer();
    final maxV = values.reduce((a, b) => a > b ? a : b);
    const padLeft = 40.0, padBottom = 30.0, padTop = 30.0, padRight = 10.0;
    final chartW = width - padLeft - padRight;
    final chartH = height - padTop - padBottom;
    final barW = chartW / values.length;

    buf.writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height">',
    );
    if (title.isNotEmpty) {
      buf.writeln(
        '<text x="${width / 2}" y="16" text-anchor="middle" font-size="14" font-weight="bold" fill="#1a1a1a">$title</text>',
      );
    }

    // Grid lines (5 horizontal).
    for (int i = 0; i <= 5; i++) {
      final y = padTop + chartH - (i / 5) * chartH;
      final label = (maxV * i / 5).toStringAsFixed(0);
      buf.writeln(
        '<line x1="$padLeft" y1="$y" x2="${width - padRight}" y2="$y" '
        'stroke="#e0e0e0" stroke-width="0.5"/>',
      );
      buf.writeln(
        '<text x="${padLeft - 4}" y="${y + 4}" text-anchor="end" '
        'font-size="9" fill="#666">$label</text>',
      );
    }

    // Bars.
    for (int i = 0; i < values.length; i++) {
      final barH = maxV > 0 ? (values[i] / maxV) * chartH : 0;
      final x = padLeft + i * barW + barW * 0.1;
      final y = padTop + chartH - barH;
      final color = colors != null && i < colors.length
          ? colors[i]
          : _defaultColors[i % _defaultColors.length];
      buf.writeln(
        '<rect x="${x.toStringAsFixed(1)}" y="${y.toStringAsFixed(1)}" '
        'width="${(barW * 0.8).toStringAsFixed(1)}" '
        'height="${barH.toStringAsFixed(1)}" fill="$color" rx="2"/>',
      );
      if (i < labels.length) {
        final lx = padLeft + i * barW + barW / 2;
        buf.writeln(
          '<text x="${lx.toStringAsFixed(1)}" y="${(height - padBottom + 12).toStringAsFixed(1)}" '
          'text-anchor="middle" font-size="9" fill="#444">${labels[i]}</text>',
        );
      }
    }

    buf.writeln('</svg>');
    return buf.toString();
  }

  /// Generate a line chart SVG.
  static String lineChart({
    required List<double> values,
    double width = 400,
    double height = 250,
    String color = '#2196F3',
    bool filled = false,
    String title = '',
  }) {
    if (values.isEmpty) return _emptySvg(width, height);
    const padLeft = 40.0, padBottom = 20.0, padTop = 30.0, padRight = 10.0;
    final chartW = width - padLeft - padRight;
    final chartH = height - padTop - padBottom;

    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs().clamp(1.0, double.infinity);

    Offset toCanvas(int i) {
      final x = padLeft + (i / (values.length - 1)) * chartW;
      final y = padTop + chartH - ((values[i] - minV) / range) * chartH;
      return Offset(x, y);
    }

    final pts = List.generate(values.length, (i) => toCanvas(i));
    final d = pts
        .asMap()
        .entries
        .map(
          (e) =>
              '${e.key == 0 ? 'M' : 'L'}${e.value.dx.toStringAsFixed(1)},${e.value.dy.toStringAsFixed(1)}',
        )
        .join(' ');

    final buf = StringBuffer();
    buf.writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height">',
    );
    if (title.isNotEmpty) {
      buf.writeln(
        '<text x="${width / 2}" y="16" text-anchor="middle" font-size="14" '
        'font-weight="bold" fill="#1a1a1a">$title</text>',
      );
    }
    if (filled) {
      final first = pts.first;
      final last = pts.last;
      final fillD =
          '$d L${last.dx.toStringAsFixed(1)},${(padTop + chartH).toStringAsFixed(1)} '
          'L${first.dx.toStringAsFixed(1)},${(padTop + chartH).toStringAsFixed(1)} Z';
      buf.writeln(
        '<path d="$fillD" fill="$color" fill-opacity="0.15" stroke="none"/>',
      );
    }
    buf.writeln(
      '<path d="$d" stroke="$color" stroke-width="2" fill="none" stroke-linejoin="round"/>',
    );
    buf.writeln('</svg>');
    return buf.toString();
  }

  static String _emptySvg(double w, double h) =>
      '<svg xmlns="http://www.w3.org/2000/svg" width="$w" height="$h">'
      '<text x="${w / 2}" y="${h / 2}" text-anchor="middle" fill="#999">No data</text>'
      '</svg>';

  static const _defaultColors = [
    '#2196F3',
    '#4CAF50',
    '#FF9800',
    '#E91E63',
    '#9C27B0',
    '#00BCD4',
    '#FF5722',
    '#607D8B',
  ];
}
