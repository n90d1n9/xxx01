import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';

// Example of usage
class ScatterChartExample extends StatelessWidget {
  const ScatterChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    return /* Scaffold(
      appBar: AppBar(
        title: const Text('Scatter Chart Example'),
      ),
      body:  */ Padding(
      padding: const EdgeInsets.all(16.0),
      child: ScatterBarChartWidget(
        config: ScatterChartConfig(
          title: TitlesData(text: 'Interactive Scatter Chart'),
          tooltip: ChartTooltip(show: true),
          legend: ChartLegend(show: true),
          toolbox: ChartToolbox(show: true),
          grid: GridData(show: true),
          xAxis: XYAxis(show: true),
          yAxis: XYAxis(show: true),
          minX: 0,
          maxX: 100,
          minY: 0,
          maxY: 100,
          dotSize: 6,
          //type: ChartType.scatter,
          series: [
            Series(
              name: 'Series A',
              type: ChartType.scatter,
              itemStyle: ItemStyle(color: 'blue'),
              data: [
                {'x': 10, 'y': 30, 'value': 5},
                {'x': 20, 'y': 40, 'value': 10},
                {'x': 30, 'y': 20, 'value': 15},
                {'x': 40, 'y': 60, 'value': 20},
                {'x': 50, 'y': 50, 'value': 25},
              ],
            ),
            Series(
              name: 'Series B',
              type: ChartType.scatter,
              itemStyle: ItemStyle(color: 'red'),
              data: [
                {'x': 15, 'y': 45, 'value': 8},
                {'x': 25, 'y': 35, 'value': 12},
                {'x': 35, 'y': 55, 'value': 16},
                {'x': 45, 'y': 25, 'value': 20},
                {'x': 55, 'y': 65, 'value': 24},
              ],
            ),
          ],
        ),
        height: 400,
      ),
      // ),
    );
  }
}

class ScatterInteractiveKnobExample extends StatelessWidget {
  final String dataMode;
  final int pointCount;
  final int samplingThreshold;
  final int samplingStrategyIndex;
  final bool showTooltip;

  const ScatterInteractiveKnobExample({
    super.key,
    this.dataMode = 'regular',
    this.pointCount = 2500,
    this.samplingThreshold = 600,
    this.samplingStrategyIndex = 0,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    final isRegular = dataMode == 'regular';
    final points = isRegular ? 20 : (pointCount < 100 ? 100 : pointCount);

    final json = <String, dynamic>{
      'type': 'scatter',
      'title': {
        'text': isRegular
            ? 'Scatter (regular mode)'
            : 'Scatter ($dataMode mode, $points points)',
      },
      'legend': {'show': true},
      'tooltip': {'show': showTooltip},
      'grid': {'show': true},
      'series': [
        {
          'name': 'Series A',
          'color': '#2563EB',
          'data': List.generate(points, (i) {
            final x = i.toDouble();
            final y = 32 + ((i * 7) % 47).toDouble();
            return {'x': x, 'y': y, 'value': (i % 30).toDouble()};
          }),
        },
        {
          'name': 'Series B',
          'color': '#DC2626',
          'data': List.generate(points, (i) {
            final x = (i + 3).toDouble();
            final y = 24 + ((i * 5) % 53).toDouble();
            return {'x': x, 'y': y, 'value': (i % 35).toDouble()};
          }),
        },
      ],
      'dataMode': dataMode,
      'sampling': isRegular
          ? {'enabled': false}
          : {
              'enabled': true,
              'threshold': samplingThreshold,
              'strategy': _strategyName(samplingStrategyIndex),
            },
    };

    return SizedBox(
      height: 400,
      child: TenunChartFromJson(
        jsonConfig: json,
        padding: const EdgeInsets.all(8),
      ),
    );
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
}

/* 
// These are mock classes to complement your provided classes
class ChartType {
  static const scatter = 'scatter';
  // Add other chart types as needed
}

class Series {
  final String? name;
  final String? type;
  final ItemStyle? itemStyle;
  final dynamic data;

  Series({
    this.name,
    this.type,
    this.itemStyle,
    this.data,
  });
}

class ItemStyle {
  final Color? color;

  ItemStyle({
    this.color,
  });
}

class Grid {
  final bool show;

  Grid({
    this.show = true,
  });
}

class TitlesData {
  final String text;

  TitlesData({
    required this.text,
  });
}

class ChartTooltip {
  final bool show;

  ChartTooltip({
    this.show = true,
  });
}

class ChartLegend {
  final bool show;

  ChartLegend({
    this.show = true,
  });
}

class ChartToolbox {
  final bool show;

  ChartToolbox({
    this.show = true,
  });
}
 */
