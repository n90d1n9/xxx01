import '../model/data_type.dart';
import '../model/report_column.dart';
import '../model/report_configuration.dart';
import '../model/report_filter.dart';
import '../model/report_sort.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Simulate database with in-memory storage
  final Map<String, ReportConfiguration> _savedReports = {};
  final Map<String, List<Map<String, dynamic>>> _mockData = {};

  Future<void> initialize() async {
    // Initialize mock data
    _initializeMockData();
  }

  void _initializeMockData() {
    // Sales data
    _mockData['sales'] = List.generate(
      100,
      (i) => {
        'orderId': 'ORD-${1000 + i}',
        'customer': 'Customer ${i % 20 + 1}',
        'amount': (500 + (i * 17) % 2000).toDouble(),
        'quantity': (i % 10) + 1,
        'date': DateTime.now().subtract(Duration(days: i)),
        'status': ['Pending', 'Completed', 'Cancelled'][i % 3],
        'region': ['North', 'South', 'East', 'West'][i % 4],
        'product': 'Product ${i % 15 + 1}',
        'category': ['Electronics', 'Clothing', 'Food', 'Books'][i % 4],
        'discount': ((i % 5) * 5).toDouble(),
      },
    );

    // Finance data
    _mockData['finance'] = List.generate(
      100,
      (i) => {
        'transactionId': 'TXN-${2000 + i}',
        'account': 'Account ${i % 10 + 1}',
        'debit': i % 2 == 0 ? (i * 50).toDouble() : 0.0,
        'credit': i % 2 == 1 ? (i * 45).toDouble() : 0.0,
        'balance': (10000 + (i * 100)).toDouble(),
        'date': DateTime.now().subtract(Duration(days: i)),
        'category': ['Income', 'Expense', 'Transfer'][i % 3],
        'description': 'Transaction description ${i + 1}',
      },
    );

    // HR data
    _mockData['hr'] = List.generate(
      50,
      (i) => {
        'employeeId': 'EMP-${3000 + i}',
        'name': 'Employee ${i + 1}',
        'department': ['Engineering', 'Sales', 'Marketing', 'HR'][i % 4],
        'position': ['Manager', 'Senior', 'Junior', 'Intern'][i % 4],
        'salary': (50000 + (i * 1000)).toDouble(),
        'hireDate': DateTime.now().subtract(Duration(days: i * 30)),
        'performance': (70 + (i % 30)).toDouble(),
        'status': ['Active', 'On Leave', 'Inactive'][i % 3],
      },
    );

    // Inventory data
    _mockData['inventory'] = List.generate(
      75,
      (i) => {
        'itemId': 'ITEM-${4000 + i}',
        'name': 'Item ${i + 1}',
        'sku': 'SKU-${i + 1}',
        'quantity': (100 - i) % 100,
        'reorderLevel': 20,
        'unitPrice': (10 + (i * 5) % 100).toDouble(),
        'category': [
          'Electronics',
          'Hardware',
          'Software',
          'Accessories',
        ][i % 4],
        'supplier': 'Supplier ${i % 10 + 1}',
        'lastRestocked': DateTime.now().subtract(Duration(days: i % 30)),
      },
    );
  }

  Future<List<Map<String, dynamic>>> queryData(
    ReportConfiguration config,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate query delay

    var data = List<Map<String, dynamic>>.from(
      _mockData[config.domain.name] ?? [],
    );

    // Apply filters
    data = _applyFilters(data, config.filters, config.columns);

    // Apply sorting
    data = _applySorting(data, config.sorts);

    // Apply pagination
    if (data.length > config.pageSize) {
      data = data.sublist(0, config.pageSize);
    }

    return data;
  }

  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> data,
    List<ReportFilter> filters,
    List<ReportColumn> columns,
  ) {
    if (filters.isEmpty) return data;

    return data.where((row) {
      bool result = true;
      FilterLogic? previousLogic;

      for (var filter in filters) {
        final column = columns.firstWhere((c) => c.id == filter.columnId);
        final value = row[column.fieldName];
        final filterResult = _evaluateFilter(value, filter);

        if (previousLogic == null) {
          result = filterResult;
        } else if (previousLogic == FilterLogic.and) {
          result = result && filterResult;
        } else {
          result = result || filterResult;
        }

        previousLogic = filter.logic;
      }

      return result;
    }).toList();
  }

  bool _evaluateFilter(dynamic value, ReportFilter filter) {
    switch (filter.operator) {
      case FilterOperator.equals:
        return value == filter.value;
      case FilterOperator.notEquals:
        return value != filter.value;
      case FilterOperator.contains:
        return value.toString().toLowerCase().contains(
          filter.value.toString().toLowerCase(),
        );
      case FilterOperator.notContains:
        return !value.toString().toLowerCase().contains(
          filter.value.toString().toLowerCase(),
        );
      case FilterOperator.greaterThan:
        return (value as num) > (filter.value as num);
      case FilterOperator.lessThan:
        return (value as num) < (filter.value as num);
      case FilterOperator.greaterThanOrEqual:
        return (value as num) >= (filter.value as num);
      case FilterOperator.lessThanOrEqual:
        return (value as num) <= (filter.value as num);
      case FilterOperator.isNull:
        return value == null;
      case FilterOperator.isNotNull:
        return value != null;
      default:
        return true;
    }
  }

  List<Map<String, dynamic>> _applySorting(
    List<Map<String, dynamic>> data,
    List<ReportSort> sorts,
  ) {
    if (sorts.isEmpty) return data;

    data.sort((a, b) {
      for (var sort in sorts) {
        final aVal = a[sort.columnId];
        final bVal = b[sort.columnId];

        int comparison;
        if (aVal == null && bVal == null) {
          comparison = 0;
        } else if (aVal == null) {
          comparison = 1;
        } else if (bVal == null) {
          comparison = -1;
        } else {
          comparison = Comparable.compare(aVal, bVal);
        }

        if (comparison != 0) {
          return sort.ascending ? comparison : -comparison;
        }
      }
      return 0;
    });

    return data;
  }

  Future<void> saveReport(ReportConfiguration config) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _savedReports[config.id] = config;
  }

  Future<void> deleteReport(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _savedReports.remove(id);
  }

  Future<List<ReportConfiguration>> getSavedReports() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _savedReports.values.toList();
  }

  Future<ReportConfiguration?> getReport(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _savedReports[id];
  }
}
