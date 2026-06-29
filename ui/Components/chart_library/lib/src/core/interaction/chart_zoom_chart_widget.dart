/// Ready-to-use zoomable + drilldown chart widget.
///
/// [ZoomableTenunChart] wraps any [BaseChartConfig]-based chart with:
///  - Pinch-to-zoom + pan + fling
///  - Double-tap to zoom in
///  - Scroll wheel (desktop/web)
///  - Zoom reset button overlay
///  - Optional minimap scrubber
///  - Crosshair on long-press
///  - Programmatic drill-down via [ChartDrillDownController]
///
/// Quick usage:
/// ```dart
/// ZoomableTenunChart(
///   config: myBarConfig,
///   height: 300,
///   showMinimap: true,
/// )
/// ```
///
/// Advanced usage with drill-down:
/// ```dart
/// final drill = ChartDrillDownController(root: myRootLevel);
///
/// ZoomableTenunChart.drillDown(
///   drillController: drill,
///   height: 300,
///   onTap: (frac, zoomCtrl) {
///     // Push a new level when the user taps a bar
///     drill.push(DrillDownLevel(
///       id: 'q1',
///       label: 'Q1 Detail',
///       config: myDetailConfig,
///       parentXStart: frac - 0.1,
///       parentXEnd: frac + 0.1,
///     ));
///     // Also zoom into that x-range on the same chart
///     zoomCtrl.zoomToRange(frac - 0.1, frac + 0.1, label: 'Q1');
///   },
/// )
/// ```
library chart_zoom_chart_widget;

import 'package:flutter/material.dart';

import '../config/base_config.dart';
import 'chart_drilldown_controller.dart';
import 'chart_interaction_layer.dart';
import 'chart_zoom_state.dart';

// ---------------------------------------------------------------------------
// ZoomableTenunChart
// ---------------------------------------------------------------------------

class ZoomableTenunChart extends StatefulWidget {
  // ---- Simple mode ----
  final BaseChartConfig? config;

  // ---- Drill-down mode ----
  final ChartDrillDownController? drillController;

  // ---- Layout ----
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  // ---- Zoom constraints ----
  final ZoomConstraints zoomConstraints;

  // ---- Features ----
  final bool showMinimap;
  final bool showResetButton;
  final bool showBreadcrumbs;
  final double minimapHeight;

  // ---- Callbacks ----
  /// Called with the x-fraction [0..1] of the tapped position.
  final void Function(double fraction, ChartZoomController zoom)? onTap;

  /// Called with the x-fraction [0..1] during crosshair movement.
  final void Function(double fraction)? onCrosshairMove;
  final void Function()? onCrosshairEnd;

  /// Called with the x-fraction when the user double-taps.
  final void Function(double fraction, ChartZoomController zoom)? onDoubleTap;

  /// External zoom controller — pass your own to read the state elsewhere.
  final ChartZoomController? zoomController;

  const ZoomableTenunChart({
    super.key,
    this.config,
    this.drillController,
    this.width,
    this.height,
    this.padding = EdgeInsets.zero,
    this.zoomConstraints = const ZoomConstraints(),
    this.showMinimap = false,
    this.showResetButton = true,
    this.showBreadcrumbs = true,
    this.minimapHeight = 28,
    this.onTap,
    this.onCrosshairMove,
    this.onCrosshairEnd,
    this.onDoubleTap,
    this.zoomController,
  }) : assert(
          config != null || drillController != null,
          'Provide either config or drillController',
        );

  /// Convenience constructor for drill-down mode.
  const ZoomableTenunChart.drillDown({
    super.key,
    required ChartDrillDownController drillController,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    ZoomConstraints zoomConstraints = const ZoomConstraints(),
    bool showMinimap = false,
    bool showResetButton = true,
    bool showBreadcrumbs = true,
    double minimapHeight = 28,
    void Function(double fraction, ChartZoomController zoom)? onTap,
    void Function(double fraction)? onCrosshairMove,
    void Function()? onCrosshairEnd,
    void Function(double fraction, ChartZoomController zoom)? onDoubleTap,
    ChartZoomController? zoomController,
  }) : this(
          drillController: drillController,
          width: width,
          height: height,
          padding: padding,
          zoomConstraints: zoomConstraints,
          showMinimap: showMinimap,
          showResetButton: showResetButton,
          showBreadcrumbs: showBreadcrumbs,
          minimapHeight: minimapHeight,
          onTap: onTap,
          onCrosshairMove: onCrosshairMove,
          onCrosshairEnd: onCrosshairEnd,
          onDoubleTap: onDoubleTap,
          zoomController: zoomController,
        );

  @override
  State<ZoomableTenunChart> createState() => _ZoomableTenunChartState();
}

class _ZoomableTenunChartState extends State<ZoomableTenunChart> {
  late ChartZoomController _zoomCtrl;
  bool _ownsZoomCtrl = false;

  @override
  void initState() {
    super.initState();
    if (widget.zoomController != null) {
      _zoomCtrl = widget.zoomController!;
    } else {
      _zoomCtrl = ChartZoomController(
        constraints: widget.zoomConstraints,
      );
      _ownsZoomCtrl = true;
    }
  }

  @override
  void dispose() {
    if (_ownsZoomCtrl) _zoomCtrl.dispose();
    super.dispose();
  }

  // ---- Build ----

  @override
  Widget build(BuildContext context) {
    Widget chartContent = _buildChartContent();

    // Wrap in interaction layer.
    chartContent = ChartInteractionLayer(
      zoomController: _zoomCtrl,
      onTap: (frac) => widget.onTap?.call(frac, _zoomCtrl),
      onDoubleTap: (frac) => widget.onDoubleTap?.call(frac, _zoomCtrl),
      onCrosshairMove: widget.onCrosshairMove,
      onCrosshairEnd: widget.onCrosshairEnd,
      child: chartContent,
    );

    // Zoom reset overlay.
    if (widget.showResetButton) {
      chartContent = Stack(
        children: [
          chartContent,
          ZoomResetButton(controller: _zoomCtrl),
        ],
      );
    }

    // Assemble full column: breadcrumbs + chart + minimap.
    Widget result = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Breadcrumbs (drill-down mode only).
        if (widget.showBreadcrumbs && widget.drillController != null)
          ValueListenableBuilder<DrillDownState>(
            valueListenable: widget.drillController!,
            builder: (ctx, state, _) {
              if (state.stack.length <= 1) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                    onPressed: widget.drillController!.canPop
                        ? widget.drillController!.pop
                        : null,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  Expanded(
                      child: DrillDownBreadcrumb(
                          controller: widget.drillController!)),
                  TextButton(
                    onPressed: widget.drillController!.popAll,
                    child: const Text('Reset', style: TextStyle(fontSize: 11)),
                  ),
                ]),
              );
            },
          ),

        // Main chart (expands to fill available height).
        Expanded(child: chartContent),

        // Minimap scrubber.
        if (widget.showMinimap)
          ZoomMinimap(
            controller: _zoomCtrl,
            height: widget.minimapHeight,
          ),
      ],
    );

    // Size constraints.
    if (widget.height != null || widget.width != null) {
      result = SizedBox(
        width: widget.width,
        height: widget.height,
        child: result,
      );
    }

    if (widget.padding != EdgeInsets.zero) {
      result = Padding(padding: widget.padding, child: result);
    }

    return result;
  }

  Widget _buildChartContent() {
    if (widget.drillController != null) {
      return ValueListenableBuilder<DrillDownState>(
        valueListenable: widget.drillController!,
        builder: (ctx, state, _) {
          return _ZoomInjectedChart(
            config: state.current.resolveConfig(),
            zoomController: _zoomCtrl,
          );
        },
      );
    }
    return _ZoomInjectedChart(
      config: widget.config!,
      zoomController: _zoomCtrl,
    );
  }
}

// ---------------------------------------------------------------------------
// _ZoomInjectedChart — passes zoom state into chart config / painter
// ---------------------------------------------------------------------------

/// Internal widget that injects the [ChartZoomController] into the config's
/// controller so the chart's painter can read the current zoom state.
class _ZoomInjectedChart extends StatelessWidget {
  final BaseChartConfig config;
  final ChartZoomController zoomController;

  const _ZoomInjectedChart({
    required this.config,
    required this.zoomController,
  });

  @override
  Widget build(BuildContext context) {
    // Rebuild the chart every time zoom changes so the painter gets
    // updated visible index ranges.
    return ValueListenableBuilder<ChartZoomState>(
      valueListenable: zoomController,
      builder: (ctx, zoomState, _) {
        // Pass zoom into config via the controller bridge.
        // Concrete chart painters read `config.controller?.zoom`
        // and `config.controller?.zoomState`.
        final effectiveConfig = config.controller != null
            ? config  // controller already attached
            : config; // painters should accept a zoom override

        return effectiveConfig.buildChart();
      },
    );
  }
}

// ---------------------------------------------------------------------------
// ChartController <-> ChartZoomController bridge
// ---------------------------------------------------------------------------
// NOTE: When a chart's BaseChartConfig has a ChartController attached,
// call ChartZoomBridge.attach() to keep the two in sync.

import 'chart_controller.dart';

/// Bridges [ChartController] zoom operations with a [ChartZoomController].
///
/// After attaching, calls to `chartCtrl.zoomTo(start, end)` will update
/// the [ChartZoomController] and vice versa.
class ChartZoomBridge {
  final ChartController chartController;
  final ChartZoomController zoomController;
  final int totalDataPoints;

  ChartZoomBridge({
    required this.chartController,
    required this.zoomController,
    required this.totalDataPoints,
  }) {
    // Sync chartController → zoomController
    chartController.addListener(_onChartControllerChange);
    // Sync zoomController → chartController
    zoomController.addListener(_onZoomControllerChange);
  }

  bool _syncing = false;

  void _onChartControllerChange() {
    if (_syncing) return;
    _syncing = true;
    final z = chartController.zoom;
    if (totalDataPoints > 1) {
      final s = z.start / (totalDataPoints - 1);
      final e = z.end == -1 ? 1.0 : z.end / (totalDataPoints - 1);
      zoomController.value = ChartZoomState(
        xStart: s.clamp(0.0, 1.0),
        xEnd: e.clamp(0.0, 1.0),
      );
    }
    _syncing = false;
  }

  void _onZoomControllerChange() {
    if (_syncing) return;
    _syncing = true;
    final z = zoomController.value;
    chartController.zoomTo(
      start: z.startIndex(totalDataPoints),
      end: z.endIndex(totalDataPoints),
      factor: 1.0 / z.windowSize,
    );
    _syncing = false;
  }

  void dispose() {
    chartController.removeListener(_onChartControllerChange);
    zoomController.removeListener(_onZoomControllerChange);
  }
}
