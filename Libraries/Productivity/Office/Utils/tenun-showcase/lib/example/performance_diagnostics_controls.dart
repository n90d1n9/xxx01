import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide FontWeight;

class PerformanceDiagnosticsControls extends StatelessWidget {
  final ChartType chartType;
  final ChartDataMode dataMode;
  final SamplingStrategy? samplingStrategy;
  final bool useCache;
  final bool useIsolate;
  final bool warmCache;
  final bool running;
  final int points;
  final int renderThreshold;
  final int isolateThreshold;
  final int signalLength;
  final int renderedPoints;
  final int diagnosticOutputPoints;
  final ValueChanged<ChartType> onChartTypeChanged;
  final ValueChanged<ChartDataMode> onDataModeChanged;
  final ValueChanged<SamplingStrategy?> onSamplingStrategyChanged;
  final ValueChanged<bool> onUseCacheChanged;
  final ValueChanged<bool> onUseIsolateChanged;
  final ValueChanged<bool> onWarmCacheChanged;
  final ValueChanged<int> onPointsChanged;
  final ValueChanged<int> onRenderThresholdChanged;
  final ValueChanged<int> onIsolateThresholdChanged;
  final VoidCallback onRunDiagnostics;
  final VoidCallback onClearCache;

  const PerformanceDiagnosticsControls({
    super.key,
    required this.chartType,
    required this.dataMode,
    required this.samplingStrategy,
    required this.useCache,
    required this.useIsolate,
    required this.warmCache,
    required this.running,
    required this.points,
    required this.renderThreshold,
    required this.isolateThreshold,
    required this.signalLength,
    required this.renderedPoints,
    required this.diagnosticOutputPoints,
    required this.onChartTypeChanged,
    required this.onDataModeChanged,
    required this.onSamplingStrategyChanged,
    required this.onUseCacheChanged,
    required this.onUseIsolateChanged,
    required this.onWarmCacheChanged,
    required this.onPointsChanged,
    required this.onRenderThresholdChanged,
    required this.onIsolateThresholdChanged,
    required this.onRunDiagnostics,
    required this.onClearCache,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
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
                SizedBox(width: 170, child: _buildChartTypeDropdown()),
                SizedBox(width: 170, child: _buildDataModeDropdown()),
                SizedBox(width: 190, child: _buildStrategyDropdown()),
                FilterChip(
                  label: const Text('Cache'),
                  selected: useCache,
                  onSelected: onUseCacheChanged,
                ),
                FilterChip(
                  label: const Text('Isolate'),
                  selected: useIsolate,
                  onSelected: onUseIsolateChanged,
                ),
                FilterChip(
                  label: const Text('Warm Cache Twice'),
                  selected: warmCache,
                  onSelected: onWarmCacheChanged,
                ),
                OutlinedButton.icon(
                  onPressed: running ? null : onRunDiagnostics,
                  icon: const Icon(Icons.speed, size: 16),
                  label: const Text('Run Diagnostics'),
                ),
                OutlinedButton.icon(
                  onPressed: onClearCache,
                  icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                  label: const Text('Clear Cache'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Dataset Size: $points points'),
            Slider(
              value: points.toDouble(),
              min: 1000,
              max: 50000,
              divisions: 49,
              label: points.toString(),
              onChanged: (value) => onPointsChanged(value.round()),
            ),
            Text('Render Threshold: $renderThreshold points'),
            Slider(
              value: renderThreshold.toDouble(),
              min: 100,
              max: 5000,
              divisions: 49,
              label: renderThreshold.toString(),
              onChanged: (value) => onRenderThresholdChanged(value.round()),
            ),
            Text('Isolate Threshold: $isolateThreshold points'),
            Slider(
              value: isolateThreshold.toDouble(),
              min: 1000,
              max: 30000,
              divisions: 29,
              label: isolateThreshold.toString(),
              onChanged: (value) => onIsolateThresholdChanged(value.round()),
            ),
            Text(
              'Chart render data: source=$signalLength, rendered=$renderedPoints | '
              'Diagnostics output=$diagnosticOutputPoints',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeDropdown() {
    return DropdownButtonFormField<ChartType>(
      initialValue: chartType,
      decoration: const InputDecoration(
        labelText: 'Chart Type',
        isDense: true,
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: ChartType.line, child: Text('line')),
        DropdownMenuItem(value: ChartType.area, child: Text('area')),
        DropdownMenuItem(value: ChartType.bar, child: Text('bar')),
      ],
      onChanged: (value) {
        if (value == null) return;
        onChartTypeChanged(value);
      },
    );
  }

  Widget _buildDataModeDropdown() {
    return DropdownButtonFormField<ChartDataMode>(
      initialValue: dataMode,
      decoration: const InputDecoration(
        labelText: 'Data Mode',
        isDense: true,
        border: OutlineInputBorder(),
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

  Widget _buildStrategyDropdown() {
    return DropdownButtonFormField<SamplingStrategy?>(
      initialValue: samplingStrategy,
      decoration: const InputDecoration(
        labelText: 'Sampling',
        isDense: true,
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('auto')),
        DropdownMenuItem(value: SamplingStrategy.lttb, child: Text('lttb')),
        DropdownMenuItem(value: SamplingStrategy.minMax, child: Text('minMax')),
        DropdownMenuItem(value: SamplingStrategy.nth, child: Text('nth')),
      ],
      onChanged: onSamplingStrategyChanged,
    );
  }
}
