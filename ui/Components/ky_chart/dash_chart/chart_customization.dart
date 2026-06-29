import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartCustomization {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final bool showGrid;
  final bool showLabels;
  final bool showLegend;
  final double animationDuration;
  final ChartTheme theme;

  ChartCustomization({
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.red,
    this.backgroundColor = Colors.white,
    this.showGrid = true,
    this.showLabels = true,
    this.showLegend = true,
    this.animationDuration = 500,
    this.theme = ChartTheme.light,
  });
}

enum ChartTheme { light, dark, custom }

class CustomizableChart extends StatelessWidget {
  final Widget Function(ChartCustomization) builder;
  final ChartCustomization customization;

  const CustomizableChart({
    super.key,
    required this.builder,
    required this.customization,
  });

  @override
  Widget build(BuildContext context) {
    return builder(customization);
  }
}
