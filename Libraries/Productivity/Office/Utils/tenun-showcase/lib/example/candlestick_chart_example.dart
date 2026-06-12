import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro_financial.dart';
import 'dart:math' as math;

class CandlestickChartExample extends StatelessWidget {
  const CandlestickChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    registerTenunProFinancialCharts();

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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Expanded(child: CandlestickChartWidget(config: _buildChartConfig())),
          const SizedBox(height: 16),
          _buildTimeFrameSelector(),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        child: Text(label),
      ),
    );
  }

  CandlestickChartConfig _buildChartConfig() {
    final random = math.Random(42); // Fixed seed for consistent results

    // Generate fake stock data for the last 30 days
    final List<OhlcBar> bars = [];
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

      final date = DateTime.now().subtract(Duration(days: 30 - i));
      bars.add(
        OhlcBar(
          date:
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
          open: open,
          high: high,
          low: low,
          close: close,
          volume: 2000000 + random.nextInt(10000000).toDouble(),
        ),
      );

      lastClose = close; // Set for next iteration
    }

    return CandlestickChartConfig(
      bars: bars,
      type: ChartType.candlestick,
      showVolume: true,
      bullColor: Colors.green.shade600,
      bearColor: Colors.red.shade600,
      title: TitlesData(
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
        textStyle: ChartTextStyle(fontSize: 12, color: 'white'),
        backgroundColor: 'black',
      ),
      legend: ChartLegend(
        show: true,
        data: ['AAPL'],
        textStyle: ChartTextStyle(fontSize: 12, color: 'grey'),
      ),
      grid: GridData(
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

class CandlestickInteractiveKnobExample extends StatelessWidget {
  final String dataMode;
  final int pointCount;
  final int samplingThreshold;
  final int samplingStrategyIndex;
  final bool showTooltip;

  const CandlestickInteractiveKnobExample({
    super.key,
    this.dataMode = 'regular',
    this.pointCount = 2500,
    this.samplingThreshold = 600,
    this.samplingStrategyIndex = 0,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    registerTenunProFinancialCharts();

    final isRegular = dataMode == 'regular';
    final points = isRegular ? 40 : (pointCount < 100 ? 100 : pointCount);

    final series = List.generate(points, (i) {
      final base = 100 + 12 * math.sin(i * 0.012) + 6 * math.sin(i * 0.17);
      final open = base + 2 * math.sin(i * 0.11);
      final close = base + 2 * math.sin(i * 0.14 + 0.7);
      final high = math.max(open, close) + 2.2;
      final low = math.min(open, close) - 2.2;
      return [open, high, low, close];
    });

    final json = <String, dynamic>{
      'type': 'candlestick',
      'title': {
        'text': isRegular
            ? 'Candlestick (regular mode)'
            : 'Candlestick ($dataMode mode, $points points)',
      },
      'xAxis': {'data': List.generate(points, (i) => '$i')},
      'legend': {'show': true},
      'tooltip': {'show': showTooltip},
      'series': [
        {'name': 'OHLC', 'data': series},
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
      height: 420,
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

class TitlesData {
  final String text;
  final String? subtext;
  final TextStyle? textStyle;

  TitlesData({
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
