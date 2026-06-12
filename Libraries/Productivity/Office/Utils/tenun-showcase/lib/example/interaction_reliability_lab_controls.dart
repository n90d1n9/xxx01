import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

const interactionReliabilityPrimaryTypes = <ChartType>[
  ChartType.line,
  ChartType.area,
  ChartType.bar,
];

class InteractionReliabilityControls extends StatelessWidget {
  const InteractionReliabilityControls({
    super.key,
    required this.sourcePoints,
    required this.primaryRendered,
    required this.secondaryRendered,
    required this.zoomListenable,
    required this.dataMode,
    required this.primaryType,
    required this.samplingStrategy,
    required this.showLegend,
    required this.showTooltip,
    required this.showMinimap,
    required this.showBreadcrumbs,
    required this.points,
    required this.samplingThreshold,
    required this.onDataModeChanged,
    required this.onPrimaryTypeChanged,
    required this.onSamplingStrategyChanged,
    required this.onShowLegendChanged,
    required this.onShowTooltipChanged,
    required this.onShowMinimapChanged,
    required this.onShowBreadcrumbsChanged,
    required this.onPointsChanged,
    required this.onSamplingThresholdChanged,
    required this.onReset,
  });

  final int sourcePoints;
  final int primaryRendered;
  final int secondaryRendered;
  final ValueListenable<ChartZoomState> zoomListenable;
  final ChartDataMode dataMode;
  final ChartType primaryType;
  final SamplingStrategy? samplingStrategy;
  final bool showLegend;
  final bool showTooltip;
  final bool showMinimap;
  final bool showBreadcrumbs;
  final int points;
  final int samplingThreshold;
  final ValueChanged<ChartDataMode> onDataModeChanged;
  final ValueChanged<ChartType> onPrimaryTypeChanged;
  final ValueChanged<SamplingStrategy?> onSamplingStrategyChanged;
  final ValueChanged<bool> onShowLegendChanged;
  final ValueChanged<bool> onShowTooltipChanged;
  final ValueChanged<bool> onShowMinimapChanged;
  final ValueChanged<bool> onShowBreadcrumbsChanged;
  final ValueChanged<int> onPointsChanged;
  final ValueChanged<int> onSamplingThresholdChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(width: 190, child: _buildDataModeDropdown()),
                SizedBox(width: 190, child: _buildPrimaryTypeDropdown()),
                SizedBox(width: 190, child: _buildStrategyDropdown()),
                FilterChip(
                  label: const Text('Legend'),
                  selected: showLegend,
                  onSelected: onShowLegendChanged,
                ),
                FilterChip(
                  label: const Text('Tooltip'),
                  selected: showTooltip,
                  onSelected: onShowTooltipChanged,
                ),
                FilterChip(
                  label: const Text('Minimap'),
                  selected: showMinimap,
                  onSelected: onShowMinimapChanged,
                ),
                FilterChip(
                  label: const Text('Breadcrumbs'),
                  selected: showBreadcrumbs,
                  onSelected: onShowBreadcrumbsChanged,
                ),
                OutlinedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt, size: 16),
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Dataset Size: $points points'),
            Slider(
              value: points.toDouble(),
              min: 1000,
              max: 30000,
              divisions: 58,
              label: points.toString(),
              onChanged: (value) => onPointsChanged(value.round()),
            ),
            if (dataMode != ChartDataMode.regular) ...[
              Text('Sampling Threshold: $samplingThreshold points'),
              Slider(
                value: samplingThreshold.toDouble(),
                min: 100,
                max: 4000,
                divisions: 39,
                label: samplingThreshold.toString(),
                onChanged: (value) => onSamplingThresholdChanged(value.round()),
              ),
            ],
            ValueListenableBuilder<ChartZoomState>(
              valueListenable: zoomListenable,
              builder: (context, state, _) {
                return Text(
                  'Source: $sourcePoints | Rendered: primary=$primaryRendered, secondary=$secondaryRendered '
                  '| Zoom window: ${(state.xStart * 100).toStringAsFixed(1)}%..${(state.xEnd * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataModeDropdown() {
    return DropdownButtonFormField<ChartDataMode>(
      initialValue: dataMode,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Data Mode',
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      items: const [
        DropdownMenuItem(value: ChartDataMode.regular, child: Text('regular')),
        DropdownMenuItem(value: ChartDataMode.auto, child: Text('auto')),
        DropdownMenuItem(value: ChartDataMode.large, child: Text('large')),
      ],
      onChanged: (value) {
        if (value == null) return;
        onDataModeChanged(value);
      },
    );
  }

  Widget _buildPrimaryTypeDropdown() {
    return DropdownButtonFormField<ChartType>(
      initialValue: primaryType,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Primary Type',
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      items: interactionReliabilityPrimaryTypes
          .map(
            (value) => DropdownMenuItem<ChartType>(
              value: value,
              child: Text(chartTypeToString(value)),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        onPrimaryTypeChanged(value);
      },
    );
  }

  Widget _buildStrategyDropdown() {
    return DropdownButtonFormField<SamplingStrategy?>(
      initialValue: samplingStrategy,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Sampling Strategy',
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      items: const [
        DropdownMenuItem<SamplingStrategy?>(value: null, child: Text('auto')),
        DropdownMenuItem<SamplingStrategy?>(
          value: SamplingStrategy.lttb,
          child: Text('lttb'),
        ),
        DropdownMenuItem<SamplingStrategy?>(
          value: SamplingStrategy.minMax,
          child: Text('minMax'),
        ),
        DropdownMenuItem<SamplingStrategy?>(
          value: SamplingStrategy.nth,
          child: Text('nth'),
        ),
      ],
      onChanged: dataMode == ChartDataMode.regular
          ? null
          : (value) => onSamplingStrategyChanged(value),
    );
  }
}
