// chart_builder.dart
//
// Changes from previous version:
//  • TenunChart now accepts [theme] and [controller] and threads them into the config.
//  • ChartFactory.fromJson accepts optional theme/controller.
//  • TenunChartFromJson mirrors the same additions.

import 'package:flutter/material.dart';

import 'core/config/base_config.dart';
import 'core/config/chart_theme.dart';
import 'core/controllers/chart_controller.dart';

// ---------------------------------------------------------------------------
// TenunChart — main entry point
// ---------------------------------------------------------------------------

/// The primary chart widget.
///
/// Provide either a typed [config] object or a raw [jsonConfig] map.
/// Both paths support an optional [theme] and [controller].
///
/// ```dart
/// TenunChart(
///   jsonConfig: const {
///     'type': 'bar',
///     'series': [{ 'name': 'Sales', 'data': [120, 200, 150] }],
///   },
///   theme: ChartTheme.dark,
///   height: 300,
/// )
/// ```
class TenunChart extends StatelessWidget {
  /// Typed config — preferred when building charts in Dart code.
  final BaseChartConfig? config;

  /// JSON config — preferred when driven from an API / remote config.
  final Map<String, dynamic>? jsonConfig;

  /// Override the theme embedded in [config] / [jsonConfig].
  final ChartTheme? theme;

  /// Attach a [ChartController] for programmatic interaction.
  final ChartController? controller;

  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const TenunChart({
    super.key,
    this.config,
    this.jsonConfig,
    this.theme,
    this.controller,
    this.width,
    this.height,
    this.padding,
  }) : assert(
         config != null || jsonConfig != null,
         'Provide either config or jsonConfig.',
       );

  @override
  Widget build(BuildContext context) {
    var effectiveConfig = config ?? ChartFactory.fromJson(jsonConfig!);

    // Apply theme / controller overrides if supplied at the widget level.
    if (theme != null) {
      effectiveConfig = effectiveConfig.withTheme(theme!);
    }
    if (controller != null) {
      effectiveConfig = effectiveConfig.withController(controller!);
    }

    Widget result = effectiveConfig.buildChart();

    if (padding != null) result = Padding(padding: padding!, child: result);
    if (width != null || height != null) {
      result = SizedBox(width: width, height: height, child: result);
    }

    return result;
  }
}

// ---------------------------------------------------------------------------
// ChartFactory
// ---------------------------------------------------------------------------

class ChartFactory {
  /// Build a chart widget directly from a [BaseChartConfig].
  static Widget createChart(BaseChartConfig config) => config.buildChart();

  /// Parse a [BaseChartConfig] from JSON.
  static BaseChartConfig fromJson(
    Map<String, dynamic> json, {
    ChartTheme? theme,
    ChartController? controller,
  }) => BaseChartConfig.fromJson(json, theme: theme, controller: controller);

  /// Parse JSON and immediately build the chart widget.
  static Widget fromJsonToChart(
    Map<String, dynamic> json, {
    ChartTheme? theme,
    ChartController? controller,
  }) => fromJson(json, theme: theme, controller: controller).buildChart();
}

// ---------------------------------------------------------------------------
// TenunChartFromJson — convenience widget
// ---------------------------------------------------------------------------

class TenunChartFromJson extends StatelessWidget {
  final Map<String, dynamic> jsonConfig;
  final ChartTheme? theme;
  final ChartController? controller;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const TenunChartFromJson({
    super.key,
    required this.jsonConfig,
    this.theme,
    this.controller,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return TenunChart(
      jsonConfig: jsonConfig,
      theme: theme,
      controller: controller,
      width: width,
      height: height,
      padding: padding,
    );
  }
}
