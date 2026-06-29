import 'data_type.dart';

class ChartConfiguration {
  final ChartType type;
  final String xAxisColumn;
  final List<String> yAxisColumns;
  final String? title;
  final bool showLegend;
  final bool showDataLabels;
  final Map<String, dynamic> customOptions;

  ChartConfiguration({
    required this.type,
    required this.xAxisColumn,
    required this.yAxisColumns,
    this.title,
    this.showLegend = true,
    this.showDataLabels = false,
    this.customOptions = const {},
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'xAxisColumn': xAxisColumn,
    'yAxisColumns': yAxisColumns,
    'title': title,
    'showLegend': showLegend,
    'showDataLabels': showDataLabels,
    'customOptions': customOptions,
  };

  factory ChartConfiguration.fromJson(Map<String, dynamic> json) =>
      ChartConfiguration(
        type: ChartType.values.firstWhere((e) => e.name == json['type']),
        xAxisColumn: json['xAxisColumn'],
        yAxisColumns: List<String>.from(json['yAxisColumns']),
        title: json['title'],
        showLegend: json['showLegend'] ?? true,
        showDataLabels: json['showDataLabels'] ?? false,
        customOptions: json['customOptions'] ?? {},
      );

  ChartConfiguration copyWith({
    ChartType? type,
    String? xAxisColumn,
    List<String>? yAxisColumns,
    String? title,
    bool? showLegend,
    bool? showDataLabels,
    Map<String, dynamic>? customOptions,
  }) {
    return ChartConfiguration(
      type: type ?? this.type,
      xAxisColumn: xAxisColumn ?? this.xAxisColumn,
      yAxisColumns: yAxisColumns ?? this.yAxisColumns,
      title: title ?? this.title,
      showLegend: showLegend ?? this.showLegend,
      showDataLabels: showDataLabels ?? this.showDataLabels,
      customOptions: customOptions ?? this.customOptions,
    );
  }
}
