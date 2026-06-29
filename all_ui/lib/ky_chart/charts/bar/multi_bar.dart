import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ky_chart/utils/helper.dart';

import 'bar_config.dart';

class MultiBarChartWidget extends StatelessWidget {
  final BarChartConfig config;

  const MultiBarChartWidget({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          if (config.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                config.title!.text!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ),

          // Legend
          if (config.legend != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: _buildLegendItems(context),
              ),
            ),

          // Chart
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: _getAlignment(),
                maxY: config.maxY,
                barTouchData: BarTouchData(
                  enabled: config.tooltip != null,
                  touchTooltipData: BarTouchTooltipData(
                    //tooltipBgColor: Colors.blueGrey.shade800,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${_getSeriesName(rodIndex)}: ${rod.toY.round()}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: config.grid != null,
                  drawVerticalLine: config.grid?.showVerticalLines ?? false,
                  drawHorizontalLine: config.grid?.showHorizontalLines ?? false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: stringToColor(config.grid!.lineStyle.color),
                      strokeWidth: config.grid?.lineStyle?.width ?? 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: stringToColor(config.grid!.lineStyle.color),
                      strokeWidth: config.grid?.lineStyle?.width ?? 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    left: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                ),
                barGroups: _createBarGroups(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 500),
              swapAnimationCurve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLegendItems(BuildContext context) {
    List<Widget> items = [];

    for (int i = 0; i < config.series.length; i++) {
      final series = config.series[i];
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getSeriesColor(i),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              series.name ?? 'Series ${i + 1}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    }

    return items;
  }

  List<BarChartGroupData> _createBarGroups() {
    Map<int, List<BarChartRodData>> groupedData = {};

    // Group the data by x-axis value
    for (int seriesIndex = 0;
        seriesIndex < config.series.length;
        seriesIndex++) {
      final series = config.series[seriesIndex];

      for (int i = 0; i < series.data!.length; i++) {
        final dataItem = series.data![i];
        final xValue = dataItem[0].toInt();
        final yValue = dataItem[1].toDouble();

        if (!groupedData.containsKey(xValue)) {
          groupedData[xValue] = [];
        }

        groupedData[xValue]!.add(
          BarChartRodData(
            toY: yValue,
            color: _getSeriesColor(seriesIndex),
            width: config.barWidth,
            borderRadius: config.barBorderRadius,
          ),
        );
      }
    }

    // Create bar groups from the grouped data
    return groupedData.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: entry.value,
        showingTooltipIndicators: [],
      );
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  Color _getSeriesColor(int index) {
    final defaultColors = [
      const Color(0xFF5470C6),
      const Color(0xFF91CC75),
      const Color(0xFFFAC858),
      const Color(0xFFEE6666),
      const Color(0xFF73C0DE),
      const Color(0xFF3BA272),
      const Color(0xFFFC8452),
      const Color(0xFF9A60B4),
      const Color(0xFFEA7CCC),
    ];

    if (index < config.series.length &&
        config.series[index].itemStyle != null) {
      return stringToColor(config.series[index].itemStyle!.color);
    }

    return defaultColors[index % defaultColors.length];
  }

  String _getSeriesName(int index) {
    if (index < config.series.length && config.series[index].name != null) {
      return config.series[index].name!;
    }
    return 'Series ${index + 1}';
  }

  BarChartAlignment _getAlignment() {
    switch (config.alignment) {
      case BarChartAlignment.start:
        return BarChartAlignment.start;
      case BarChartAlignment.end:
        return BarChartAlignment.end;
      case BarChartAlignment.center:
      default:
        return BarChartAlignment.center;
    }
  }
}
