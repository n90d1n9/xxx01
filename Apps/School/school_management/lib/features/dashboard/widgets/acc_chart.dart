import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/dashboard_data.dart';

class AcquisitionChart extends StatelessWidget {
  final AcquisitionData acquisitionData;

  const AcquisitionChart({super.key, required this.acquisitionData});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: acquisitionData.reviews.toDouble(),
                    color: Colors.pink.shade300,
                    title: '${acquisitionData.reviews}%',
                    radius: 80,
                    titleStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: acquisitionData.education.toDouble(),
                    color: Colors.amber.shade300,
                    title: '${acquisitionData.education}%',
                    radius: 80,
                    titleStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: acquisitionData.deals.toDouble(),
                    color: Colors.blue.shade300,
                    title: '${acquisitionData.deals}%',
                    radius: 80,
                    titleStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
                centerSpaceRadius: 40,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  acquisitionData.reviews.toString(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text('Reviews'),
                const SizedBox(height: 16),
                Text(
                  acquisitionData.education.toString(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text('Education'),
                const SizedBox(height: 16),
                Text(
                  acquisitionData.deals.toString(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text('Deals'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
