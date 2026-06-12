import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

class ZoomableLegacyChartsExample extends StatefulWidget {
  const ZoomableLegacyChartsExample({super.key});

  @override
  State<ZoomableLegacyChartsExample> createState() =>
      _ZoomableLegacyChartsExampleState();
}

class _ZoomableLegacyChartsExampleState
    extends State<ZoomableLegacyChartsExample> {
  final ChartSyncGroup _syncGroup = ChartSyncGroup();
  late final ChartController _ctrlA;
  late final ChartController _ctrlB;

  @override
  void initState() {
    super.initState();
    _ctrlA = _syncGroup.add(ChartController());
    _ctrlB = _syncGroup.add(ChartController());
  }

  @override
  void dispose() {
    _syncGroup.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Sync Group: Zoom or pan one chart to update the other.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: TenunChart(
            config: LineChartConfig(
              title: TitlesData(text: 'Primary (Line)'),
              xAxis: XYAxis(data: List.generate(50, (i) => 'T$i')),
              series: [
                Series(
                  type: ChartType.line,
                  name: 'Trend',
                  data: List.generate(50, (i) => math.sin(i / 5) * 10 + 20),
                  color: Colors.blue,
                ),
              ],
              controller: _ctrlA,
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: TenunChart(
            config: BarChartConfig(
              title: TitlesData(text: 'Secondary (Bar)'),
              xAxis: XYAxis(data: List.generate(50, (i) => 'T$i')),
              series: [
                Series(
                  type: ChartType.bar,
                  name: 'Volume',
                  data: List.generate(
                    50,
                    (i) => (math.cos(i / 5) * 5 + 10).abs(),
                  ),
                  color: Colors.green,
                ),
              ],
              controller: _ctrlB,
            ),
          ),
        ),
      ],
    );
  }
}

class DrilldownLegacyBarExample extends StatefulWidget {
  const DrilldownLegacyBarExample({super.key});

  @override
  State<DrilldownLegacyBarExample> createState() =>
      _DrilldownLegacyBarExampleState();
}

class _DrilldownLegacyBarExampleState extends State<DrilldownLegacyBarExample> {
  late final List<double> _rootData;

  @override
  void initState() {
    super.initState();
    _rootData = List.generate(24, (i) => 60 + math.sin(i / 3) * 20 + i * 1.8);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Drilldown Example (Consolidated API)'),
        ),
        Expanded(
          child: TenunChart(
            config: BarChartConfig(
              title: TitlesData(text: 'Monthly Sales'),
              xAxis: XYAxis(data: List.generate(24, (i) => 'M${i + 1}')),
              series: [
                Series(
                  type: ChartType.bar,
                  name: 'Revenue',
                  data: _rootData,
                  color: Colors.teal,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
