import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'line_sampel_2_models.dart';
import 'line_sampel_2_painter.dart';
import 'line_sampel_2_provider.dart';
import 'line_sampel_2_tooltip.dart';

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
  late LineChartProvider _provider;

  Rect? _chartArea;

  @override
  void initState() {
    super.initState();
    _provider = LineChartProvider();
    _provider.setData(widget.series);

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
  void didUpdateWidget(ModernLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.series != widget.series) {
      _provider.setData(widget.series);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LineChartProvider>.value(
      value: _provider,
      child: Consumer<LineChartProvider>(
        builder: (context, provider, child) {
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
                _buildHeader(provider),
                Expanded(
                  child: Row(
                    children: [
                      if (widget.yAxisLabel != null) _buildYAxisLabel(),
                      Expanded(child: _buildChartArea(provider)),
                    ],
                  ),
                ),
                if (widget.xAxisLabel != null) _buildXAxisLabel(),
                if (widget.config.showLegend && widget.series.length > 1)
                  _buildLegend(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(LineChartProvider provider) {
    return Row(
      children: [
        if (widget.title != null)
          Expanded(
            child: Padding(
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
          ),
        if (provider.isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        IconButton(
          onPressed: provider.resetZoomAndPan,
          icon: const Icon(Icons.zoom_out_map),
          tooltip: 'Reset Zoom & Pan',
        ),
      ],
    );
  }

  Widget _buildYAxisLabel() {
    return RotatedBox(
      quarterTurns: 3,
      child: Text(widget.yAxisLabel!, style: widget.config.axisTextStyle),
    );
  }

  Widget _buildXAxisLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: Text(widget.xAxisLabel!, style: widget.config.axisTextStyle),
      ),
    );
  }

  Widget _buildChartArea(LineChartProvider provider) {
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              'Error: ${provider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final calculatedArea = Rect.fromLTWH(
          40,
          10,
          constraints.maxWidth - 60,
          constraints.maxHeight - 30,
        );

        _chartArea = calculatedArea;

        final bounds = provider.dataBounds;

        return SizedBox.expand(
          child: Stack(
            children: [
              GestureDetector(
                onTapDown: widget.config.enableTooltip
                    ? (details) =>
                          _handleTapDown(details, provider, _chartArea!, bounds)
                    : null,
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                onLongPressMoveUpdate: (details) {
                  _handleHoverOrDrag(details.globalPosition);
                },
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: OptimizedLineChartPainter(
                        series: provider.optimizedSeries,
                        config: widget.config,
                        animationValue: widget.config.animate
                            ? _animation.value
                            : 1.0,
                        dataBounds: bounds,
                        zoomLevel: provider.zoomLevel,
                        panOffset: provider.panOffset,
                        tooltipData: provider.tooltipData,
                        chartArea: _chartArea!,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
              ),
              if (provider.tooltipData != null)
                _buildTooltip(provider.tooltipData!),
            ],
          ),
        );
      },
    );
  }

  Rect _getChartArea() {
    return _chartArea ??
        const Rect.fromLTWH(40, 10, 300, 200); // Fallback default
  }

  void _handleHoverOrDrag(Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox;
    final local = box.globalToLocal(globalPosition);
    final chartArea =
        _getChartArea(); // Implement this to return current chartArea
    final bounds = _provider.dataBounds;

    if (!chartArea.contains(local) || bounds == null) {
      _provider.hideTooltip();
      return;
    }

    final localInChart = Offset(
      local.dx - chartArea.left,
      local.dy - chartArea.top,
    );

    final tooltip = TooltipDetector.detectNearestPoint(
      tapPosition: localInChart,
      series: _provider.optimizedSeries,
      chartArea: Rect.fromLTWH(0, 0, chartArea.width, chartArea.height),
      bounds: bounds,
      tolerance: widget.config.tooltipRadius,
    );

    if (tooltip != null) {
      _provider.showTooltip(tooltip);
    } else {
      _provider.hideTooltip();
    }
  }

  void _handleTapDown(
    TapDownDetails details,
    LineChartProvider provider,
    Rect chartArea,
    ChartBounds? bounds,
  ) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final local = box.globalToLocal(details.globalPosition);
    final localInChart = Offset(
      local.dx - chartArea.left,
      local.dy - chartArea.top,
    );

    if (bounds == null) return;

    if (!chartArea.contains(localPosition)) {
      provider.hideTooltip();
      return;
    }

    final tooltip = TooltipDetector.detectNearestPoint(
      tapPosition: localInChart,
      series: provider.optimizedSeries,
      chartArea: chartArea,
      bounds: bounds,
      tolerance: widget.config.tooltipRadius,
    );

    if (tooltip != null) {
      provider.showTooltip(tooltip);
    } else {
      provider.hideTooltip();
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _provider.hideTooltip();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale != 1.0) {
      _provider.updateZoom(
        _provider.zoomLevel * details.scale,
        details.localFocalPoint,
      );
    } else {
      _provider.updatePan(details.focalPointDelta);
    }
  }

  Widget _buildTooltip(TooltipData tooltip) {
    return Positioned(
      left: tooltip.position.dx - 50, // Center horizontally
      top: tooltip.position.dy - 70, // Position above point
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tooltip.seriesName,
                style: TextStyle(
                  color: tooltip.seriesColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'X: ${tooltip.point.x.toStringAsFixed(2)}${tooltip.point.label != null ? ' (${tooltip.point.label})' : ''}',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
              Text(
                'Y: ${tooltip.point.y.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
        ),
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
