import 'package:flutter/material.dart';
import 'package:ky_chart/utils/helper.dart';

import 'average_line_painter.dart';
import 'axes_painter.dart';
import 'candle_stick_config.dart';
import 'candlestick_painter.dart';
import 'grid_painter.dart';

class CandlestickChartWidget extends StatelessWidget {
  final CandlestickChartConfig config;

  const CandlestickChartWidget({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          if (config.title != null) _buildTitle(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildChart(),
            ),
          ),
          if (config.legend != null) _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            config.title?.text ?? '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: stringToColor(config.title!.textStyle!.color),
            ),
          ),
          if (config.toolbox != null) _buildToolbox(),
        ],
      ),
    );
  }

  Widget _buildToolbox() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.save_alt),
          onPressed: () {
            // Download chart functionality
          },
          tooltip: 'Download',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            // Refresh data functionality
          },
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.fullscreen),
          onPressed: () {
            // Expand chart functionality
          },
          tooltip: 'Fullscreen',
        ),
      ],
    );
  }

  Widget _buildChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Grid
            if (config.grid != null) _buildGrid(constraints),

            // Axes
            _buildAxes(constraints),

            // Candlesticks
            _buildCandlesticks(constraints),

            // Average line if enabled
            if (config.showAverage) _buildAverageLine(constraints),

            // Tooltip overlay
            if (config.tooltip != null) _buildTooltipOverlay(constraints),
          ],
        );
      },
    );
  }

  Widget _buildGrid(BoxConstraints constraints) {
    return CustomPaint(
      size: Size(constraints.maxWidth, constraints.maxHeight),
      painter: GridPainter(config.grid!),
    );
  }

  Widget _buildAxes(BoxConstraints constraints) {
    return CustomPaint(
      size: Size(constraints.maxWidth, constraints.maxHeight),
      painter: AxesPainter(
        xAxis: config.xAxis,
        yAxis: config.yAxis,
      ),
    );
  }

  Widget _buildCandlesticks(BoxConstraints constraints) {
    return CustomPaint(
      size: Size(constraints.maxWidth, constraints.maxHeight),
      painter: CandlestickPainter(
        series: config.series,
        constraints: constraints,
        bullColor: config.bullColor,
        bearColor: config.bearColor,
        barWidth: config.barWidth,
        xAxis: config.xAxis,
        yAxis: config.yAxis,
      ),
    );
  }

  Widget _buildAverageLine(BoxConstraints constraints) {
    return CustomPaint(
      size: Size(constraints.maxWidth, constraints.maxHeight),
      painter: AverageLinePainter(
        series: config.series,
        constraints: constraints,
        xAxis: config.xAxis,
        yAxis: config.yAxis,
      ),
    );
  }

  Widget _buildTooltipOverlay(BoxConstraints constraints) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Handle tooltip positioning
      },
      child: Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        color: Colors.transparent,
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(config.bullColor, 'Bullish'),
          const SizedBox(width: 16),
          _buildLegendItem(config.bearColor, 'Bearish'),
          if (config.showAverage) ...[
            const SizedBox(width: 16),
            _buildLegendItem(Colors.blue, 'Average'),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: stringToColor(config.legend!.textStyle!.color),
          ),
        ),
      ],
    );
  }
}
