import 'dart:math';

import 'package:flutter/material.dart';

import 'model/ky_data.dart';
import 'utils/helper.dart';

class TableController with ChangeNotifier {
  static final TableController _instance = TableController._internal();
  static bool _isDummy = false;
  List<KyRow> _tableData = [];
  KyRow? _selectedItem;
  Map<String, dynamic> _filters = {};
  Map<String, dynamic> _sorting = {'field': 'name', 'ascending': true};
  Map<String, dynamic> _pageInfo = {'currentPage': 0, 'itemsPerPage': 10};

  // Getters
  List<KyRow> get tableData => _tableData;
  KyRow? get selectedItem => _selectedItem;
  Map<String, dynamic> get filters => _filters;
  Map<String, dynamic> get sorting => _sorting;
  Map<String, dynamic> get pageInfo => _pageInfo;

  factory TableController([isDummy = false]) {
    _isDummy = isDummy;
    return _instance;
  }
  TableController._internal() {
    _initializeData();
  }

  void _initializeData() {
    _tableData = _isDummy ? dummy() : [];
    notifyListeners();
  }

  void getData(List<KyRow> rows) {
    _tableData = rows;
    notifyListeners();
  }

  void setupPagination() {
    final sortField = sorting['field'] as String;
    final ascending = sorting['ascending'] as bool;
    final currentPage = pageInfo['currentPage'] as int;
    final itemsPerPage = pageInfo['itemsPerPage'] as int;
    final filteredAndSortedData = getFilteredAndSortedData();

    if (filteredAndSortedData.isEmpty) {
      Future.microtask(() {
        final newPageInfo = Map<String, dynamic>.from(pageInfo);
        newPageInfo['totalPages'] = 1;
        newPageInfo['totalItems'] = 0;
        setPageInfo(newPageInfo);
      });
    } else if (pageInfo['totalItems'] != filteredAndSortedData.length) {
      Future.microtask(() {
        final totalPages = (filteredAndSortedData.length / itemsPerPage).ceil();
        final newPageInfo = Map<String, dynamic>.from(pageInfo);
        newPageInfo['totalPages'] = totalPages;
        newPageInfo['totalItems'] = filteredAndSortedData.length;

        // Adjust current page if needed
        if (currentPage >= totalPages) {
          newPageInfo['currentPage'] = max(0, totalPages - 1);
        }

        setPageInfo(newPageInfo);
      });
    }
  }

  // Setters
  void setSelectedItem(KyRow? item) {
    _selectedItem = item;
    notifyListeners();
  }

  void setFilters(Map<String, dynamic> filters) {
    _filters = filters;
    notifyListeners();
  }

  void setSorting(Map<String, dynamic> sorting) {
    _sorting = sorting;
    notifyListeners();
  }

  void setPageInfo(Map<String, dynamic> pageInfo) {
    _pageInfo = pageInfo;
    notifyListeners();
  }

  // Business logic methods
  List<KyRow> getFilteredAndSortedData() {
    List<KyRow> filteredItems = List.from(_tableData);
    final sortField = _sorting['field'] ?? 'name';
    final ascending = _sorting['ascending'] ?? true;

    // Apply filters
    if (_filters.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        if (item.cells == null) return false;

        // Check if all filters match any cell in the row
        return _filters.entries.every((filter) {
          final cell = item.cells!.firstWhere(
            (cell) => cell.value == filter.key,
            orElse: () => KyCell(value: null),
          );
          return cell.value != null && cell.value == filter.value;
        });
      }).toList();
    }

    // Apply sorting
    if (sortField.isNotEmpty) {
      filteredItems.sort((a, b) {
        dynamic aValue;
        dynamic bValue;

        // Try to find the cell that matches the sortField
        if (a.cells != null && b.cells != null) {
          final aCell = a.cells!.firstWhere(
            (cell) => cell.value == sortField,
            orElse: () => KyCell(value: null),
          );
          final bCell = b.cells!.firstWhere(
            (cell) => cell.value == sortField,
            orElse: () => KyCell(value: null),
          );

          aValue = aCell.value;
          bValue = bCell.value;
        }

        int comparison;
        if (aValue is String && bValue is String) {
          comparison = aValue.compareTo(bValue);
        } else if (aValue is num && bValue is num) {
          comparison = aValue.compareTo(bValue);
        } else if (aValue is DateTime && bValue is DateTime) {
          comparison = aValue.compareTo(bValue);
        } else if (aValue is bool && bValue is bool) {
          comparison = aValue == bValue ? 0 : (aValue ? 1 : -1);
        } else {
          // Handle null values or incompatible types
          if (aValue == null && bValue == null) {
            comparison = 0;
          } else if (aValue == null) {
            comparison = -1;
          } else if (bValue == null) {
            comparison = 1;
          } else {
            // Fallback to string comparison for other types
            comparison = aValue.toString().compareTo(bValue.toString());
          }
        }

        return ascending ? comparison : -comparison;
      });
    }

    return filteredItems;
  }

  List<KyRow> getPaginatedData(List<KyRow> data) {
    final page = _pageInfo['currentPage'] ?? 0;
    final itemsPerPage = _pageInfo['itemsPerPage'] ?? 10;

    final startIndex = page * itemsPerPage;
    final endIndex = min(startIndex + itemsPerPage, data.length);

    if (startIndex >= data.length) {
      return [];
    }
    setupPagination();
    return data.sublist(startIndex, endIndex);
  }

  void updateItem(KyRow item) {
    //_tableData = _tableData.map((e) => e.id == item.id ? item : e).toList();
    notifyListeners();
  }

  void addItem(KyRow item) {
    _tableData = [..._tableData, item];
    notifyListeners();
  }

  void deleteItem(String id) {
    //_tableData = _tableData.where((item) => item.id != id).toList();
    notifyListeners();
  }
}
