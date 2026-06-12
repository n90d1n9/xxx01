import 'dart:ui';

import 'package:flutter_riverpod/legacy.dart';

import '../models/layout_drag_preview.dart';
import '../models/layout_config.dart';

const layoutCanvasSize = Size(
  LayoutConfig.defaultCanvasWidth,
  LayoutConfig.defaultCanvasHeight,
);
const layoutCanvasZoomPresets = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
const _maxRecentCanvasZoomPresetCount = 6;
const Object _unsetPointerPosition = Object();
const Object _unsetAutoGridPreview = Object();
const Object _unsetLayoutDragPreview = Object();
const _autoGridPreviewTolerance = 0.5;

final recentCanvasZoomPresets = <double>[];

void rememberCanvasZoomPreset(double zoom) {
  final normalizedZoom = _normalizeCanvasZoom(zoom);
  if (_containsCanvasZoom(layoutCanvasZoomPresets, normalizedZoom)) return;

  recentCanvasZoomPresets.removeWhere(
    (preset) => _isSameCanvasZoom(preset, normalizedZoom),
  );
  recentCanvasZoomPresets.insert(0, normalizedZoom);

  if (recentCanvasZoomPresets.length > _maxRecentCanvasZoomPresetCount) {
    recentCanvasZoomPresets.removeRange(
      _maxRecentCanvasZoomPresetCount,
      recentCanvasZoomPresets.length,
    );
  }
}

void clearRecentCanvasZoomPresets() {
  recentCanvasZoomPresets.clear();
}

bool _containsCanvasZoom(Iterable<double> presets, double zoom) {
  return presets.any((preset) => _isSameCanvasZoom(preset, zoom));
}

bool _isSameCanvasZoom(double first, double second) {
  return (first - second).abs() < 0.001;
}

double _normalizeCanvasZoom(double zoom) {
  return zoom
      .clamp(CanvasViewportNotifier.minZoom, CanvasViewportNotifier.maxZoom)
      .toDouble();
}

final canvasViewportProvider =
    StateNotifierProvider<CanvasViewportNotifier, CanvasViewportState>((ref) {
      return CanvasViewportNotifier();
    });

class AutoGridPreviewItem {
  final String componentId;
  final Rect bounds;

  const AutoGridPreviewItem({required this.componentId, required this.bounds});

  bool isSamePlacement(AutoGridPreviewItem other) {
    return componentId == other.componentId &&
        _isSameRect(bounds, other.bounds);
  }
}

class AutoGridPreview {
  final List<AutoGridPreviewItem> items;

  const AutoGridPreview({required this.items});

  bool get isEmpty => items.isEmpty;

  Set<String> get componentIds {
    return items.map((item) => item.componentId).toSet();
  }
}

class CanvasViewportState {
  final double zoom;
  final Offset pan;
  final int fitRequestId;
  final int fitSelectionRequestId;
  final int resetRequestId;
  final bool isMarqueeSelecting;
  final bool showPrecisionGuides;
  final bool showAutoGridOccupancy;
  final Offset? pointerCanvasPosition;
  final AutoGridPreview? autoGridPreview;
  final LayoutDragPreview? layoutDragPreview;

  const CanvasViewportState({
    this.zoom = 1,
    this.pan = Offset.zero,
    this.fitRequestId = 1,
    this.fitSelectionRequestId = 0,
    this.resetRequestId = 0,
    this.isMarqueeSelecting = false,
    this.showPrecisionGuides = true,
    this.showAutoGridOccupancy = true,
    this.pointerCanvasPosition,
    this.autoGridPreview,
    this.layoutDragPreview,
  });

  CanvasViewportState copyWith({
    double? zoom,
    Offset? pan,
    int? fitRequestId,
    int? fitSelectionRequestId,
    int? resetRequestId,
    bool? isMarqueeSelecting,
    bool? showPrecisionGuides,
    bool? showAutoGridOccupancy,
    Object? pointerCanvasPosition = _unsetPointerPosition,
    Object? autoGridPreview = _unsetAutoGridPreview,
    Object? layoutDragPreview = _unsetLayoutDragPreview,
  }) {
    return CanvasViewportState(
      zoom: zoom ?? this.zoom,
      pan: pan ?? this.pan,
      fitRequestId: fitRequestId ?? this.fitRequestId,
      fitSelectionRequestId:
          fitSelectionRequestId ?? this.fitSelectionRequestId,
      resetRequestId: resetRequestId ?? this.resetRequestId,
      isMarqueeSelecting: isMarqueeSelecting ?? this.isMarqueeSelecting,
      showPrecisionGuides: showPrecisionGuides ?? this.showPrecisionGuides,
      showAutoGridOccupancy:
          showAutoGridOccupancy ?? this.showAutoGridOccupancy,
      pointerCanvasPosition:
          identical(pointerCanvasPosition, _unsetPointerPosition)
              ? this.pointerCanvasPosition
              : pointerCanvasPosition as Offset?,
      autoGridPreview:
          identical(autoGridPreview, _unsetAutoGridPreview)
              ? this.autoGridPreview
              : autoGridPreview as AutoGridPreview?,
      layoutDragPreview:
          identical(layoutDragPreview, _unsetLayoutDragPreview)
              ? this.layoutDragPreview
              : layoutDragPreview as LayoutDragPreview?,
    );
  }
}

class CanvasViewportNotifier extends StateNotifier<CanvasViewportState> {
  CanvasViewportNotifier() : super(const CanvasViewportState());

  static const minZoom = 0.35;
  static const maxZoom = 2.25;
  static const zoomStep = 0.1;

  void zoomIn() {
    setZoom(state.zoom + zoomStep);
  }

  void zoomOut() {
    setZoom(state.zoom - zoomStep);
  }

  void setZoom(double zoom) {
    final nextZoom = _clampZoom(zoom);
    if ((nextZoom - state.zoom).abs() < 0.001) return;
    state = state.copyWith(zoom: nextZoom);
  }

  void syncZoom(double zoom) {
    syncTransform(zoom: zoom, pan: state.pan);
  }

  void syncTransform({required double zoom, required Offset pan}) {
    final nextZoom = _clampZoom(zoom);
    if ((nextZoom - state.zoom).abs() < 0.005 &&
        (pan - state.pan).distance < 0.5) {
      return;
    }
    state = state.copyWith(zoom: nextZoom, pan: pan);
  }

  void fitToScreen() {
    state = state.copyWith(fitRequestId: state.fitRequestId + 1);
  }

  void fitSelection() {
    state = state.copyWith(
      fitSelectionRequestId: state.fitSelectionRequestId + 1,
    );
  }

  void resetZoom() {
    state = state.copyWith(zoom: 1, resetRequestId: state.resetRequestId + 1);
  }

  void setMarqueeSelecting(bool isSelecting) {
    if (state.isMarqueeSelecting == isSelecting) return;
    state = state.copyWith(isMarqueeSelecting: isSelecting);
  }

  void togglePrecisionGuides() {
    state = state.copyWith(showPrecisionGuides: !state.showPrecisionGuides);
  }

  void toggleAutoGridOccupancy() {
    state = state.copyWith(showAutoGridOccupancy: !state.showAutoGridOccupancy);
  }

  void setAutoGridPreviewItems(Iterable<AutoGridPreviewItem> items) {
    final nextItems = items
        .where((item) => _isUsableBounds(item.bounds))
        .toList(growable: false);
    final nextPreview =
        nextItems.isEmpty
            ? null
            : AutoGridPreview(items: List.unmodifiable(nextItems));

    if (_isSameAutoGridPreview(state.autoGridPreview, nextPreview)) return;
    state = state.copyWith(autoGridPreview: nextPreview);
  }

  void clearAutoGridPreview() {
    if (state.autoGridPreview == null) return;
    state = state.copyWith(autoGridPreview: null);
  }

  void setLayoutDragPreview(LayoutDragPreview? preview) {
    final nextPreview = preview == null || preview.isEmpty ? null : preview;
    final nextAutoGridPreview = _autoGridPreviewForLayoutDragPreview(
      nextPreview,
    );
    if (_isSameLayoutDragPreview(state.layoutDragPreview, nextPreview) &&
        _isSameAutoGridPreview(state.autoGridPreview, nextAutoGridPreview)) {
      return;
    }

    state = state.copyWith(
      layoutDragPreview: nextPreview,
      autoGridPreview: nextAutoGridPreview,
    );
  }

  void clearLayoutDragPreview() {
    if (state.layoutDragPreview == null && state.autoGridPreview == null) {
      return;
    }
    state = state.copyWith(layoutDragPreview: null, autoGridPreview: null);
  }

  void setPointerCanvasPosition(Offset? position) {
    final current = state.pointerCanvasPosition;
    if (position == null && current == null) return;
    if (position != null &&
        current != null &&
        (position - current).distance < 0.5) {
      return;
    }

    state = state.copyWith(pointerCanvasPosition: position);
  }

  double _clampZoom(double zoom) {
    return zoom.clamp(minZoom, maxZoom).toDouble();
  }
}

bool _isSameAutoGridPreview(AutoGridPreview? current, AutoGridPreview? next) {
  final currentItems = current?.items ?? const <AutoGridPreviewItem>[];
  final nextItems = next?.items ?? const <AutoGridPreviewItem>[];
  if (currentItems.length != nextItems.length) return false;

  for (var index = 0; index < currentItems.length; index++) {
    if (!currentItems[index].isSamePlacement(nextItems[index])) return false;
  }

  return true;
}

AutoGridPreview? _autoGridPreviewForLayoutDragPreview(
  LayoutDragPreview? preview,
) {
  if (preview == null || preview.mechanism != LayoutMechanism.autoGrid) {
    return null;
  }

  final items = preview.items
      .map(
        (item) => AutoGridPreviewItem(
          componentId: item.componentId,
          bounds: item.ruleBounds,
        ),
      )
      .where((item) => _isUsableBounds(item.bounds))
      .toList(growable: false);
  if (items.isEmpty) return null;

  return AutoGridPreview(items: List.unmodifiable(items));
}

bool _isSameLayoutDragPreview(
  LayoutDragPreview? current,
  LayoutDragPreview? next,
) {
  final currentItems = current?.items ?? const <LayoutDragPreviewItem>[];
  final nextItems = next?.items ?? const <LayoutDragPreviewItem>[];
  if (current?.mechanism != next?.mechanism) return false;
  if (current?.willApplyRulesOnDrop != next?.willApplyRulesOnDrop) {
    return false;
  }
  if (currentItems.length != nextItems.length) return false;

  for (var index = 0; index < currentItems.length; index++) {
    if (!currentItems[index].isSamePlacement(nextItems[index])) return false;
  }

  return true;
}

bool _isUsableBounds(Rect bounds) {
  return bounds.left.isFinite &&
      bounds.top.isFinite &&
      bounds.width.isFinite &&
      bounds.height.isFinite &&
      bounds.width > 0 &&
      bounds.height > 0;
}

bool _isSameRect(Rect first, Rect second) {
  return (first.left - second.left).abs() < _autoGridPreviewTolerance &&
      (first.top - second.top).abs() < _autoGridPreviewTolerance &&
      (first.width - second.width).abs() < _autoGridPreviewTolerance &&
      (first.height - second.height).abs() < _autoGridPreviewTolerance;
}
