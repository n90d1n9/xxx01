import 'package:flutter/material.dart';

import 'line_sampel_models.dart';
import 'line_sampel_painter.dart';

// Main chart widget
class ModernLineChart extends StatefulWidget {
  final List<ChartSeries> series;
  final LineChartConfig config;
  final String? title;
  final String? xAxisLabel;
  final String? yAxisLabel;

  const ModernLineChart({
    super.key,
    required this.series,
    this.config = const LineChartConfig(),
    this.title,
    this.xAxisLabel,
    this.yAxisLabel,
  });

  @override
  State<ModernLineChart> createState() => _ModernLineChartState();
}

class _ModernLineChartState extends State<ModernLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.config.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.config.animate) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.config.padding,
      decoration: BoxDecoration(
        color: widget.config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                widget.title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          Expanded(
            child: Row(
              children: [
                // Y-axis label
                if (widget.yAxisLabel != null)
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      widget.yAxisLabel!,
                      style: widget.config.axisTextStyle,
                    ),
                  ),
                // Chart area
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: LineChartPainter(
                                series: widget.series,
                                config: widget.config,
                                animationValue: widget.config.animate
                                    ? _animation.value
                                    : 1.0,
                              ),
                              size: Size.infinite,
                            );
                          },
                        ),
                      ),
                      // X-axis label
                      if (widget.xAxisLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            widget.xAxisLabel!,
                            style: widget.config.axisTextStyle,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Legend
          if (widget.config.showLegend && widget.series.length > 1)
            _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: widget.series.map((series) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 3,
                decoration: BoxDecoration(
                  color: series.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                series.name,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
