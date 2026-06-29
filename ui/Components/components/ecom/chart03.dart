import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart03 extends StatefulWidget {
  const Chart03({Key? key}) : super(key: key);

  @override
  State<Chart03> createState() => _Chart03State();
}

class _Chart03State extends State<Chart03> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: const Icon(Icons.menu),
        actions: const [
          Icon(Icons.notifications),
          Icon(Icons.settings),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text('30 DAYS'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGauge(
                  title: 'Revenues',
                  value: 9.84,
                  maxValue: 10,
                ),
                _buildGauge(
                  title: 'Cash flow',
                  value: 14.68,
                  maxValue: 20,
                ),
                _buildGauge(
                  title: 'Balance',
                  value: 44.99,
                  maxValue: 50,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Balance Trend',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'USD 44 992.00',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: SfCartesianChart(
                      primaryXAxis: NumericAxis(
                        majorGridLines: const MajorGridLines(width: 0),
                        minorGridLines: const MinorGridLines(width: 0),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                      ),
                      primaryYAxis: NumericAxis(
                        majorGridLines: const MajorGridLines(width: 0),
                        minorGridLines: const MinorGridLines(width: 0),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                      ),
                      series: [
                        LineSeries<ChartData, num>(
                          dataSource: <ChartData>[
                            ChartData(0, 10),
                            ChartData(1, 30),
                            ChartData(2, 20),
                            ChartData(3, 40),
                            ChartData(4, 45),
                          ],
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'USD 44 992.00',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGauge({
    required String title,
    required double value,
    required double maxValue,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: maxValue,
                ranges: <GaugeRange>[
                  GaugeRange(
                    startValue: 0,
                    endValue: maxValue / 3,
                    color: Colors.green,
                  ),
                  GaugeRange(
                    startValue: maxValue / 3,
                    endValue: maxValue * 2 / 3,
                    color: Colors.yellow,
                  ),
                  GaugeRange(
                    startValue: maxValue * 2 / 3,
                    endValue: maxValue,
                    color: Colors.red,
                  ),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(
                    value: value,
                    needleLength: 0.8,
                    needleStartWidth: 2,
                    needleEndWidth: 4,
                    knobStyle: KnobStyle(
                      knobRadius: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Text(
                      value.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    positionFactor: 0.5,
                    angle: 90,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${value.toStringAsFixed(2)}K',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final num x;
  final num y;
}