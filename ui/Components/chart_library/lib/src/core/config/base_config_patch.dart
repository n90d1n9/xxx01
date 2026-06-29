/// Patch file for core/config/base_config.dart
///
/// MERGE INSTRUCTIONS
/// ==================
/// This file documents every change to apply to the existing base_config.dart.
/// Do NOT replace the file wholesale — follow the numbered steps below.
///
/// ─────────────────────────────────────────────────────────────────────────
/// STEP 1 — Add imports at the top of base_config.dart
/// ─────────────────────────────────────────────────────────────────────────
///
///   import '../controllers/chart_controller.dart';
///   import 'chart_theme.dart';
///   import 'chart_axis_config.dart';   // new in v2
///
/// ─────────────────────────────────────────────────────────────────────────
/// STEP 2 — Extend BaseChartConfig fields
/// ─────────────────────────────────────────────────────────────────────────
///
/// abstract class BaseChartConfig {
///   // ... keep all existing fields ...
///
///   /// Theme — falls back to ChartTheme.light when not set.
///   final ChartTheme theme;
///
///   /// Optional controller for programmatic interaction.
///   final ChartController? controller;
///
///   /// Optional X-axis configuration (scale, ticks, labels).
///   final ChartAxisConfig? xAxisConfig;
///
///   /// Optional Y-axis configuration (scale, ticks, labels).
///   final ChartAxisConfig? yAxisConfig;
///
///   BaseChartConfig({
///     required this.type,
///     this.title,
///     this.tooltip,
///     this.legend,
///     this.toolbox,
///     this.grid,
///     required this.series,
///     ChartTheme? theme,
///     this.controller,
///     this.xAxisConfig,
///     this.yAxisConfig,
///   }) : theme = theme ?? ChartTheme.light;
///
/// ─────────────────────────────────────────────────────────────────────────
/// STEP 3 — Replace getMaxSeriesValue with safe version
/// ─────────────────────────────────────────────────────────────────────────
///
///   /// Safe maximum — handles null data, empty series, non-numeric values
///   /// and adds 10% headroom so data never clips the top of the chart.
///   double getMaxSeriesValue() {
///     if (series.isEmpty) return 100;
///     double max = double.negativeInfinity;
///     for (final s in series) {
///       for (final item in s.data ?? const []) {
///         double? v;
///         if (item is num) {
///           v = item.toDouble();
///         } else if (item is Map) {
///           v = (item['value'] as num?)?.toDouble();
///         }
///         if (v != null && v > max) max = v;
///       }
///     }
///     if (!max.isFinite) return 100;
///     // 10% headroom, minimum +1 so zero-data charts still show sensible axis.
///     return max + (max.abs() * 0.1).clamp(1.0, 1e6);
///   }
///
/// ─────────────────────────────────────────────────────────────────────────
/// STEP 4 — Add withTheme / withController convenience methods
/// ─────────────────────────────────────────────────────────────────────────
///
///   /// Return a copy of this config with [theme] applied.
///   ///
///   /// Usage in TenunChart:
///   ///   TenunChart(config: myConfig.withTheme(ChartTheme.dark))
///   BaseChartConfig withTheme(ChartTheme theme);
///
///   /// Return a copy of this config with [controller] attached.
///   BaseChartConfig withController(ChartController controller);
///
/// Concrete chart configs must implement these by forwarding to copyWith.
/// Example for BarChartConfig:
///
///   @override
///   BarChartConfig withTheme(ChartTheme t) => copyWith(theme: t);
///
///   @override
///   BarChartConfig withController(ChartController c) => copyWith(controller: c);
///
/// ─────────────────────────────────────────────────────────────────────────
/// STEP 5 — Update toJson / fromJson
/// ─────────────────────────────────────────────────────────────────────────
///
///   Map<String, dynamic> toJson() {
///     return {
///       'type': chartTypeToString(type),
///       'title': title?.toJson(),
///       'tooltip': tooltip?.toJson(),
///       'legend': legend?.toJson(),
///       'toolbox': toolbox?.toJson(),
///       'grid': grid?.toJson(),
///       'series': series.map((s) => s.toJson()).toList(),
///       if (xAxisConfig != null) 'xAxis': xAxisConfig!.toJson(),
///       if (yAxisConfig != null) 'yAxis': yAxisConfig!.toJson(),
///       // NOTE: theme is intentionally not serialised — it comes from the
///       // runtime environment, not the data payload.
///     };
///   }
///
///   factory BaseChartConfig.fromJson(Map<String, dynamic> json) {
///     final chartType = json['type'] != null
///         ? getChartType(json['type'])
///         : ChartType.line;
///     return getChartConfig(chartType, json);
///   }
///
/// ─────────────────────────────────────────────────────────────────────────
/// STEP 6 — Update helper.dart (getChartConfig switch)
/// ─────────────────────────────────────────────────────────────────────────
///
/// In helper.dart add cases for every new ChartType added in chart_type.dart:
///
///   case ChartType.combo:
///     return ComboChartConfig.fromJson(json);
///   case ChartType.sparkline:
///     return SparklineChartConfig.fromJson(json);
///   case ChartType.violin:
///     return ViolinChartConfig.fromJson(json);
///   case ChartType.bullet:
///     return BulletChartConfig.fromJson(json);
///   case ChartType.lollipop:
///     return LollipopChartConfig.fromJson(json);
///   case ChartType.ohlc:
///     return OhlcChartConfig.fromJson(json);
///   case ChartType.strip:
///     return StripChartConfig.fromJson(json);
///   case ChartType.ridgeline:
///     return RidgelineChartConfig.fromJson(json);
///   case ChartType.kagi:
///     return KagiChartConfig.fromJson(json);
///   case ChartType.renko:
///     return RenkoChartConfig.fromJson(json);
///   case ChartType.macd:
///     return MacdChartConfig.fromJson(json);
///
/// ─────────────────────────────────────────────────────────────────────────
/// STEP 7 — Replace stringToColor in helper.dart with cache-backed version
/// ─────────────────────────────────────────────────────────────────────────
///
/// Add import:
///   import 'chart_cache.dart';
///
/// Replace:
///   Color stringToColor(String colorString) => colorCache.resolve(colorString);
///
/// ─────────────────────────────────────────────────────────────────────────
/// STEP 8 — Replace old chart_type.dart (config/chart_type.dart)
/// ─────────────────────────────────────────────────────────────────────────
///
/// The existing core/config/chart_type.dart defines a smaller enum without the
/// new types. Replace it entirely with the new chart_type.dart from this patch.
///
/// ─────────────────────────────────────────────────────────────────────────
/// SUMMARY
/// ─────────────────────────────────────────────────────────────────────────
///
/// Files to update:
///   core/config/base_config.dart   — steps 2, 3, 4, 5
///   core/config/chart_type.dart    — step 8 (replace with new chart_type.dart)
///   core/utils/helper.dart         — steps 6, 7
///
/// New files to add to core/:
///   core/utils/data_sampler.dart         (updated)
///   core/utils/chart_data_processor.dart (updated)
///   core/utils/chart_cache.dart          (updated)
///   core/utils/chart_painter_base.dart   (updated)
///   core/config/chart_type.dart          (updated — replaces old)
///   core/config/chart_axis_config.dart   (new)
///   core/controllers/chart_controller.dart (updated)
///
library base_config_patch;

// Documentation only — see merge instructions above.
