import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';

import 'bar_chart_data.dart';

/// Simple vertical bar chart example
class SimpleBarChartExample extends StatelessWidget {
  final bool showTooltip;

  const SimpleBarChartExample({super.key, this.showTooltip = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: BarChartWidget(
        config: BarChartSamples.simple(showTooltip: showTooltip),
      ),
    );
  }
}

/// Grouped bar chart example (multi-series)
class GroupedBarChartExample extends StatelessWidget {
  final bool showTooltip;

  const GroupedBarChartExample({super.key, this.showTooltip = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: MultiBarChartWidget(
        config: BarChartSamples.grouped(showTooltip: showTooltip),
      ),
    );
  }
}

/// Stacked bar chart example
class StackedBarChartExample extends StatelessWidget {
  final bool showTooltip;

  const StackedBarChartExample({super.key, this.showTooltip = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: StackedBarChartWidget(
        config: BarChartSamples.stacked(showTooltip: showTooltip),
      ),
    );
  }
}

/// Horizontal bar chart example
class HorizontalBarChartExample extends StatelessWidget {
  final bool showTooltip;

  const HorizontalBarChartExample({super.key, this.showTooltip = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: BarChartWidget(
        config: BarChartSamples.horizontal(showTooltip: showTooltip),
      ),
    );
  }
}

/// Bar chart with gradient colors
class GradientBarChartExample extends StatelessWidget {
  final bool showTooltip;

  const GradientBarChartExample({super.key, this.showTooltip = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: BarChartWidget(
        config: BarChartSamples.gradient(showTooltip: showTooltip),
      ),
    );
  }
}

/// Bar chart with negative values
class NegativeBarChartExample extends StatelessWidget {
  final bool showTooltip;

  const NegativeBarChartExample({super.key, this.showTooltip = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: BarChartWidget(
        config: BarChartSamples.negative(showTooltip: showTooltip),
      ),
    );
  }
}

/// Bar chart with custom colors per bar
class CustomColorBarChartExample extends StatelessWidget {
  final bool showTooltip;

  const CustomColorBarChartExample({super.key, this.showTooltip = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: BarChartWidget(
        config: BarChartSamples.customColor(showTooltip: showTooltip),
      ),
    );
  }
}

/// Mixed bar and line chart example (using bar chart as base)
class MixedBarLineChartExample extends StatelessWidget {
  final bool showTooltip;

  const MixedBarLineChartExample({super.key, this.showTooltip = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: BarChartWidget(
        config: BarChartSamples.mixedBarLine(showTooltip: showTooltip),
      ),
    );
  }
}
