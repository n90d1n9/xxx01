import 'dart:convert';

import 'showcase_source_panel.dart';

class ChartSampleShowcaseOptions {
  const ChartSampleShowcaseOptions({
    this.showSampleJson = true,
    this.showSampleCode = true,
    this.showSampleTitle = true,
    this.showChart = true,
    this.showLegend = true,
    this.showTooltip = true,
    this.chartPadding = 8,
    this.sourcePanelHeight = 180,
    this.sourcePanelMinWidth = 360,
  }) : assert(chartPadding >= 0),
       assert(sourcePanelHeight > 0),
       assert(sourcePanelMinWidth > 0);

  static const compact = ChartSampleShowcaseOptions(
    showSampleJson: false,
    showSampleCode: false,
    sourcePanelHeight: 140,
    sourcePanelMinWidth: 300,
  );

  static const sourceOnly = ChartSampleShowcaseOptions(
    showSampleTitle: false,
    showChart: false,
  );

  final bool showSampleJson;
  final bool showSampleCode;
  final bool showSampleTitle;
  final bool showChart;
  final bool showLegend;
  final bool showTooltip;
  final double chartPadding;
  final double sourcePanelHeight;
  final double sourcePanelMinWidth;

  bool get showSampleSource => showSampleJson || showSampleCode;

  ChartSampleShowcaseOptions copyWith({
    bool? showSampleJson,
    bool? showSampleCode,
    bool? showSampleTitle,
    bool? showChart,
    bool? showLegend,
    bool? showTooltip,
    double? chartPadding,
    double? sourcePanelHeight,
    double? sourcePanelMinWidth,
  }) {
    return ChartSampleShowcaseOptions(
      showSampleJson: showSampleJson ?? this.showSampleJson,
      showSampleCode: showSampleCode ?? this.showSampleCode,
      showSampleTitle: showSampleTitle ?? this.showSampleTitle,
      showChart: showChart ?? this.showChart,
      showLegend: showLegend ?? this.showLegend,
      showTooltip: showTooltip ?? this.showTooltip,
      chartPadding: chartPadding ?? this.chartPadding,
      sourcePanelHeight: sourcePanelHeight ?? this.sourcePanelHeight,
      sourcePanelMinWidth: sourcePanelMinWidth ?? this.sourcePanelMinWidth,
    );
  }
}

Map<String, dynamic> chartSampleJsonWithOptions(
  Map<String, dynamic> source,
  ChartSampleShowcaseOptions options,
) {
  final json = cloneChartSampleJson(source);
  _upsertJsonMap(json, 'legend')['show'] = options.showLegend;
  _upsertJsonMap(json, 'tooltip')['show'] = options.showTooltip;
  return json;
}

Map<String, dynamic> cloneChartSampleJson(Map<String, dynamic> source) {
  return jsonDecode(jsonEncode(source)) as Map<String, dynamic>;
}

String chartSampleJsonText(Map<String, dynamic> json) {
  return showcasePrettyJson(json);
}

String chartSampleCodeText(
  Map<String, dynamic> json, {
  double chartPadding = 8,
}) {
  final lines = chartSampleJsonText(json).split('\n');
  final firstLine = lines.first;
  final rest = lines.skip(1).map((line) => '    $line').join('\n');
  final padding = _formatSampleNumber(chartPadding);
  return '''
TenunChartFromJson(
  jsonConfig: const <String, dynamic>$firstLine
$rest,
  padding: const EdgeInsets.all($padding),
)''';
}

Map<String, dynamic> _upsertJsonMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    final normalized = Map<String, dynamic>.from(value);
    json[key] = normalized;
    return normalized;
  }
  final normalized = <String, dynamic>{};
  json[key] = normalized;
  return normalized;
}

String _formatSampleNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}
