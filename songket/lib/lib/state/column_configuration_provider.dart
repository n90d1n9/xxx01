// services/column_configuration_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/data_type.dart';
import '../model/report.dart';
import '../model/report_column.dart';

class ColumnConfigurationService {
  List<ReportColumn> getColumnsForDomain(ReportDomain domain) {
    switch (domain) {
      case ReportDomain.sales:
        return _getSalesColumns();
      case ReportDomain.finance:
        return _getFinanceColumns();
      case ReportDomain.hr:
        return _getHRColumns();
      case ReportDomain.inventory:
        return _getInventoryColumns();
      default:
        return [];
    }
  }

  String getDomainName(ReportDomain domain) {
    return domain.name[0].toUpperCase() + domain.name.substring(1);
  }

  List<ReportColumn> _getSalesColumns() {
    return [
      ReportColumn(
        id: 'order_id',
        fieldName: 'orderId',
        displayName: 'Order ID',
        dataType: DataType.string,
      ),
      ReportColumn(
        id: 'customer',
        fieldName: 'customer',
        displayName: 'Customer',
        dataType: DataType.string,
        groupable: true,
      ),
      // ... rest of sales columns
    ];
  }

  List<ReportColumn> _getFinanceColumns() {
    return [
      ReportColumn(
        id: 'transaction_id',
        fieldName: 'transactionId',
        displayName: 'Transaction ID',
        dataType: DataType.string,
      ),
      // ... rest of finance columns
    ];
  }

  List<ReportColumn> _getHRColumns() {
    return [
      ReportColumn(
        id: 'employee_id',
        fieldName: 'employeeId',
        displayName: 'Employee ID',
        dataType: DataType.string,
      ),
      // ... rest of HR columns
    ];
  }

  List<ReportColumn> _getInventoryColumns() {
    return [
      ReportColumn(
        id: 'item_id',
        fieldName: 'itemId',
        displayName: 'Item ID',
        dataType: DataType.string,
      ),
      // ... rest of inventory columns
    ];
  }
}

final columnConfigurationServiceProvider = Provider<ColumnConfigurationService>(
  (ref) {
    return ColumnConfigurationService();
  },
);
