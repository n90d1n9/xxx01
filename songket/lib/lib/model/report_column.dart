import 'conditional_format.dart';
import 'data_type.dart';

class ReportColumn {
  final String id;
  final String fieldName;
  final String displayName;
  final DataType dataType;
  final bool sortable;
  final bool filterable;
  final bool aggregatable;
  final bool groupable;
  final AggregationType? defaultAggregation;
  final String? format;
  final int width;
  final bool visible;

  final List<String>? dependencies; // For calculated columns

  final int? minWidth;
  final int? maxWidth;
  final bool resizable;
  final bool frozen;
  final String? tooltip;

  // Advanced features
  final String? formula; // e.g., "amount * quantity"

  final String? transformation; // e.g., "UPPER", "TRIM", "FORMAT"
  final Map<String, dynamic>? validationRules;
  final List<ConditionalFormat>? conditionalFormats;
  final String? hyperlink; // Link pattern
  final bool isCalculated;
  final bool isDerived; // Derived from other columns
  final String? aiSuggestion; // AI-suggested configuration

  ReportColumn({
    required this.id,
    required this.fieldName,
    required this.displayName,
    required this.dataType,
    this.sortable = true,
    this.filterable = true,
    this.aggregatable = false,
    this.groupable = false,
    this.defaultAggregation,
    this.format,
    this.width = 150,
    this.visible = true,
    this.formula,
    this.dependencies,

    this.minWidth,
    this.maxWidth,
    this.resizable = true,
    this.frozen = false,
    this.tooltip,

    this.transformation,
    this.validationRules,
    this.conditionalFormats,
    this.hyperlink,
    this.isCalculated = false,
    this.isDerived = false,
    this.aiSuggestion,
  });

  ReportColumn copyWith({
    String? id,
    String? fieldName,
    String? displayName,
    DataType? dataType,
    bool? sortable,
    bool? filterable,
    bool? aggregatable,
    bool? groupable,
    AggregationType? defaultAggregation,
    String? format,
    int? width,
    bool? visible,
    String? formula,
    List<String>? dependencies,
  }) {
    return ReportColumn(
      id: id ?? this.id,
      fieldName: fieldName ?? this.fieldName,
      displayName: displayName ?? this.displayName,
      dataType: dataType ?? this.dataType,
      sortable: sortable ?? this.sortable,
      filterable: filterable ?? this.filterable,
      aggregatable: aggregatable ?? this.aggregatable,
      groupable: groupable ?? this.groupable,
      defaultAggregation: defaultAggregation ?? this.defaultAggregation,
      format: format ?? this.format,
      width: width ?? this.width,
      visible: visible ?? this.visible,
      formula: formula ?? this.formula,
      dependencies: dependencies ?? this.dependencies,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fieldName': fieldName,
    'displayName': displayName,
    'dataType': dataType.name,
    'sortable': sortable,
    'filterable': filterable,
    'aggregatable': aggregatable,
    'groupable': groupable,
    'defaultAggregation': defaultAggregation?.name,
    'format': format,
    'width': width,
    'visible': visible,
    'formula': formula,
    'dependencies': dependencies,

    'minWidth': minWidth,
    'maxWidth': maxWidth,
    'resizable': resizable,
    'frozen': frozen,
    'tooltip': tooltip,

    'transformation': transformation,
    'validationRules': validationRules,
    'conditionalFormats': conditionalFormats?.map((c) => c.toJson()).toList(),
    'hyperlink': hyperlink,
    'isCalculated': isCalculated,
    'isDerived': isDerived,
    'aiSuggestion': aiSuggestion,
  };

  factory ReportColumn.fromJson(Map<String, dynamic> json) => ReportColumn(
    id: json['id'],
    fieldName: json['fieldName'],
    displayName: json['displayName'],
    dataType: DataType.values.firstWhere((e) => e.name == json['dataType']),
    sortable: json['sortable'] ?? true,
    filterable: json['filterable'] ?? true,
    aggregatable: json['aggregatable'] ?? false,
    groupable: json['groupable'] ?? false,
    defaultAggregation: json['defaultAggregation'] != null
        ? AggregationType.values.firstWhere(
            (e) => e.name == json['defaultAggregation'],
          )
        : null,
    format: json['format'],
    width: json['width'] ?? 150,
    visible: json['visible'] ?? true,
    formula: json['formula'],
    dependencies: json['dependencies'] != null
        ? List<String>.from(json['dependencies'])
        : null,
  );
}
