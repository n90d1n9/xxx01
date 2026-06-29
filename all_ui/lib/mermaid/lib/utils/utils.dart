import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/data_type.dart';
import '../model/report.dart';
import '../model/report_filter.dart';

String formatValue(dynamic value, DataType type) {
  if (value == null) return '-';

  switch (type) {
    case DataType.currency:
      return NumberFormat.currency(symbol: '\\').format(value);
    case DataType.number:
      return NumberFormat('#,##0.##').format(value);
    case DataType.percentage:
      return '${value}%';
    default:
      return value.toString();
  }
}

String formatCellValue(dynamic value, DataType type) {
  if (value == null) return '-';

  switch (type) {
    case DataType.currency:
      return NumberFormat.currency(symbol: '\\').format(value);
    case DataType.number:
      return NumberFormat('#,##0').format(value);
    case DataType.date:
      if (value is DateTime) {
        return DateFormat('MMM dd, yyyy').format(value);
      }
      return value.toString();
    case DataType.percentage:
      return '${value}%';
    case DataType.boolean:
      return value ? '✓' : '✗';
    case DataType.email:
    case DataType.phone:
    case DataType.url:
    case DataType.string:
    default:
      return value.toString();
  }
}

IconData getDomainIcon(ReportDomain domain) {
  switch (domain) {
    case ReportDomain.sales:
      return Icons.shopping_cart;
    case ReportDomain.finance:
      return Icons.account_balance;
    case ReportDomain.operations:
      return Icons.settings;
    case ReportDomain.hr:
      return Icons.people;
    case ReportDomain.marketing:
      return Icons.campaign;
    case ReportDomain.analytics:
      return Icons.analytics;
    case ReportDomain.inventory:
      return Icons.inventory;
    case ReportDomain.customer:
      return Icons.person;
  }
}

IconData getDataTypeIcon(DataType type) {
  switch (type) {
    case DataType.string:
      return Icons.text_fields;
    case DataType.number:
      return Icons.numbers;
    case DataType.date:
      return Icons.calendar_today;
    case DataType.boolean:
      return Icons.check_box;
    case DataType.currency:
      return Icons.attach_money;
    case DataType.percentage:
      return Icons.percent;
    case DataType.email:
      return Icons.email;
    case DataType.phone:
      return Icons.phone;
    case DataType.url:
      return Icons.link;
    case DataType.datetime:
      // TODO: Handle this case.
      throw UnimplementedError();
    case DataType.time:
      // TODO: Handle this case.
      throw UnimplementedError();
    case DataType.json:
      // TODO: Handle this case.
      throw UnimplementedError();
    case DataType.array:
      // TODO: Handle this case.
      throw UnimplementedError();
    case DataType.object:
      // TODO: Handle this case.
      throw UnimplementedError();
    case DataType.binary:
      // TODO: Handle this case.
      throw UnimplementedError();
    case DataType.geo:
      // TODO: Handle this case.
      throw UnimplementedError();
    case DataType.uuid:
      // TODO: Handle this case.
      throw UnimplementedError();
  }
}

IconData getChartIcon(ChartType type) {
  switch (type) {
    case ChartType.line:
      return Icons.show_chart;
    case ChartType.bar:
      return Icons.bar_chart;
    case ChartType.pie:
      return Icons.pie_chart;
    case ChartType.scatter:
      return Icons.scatter_plot;
    case ChartType.area:
      return Icons.area_chart;
    case ChartType.combo:
      return Icons.multiline_chart;
  }
}

String getOperatorLabel(FilterOperator op) {
  switch (op) {
    case FilterOperator.equals:
      return 'Equals';
    case FilterOperator.notEquals:
      return 'Not Equals';
    case FilterOperator.contains:
      return 'Contains';
    case FilterOperator.notContains:
      return 'Not Contains';
    case FilterOperator.startsWith:
      return 'Starts With';
    case FilterOperator.endsWith:
      return 'Ends With';
    case FilterOperator.greaterThan:
      return 'Greater Than';
    case FilterOperator.lessThan:
      return 'Less Than';
    case FilterOperator.greaterThanOrEqual:
      return 'Greater Than or Equal';
    case FilterOperator.lessThanOrEqual:
      return 'Less Than or Equal';
    case FilterOperator.between:
      return 'Between';
    case FilterOperator.inList:
      return 'In List';
    case FilterOperator.notInList:
      return 'Not In List';
    case FilterOperator.isNull:
      return 'Is Null';
    case FilterOperator.isNotNull:
      return 'Is Not Null';
    case FilterOperator.isEmpty:
      return 'Is Empty';
    case FilterOperator.isNotEmpty:
      return 'Is Not Empty';
    case FilterOperator.regex:
      // TODO: Handle this case.
      throw UnimplementedError();
    case FilterOperator.custom:
      // TODO: Handle this case.
      throw UnimplementedError();
  }
}

String getOperatorSymbol(FilterOperator op) {
  switch (op) {
    case FilterOperator.equals:
      return '=';
    case FilterOperator.notEquals:
      return '≠';
    case FilterOperator.contains:
      return '⊃';
    case FilterOperator.greaterThan:
      return '>';
    case FilterOperator.lessThan:
      return '<';
    case FilterOperator.greaterThanOrEqual:
      return '≥';
    case FilterOperator.lessThanOrEqual:
      return '≤';
    default:
      return op.name;
  }
}
