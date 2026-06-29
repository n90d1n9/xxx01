import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Chart extends StatelessWidget {
  const Chart({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const defaultPadding = 16.0;

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
              sections: paiChartSelectionData,
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: defaultPadding),
                Text(
                  "29.1",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 0.5,
                      ),
                ),
                Text("of 128GB")
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<PieChartSectionData> paiChartSelectionData = [
  PieChartSectionData(
    color: Colors.green[100],
    value: 25,
    showTitle: false,
    radius: 25,
  ),
  PieChartSectionData(
    color: Colors.blue[700],
    value: 20,
    showTitle: false,
    radius: 22,
  ),
  PieChartSectionData(
    color: Colors.amber[700],
    value: 10,
    showTitle: false,
    radius: 19,
  ),
  PieChartSectionData(
    color: Colors.red[700],
    value: 15,
    showTitle: false,
    radius: 16,
  ),
  PieChartSectionData(
    color: Colors.cyan[700],
    value: 25,
    showTitle: false,
    radius: 13,
  ),
];
