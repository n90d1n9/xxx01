/// Structured render pipeline for chart painters.
///
/// Replaces the monolithic `paint()` call in each chart with an ordered,
/// composable layer stack. Each layer is responsible for a single concern:
/// background, grid, data, labels, overlay, tooltip. Only dirty layers
/// repaint — the rest are drawn from a raster cache.
///
/// Benefits:
///  - Tooltip hover no longer triggers a full canvas repaint.
///  - Grid lines are cached as a [ui.Picture] and replayed cheaply.
///  - Individual series can be marked dirty independently (e.g. after
///    a single series data update).
///  - New chart types add layers without touching existing ones.
///
/// Usage in a painter:
/// ```dart
/// class BarChartPainter extends ChartPainterBase {
///   @override
///   void paint(Canvas canvas, Size size) {
///     _pipeline
///       ..setSize(size)
///       ..paint(canvas);
///   }
///
///   late final _pipeline = ChartRenderPipeline([
///     BackgroundLayer(theme),
///     GridLayer(viewport, yTicks),
///     BarDataLayer(processed, viewport, theme),
///     DataLabelLayer(processed, viewport, theme),
///     CrosshairLayer(crosshairX, viewport, theme),
///     TooltipLayer(tooltipLines, tooltipAnchor, theme),
///   ]);
/// }
/// ```
library chart_render_pipeline;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'chart_painter_base.dart';
import '../config/chart_theme.dart';
import 'chart_cache.dart';

// ---------------------------------------------------------------------------
// RenderLayer — abstract base for all paint layers
// ---------------------------------------------------------------------------

/// One composable layer in a [ChartRenderPipeline].
abstract class RenderLayer {
  /// Human-readable name — used for debug logging and profiling.
  String get name;

  /// Whether this layer should be cached as a [ui.Picture].
  ///
  /// - `true` → layer is recorded once and replayed on subsequent frames.
  ///   Set to `false` (via [markDirty]) to force a re-record.
  /// - `false` → layer is always drawn live (good for rapidly changing
  ///   overlays like tooltips and crosshairs).
  bool get cacheable => true;

  /// Whether this layer needs to be re-recorded on the next paint.
  bool get isDirty;

  /// Mark this layer as dirty — will be re-recorded next frame.
  void markDirty();

  /// Draw this layer onto [canvas].
  void paint(Canvas canvas, Size size);

  /// Called when canvas [size] changes so layers can recompute geometry.
  void onSizeChanged(Size size) {}
}

// ---------------------------------------------------------------------------
// _CachedLayer — wraps a RenderLayer in a ui.Picture cache
// ---------------------------------------------------------------------------

class _CachedLayer {
  final RenderLayer layer;
  ui.Picture? _picture;
  Size _lastSize = Size.zero;

  _CachedLayer(this.layer);

  void paintOnto(Canvas canvas, Size size) {
    if (!layer.cacheable) {
      // Always live-draw non-cacheable layers.
      layer.paint(canvas, size);
      return;
    }

    final sizeChanged = size != _lastSize;

    if (layer.isDirty || sizeChanged || _picture == null) {
      // Record into a Picture.
      final recorder = ui.PictureRecorder();
      final recordCanvas = Canvas(recorder);
      if (sizeChanged) {
        layer.onSizeChanged(size);
        _lastSize = size;
      }
      layer.paint(recordCanvas, size);
      _picture?.dispose();
      _picture = recorder.endRecording();
    }

    // Replay cached picture.
    canvas.drawPicture(_picture!);
  }

  void dispose() {
    _picture?.dispose();
    _picture = null;
  }
}

// ---------------------------------------------------------------------------
// ChartRenderPipeline
// ---------------------------------------------------------------------------

/// Orchestrates an ordered stack of [RenderLayer] objects.
///
/// Layers are painted in order (index 0 = bottom, last = top).
class ChartRenderPipeline {
  final List<_CachedLayer> _layers;
  Size _size = Size.zero;

  ChartRenderPipeline(List<RenderLayer> layers)
      : _layers = layers.map(_CachedLayer.new).toList(growable: false);

  /// Update canvas size — propagated to all layers.
  void setSize(Size size) {
    if (size != _size) {
      _size = size;
      for (final l in _layers) {
        l.layer.onSizeChanged(size);
      }
    }
  }

  /// Execute all layers in order onto [canvas].
  void paint(Canvas canvas, Size size) {
    setSize(size);
    for (final l in _layers) {
      l.paintOnto(canvas, size);
    }
  }

  /// Mark a specific layer dirty by type [T].
  void markDirty<T extends RenderLayer>() {
    for (final l in _layers) {
      if (l.layer is T) l.layer.markDirty();
    }
  }

  /// Mark all layers dirty (equivalent to full repaint).
  void markAllDirty() {
    for (final l in _layers) {
      l.layer.markDirty();
    }
  }

  void dispose() {
    for (final l in _layers) {
      l.dispose();
    }
  }
}

// ---------------------------------------------------------------------------
// Base layer implementations
// ---------------------------------------------------------------------------

/// Base class that tracks a single dirty flag.
abstract class BaseRenderLayer implements RenderLayer {
  bool _dirty = true;

  @override
  bool get isDirty => _dirty;

  @override
  void markDirty() => _dirty = true;

  /// Call at the end of [paint] to clear the dirty flag.
  void clearDirty() => _dirty = false;
}

// ---------------------------------------------------------------------------
// BackgroundLayer
// ---------------------------------------------------------------------------

class BackgroundLayer extends BaseRenderLayer {
  final ChartTheme theme;
  BackgroundLayer(this.theme);

  @override
  String get name => 'background';

  @override
  void paint(Canvas canvas, Size size) {
    if (theme.backgroundColor != Colors.transparent) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        paintCache.fill(theme.backgroundColor),
      );
    }
    clearDirty();
  }
}

// ---------------------------------------------------------------------------
// GridLayer
// ---------------------------------------------------------------------------

class GridLayer extends BaseRenderLayer {
  final ChartViewport viewport;
  final List<double> yTicks;
  final List<double> xPositions;
  final bool dashedH;
  final bool dashedV;
  final ChartTheme theme;

  GridLayer({
    required this.viewport,
    required this.theme,
    this.yTicks = const [],
    this.xPositions = const [],
    this.dashedH = true,
    this.dashedV = false,
  });

  @override
  String get name => 'grid';

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = paintCache.stroke(
        theme.gridColor, theme.spacing.gridLineWidth);

    // Horizontal grid lines.
    for (final y in yTicks) {
      final cy = viewport.toCanvasY(y);
      canvas.drawLine(Offset(viewport.left, cy), Offset(viewport.right, cy),
          gridPaint);
    }

    // Vertical grid lines.
    for (final x in xPositions) {
      canvas.drawLine(Offset(x, viewport.top), Offset(x, viewport.bottom),
          gridPaint);
    }
    clearDirty();
  }
}

// ---------------------------------------------------------------------------
// CrosshairLayer — non-cacheable overlay
// ---------------------------------------------------------------------------

class CrosshairLayer extends BaseRenderLayer {
  double? crosshairX;
  double? crosshairY;
  final ChartViewport viewport;
  final ChartTheme theme;

  CrosshairLayer({
    required this.viewport,
    required this.theme,
    this.crosshairX,
    this.crosshairY,
  });

  @override
  String get name => 'crosshair';

  @override
  bool get cacheable => false; // Always drawn live.

  @override
  void paint(Canvas canvas, Size size) {
    if (crosshairX == null && crosshairY == null) return;
    final paint =
        paintCache.stroke(theme.crosshairColor, 1.0);
    if (crosshairX != null) {
      canvas.drawLine(
        Offset(crosshairX!, viewport.top),
        Offset(crosshairX!, viewport.bottom),
        paint,
      );
    }
    if (crosshairY != null) {
      canvas.drawLine(
        Offset(viewport.left, crosshairY!),
        Offset(viewport.right, crosshairY!),
        paint,
      );
    }
    clearDirty();
  }
}

// ---------------------------------------------------------------------------
// TooltipLayer — non-cacheable overlay
// ---------------------------------------------------------------------------

class TooltipLayer extends BaseRenderLayer {
  List<String>? lines;
  Offset? anchor;
  final ChartTheme theme;

  TooltipLayer({required this.theme, this.lines, this.anchor});

  @override
  String get name => 'tooltip';

  @override
  bool get cacheable => false;

  @override
  void paint(Canvas canvas, Size size) {
    if (lines == null || lines!.isEmpty || anchor == null) return;
    _drawTooltip(canvas, size, anchor!, lines!);
    clearDirty();
  }

  void _drawTooltip(
      Canvas canvas, Size canvasSize, Offset anchor, List<String> lines) {
    const padding = 8.0;
    const radius = 6.0;
    const lineSpacing = 4.0;

    final style = theme.typography.tooltipStyle.copyWith(
      color: theme.tooltipTextColor,
    );

    final painters =
        lines.map((l) => textPainterCache.get(l, style, maxWidth: 220)).toList();
    final maxW =
        painters.fold<double>(0, (m, p) => p.width > m ? p.width : m);
    final totalH = painters.fold<double>(0, (s, p) => s + p.height) +
        lineSpacing * (painters.length - 1);

    double x = anchor.dx + 12;
    double y = anchor.dy - totalH / 2 - padding;
    x = x.clamp(0, canvasSize.width - maxW - padding * 2 - 12);
    y = y.clamp(0, canvasSize.height - totalH - padding * 2);

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, maxW + padding * 2, totalH + padding * 2),
      const Radius.circular(radius),
    );
    canvas.drawRRect(rect, paintCache.fill(theme.tooltipBackgroundColor));

    double textY = y + padding;
    for (final tp in painters) {
      tp.paint(canvas, Offset(x + padding, textY));
      textY += tp.height + lineSpacing;
    }
  }
}

// ---------------------------------------------------------------------------
// SelectionHighlightLayer — highlights a selected bar/segment
// ---------------------------------------------------------------------------

class SelectionHighlightLayer extends BaseRenderLayer {
  int? selectedIndex;
  final Color highlightColor;
  final double Function(int index) getX;
  final double slotWidth;
  final ChartViewport viewport;

  SelectionHighlightLayer({
    required this.getX,
    required this.slotWidth,
    required this.viewport,
    this.selectedIndex,
    this.highlightColor = const Color(0x33000000),
  });

  @override
  String get name => 'selection_highlight';

  @override
  bool get cacheable => false;

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedIndex == null) return;
    final cx = getX(selectedIndex!);
    canvas.drawRect(
      Rect.fromLTWH(
        cx - slotWidth / 2,
        viewport.top,
        slotWidth,
        viewport.height,
      ),
      paintCache.fill(highlightColor),
    );
    clearDirty();
  }
}
