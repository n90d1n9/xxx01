import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide FontWeight;

import 'simple_charts_showcase_gallery_options.dart';
import 'simple_charts_showcase_source.dart';
import 'simple_charts_showcase_widgets.dart';

List<Widget> simpleChartsApiPanels(SimpleChartsGalleryOptions options) => [
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'API Behavior',
    subtitle:
        'Shared widget hooks for empty, semantic, decorative, and tap states',
    source: simpleApiBehaviorSampleSource(options),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleChartsApiBehaviorDemo(
      barStyle: options.barStyle,
      trendStyle: options.trendStyle,
      showTooltips: options.showTooltips,
    ),
  ),
];

SimpleChartSampleSource? simpleApiBehaviorSampleSource(
  SimpleChartsGalleryOptions options,
) {
  if (!options.showSampleSource) return null;

  return SimpleChartSampleSource(
    sampleJson: simpleChartSourceJson(
      chartType: 'SimpleBarChart',
      title: 'API Behavior',
      subtitle: 'Shared widget hooks',
      data: {
        'data': simpleBarDataJson(_apiBehaviorBars),
        'sparkline': simpleTrendPointsJson(_apiBehaviorSparkline),
      },
      options: const {
        'emptyBuilder': 'custom WidgetBuilder',
        'semanticLabel': 'Custom accessibility summary',
        'excludeFromSemantics': 'decorative sparkline only',
        'showTooltip': false,
        'valueFormatter': 'compactCurrency',
        'onBarTap': 'updates selected bar status',
      },
    ),
    dartCode:
        '''
SimpleBarChart(
  data: data,
  style: SimpleBarChartStyle.${options.barStyle.name},
  semanticLabel: 'Quarterly revenue by segment',
  showTooltip: false,
  valueFormatter: compactCurrency,
  onBarTap: (item, index) => setState(() => selected = item.label),
)

SimpleBarChart(
  data: const [],
  emptyBuilder: (context) => const Center(child: Text('No rows ready')),
  semanticLabel: 'API behavior empty state chart.',
)

SimpleSparklineChart(
  points: trend,
  excludeFromSemantics: true,
)''',
  );
}

class SimpleChartsApiBehaviorDemo extends StatefulWidget {
  final SimpleBarChartStyle barStyle;
  final SimpleTrendChartStyle trendStyle;
  final bool showTooltips;

  const SimpleChartsApiBehaviorDemo({
    super.key,
    required this.barStyle,
    required this.trendStyle,
    required this.showTooltips,
  });

  @override
  State<SimpleChartsApiBehaviorDemo> createState() =>
      _SimpleChartsApiBehaviorDemoState();
}

class _SimpleChartsApiBehaviorDemoState
    extends State<SimpleChartsApiBehaviorDemo> {
  String _selectedLabel = 'Tap callback ready';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _ApiChartSlot(
                  label: 'Custom empty',
                  child: SimpleBarChart(
                    data: const [],
                    style: widget.barStyle,
                    showGrid: false,
                    showValues: false,
                    showTooltip: widget.showTooltips,
                    semanticLabel: 'API behavior empty state chart.',
                    emptyBuilder: _apiEmptyBuilder,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ApiChartSlot(
                  label: 'Formatter',
                  child: SimpleBarChart(
                    data: _apiBehaviorBars,
                    style: widget.barStyle,
                    showGrid: false,
                    showTrack: true,
                    showValues: true,
                    showTooltip: widget.showTooltips,
                    semanticLabel: 'Quarterly revenue by segment.',
                    valueFormatter: _compactCurrency,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _ApiChartSlot(
                  label: 'Decorative',
                  child: Center(
                    child: SimpleSparklineChart(
                      points: _apiBehaviorSparkline,
                      type: SimpleSparklineType.area,
                      style: widget.trendStyle,
                      height: 64,
                      color: colorScheme.tertiary,
                      showTooltip: false,
                      excludeFromSemantics: true,
                      valueFormatter: _compactCurrency,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ApiChartSlot(
                  label: _selectedLabel,
                  child: SimpleBarChart(
                    data: _apiBehaviorBars,
                    style: widget.barStyle,
                    orientation: SimpleBarChartOrientation.horizontal,
                    showGrid: false,
                    showTrack: false,
                    showValues: false,
                    showTooltip: false,
                    showActiveBar: true,
                    semanticLabel: 'Tap callback demo chart.',
                    valueFormatter: _compactCurrency,
                    onBarTap: (item, index) {
                      setState(() => _selectedLabel = 'Tapped ${item.label}');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _apiEmptyBuilder(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 22,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 4),
          Text(
            'No rows ready',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiChartSlot extends StatelessWidget {
  final String label;
  final Widget child;

  const _ApiChartSlot({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Expanded(child: child),
      ],
    );
  }
}

const _apiBehaviorBars = [
  SimpleBarChartData(label: 'SMB', value: 42),
  SimpleBarChartData(label: 'Mid', value: 68),
  SimpleBarChartData(label: 'Ent', value: 93),
];

const _apiBehaviorSparkline = [
  SimpleTrendPoint(label: 'Jan', value: 38),
  SimpleTrendPoint(label: 'Feb', value: 44),
  SimpleTrendPoint(label: 'Mar', value: 47),
  SimpleTrendPoint(label: 'Apr', value: 53),
  SimpleTrendPoint(label: 'May', value: 61),
  SimpleTrendPoint(label: 'Jun', value: 72),
];

String _compactCurrency(double value) => '\$${value.toStringAsFixed(0)}k';
