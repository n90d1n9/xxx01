import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../charts/candle/candle_stick_config.dart';
import '../charts/candle/candlestick_data.dart';
import '../charts/candle/candlestrick_chart.dart';
import '../model/chart_model.dart';
import '../model/chart_type.dart';
import '../model/grid.dart';
import '../model/legend.dart';
import '../model/series.dart';
import '../model/text_style.dart';
import '../model/title.dart';
import '../model/toolbox_feature.dart';
import '../model/tooltip.dart';
import '../model/xyaxis.dart';

class CandlestickChartExample extends StatelessWidget {
  const CandlestickChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AAPL Stock Performance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Last 30 days trading data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: CandlestickChartWidget(
              config: _buildChartConfig(),
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeFrameSelector(),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _timeFrameButton('1D', true),
        _timeFrameButton('1W', false),
        _timeFrameButton('1M', false),
        _timeFrameButton('3M', false),
        _timeFrameButton('1Y', false),
        _timeFrameButton('All', false),
      ],
    );
  }

  Widget _timeFrameButton(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
        ),
        child: Text(label),
      ),
    );
  }

  CandlestickChartConfig _buildChartConfig() {
    final random = math.Random(42); // Fixed seed for consistent results

    // Generate fake stock data for the last 30 days
    final List<CandlestickData> data = [];
    double lastClose = 180.0; // Starting price

    for (int i = 0; i < 30; i++) {
      const volatility = 3.0; // Daily price volatility

      // Generate related OHLC values
      final change = (random.nextDouble() * 2 - 1) * volatility;
      final open = lastClose;
      final close = open + change;

      // High is the maximum of open and close, plus some random amount
      final highAdd = random.nextDouble() * volatility * 0.5;
      final high = math.max(open, close) + highAdd;

      // Low is the minimum of open and close, minus some random amount
      final lowSub = random.nextDouble() * volatility * 0.5;
      final low = math.min(open, close) - lowSub;

      data.add(CandlestickData(
        open: open,
        high: high,
        low: low,
        close: close,
        date: DateTime.now().subtract(Duration(days: 30 - i)),
      ));

      lastClose = close; // Set for next iteration
    }

    // Create x-axis labels (dates)
    final xAxisLabels = data.map((d) {
      final date = d.date;
      return '${date.month}/${date.day}';
    }).toList();

    // Determine min and max prices for y-axis
    final allPrices =
        data.expand((d) => [d.open, d.high, d.low, d.close]).toList();
    final minPrice = allPrices.reduce(math.min);
    final maxPrice = allPrices.reduce(math.max);

    // Round to nearest 5
    final minY = (minPrice / 5).floor() * 5.0;
    final maxY = (maxPrice / 5).ceil() * 5.0;

    // Create y-axis labels (price levels)
    final yAxisLabels = [
      minY.toStringAsFixed(2),
      (minY + (maxY - minY) * 0.25).toStringAsFixed(2),
      (minY + (maxY - minY) * 0.5).toStringAsFixed(2),
      (minY + (maxY - minY) * 0.75).toStringAsFixed(2),
      maxY.toStringAsFixed(2),
    ];

    return CandlestickChartConfig(
      series: [
        Series(
          name: 'AAPL',
          type: ChartType.candlestick,
          data: data,
        ),
      ],
      xAxis: XYAxis(
        type: AxisType.category,
        data: xAxisLabels,
        axisLine: AxisLine(
          show: true,
          lineStyle: ChartLineStyle(
            color: 'grey',
            width: 1.0,
          ),
        ),
        axisLabel: AxisLabel(
          show: true,
          textStyle: ChartTextStyle(
            color: 'grey',
            fontSize: 10,
          ),
        ),
      ),
      yAxis: XYAxis(
        type: AxisType.value,
        data: yAxisLabels,
        axisLine: AxisLine(
          show: true,
          lineStyle: ChartLineStyle(
            color: 'grey',
            width: 1.0,
          ),
        ),
        axisLabel: AxisLabel(
          show: true,
          textStyle: ChartTextStyle(
            color: 'grey',
            fontSize: 10,
          ),
        ),
      ),
      bullColor: Colors.green.shade600,
      bearColor: Colors.red.shade600,
      barWidth: 8.0,
      showAverage: true,
      title: ChartTitle(
        text: 'AAPL Stock Chart',
        subtext: 'Daily Price Movement',
        textStyle: ChartTextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: 'black',
        ),
      ),
      tooltip: ChartTooltip(
        trigger: TooltipTrigger.axis,
        formatter: '{a0}: {c0}',
        textStyle: ChartTextStyle(
          fontSize: 12,
          color: 'white',
        ),
        backgroundColor: 'black',
      ),
      legend: ChartLegend(
        show: true,
        data: ['AAPL'],
        textStyle: ChartTextStyle(
          fontSize: 12,
          color: 'grey',
        ),
      ),
      grid: Grid(
        show: true,
        left: 10,
        right: 10,
        top: 15,
        bottom: 15,
        containLabel: true,
        showHorizontalLines: true,
        showVerticalLines: true,
        color: 'grey',
      ),
      toolbox: ChartToolbox(
        show: true,
        feature: ToolboxFeature(
          saveAsImage: Feature(show: true),
          dataZoom: Feature(show: true),
          dataView: Feature(show: true),
          restore: Feature(show: true),
        ),
      ),
    );
  }
}

// Sample data class for candlestick data

/* 
// Required model classes (simplified versions for the example)
enum ChartType { candlestick }

enum SeriesType { candlestick }



class Series {
  final String name;
  final SeriesType type;
  final List<dynamic> data;

  Series({
    required this.name,
    required this.type,
    required this.data,
  });
}

class ChartTitle {
  final String text;
  final String? subtext;
  final TextStyle? textStyle;

  ChartTitle({
    required this.text,
    this.subtext,
    this.textStyle,
  });
}

class ChartTooltip {
  final String trigger;
  final String formatter;
  final TextStyle? textStyle;
  final Color backgroundColor;

  ChartTooltip({
    this.trigger = 'item',
    this.formatter = '{a} <br/>{b} : {c}',
    this.textStyle,
    this.backgroundColor = Colors.black54,
  });
}

class ChartLegend {
  final bool show;
  final List<String> data;
  final TextStyle? textStyle;

  ChartLegend({
    this.show = true,
    required this.data,
    this.textStyle,
  });
}

class AxisLine {
  final bool show;
  final LineStyle lineStyle;

  AxisLine({
    this.show = true,
    required this.lineStyle,
  });
}

class LineStyle {
  final Color color;
  final double width;

  LineStyle({
    this.color = Colors.grey,
    this.width = 1.0,
  });
}

class AxisLabel {
  final bool show;
  final TextStyle? textStyle;

  AxisLabel({
    this.show = true,
    this.textStyle,
  });
}

class XYAxis {
  final AxisType type;
  final List<dynamic>? data;
  final AxisLine? axisLine;
  final AxisLabel? axisLabel;

  XYAxis({
    required this.type,
    this.data,
    this.axisLine,
    this.axisLabel,
  });
}

class Grid {
  final bool show;
  final String left;
  final String right;
  final String top;
  final String bottom;
  final bool containLabel;
  final bool? showHorizontalLines;
  final bool? showVerticalLines;
  final Color? color;

  Grid({
    this.show = true,
    this.left = '10%',
    this.right = '10%',
    this.top = '10%',
    this.bottom = '10%',
    this.containLabel = true,
    this.showHorizontalLines,
    this.showVerticalLines,
    this.color,
  });
}



class ChartToolbox {
  final bool show;
  final ToolboxFeature feature;

  ChartToolbox({
    this.show = false,
    required this.feature,
  });
} */
