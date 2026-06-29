import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'gchart_model.dart';

class GLine extends StatefulWidget {
  const GLine({Key? key, this.config}) : super(key: key);
  final ChartConfig? config;

  @override
  State<GLine> createState() => _GLineState();
}

class _GLineState extends State<GLine> {
  @override
  Widget build(BuildContext context) {
    var xLength = widget.config!.xAxis!.data!.length;

    List<LineChartBarData> seriesdata = [];
    List<FlSpot> lbd = [];
    for (var el in widget.config!.series!) {
      for (var n = 0; n < el.data!.length; n++) {
        lbd.add(FlSpot(n.toDouble(), el.data![n].value! / nodeValue));
      }

      seriesdata.add(LineChartBarData(
        isCurved: false,
        //  color: AppColors.contentColorGreen,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: lbd,
      ));
    }
    return LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: tooltipsItem,
              getTooltipColor: (touchedSpot) => Colors.amber.withOpacity(0.8),
            ),
          ),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1,
                getTitlesWidget: bottomTitleWidgets,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                getTitlesWidget: leftTitleWidgets,
                showTitles: true,
                interval: 1,
                reservedSize: 40,
              ),
            ),
          ),
          borderData: borderData,
          lineBarsData: seriesdata,
          minX: 0,
          maxX: xLength.toDouble() - 1,
          maxY: widget.config!.maxY,
          minY: 0,
        ),
        duration: const Duration(milliseconds: 250));
  }

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.amber, width: 4),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    Text text = const Text('');
    for (var i = 0; i < widget.config!.xAxis!.data!.length; i++) {
      if (value.toInt() == i) {
        text = Text(
          widget.config!.xAxis!.data![i],
          style: style,
        );
      }
    }
    return text;
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    return Text('${nodeValue * value}',
        style: style, textAlign: TextAlign.center);
  }

  double get nodeValue => widget.config!.maxValueY! / widget.config!.maxY!;

  List<LineTooltipItem?> tooltipsItem(List<LineBarSpot> touchedBarSpots) {
    return touchedBarSpots.map((barSpot) {
      final flSpot = barSpot;
      /* if (flSpot.x == 0 || flSpot.x == 6) {
        return null;
      } */

      TextAlign textAlign;
      switch (flSpot.x.toInt()) {
        case 1:
          textAlign = TextAlign.left;
          break;
        case 4:
          textAlign = TextAlign.right;
          break;
        default:
          textAlign = TextAlign.center;
      }

      return LineTooltipItem(
        'Data:\n',
        const TextStyle(
          //color: widget.tooltipTextColor,
          fontWeight: FontWeight.bold,
        ),
        textAlign: textAlign,
        children: tooltipLabels(flSpot.x.toInt())
      );
    }).toList();
  }

  List<TextSpan> tooltipLabels(index) {
    List<TextSpan> labels = [];
    for (var el in widget.config!.series!) {
      labels.add(TextSpan(text: '${el.name}\n'));
      labels.add(TextSpan(text: '${el.data![index].value}\n'));
    }
    return labels;
  }
}
