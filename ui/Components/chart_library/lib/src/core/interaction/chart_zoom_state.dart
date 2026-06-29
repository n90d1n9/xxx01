/// Core zoom and pan state for chart interactions.
///
/// Design decisions:
/// - Zoom is tracked in **data space** (xStart..xEnd), not pixel space.
///   This makes it independent of canvas size and correct after resize.
/// - History stack enables programmatic drill-down / back navigation.
/// - Velocity is stored for momentum panning (fling).
/// - All mutations return a **new** [ChartZoomState] — the class is immutable,
///   making it trivial to hold in a [ValueNotifier] or [setState].
///
/// Coordinate conventions:
///   xStart / xEnd are fractional [0..1] positions in the full data range,
///   where 0 = first data point and 1 = last data point.
///   This means zoom state is independent of the actual data length.
library chart_zoom_state;

import 'dart:math' as math;

// ---------------------------------------------------------------------------
// ChartZoomState
// ---------------------------------------------------------------------------

/// Immutable zoom + pan state for one axis (X).
///
/// [xStart] and [xEnd] are normalised fractions of the full data range [0..1].
/// The visible window is `[xStart, xEnd]`.
class ChartZoomState {
  /// Visible window start — normalised [0..1] fraction of full data range.
  final double xStart;

  /// Visible window end — normalised [0..1] fraction of full data range.
  final double xEnd;

  /// Current horizontal pan velocity (data-units per frame), used for fling.
  final double velocityX;

  /// Maximum allowed zoom ratio (visible fraction of data, e.g. 0.02 = 2%).
  final double minWindowFraction;

  /// The full history stack of previous zoom states (for back navigation).
  final List<_HistoryEntry> _history;

  static const ChartZoomState identity = ChartZoomState._(
    xStart: 0,
    xEnd: 1,
    velocityX: 0,
    minWindowFraction: 0.02,
    history: [],
  );

  const ChartZoomState._({
    required this.xStart,
    required this.xEnd,
    required this.velocityX,
    required this.minWindowFraction,
    required List<_HistoryEntry> history,
  }) : _history = history;

  factory ChartZoomState({
    double xStart = 0,
    double xEnd = 1,
    double velocityX = 0,
    double minWindowFraction = 0.02,
  }) {
    return ChartZoomState._(
      xStart: xStart.clamp(0.0, 1.0),
      xEnd: xEnd.clamp(0.0, 1.0),
      velocityX: velocityX,
      minWindowFraction: minWindowFraction,
      history: const [],
    );
  }

  /// Current visible window size as a fraction of total data.
  double get windowSize => (xEnd - xStart).clamp(0.0, 1.0);

  /// True when showing the full data range.
  bool get isIdentity => xStart <= 0 && xEnd >= 1;

  /// True when there is zoom history to pop back to.
  bool get canPop => _history.isNotEmpty;

  /// How many history levels deep we are (= drill-down depth).
  int get depth => _history.length;

  /// Label of the current drill-down level (topmost history entry).
  String? get currentLabel =>
      _history.isNotEmpty ? _history.last.label : null;

  /// All breadcrumb labels from root to current level.
  List<String> get breadcrumbs => _history.map((e) => e.label).toList();

  // --------------------------------------------------------------------------
  // Zoom operations — all return a new immutable state
  // --------------------------------------------------------------------------

  /// Zoom so that `[focalFraction - halfWindow .. focalFraction + halfWindow]`
  /// is visible, where [focalFraction] is the pinch focal point in [0..1].
  ChartZoomState zoomAroundFraction(
    double focalFraction,
    double scaleDelta, {
    bool pushHistory = false,
    String historyLabel = '',
  }) {
    // New window half-size.
    final newHalf = (windowSize / 2) / scaleDelta;
    return _applyWindow(
      focalFraction - newHalf,
      focalFraction + newHalf,
      pushHistory: pushHistory,
      historyLabel: historyLabel,
    );
  }

  /// Zoom centred on screen-relative position [focalX] in [0..canvasWidth].
  ChartZoomState zoomAroundCanvas(
    double focalX,
    double canvasWidth,
    double scaleDelta, {
    bool pushHistory = false,
    String historyLabel = '',
  }) {
    final frac = xStart + (focalX / canvasWidth) * windowSize;
    return zoomAroundFraction(
      frac,
      scaleDelta,
      pushHistory: pushHistory,
      historyLabel: historyLabel,
    );
  }

  /// Pan by [deltaFraction] — positive = move viewport right (data moves left).
  ChartZoomState panBy(double deltaFraction) {
    return _applyWindow(xStart + deltaFraction, xEnd + deltaFraction);
  }

  /// Pan so that [frac] is at the left edge of the viewport.
  ChartZoomState panTo(double frac) {
    return _applyWindow(frac, frac + windowSize);
  }

  /// Pan to centre [frac] in the viewport.
  ChartZoomState centreOn(double frac) {
    final half = windowSize / 2;
    return _applyWindow(frac - half, frac + half);
  }

  /// Zoom to a specific data fraction range, pushing current state to history.
  ChartZoomState zoomToRange(
    double start,
    double end, {
    String label = 'Zoom',
  }) {
    return _applyWindow(start, end, pushHistory: true, historyLabel: label);
  }

  /// Apply fling velocity.
  ChartZoomState withVelocity(double vx) => ChartZoomState._(
        xStart: xStart,
        xEnd: xEnd,
        velocityX: vx,
        minWindowFraction: minWindowFraction,
        history: _history,
      );

  /// Advance one fling frame — decays velocity and applies pan.
  ///
  /// Returns new state. Returns same state when velocity has decayed to zero.
  ChartZoomState advanceFling({double friction = 0.9}) {
    if (velocityX.abs() < 0.0001) return this;
    final newVel = velocityX * friction;
    final moved = panBy(velocityX);
    return moved.withVelocity(newVel);
  }

  bool get hasMomentum => velocityX.abs() >= 0.0001;

  /// Reset to full view without pushing history.
  ChartZoomState reset() => ChartZoomState._(
        xStart: 0,
        xEnd: 1,
        velocityX: 0,
        minWindowFraction: minWindowFraction,
        history: const [],
      );

  // --------------------------------------------------------------------------
  // Drill-down / history navigation
  // --------------------------------------------------------------------------

  /// Push current state onto history and zoom to [start..end].
  ///
  /// Call [pop] to return to the pre-drill state.
  ChartZoomState drillDown(
    double start,
    double end, {
    required String label,
    Map<String, dynamic>? metadata,
  }) {
    final entry = _HistoryEntry(
      xStart: xStart,
      xEnd: xEnd,
      label: label,
      metadata: metadata ?? const {},
    );
    return ChartZoomState._(
      xStart: start.clamp(0.0, 1.0),
      xEnd: end.clamp(0.0, 1.0),
      velocityX: 0,
      minWindowFraction: minWindowFraction,
      history: [..._history, entry],
    );
  }

  /// Pop the most recent history entry, returning to the previous zoom level.
  ///
  /// Does nothing if [canPop] is false.
  ChartZoomState pop() {
    if (!canPop) return this;
    final prev = _history.last;
    return ChartZoomState._(
      xStart: prev.xStart,
      xEnd: prev.xEnd,
      velocityX: 0,
      minWindowFraction: minWindowFraction,
      history: _history.sublist(0, _history.length - 1),
    );
  }

  /// Pop all history entries and return to full view.
  ChartZoomState popAll() => reset();

  /// Metadata stored with the current drill-down entry.
  Map<String, dynamic> get currentMetadata =>
      _history.isNotEmpty ? _history.last.metadata : const {};

  // --------------------------------------------------------------------------
  // Data-space conversion helpers
  // --------------------------------------------------------------------------

  /// Convert a normalised fraction [0..1] to a data index in [0..dataLength-1].
  int fractionToIndex(double frac, int dataLength) {
    if (dataLength <= 1) return 0;
    return (frac * (dataLength - 1)).round().clamp(0, dataLength - 1);
  }

  /// First visible data index.
  int startIndex(int dataLength) => fractionToIndex(xStart, dataLength);

  /// Last visible data index.
  int endIndex(int dataLength) => fractionToIndex(xEnd, dataLength);

  /// Number of visible data points.
  int visibleCount(int dataLength) =>
      (endIndex(dataLength) - startIndex(dataLength) + 1).clamp(1, dataLength);

  /// Convert a canvas x-pixel to a data fraction.
  double canvasToFraction(double canvasX, double canvasWidth) {
    if (canvasWidth <= 0) return xStart;
    return xStart + (canvasX / canvasWidth) * windowSize;
  }

  /// Convert a data fraction to a canvas x-pixel.
  double fractionToCanvas(double frac, double canvasWidth) {
    if (windowSize <= 0) return 0;
    return ((frac - xStart) / windowSize) * canvasWidth;
  }

  // --------------------------------------------------------------------------
  // Internal
  // --------------------------------------------------------------------------

  ChartZoomState _applyWindow(
    double newStart,
    double newEnd, {
    bool pushHistory = false,
    String historyLabel = '',
  }) {
    // Clamp window size to min.
    double size = (newEnd - newStart).clamp(minWindowFraction, 1.0);

    // Clamp start/end to [0..1].
    double start = newStart.clamp(0.0, 1.0 - size);
    double end = (start + size).clamp(size, 1.0);
    // Re-clamp start in case end was adjusted.
    start = (end - size).clamp(0.0, 1.0);

    final history = pushHistory
        ? [
            ..._history,
            _HistoryEntry(
              xStart: xStart,
              xEnd: xEnd,
              label: historyLabel,
              metadata: const {},
            ),
          ]
        : _history;

    return ChartZoomState._(
      xStart: start,
      xEnd: end,
      velocityX: 0,
      minWindowFraction: minWindowFraction,
      history: history,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ChartZoomState &&
      other.xStart == xStart &&
      other.xEnd == xEnd;

  @override
  int get hashCode => Object.hash(xStart, xEnd);

  @override
  String toString() =>
      'ChartZoomState(${(xStart * 100).toStringAsFixed(1)}%'
      '..${(xEnd * 100).toStringAsFixed(1)}%, depth=$depth)';
}

// ---------------------------------------------------------------------------
// Internal history entry
// ---------------------------------------------------------------------------

class _HistoryEntry {
  final double xStart;
  final double xEnd;
  final String label;
  final Map<String, dynamic> metadata;

  const _HistoryEntry({
    required this.xStart,
    required this.xEnd,
    required this.label,
    required this.metadata,
  });
}

// ---------------------------------------------------------------------------
// ZoomConstraints — configure min/max zoom limits
// ---------------------------------------------------------------------------

class ZoomConstraints {
  /// Minimum visible window fraction (= maximum zoom level).
  /// 0.02 = can zoom to see 2% of data at most.
  final double minWindowFraction;

  /// Maximum visible window fraction (= minimum zoom = most zoomed out).
  /// 1.0 = full data range always visible.
  final double maxWindowFraction;

  /// Minimum number of data points to show.
  final int minVisiblePoints;

  /// Whether pinch-to-zoom is enabled.
  final bool enablePinchZoom;

  /// Whether mouse-wheel zoom is enabled (web / desktop).
  final bool enableScrollZoom;

  /// Whether double-tap to zoom is enabled.
  final bool enableDoubleTapZoom;

  /// Whether pan/drag is enabled.
  final bool enablePan;

  /// Zoom factor applied per double-tap.
  final double doubleTapZoomFactor;

  /// Whether fling (momentum pan) is enabled.
  final bool enableFling;

  /// Friction coefficient for fling deceleration [0..1]. Higher = stops faster.
  final double flingFriction;

  const ZoomConstraints({
    this.minWindowFraction = 0.02,
    this.maxWindowFraction = 1.0,
    this.minVisiblePoints = 3,
    this.enablePinchZoom = true,
    this.enableScrollZoom = true,
    this.enableDoubleTapZoom = true,
    this.enablePan = true,
    this.doubleTapZoomFactor = 2.5,
    this.enableFling = true,
    this.flingFriction = 0.88,
  });

  /// No interactions at all — fully static chart.
  static const ZoomConstraints none = ZoomConstraints(
    enablePinchZoom: false,
    enableScrollZoom: false,
    enableDoubleTapZoom: false,
    enablePan: false,
    enableFling: false,
  );

  /// Only pan, no zoom.
  static const ZoomConstraints panOnly = ZoomConstraints(
    enablePinchZoom: false,
    enableScrollZoom: false,
    enableDoubleTapZoom: false,
    enablePan: true,
  );

  factory ZoomConstraints.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ZoomConstraints();
    return ZoomConstraints(
      minWindowFraction: (json['minWindowFraction'] as num?)?.toDouble() ?? 0.02,
      maxWindowFraction: (json['maxWindowFraction'] as num?)?.toDouble() ?? 1.0,
      minVisiblePoints: (json['minVisiblePoints'] as int?) ?? 3,
      enablePinchZoom: json['enablePinchZoom'] as bool? ?? true,
      enableScrollZoom: json['enableScrollZoom'] as bool? ?? true,
      enableDoubleTapZoom: json['enableDoubleTapZoom'] as bool? ?? true,
      enablePan: json['enablePan'] as bool? ?? true,
      doubleTapZoomFactor: (json['doubleTapZoomFactor'] as num?)?.toDouble() ?? 2.5,
      enableFling: json['enableFling'] as bool? ?? true,
      flingFriction: (json['flingFriction'] as num?)?.toDouble() ?? 0.88,
    );
  }
}

// ---------------------------------------------------------------------------
// ChartZoomController — ValueNotifier wrapping ChartZoomState
// ---------------------------------------------------------------------------

/// A [ValueNotifier] that owns [ChartZoomState] and exposes gesture-friendly
/// mutation helpers.
///
/// Attach to a [ChartInteractionLayer] and read `.value` in painters.
///
/// ```dart
/// final zoomCtrl = ChartZoomController();
///
/// // In a StatefulWidget:
/// zoomCtrl.addListener(() => setState(() {}));
///
/// // Programmatic zoom to data range [20%..60%]:
/// zoomCtrl.zoomToRange(0.2, 0.6, label: 'Q2');
///
/// // Back:
/// zoomCtrl.pop();
/// ```
class ChartZoomController extends ValueNotifier<ChartZoomState> {
  final ZoomConstraints constraints;

  ChartZoomController({
    ChartZoomState? initial,
    this.constraints = const ZoomConstraints(),
  }) : super(initial ?? ChartZoomState.identity);

  // ---- Basic operations ----

  void zoomIn(double focalFraction, {double factor = 2.0}) {
    if (!constraints.enablePinchZoom && !constraints.enableDoubleTapZoom) return;
    value = value.zoomAroundFraction(focalFraction, factor);
    _clampToConstraints();
  }

  void zoomOut({double factor = 2.0}) {
    value = value.zoomAroundFraction(
      value.xStart + value.windowSize / 2,
      1.0 / factor,
    );
    _clampToConstraints();
  }

  void pan(double deltaFraction) {
    if (!constraints.enablePan) return;
    value = value.panBy(deltaFraction);
  }

  void reset() {
    value = value.reset();
  }

  // ---- Gesture entry-points (called by ChartInteractionLayer) ----

  void onScaleUpdate(double focalX, double canvasWidth, double scale) {
    if (!constraints.enablePinchZoom) return;
    final s = scale.clamp(0.1, 10.0);
    value = value.zoomAroundCanvas(focalX, canvasWidth, s);
    _clampToConstraints();
  }

  void onPanDelta(double deltaX, double canvasWidth) {
    if (!constraints.enablePan) return;
    final deltaFrac = -(deltaX / canvasWidth) * value.windowSize;
    value = value.panBy(deltaFrac);
  }

  void onDoubleTap(double focalX, double canvasWidth) {
    if (!constraints.enableDoubleTapZoom) return;
    final frac = value.canvasToFraction(focalX, canvasWidth);
    value = value.zoomAroundFraction(frac, constraints.doubleTapZoomFactor);
    _clampToConstraints();
  }

  void onFlingStart(double velocityX, double canvasWidth) {
    if (!constraints.enableFling) return;
    // Convert pixel velocity to fraction velocity.
    final fracVel = -(velocityX / canvasWidth) * value.windowSize * 0.016;
    value = value.withVelocity(fracVel);
  }

  /// Call every animation frame while [hasMomentum] is true.
  void advanceFling() {
    if (!value.hasMomentum) return;
    value = value.advanceFling(friction: constraints.flingFriction);
  }

  bool get hasMomentum => value.hasMomentum;

  // ---- Scroll wheel (desktop/web) ----
  void onScrollWheel(double deltaY, double focalX, double canvasWidth) {
    if (!constraints.enableScrollZoom) return;
    final scaleDelta = deltaY < 0 ? 1.15 : 0.87;
    final frac = value.canvasToFraction(focalX, canvasWidth);
    value = value.zoomAroundFraction(frac, scaleDelta);
    _clampToConstraints();
  }

  // ---- Drill-down ----

  void drillDown(
    double start,
    double end, {
    required String label,
    Map<String, dynamic>? metadata,
  }) {
    value = value.drillDown(start, end, label: label, metadata: metadata);
  }

  void pop() {
    value = value.pop();
  }

  void popAll() {
    value = value.popAll();
  }

  bool get canPop => value.canPop;
  int get depth => value.depth;
  List<String> get breadcrumbs => value.breadcrumbs;

  // ---- Programmatic zoom (used by ChartController bridge) ----

  void zoomToRange(double start, double end, {String label = 'Zoom'}) {
    value = value.zoomToRange(start, end, label: label);
    _clampToConstraints();
  }

  void zoomToIndexRange(int start, int end, int totalPoints,
      {String label = 'Zoom'}) {
    if (totalPoints <= 1) return;
    final s = start / (totalPoints - 1);
    final e = end / (totalPoints - 1);
    zoomToRange(s, e, label: label);
  }

  // ---- Internal ----

  void _clampToConstraints() {
    final v = value;
    final minW = math.max(
      constraints.minWindowFraction,
      constraints.minVisiblePoints <= 1
          ? 0.0
          : constraints.minVisiblePoints / 1000.0,
    );
    if (v.windowSize < minW) {
      final centre = (v.xStart + v.xEnd) / 2;
      value = ChartZoomState._(
        xStart: (centre - minW / 2).clamp(0.0, 1.0 - minW),
        xEnd: (centre + minW / 2).clamp(minW, 1.0),
        velocityX: 0,
        minWindowFraction: minW,
        history: v._history,
      );
    }
  }
}
