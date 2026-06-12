import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

import 'interaction_reliability_lab_config.dart';
import 'interaction_reliability_lab_controls.dart';
import 'interaction_reliability_lab_data.dart';
import 'interaction_reliability_lab_panels.dart';

class InteractionReliabilityLabExample extends StatefulWidget {
  const InteractionReliabilityLabExample({super.key});

  @override
  State<InteractionReliabilityLabExample> createState() =>
      _InteractionReliabilityLabExampleState();
}

class _InteractionReliabilityLabExampleState
    extends State<InteractionReliabilityLabExample> {
  final ChartZoomController _syncZoom = ChartZoomController(
    constraints: const ZoomConstraints(minWindowFraction: 0.02),
  );

  final ChartZoomController _drillZoom = ChartZoomController(
    constraints: const ZoomConstraints(minWindowFraction: 0.05),
  );

  late ChartDrillDownController _drillController;

  ChartDataMode _dataMode = ChartDataMode.auto;
  SamplingStrategy? _samplingStrategy;
  ChartType _primaryType = ChartType.line;

  bool _showLegend = true;
  bool _showTooltip = true;
  bool _showMinimap = true;
  bool _showBreadcrumbs = true;

  int _points = 8000;
  int _samplingThreshold = 900;

  late List<double> _signal;
  late List<double> _volume;

  @override
  void initState() {
    super.initState();
    _rebuildSeries();
    _drillController = ChartDrillDownController(root: _buildRootLevel());
    _drillController.addListener(_syncDrillZoomToCurrentLevel);
  }

  @override
  void dispose() {
    _drillController.removeListener(_syncDrillZoomToCurrentLevel);
    _drillController.dispose();
    _syncZoom.dispose();
    _drillZoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryConfig = _buildPrimaryConfig();
    final secondaryConfig = _buildSecondaryConfig();
    final sourcePoints = _signal.length;
    final primaryRendered = primaryConfig.series.first.data?.length ?? 0;
    final secondaryRendered = secondaryConfig.series.first.data?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interaction Reliability Lab',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Stress test synced zoom + drilldown with runtime sampling controls.',
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          InteractionReliabilityControls(
            sourcePoints: sourcePoints,
            primaryRendered: primaryRendered,
            secondaryRendered: secondaryRendered,
            zoomListenable: _syncZoom,
            dataMode: _dataMode,
            primaryType: _primaryType,
            samplingStrategy: _samplingStrategy,
            showLegend: _showLegend,
            showTooltip: _showTooltip,
            showMinimap: _showMinimap,
            showBreadcrumbs: _showBreadcrumbs,
            points: _points,
            samplingThreshold: _samplingThreshold,
            onDataModeChanged: _setDataMode,
            onPrimaryTypeChanged: _setPrimaryType,
            onSamplingStrategyChanged: _setSamplingStrategy,
            onShowLegendChanged: (value) => setState(() => _showLegend = value),
            onShowTooltipChanged: (value) =>
                setState(() => _showTooltip = value),
            onShowMinimapChanged: (value) =>
                setState(() => _showMinimap = value),
            onShowBreadcrumbsChanged: (value) =>
                setState(() => _showBreadcrumbs = value),
            onPointsChanged: _setPointCount,
            onSamplingThresholdChanged: _setSamplingThreshold,
            onReset: _resetAllInteractions,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final syncPanel = InteractionReliabilitySyncPanel(
                  primaryConfig: primaryConfig,
                  secondaryConfig: secondaryConfig,
                  zoomController: _syncZoom,
                  showMinimap: _showMinimap,
                );
                final drillPanel = InteractionReliabilityDrillPanel(
                  drillController: _drillController,
                  zoomController: _drillZoom,
                  showMinimap: _showMinimap,
                  showBreadcrumbs: _showBreadcrumbs,
                  onTap: _onDrillTap,
                );

                if (constraints.maxWidth < 980) {
                  return Column(
                    children: [
                      Expanded(child: syncPanel),
                      const SizedBox(height: 12),
                      Expanded(child: drillPanel),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: syncPanel),
                    const SizedBox(width: 12),
                    Expanded(child: drillPanel),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _setDataMode(ChartDataMode value) {
    setState(() {
      _dataMode = value;
      if (_dataMode == ChartDataMode.regular) {
        _samplingStrategy = null;
      }
      _resetDrillHierarchy();
    });
  }

  void _setPrimaryType(ChartType value) {
    setState(() {
      _primaryType = value;
      _resetDrillHierarchy();
    });
  }

  void _setSamplingStrategy(SamplingStrategy? value) {
    setState(() {
      _samplingStrategy = value;
      _resetDrillHierarchy();
    });
  }

  void _setPointCount(int value) {
    setState(() {
      _points = value;
      _rebuildSeries();
      _resetDrillHierarchy();
    });
  }

  void _setSamplingThreshold(int value) {
    setState(() {
      _samplingThreshold = value;
      _resetDrillHierarchy();
    });
  }

  BaseChartConfig _buildPrimaryConfig() {
    return buildInteractionCartesianConfig(
      type: _primaryType,
      title: 'Primary ${chartTypeToString(_primaryType)}',
      seriesName: 'Signal',
      values: _signal,
      colorValue: 0xFF2563EB,
      dataMode: _dataMode,
      samplingThreshold: _samplingThreshold,
      samplingStrategy: _samplingStrategy,
      showLegend: _showLegend,
      showTooltip: _showTooltip,
    );
  }

  BaseChartConfig _buildSecondaryConfig() {
    final secondaryType = secondaryInteractionChartType(_primaryType);
    return buildInteractionCartesianConfig(
      type: secondaryType,
      title: 'Secondary ${chartTypeToString(secondaryType)}',
      seriesName: 'Volume',
      values: _volume,
      colorValue: 0xFF16A34A,
      dataMode: _dataMode,
      samplingThreshold: _samplingThreshold,
      samplingStrategy: _samplingStrategy,
      showLegend: _showLegend,
      showTooltip: _showTooltip,
    );
  }

  BaseChartConfig _buildDrillConfig(
    DrillDownLevel level, {
    required ChartType type,
  }) {
    return buildInteractionDrillConfig(
      level: level,
      type: type,
      dataMode: _dataMode,
      samplingThreshold: _samplingThreshold,
      samplingStrategy: _samplingStrategy,
      showLegend: _showLegend,
      showTooltip: _showTooltip,
    );
  }

  DrillDownLevel _buildRootLevel() {
    final rootData = aggregateInteractionReliabilityData(_signal, buckets: 36);
    return DrillDownLevel(
      id: 'root',
      label: 'Depth 0 • Overview',
      data: rootData,
      metadata: {'sourceStart': 0, 'sourceEnd': _signal.length - 1},
      parentXStart: 0,
      parentXEnd: 1,
      buildConfig: (level) => _buildDrillConfig(level, type: ChartType.bar),
    );
  }

  void _onDrillTap(double fraction, ChartZoomController zoom) {
    final current = _drillController.currentLevel;
    final data = extractInteractionDrillData(current);
    if (data.isEmpty) return;

    final idx = ((fraction.clamp(0.0, 1.0) * (data.length - 1)).round()).clamp(
      0,
      data.length - 1,
    );

    final sourceStart = current.metadata['sourceStart'] as int? ?? 0;
    final sourceEnd =
        current.metadata['sourceEnd'] as int? ?? (_signal.length - 1);

    if (_drillController.depth >= 2) {
      final focusStart = (idx / data.length).clamp(0.0, 1.0);
      final focusEnd = ((idx + 1) / data.length).clamp(0.0, 1.0);
      zoom.zoomToRange(
        (focusStart - 0.08).clamp(0.0, 1.0),
        (focusEnd + 0.08).clamp(0.0, 1.0),
        label: 'Focus ${idx + 1}',
      );
      return;
    }

    final span = math.max(1, sourceEnd - sourceStart + 1);
    final bucketSize = math.max(1, (span / data.length).ceil());
    final childStart = sourceStart + idx * bucketSize;
    final childEnd = math.min(sourceEnd, childStart + bucketSize - 1);

    if (childEnd <= childStart) {
      return;
    }

    final raw = _signal.sublist(childStart, childEnd + 1);
    final childData = _drillController.depth == 0
        ? aggregateInteractionReliabilityData(raw, buckets: 60)
        : trimInteractionReliabilityData(raw, maxPoints: 260);

    final parentStart = idx / data.length;
    final parentEnd = (idx + 1) / data.length;

    final nextDepth = _drillController.depth + 1;
    final nextType = nextDepth == 1 ? ChartType.line : ChartType.area;

    _drillController.push(
      DrillDownLevel(
        id: 'level_${nextDepth}_$childStart',
        label: 'Depth $nextDepth • idx ${idx + 1}',
        data: childData,
        metadata: {'sourceStart': childStart, 'sourceEnd': childEnd},
        parentXStart: parentStart,
        parentXEnd: parentEnd,
        buildConfig: (level) => _buildDrillConfig(level, type: nextType),
      ),
    );

    zoom.zoomToRange(
      (parentStart - 0.04).clamp(0.0, 1.0),
      (parentEnd + 0.04).clamp(0.0, 1.0),
      label: 'Depth $nextDepth',
    );
  }

  void _syncDrillZoomToCurrentLevel() {
    final depth = _drillController.depth;
    if (depth == 0) {
      _drillZoom.reset();
      return;
    }

    final range = _drillController.currentXRange;
    final span = (range.$2 - range.$1).abs();
    final pad = (span * 0.12).clamp(0.02, 0.2);
    final start = (range.$1 - pad).clamp(0.0, 1.0);
    final end = (range.$2 + pad).clamp(0.0, 1.0);

    _drillZoom.value = ChartZoomState(
      xStart: start,
      xEnd: end,
      minWindowFraction: _drillZoom.constraints.minWindowFraction,
    );
  }

  void _resetDrillHierarchy() {
    _drillController
      ..removeListener(_syncDrillZoomToCurrentLevel)
      ..dispose();
    _drillController = ChartDrillDownController(root: _buildRootLevel());
    _drillController.addListener(_syncDrillZoomToCurrentLevel);
    _drillZoom.reset();
    _syncZoom.reset();
  }

  void _resetAllInteractions() {
    setState(_resetDrillHierarchy);
  }

  void _rebuildSeries() {
    final series = buildInteractionReliabilitySeries(_points);
    _signal = series.signal;
    _volume = series.volume;
  }
}
