import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';

class ChartTypeSwitchExample extends StatefulWidget {
  final String dataMode;
  final int pointCount;
  final int samplingThreshold;
  final int samplingStrategyIndex;

  const ChartTypeSwitchExample({
    super.key,
    this.dataMode = 'regular',
    this.pointCount = 2500,
    this.samplingThreshold = 600,
    this.samplingStrategyIndex = 0,
  });

  @override
  State<ChartTypeSwitchExample> createState() => _ChartTypeSwitchExampleState();
}

class _ChartTypeSwitchExampleState extends State<ChartTypeSwitchExample> {
  final ChartController _controller = ChartController();

  static final Map<String, dynamic> _seedJsonBase = {
    'type': 'bar',
    'title': {'text': 'Runtime Type Switcher'},
    'xAxis': {
      'show': true,
      'data': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    },
    'yAxis': {'show': true, 'precision': 0},
    'grid': {'show': true, 'showHorizontalLines': true},
    'legend': {'show': true},
    'tooltip': {'show': true, 'formatter': '{a}: {c}'},
    'series': [
      {
        'name': '2024',
        'data': [120, 132, 101, 134, 90, 180],
        'color': '#4A90E2',
      },
      {
        'name': '2023',
        'data': [90, 110, 85, 105, 65, 150],
        'color': '#E57373',
      },
    ],
  };

  late Map<String, dynamic> _currentJson;
  ChartType _selectedType = ChartType.line;
  _SwitchPreset _switchPreset = _SwitchPreset.balanced;
  bool _includeCurrentType = false;
  bool _forceCrossShape = false;
  List<ChartType> _rankedTargets = const [];

  @override
  void initState() {
    super.initState();
    _currentJson = _buildSeedJson();
    _rankedTargets = _computeRankedTargets();
  }

  @override
  void didUpdateWidget(covariant ChartTypeSwitchExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataMode != widget.dataMode ||
        oldWidget.pointCount != widget.pointCount ||
        oldWidget.samplingThreshold != widget.samplingThreshold ||
        oldWidget.samplingStrategyIndex != widget.samplingStrategyIndex) {
      _currentJson = _buildSeedJson();
      _rankedTargets = _computeRankedTargets();
      _selectedType = _rankedTargets.isNotEmpty
          ? _rankedTargets.first
          : _currentChartType;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ChartType get _currentChartType =>
      getChartType((_currentJson['type'] ?? 'line').toString());

  @override
  Widget build(BuildContext context) {
    final shape = inferSeriesDataShape(_currentJson).name;
    final compatibleLabel = _rankedTargets.isEmpty
        ? 'No compatible target'
        : _rankedTargets.take(6).map((t) => t.name).join(', ');

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 170,
                child: DropdownButton<ChartType>(
                  value: _selectedType,
                  isExpanded: true,
                  items:
                      [
                            ChartType.bar,
                            ChartType.groupedBar,
                            ChartType.line,
                            ChartType.area,
                            ChartType.scatter,
                            ChartType.pie,
                            ChartType.donut,
                            ChartType.treemap,
                            ChartType.sunburst,
                          ]
                          .map(
                            (t) => DropdownMenuItem<ChartType>(
                              value: t,
                              child: Text(t.name.toUpperCase()),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 190,
                child: DropdownButton<_SwitchPreset>(
                  value: _switchPreset,
                  isExpanded: true,
                  items: _SwitchPreset.values
                      .map(
                        (p) => DropdownMenuItem<_SwitchPreset>(
                          value: p,
                          child: Text(p.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _switchPreset = value;
                      _rankedTargets = _computeRankedTargets();
                    });
                  },
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: _switchManual,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Switch Manual'),
              ),
              FilledButton.icon(
                onPressed: _switchAutoBest,
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Auto Best'),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _controller.replay(),
                tooltip: 'Replay Animation',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Include Current in Auto'),
                selected: _includeCurrentType,
                onSelected: (value) {
                  setState(() {
                    _includeCurrentType = value;
                    _rankedTargets = _computeRankedTargets();
                  });
                },
              ),
              FilterChip(
                label: const Text('Force Cross-Shape Manual'),
                selected: _forceCrossShape,
                onSelected: (value) {
                  setState(() {
                    _forceCrossShape = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Current: ${_currentChartType.name} | Shape: $shape',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 2),
          Text(
            'Ranked targets: $compatibleLabel',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TenunChartJson(
              jsonConfig: _currentJson,
              controller: _controller,
            ),
          ),
        ],
      ),
    );
  }

  void _switchManual() {
    try {
      final switched = switchChartTypeForSeriesShape(
        _currentJson,
        targetType: _selectedType,
        force: _forceCrossShape,
      );
      setState(() {
        _currentJson = switched;
        _rankedTargets = _computeRankedTargets();
      });
    } on StateError catch (e) {
      _showMessage(e.message);
    }
  }

  void _switchAutoBest() {
    try {
      final switched = switchChartTypeForSeriesShapeAuto(
        _currentJson,
        preferredOrder: _switchPreset.preferredOrder,
        includeCurrentType: _includeCurrentType,
      );
      setState(() {
        _currentJson = switched;
        _selectedType = _currentChartType;
        _rankedTargets = _computeRankedTargets();
      });
    } on StateError catch (e) {
      _showMessage(e.message);
    }
  }

  List<ChartType> _computeRankedTargets() {
    return rankedCompatibleChartTypesForJson(
      _currentJson,
      preferredOrder: _switchPreset.preferredOrder,
      includeCurrentType: _includeCurrentType,
    );
  }

  Map<String, dynamic> _buildSeedJson() {
    final config =
        jsonDecode(jsonEncode(_seedJsonBase)) as Map<String, dynamic>;
    final isRegular = widget.dataMode == 'regular';
    final points = isRegular
        ? ((_seedJsonBase['xAxis'] as Map<String, dynamic>)['data'] as List)
              .length
        : (widget.pointCount < 100 ? 100 : widget.pointCount);

    config['title'] = {
      'text': isRegular
          ? 'Runtime Type Switcher (regular)'
          : 'Runtime Type Switcher (${widget.dataMode}, $points points)',
    };

    config['dataMode'] = widget.dataMode;
    config['sampling'] = isRegular
        ? {'enabled': false}
        : {
            'enabled': true,
            'threshold': widget.samplingThreshold,
            'strategy': _strategyName(widget.samplingStrategyIndex),
          };

    if (!isRegular) {
      config['xAxis'] = {
        ...(config['xAxis'] as Map<String, dynamic>),
        'data': List.generate(points, (i) => '$i'),
      };
      final rawSeries = (config['series'] as List<dynamic>)
          .whereType<Map>()
          .toList();
      final patched = <Map<String, dynamic>>[];
      for (int si = 0; si < rawSeries.length; si++) {
        final s = Map<String, dynamic>.from(rawSeries[si]);
        s['data'] = List.generate(points, (i) {
          final base = 72 + (si * 18);
          final wave = ((i * (si + 4)) % 57) - 28;
          final trend = (i % 21);
          return (base + wave + trend).toDouble();
        });
        patched.add(s);
      }
      config['series'] = patched;
    }

    return config;
  }

  String? _strategyName(int index) {
    switch (index) {
      case 1:
        return 'lttb';
      case 2:
        return 'minMax';
      case 3:
        return 'nth';
      default:
        return null;
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

enum _SwitchPreset {
  balanced('Balanced'),
  presentation('Presentation'),
  hierarchyFirst('Hierarchy First');

  const _SwitchPreset(this.label);

  final String label;

  List<ChartType> get preferredOrder {
    switch (this) {
      case _SwitchPreset.balanced:
        return const [
          ChartType.line,
          ChartType.area,
          ChartType.groupedBar,
          ChartType.scatter,
          ChartType.pie,
          ChartType.donut,
          ChartType.treemap,
          ChartType.sunburst,
        ];
      case _SwitchPreset.presentation:
        return const [
          ChartType.area,
          ChartType.line,
          ChartType.donut,
          ChartType.pie,
          ChartType.groupedBar,
          ChartType.scatter,
          ChartType.treemap,
          ChartType.sunburst,
        ];
      case _SwitchPreset.hierarchyFirst:
        return const [
          ChartType.treemap,
          ChartType.sunburst,
          ChartType.donut,
          ChartType.pie,
          ChartType.area,
          ChartType.line,
          ChartType.groupedBar,
          ChartType.scatter,
        ];
    }
  }
}
