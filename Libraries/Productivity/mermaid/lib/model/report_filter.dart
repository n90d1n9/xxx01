/// Advanced filtering with expressions
class AdvancedFilter {
  final String id;
  final String? columnId;
  final FilterOperator operator;
  final dynamic value;
  final dynamic value2;
  final FilterLogic? logic;
  final String?
  expression; // Custom expression: "(amount > 100) AND (status = 'Active')"
  final bool isCustomExpression;
  final List<AdvancedFilter>? nestedFilters; // For complex filter groups

  AdvancedFilter({
    String? id,
    this.columnId,
    this.operator = FilterOperator.equals,
    this.value,
    this.value2,
    this.logic,
    this.expression,
    this.isCustomExpression = false,
    this.nestedFilters,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'columnId': columnId,
    'operator': operator.name,
    'value': value,
    'value2': value2,
    'logic': logic?.name,
    'expression': expression,
    'isCustomExpression': isCustomExpression,
    'nestedFilters': nestedFilters?.map((f) => f.toJson()).toList(),
  };
}

enum FilterOperator {
  equals,
  notEquals,
  contains,
  notContains,
  startsWith,
  endsWith,
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  between,
  inList,
  notInList,
  isNull,
  isNotNull,
  isEmpty,
  isNotEmpty,
  regex,
  custom,
}

enum FilterLogic { and, or, not }

class ReportFilter {
  final String id;
  final String columnId;
  final FilterOperator operator;
  final dynamic value;
  final dynamic value2;
  final FilterLogic? logic; // For chaining multiple filters

  ReportFilter({
    String? id,
    required this.columnId,
    required this.operator,
    required this.value,
    this.value2,
    this.logic,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'columnId': columnId,
    'operator': operator.name,
    'value': value,
    'value2': value2,
    'logic': logic?.name,
  };

  factory ReportFilter.fromJson(Map<String, dynamic> json) => ReportFilter(
    id: json['id'],
    columnId: json['columnId'],
    operator: FilterOperator.values.firstWhere(
      (e) => e.name == json['operator'],
    ),
    value: json['value'],
    value2: json['value2'],
    logic: json['logic'] != null
        ? FilterLogic.values.firstWhere((e) => e.name == json['logic'])
        : null,
  );
}
