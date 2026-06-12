import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';
import 'package:tenun_pro/tenun_pro_financial.dart'
    show registerTenunProFinancialCharts;

class LargeDataSamplingExample extends StatefulWidget {
  const LargeDataSamplingExample({super.key});

  @override
  State<LargeDataSamplingExample> createState() =>
      _LargeDataSamplingExampleState();
}

class _LargeDataSamplingExampleState extends State<LargeDataSamplingExample> {
  static const _kChartTypes = <ChartType>[
    ChartType.line,
    ChartType.area,
    ChartType.bar,
    ChartType.scatter,
    ChartType.candlestick,
  ];

  late bool _enabled;
  late int _threshold;
  SamplingStrategy? _strategy;
  ChartDataMode _mode = ChartDataMode.auto;
  int _points = 12000;
  ChartType _type = ChartType.line;

  late final bool _prevEnabled;
  late final int _prevThreshold;
  late final SamplingStrategy? _prevStrategy;
  late final ChartDataMode _prevMode;

  @override
  void initState() {
    super.initState();
    registerTenunProFinancialCharts(includeCore: true);
    _prevEnabled = LargeDataSamplingConfig.enabled;
    _prevThreshold = LargeDataSamplingConfig.threshold;
    _prevStrategy = LargeDataSamplingConfig.strategy;
    _prevMode = LargeDataSamplingConfig.mode;

    _enabled = LargeDataSamplingConfig.enabled;
    _threshold = LargeDataSamplingConfig.threshold;
    _strategy = LargeDataSamplingConfig.strategy;
    _mode = LargeDataSamplingConfig.mode;
    _applyGlobalSamplingConfig();
  }

  @override
  void dispose() {
    LargeDataSamplingConfig.enabled = _prevEnabled;
    LargeDataSamplingConfig.threshold = _prevThreshold;
    LargeDataSamplingConfig.strategy = _prevStrategy;
    LargeDataSamplingConfig.mode = _prevMode;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chartJson = _buildChartJson();
    final cfg = BaseChartConfig.fromJson(chartJson);
    final sourceLen = (chartJson['series'] as List).isNotEmpty
        ? ((chartJson['series'] as List).first as Map)['data'].length as int
        : 0;
    final renderedLen = cfg.series.first.data?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Large Data Sampling Lab', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                label: const Text('Sampling Enabled'),
                selected: _enabled,
                onSelected: (value) {
                  setState(() {
                    _enabled = value;
                    _applyGlobalSamplingConfig();
                  });
                },
              ),
              _buildDataModeDropdown(),
              _buildTypeDropdown(),
              _buildStrategyDropdown(),
            ],
          ),
          const SizedBox(height: 8),
          Text('Dataset Size: $_points points'),
          Slider(
            value: _points.toDouble(),
            min: 1000,
            max: 50000,
            divisions: 49,
            label: _points.toString(),
            onChanged: (value) {
              setState(() {
                _points = value.round();
              });
            },
          ),
          const SizedBox(height: 2),
          Text('Render Threshold: $_threshold points'),
          Slider(
            value: _threshold.toDouble(),
            min: 100,
            max: 4000,
            divisions: 39,
            label: _threshold.toString(),
            onChanged: (value) {
              setState(() {
                _threshold = value.round();
                _applyGlobalSamplingConfig();
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Source points: $sourceLen | Rendered points: $renderedLen | Reduction: ${_reductionPercent(sourceLen, renderedLen)}%',
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TenunChart(config: cfg, padding: const EdgeInsets.all(8)),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<ChartType>(
        initialValue: _type,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Chart Type',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: _kChartTypes
            .map(
              (t) => DropdownMenuItem<ChartType>(
                value: t,
                child: Text(
                  chartTypeToString(t),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            _type = value;
          });
        },
      ),
    );
  }

  Widget _buildDataModeDropdown() {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<ChartDataMode>(
        initialValue: _mode,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Data Mode',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: const [
          DropdownMenuItem(
            value: ChartDataMode.regular,
            child: Text('regular (simple)', overflow: TextOverflow.ellipsis),
          ),
          DropdownMenuItem(
            value: ChartDataMode.auto,
            child: Text('auto', overflow: TextOverflow.ellipsis),
          ),
          DropdownMenuItem(
            value: ChartDataMode.large,
            child: Text('large', overflow: TextOverflow.ellipsis),
          ),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            _mode = value;
            _applyGlobalSamplingConfig();
          });
        },
      ),
    );
  }

  Widget _buildStrategyDropdown() {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<SamplingStrategy?>(
        initialValue: _strategy,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Sampling Strategy',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: const [
          DropdownMenuItem<SamplingStrategy?>(
            value: null,
            child: Text('auto', overflow: TextOverflow.ellipsis),
          ),
          DropdownMenuItem<SamplingStrategy?>(
            value: SamplingStrategy.lttb,
            child: Text('lttb', overflow: TextOverflow.ellipsis),
          ),
          DropdownMenuItem<SamplingStrategy?>(
            value: SamplingStrategy.minMax,
            child: Text('minMax', overflow: TextOverflow.ellipsis),
          ),
          DropdownMenuItem<SamplingStrategy?>(
            value: SamplingStrategy.nth,
            child: Text('nth', overflow: TextOverflow.ellipsis),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _strategy = value;
            _applyGlobalSamplingConfig();
          });
        },
      ),
    );
  }

  Map<String, dynamic> _buildChartJson() {
    return switch (_type) {
      ChartType.bar => _buildBarJson(),
      ChartType.area => _buildAreaJson(),
      ChartType.scatter => _buildScatterJson(),
      ChartType.candlestick => _buildCandlestickJson(),
      _ => _buildLineJson(),
    };
  }

  Map<String, dynamic> _buildLineJson() {
    return {
      'type': 'line',
      'title': {
        'text':
            'Line $_points pts | mode:${_mode.name} | th:$_threshold | ${_strategy?.name ?? 'auto'}',
      },
      'xAxis': {'data': List.generate(_points, (i) => '$i')},
      'series': [
        {
          'name': 'line',
          'data': List.generate(
            _points,
            (i) => (60 + 22 * _sin(i * 0.015) + 9 * _sin(i * 0.18)).toDouble(),
          ),
          'color': '#2563EB',
        },
      ],
      'showDots': false,
      'curveSmoothness': 0.22,
      'tooltip': {'show': true},
      'legend': {'show': true},
    };
  }

  Map<String, dynamic> _buildAreaJson() {
    return {
      'type': 'area',
      'title': {
        'text':
            'Area $_points pts | mode:${_mode.name} | th:$_threshold | ${_strategy?.name ?? 'auto'}',
      },
      'xAxis': {'data': List.generate(_points, (i) => '$i')},
      'series': [
        {
          'name': 'area',
          'data': List.generate(
            _points,
            (i) => (80 + 26 * _sin(i * 0.011) + 5 * _sin(i * 0.17)).toDouble(),
          ),
          'color': '#059669',
        },
      ],
      'showDots': false,
      'gradientArea': true,
      'tooltip': {'show': true},
      'legend': {'show': true},
    };
  }

  Map<String, dynamic> _buildBarJson() {
    return {
      'type': 'bar',
      'title': {
        'text':
            'Bar $_points pts | mode:${_mode.name} | th:$_threshold | ${_strategy?.name ?? 'auto'}',
      },
      'xAxis': {'data': List.generate(_points, (i) => '$i')},
      'series': [
        {
          'name': 'bar',
          'data': List.generate(
            _points,
            (i) => (40 + 30 * _sin(i * 0.045) + (i % 15)).toDouble(),
          ),
          'color': '#DC2626',
        },
      ],
      'barWidth': 5,
      'tooltip': {'show': true},
      'legend': {'show': true},
    };
  }

  Map<String, dynamic> _buildScatterJson() {
    return {
      'type': 'scatter',
      'title': {
        'text':
            'Scatter $_points pts | mode:${_mode.name} | th:$_threshold | ${_strategy?.name ?? 'auto'}',
      },
      'series': [
        {
          'name': 'scatter',
          'data': List.generate(
            _points,
            (i) => [
              i.toDouble(),
              (55 + 20 * _sin(i * 0.03) + 2 * _sin(i * 0.37)).toDouble(),
            ],
          ),
          'color': '#7C3AED',
        },
      ],
      'tooltip': {'show': true},
      'legend': {'show': true},
    };
  }

  Map<String, dynamic> _buildCandlestickJson() {
    return {
      'type': 'candlestick',
      'title': {
        'text':
            'Candlestick $_points pts | mode:${_mode.name} | th:$_threshold | ${_strategy?.name ?? 'auto'}',
      },
      'xAxis': {'data': List.generate(_points, (i) => '$i')},
      'series': [
        {
          'name': 'ohlc',
          'data': List.generate(_points, (i) {
            final base = 100 + 12 * _sin(i * 0.012) + 5 * _sin(i * 0.19);
            final open = base + 2 * _sin(i * 0.13);
            final close = base + 2 * _sin(i * 0.16 + 0.9);
            final high = (open > close ? open : close) + 2.5;
            final low = (open < close ? open : close) - 2.5;
            return [open, high, low, close];
          }),
        },
      ],
      'tooltip': {'show': true},
      'legend': {'show': false},
    };
  }

  void _applyGlobalSamplingConfig() {
    LargeDataSamplingConfig.enabled = _enabled;
    LargeDataSamplingConfig.threshold = _threshold;
    LargeDataSamplingConfig.strategy = _strategy;
    LargeDataSamplingConfig.mode = _mode;
  }

  int _reductionPercent(int source, int rendered) {
    if (source <= 0) return 0;
    final ratio = (source - rendered) / source;
    final pct = (ratio * 100).round();
    return pct < 0 ? 0 : pct;
  }

  double _sin(num value) {
    return math.sin(value.toDouble());
  }
}
