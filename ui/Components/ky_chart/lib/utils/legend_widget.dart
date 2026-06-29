import 'package:flutter/material.dart';
import 'package:ky_chart/model/chart_model.dart';
import 'package:ky_chart/utils/helper.dart';

import '../model/series.dart';

class LegendWidget extends StatelessWidget {
  final ChartConfig config;
  const LegendWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    List<Series> series = config.series;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: series.map((seriesItem) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: stringToColor(seriesItem.itemStyle!.color),
            ),
            const SizedBox(width: 4),
            Text(seriesItem.name!),
          ],
        );
      }).toList(),
    );
  }
}
