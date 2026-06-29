// Helper method to assign colors (you can customize this)
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../model/series.dart';
import '../charts/area/area_chart_config.dart';
import '../charts/bar/bar_config.dart';
import '../charts/box_plot/box_plot_config.dart';
import '../charts/candle/candle_stick_config.dart';
import '../charts/funnel/funnel_config.dart';
import '../charts/gauge/gauge_config.dart';
import '../charts/heatmap/heatmap_config.dart';
import '../charts/line/line_config.dart';
import '../charts/pie/pie_config.dart';
import '../charts/radar/radar_config.dart';
import '../charts/scatter/scatter_config.dart';
import '../model/chart_model.dart';
import '../model/chart_type.dart';
import '../model/grid.dart';

String chartTypeToString(ChartType type) {
  switch (type) {
    case ChartType.bar:
      return 'bar';
    case ChartType.line:
      return 'line';
    case ChartType.pie:
      return 'pie';
    case ChartType.scatter:
      return 'scatter';
    case ChartType.radar:
      return 'radar';
    case ChartType.candlestick:
      return 'candlestick';
    case ChartType.boxPlot:
      return 'boxPlot';
    case ChartType.heatmap:
      return 'heatmap';
    case ChartType.area:
      return 'area';
    case ChartType.gauge:
      return 'gauge';
    case ChartType.funnel:
      return 'funnel';
    case ChartType.sankey:
      return 'sankey';
    case ChartType.radial:
      return 'radial';
    case ChartType.lineArea:
      return 'lineArea';
    case ChartType.stackedBar:
      return 'stackedBar';
  }
}

getChartConfig(ChartType chartType, Map<String, dynamic> json) {
  switch (chartType) {
    case ChartType.bar:
      return BarChartConfig.fromJson(json);
    case ChartType.line:
      return LineChartConfig.fromJson(json);
    case ChartType.pie:
      return PieChartConfig.fromJson(json);
    case ChartType.scatter:
      return ScatterChartConfig.fromJson(json);
    case ChartType.radar:
      return RadarChartConfig.fromJson(json);
    case ChartType.candlestick:
      return CandlestickChartConfig.fromJson(json);
    case ChartType.boxPlot:
      return BoxPlotChartConfig.fromJson(json);
    case ChartType.heatmap:
      return HeatmapChartConfig.fromJson(json);
    case ChartType.area:
      return AreaChartConfig.fromJson(json);
    case ChartType.gauge:
      return GaugeChartConfig.fromJson(json);
    case ChartType.funnel:
      return FunnelChartConfig.fromJson(json);
    case ChartType.sankey:
      return LineChartConfig.fromJson(json);
    case ChartType.radial:
      return LineChartConfig.fromJson(json);
    case ChartType.lineArea:
      return LineChartConfig.fromJson(json);
    case ChartType.stackedBar:
      return BarChartConfig.fromJson(json);
  }
}

ChartType getChartType(String type) {
  switch (type.toLowerCase()) {
    case 'bar':
      return ChartType.bar;
    case 'line':
      return ChartType.line;
    case 'pie':
      return ChartType.pie;
    case 'scatter':
      return ChartType.scatter;
    case 'radar':
      return ChartType.radar;
    case 'candlestick':
      return ChartType.candlestick;
    case 'boxplot':
      return ChartType.boxPlot;
    case 'heatmap':
      return ChartType.heatmap;
    case 'area':
      return ChartType.area;
    case 'gauge':
      return ChartType.gauge;
    case 'funnel':
      return ChartType.funnel;
    default:
      return ChartType.line;
  }
}

Color getDefaultSeriesColor(int index) {
  final colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.brown,
  ];

  return colors[index % colors.length];
}

/* Widget flChart(ChartType type, ChartConfig config) {
  if (config.series[0].data!.isNotEmpty &&
      config.series[0].data![0].value != null) {
    type = ChartType.pie;
  } else {
    return const Center(child: Text('Data not relevan'));
  }

  switch (type) {
    case ChartType.line || ChartType.lineArea:
      return KLine(config: config);
    case ChartType.pie || ChartType.pie:
      return KPie(config: config);
    default:
      return KBar(config: config);
  }
} */

FlGridData gridData(ChartConfig config) {
  Grid grid = config.grid != null ? config.grid! : Grid();
  return FlGridData(
    show: grid.show ?? true,
    drawVerticalLine: true,
    //horizontalInterval: 200,
    verticalInterval: 1,
  );
}

FlTitlesData titlesData(ChartConfig config) {
  List<dynamic> axisLabels = config.xAxis!.data!;
  return FlTitlesData(
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          if (value.toInt() < 0 || value.toInt() >= axisLabels.length) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              axisLabels[value.toInt()],
              style: const TextStyle(fontSize: 12),
            ),
          );
        },
        interval: 1,
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          return Text(
            value.toInt().toString(),
            style: const TextStyle(fontSize: 10),
          );
        },
        // interval: 500,
        // reservedSize: 40,
      ),
    ),
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
  );
}

FlBorderData borderData(ChartConfig config) {
  return FlBorderData(
    show: true,
    border: Border.all(color: Colors.grey.shade300),
  );
}

Widget legend(ChartConfig config) {
  return Wrap(
    spacing: 16,
    runSpacing: 8,
    children: config.series.map((series) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            color: stringToColor(series.itemStyle!.color),
          ),
          const SizedBox(width: 4),
          Text(series.name!),
        ],
      );
    }).toList(),
  );
}

Color stringToColor(String colorString) {
  // Trim the input string to remove any leading/trailing whitespace
  colorString = colorString.trim().toLowerCase();

  // Lookup table for common color names
  final Map<String, Color> colorMap = {
    'black': Colors.black,
    'white': Colors.white,
    'red': Colors.red,
    'green': Colors.green,
    'blue': Colors.blue,
    'yellow': Colors.yellow,
    'orange': Colors.orange,
    'purple': Colors.purple,
    'pink': Colors.pink,
    'grey': Colors.grey,
    'gray': Colors.grey, // Alternate spelling
    'brown': Colors.brown,
    'cyan': Colors.cyan,
    'teal': Colors.teal,
    'indigo': Colors.indigo,
    'amber': Colors.amber,
    'lime': Colors.lime,
    'transparent': Colors.transparent,
  };

  // Check if the input is a recognized color name
  if (colorMap.containsKey(colorString)) {
    return colorMap[colorString]!;
  }

  // If the input is an rgba string, parse it
  if (colorString.startsWith('rgba(') && colorString.endsWith(')')) {
    return rgbaStringToColor(colorString);
  }

  // If the input is not recognized, throw an exception or return a default color
  throw FormatException('Invalid color string: $colorString');
}

Color rgbaStringToColor(String rgbaString) {
  // Remove the "rgba(" prefix and ")" suffix
  rgbaString = rgbaString.replaceAll("rgba(", "").replaceAll(")", "");

  // Split the string by commas to get individual components
  List<String> components = rgbaString.split(",");

  // Trim any whitespace and parse the values
  int red = int.parse(components[0].trim());
  int green = int.parse(components[1].trim());
  int blue = int.parse(components[2].trim());
  double alpha = double.parse(components[3].trim());

  // Convert alpha from 0-1 to 0-255
  int alphaInt = (alpha * 255).round();

  // Create and return the Color object
  return Color.fromARGB(alphaInt, red, green, blue);
}

Color convertColor(String? name) {
  switch (name!) {
    case 'blue':
      return Colors.blue;
    case 'green':
      return Colors.green;
    case 'red':
      return Colors.red;
    case 'purple':
      return Colors.purple;
    case 'orange':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

double getMaxSeriesValue(List<Series> series) {
  var val = series
      .map((series) => series.data as List<dynamic>)
      .expand((dataList) => dataList)
      .reduce((curr, next) => curr > next ? curr : next);
  return val + (val.abs().toString().length * 10);
}

Color getRandomColor() {
  Random random = Random();
  // Generate random RGB values
  int red = random.nextInt(256);
  int green = random.nextInt(256);
  int blue = random.nextInt(256);

  // Ensure the values remain in valid color range [0, 255]
  red = red.clamp(0, 255).toInt();
  green = green.clamp(0, 255).toInt();
  blue = blue.clamp(0, 255).toInt();
  Color color = Color.fromARGB(255, red, green, blue);
  return color; // Always full opacity
}

String getStringRandomColor() {
  // List of common color names
  final List<String> colorNames = [
    'black',
    'white',
    'red',
    'green',
    'blue',
    'yellow',
    'orange',
    'purple',
    'pink',
    'grey',
    'brown',
    'cyan',
    'teal',
    'indigo',
    'amber',
    'lime',
    'transparent',
  ];

  // Random number generator
  final Random random = Random();

  // Decide randomly whether to return a named color or an rgba string
  if (random.nextBool()) {
    // Return a random named color
    return colorNames[random.nextInt(colorNames.length)];
  } else {
    // Return a random rgba string
    int r = random.nextInt(256); // Red (0-255)
    int g = random.nextInt(256); // Green (0-255)
    int b = random.nextInt(256); // Blue (0-255)
    double a = (random.nextInt(101) / 100).clamp(0.0, 1.0); // Alpha (0.0-1.0)

    return 'rgba($r, $g, $b, $a)';
  }
}

Color getContrastColor(Color color) {
  // Calculate brightness using the luminance formula
  double brightness =
      (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

  // If the brightness is high, return black; otherwise, return white
  return brightness > 0.5 ? Color(0xFF000000) : Color(0xFFFFFFFF);
}
