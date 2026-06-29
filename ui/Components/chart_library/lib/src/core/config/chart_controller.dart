/// Programmatic control over a live chart widget.
///
/// Attach a [ChartController] to a chart and call methods such as
/// [selectIndex], [zoomTo], [resetZoom], [highlight] or listen to
/// [onSelectionChanged] to drive cross-widget interaction.
///
/// v2 additions:
/// - [ChartControllerGroup]: links multiple controllers so that zooming /
///   panning / selecting on one chart synchronises all others (typical in
///   dashboard drill-down scenarios).
/// - [dataVersion]: bump to signal the chart to re-run [ChartDataProcessor]
///   (e.g., after a live data push).
/// - [filterState]: arbitrary key→value map for dimension filters (used by
///   heatmap, parallel-coordinates, etc.).
///
/// Example:
/// ```dart
/// final ctrl = ChartController();
/// TenunChart(controller: ctrl, config: myConfig)
///
/// // Programmatic control:
/// ctrl.selectIndex(3);
/// ctrl.zoomTo(start: 0, end: 50);
/// ctrl.incrementDataVersion(); // triggers re-process after data push
/// ```
library chart_controller;

import 'dart:async';
import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Value types
// ---------------------------------------------------------------------------

/// Represents a selected data point.
class ChartSelection {
  /// Series index.
  final int seriesIndex;

  /// Data-point index within the series.
  final int dataIndex;

  /// Raw value.
  final dynamic value;

  const ChartSelection({
    required this.seriesIndex,
    required this.dataIndex,
    this.value,
  });

  @override
  String toString() =>
      'ChartSelection(series=$seriesIndex, data=$dataIndex, value=$value)';
}

/// Defines the visible x-range.
class ZoomRange {
  /// Start index (inclusive).
  final int start;

  /// End index (inclusive, -1 = show all).
  final int end;

  /// Zoom factor (1.0 = no zoom).
  final double factor;

  const ZoomRange({this.start = 0, this.end = -1, this.factor = 1.0});

  static const ZoomRange full = ZoomRange(start: 0, end: -1, factor: 1.0);

  bool get isZoomed => factor != 1.0 || start != 0 || end != -1;

  @override
  String toString() => 'ZoomRange($start..$end × $factor)';
}

// ---------------------------------------------------------------------------
// ChartController
// ---------------------------------------------------------------------------

class ChartController extends ChangeNotifier {
  // ---- Selection ----
  ChartSelection? _selection;
  ChartSelection? get selection => _selection;

  final StreamController<ChartSelection?> _selectionCtrl =
      StreamController.broadcast();

  /// Stream that emits whenever the selection changes.
  Stream<ChartSelection?> get onSelectionChanged => _selectionCtrl.stream;

  void selectIndex(int dataIndex, {int seriesIndex = 0, dynamic value}) {
    _selection = ChartSelection(
      seriesIndex: seriesIndex,
      dataIndex: dataIndex,
      value: value,
    );
    _selectionCtrl.add(_selection);
    notifyListeners();
  }

  void clearSelection() {
    _selection = null;
    _selectionCtrl.add(null);
    notifyListeners();
  }

  // ---- Highlight ----
  final Set<int> _highlightedSeries = {};
  Set<int> get highlightedSeries => Set.unmodifiable(_highlightedSeries);

  void highlightSeries(int seriesIndex) {
    _highlightedSeries.add(seriesIndex);
    notifyListeners();
  }

  void unhighlightSeries(int seriesIndex) {
    _highlightedSeries.remove(seriesIndex);
    notifyListeners();
  }

  void toggleSeriesHighlight(int seriesIndex) {
    if (_highlightedSeries.contains(seriesIndex)) {
      _highlightedSeries.remove(seriesIndex);
    } else {
      _highlightedSeries.add(seriesIndex);
    }
    notifyListeners();
  }

  bool isSeriesHighlighted(int seriesIndex) =>
      _highlightedSeries.contains(seriesIndex);

  // ---- Visibility toggle (legend click) ----
  final Set<int> _hiddenSeries = {};
  Set<int> get hiddenSeries => Set.unmodifiable(_hiddenSeries);

  void toggleSeriesVisibility(int seriesIndex) {
    if (_hiddenSeries.contains(seriesIndex)) {
      _hiddenSeries.remove(seriesIndex);
    } else {
      _hiddenSeries.add(seriesIndex);
    }
    notifyListeners();
  }

  bool isSeriesVisible(int seriesIndex) => !_hiddenSeries.contains(seriesIndex);

  // ---- Zoom & Pan ----
  ZoomRange _zoom = ZoomRange.full;
  ZoomRange get zoom => _zoom;

  /// Pan offset in logical data units.
  double _panOffset = 0;
  double get panOffset => _panOffset;

  void zoomTo({int start = 0, int end = -1, double factor = 1.0}) {
    _zoom = ZoomRange(start: start, end: end, factor: factor);
    notifyListeners();
  }

  void resetZoom() {
    _zoom = ZoomRange.full;
    _panOffset = 0;
    notifyListeners();
  }

  void pan(double deltaIndex) {
    _panOffset += deltaIndex;
    notifyListeners();
  }

  // ---- Animation trigger ----
  bool _animationTrigger = false;
  bool get animationTrigger => _animationTrigger;

  /// Call to re-trigger entrance animation.
  void replay() {
    _animationTrigger = !_animationTrigger;
    notifyListeners();
  }

  // ---- Axis range override ----
  double? _yMin;
  double? _yMax;
  double? get yMin => _yMin;
  double? get yMax => _yMax;

  void setYRange(double min, double max) {
    assert(max > min, 'yMax must be greater than yMin');
    _yMin = min;
    _yMax = max;
    notifyListeners();
  }

  void clearYRange() {
    _yMin = null;
    _yMax = null;
    notifyListeners();
  }

  // ---- Data version (live data refresh signal) ----

  /// Incremented every time underlying data changes.
  ///
  /// Charts listen to [notifyListeners] and compare [dataVersion] to decide
  /// whether to re-run [ChartDataProcessor]. Bump this after a live push:
  /// ```dart
  /// series[0].data = newData;
  /// controller.incrementDataVersion();
  /// ```
  int _dataVersion = 0;
  int get dataVersion => _dataVersion;

  void incrementDataVersion() {
    _dataVersion++;
    // Also invalidate path cache for this chart so painters rebuild paths.
    notifyListeners();
  }

  // ---- Filter state (for multi-dimensional charts) ----

  /// Arbitrary filter map — keys and value semantics are chart-type-specific.
  ///
  /// Example (heatmap row/column filter):
  /// ```dart
  /// ctrl.setFilter('row', 'Q1');
  /// ctrl.setFilter('column', 'Revenue');
  /// ```
  final Map<String, dynamic> _filters = {};
  Map<String, dynamic> get filters => Map.unmodifiable(_filters);

  void setFilter(String key, dynamic value) {
    _filters[key] = value;
    notifyListeners();
  }

  void removeFilter(String key) {
    _filters.remove(key);
    notifyListeners();
  }

  void clearFilters() {
    _filters.clear();
    notifyListeners();
  }

  bool hasFilter(String key) => _filters.containsKey(key);

  // ---- Export signal ----
  final StreamController<void> _exportCtrl = StreamController.broadcast();

  /// Listen to trigger data exports (e.g., screenshot, CSV).
  Stream<void> get onExportRequested => _exportCtrl.stream;

  void requestExport() => _exportCtrl.add(null);

  // ---- Dispose ----
  @override
  void dispose() {
    _selectionCtrl.close();
    _exportCtrl.close();
    super.dispose();
  }

  @override
  String toString() =>
      'ChartController('
      'selection=$_selection, '
      'zoom=$_zoom, '
      'hiddenSeries=$_hiddenSeries, '
      'dataVersion=$_dataVersion'
      ')';
}

// ---------------------------------------------------------------------------
// ChartControllerGroup — sync multiple charts
// ---------------------------------------------------------------------------

/// Links multiple [ChartController] instances so that user interactions
/// (zoom, pan, selection) propagate across all linked charts.
///
/// Typical use-case: a dashboard where a date-range selection on a line chart
/// should also zoom a bar chart showing the same period.
///
/// ```dart
/// final group = ChartControllerGroup();
/// final lineCtrl = group.add(ChartController());
/// final barCtrl  = group.add(ChartController());
///
/// // Zooming lineCtrl will now also zoom barCtrl.
/// lineCtrl.zoomTo(start: 10, end: 50);
/// ```
class ChartControllerGroup {
  final List<ChartController> _controllers = [];

  /// Add a controller to the group and wire it up.
  ChartController add(ChartController ctrl) {
    _controllers.add(ctrl);
    ctrl.addListener(() => _onControllerChange(ctrl));
    return ctrl;
  }

  void remove(ChartController ctrl) {
    _controllers.remove(ctrl);
  }

  bool _syncing = false;

  void _onControllerChange(ChartController source) {
    if (_syncing) return;
    _syncing = true;
    for (final other in _controllers) {
      if (identical(other, source)) continue;
      // Sync zoom/pan only (not selection — that is chart-specific).
      if (other.zoom != source.zoom || other.panOffset != source.panOffset) {
        other._zoom = source.zoom;
        other._panOffset = source.panOffset;
        other.notifyListeners();
      }
    }
    _syncing = false;
  }

  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _controllers.clear();
  }
}
