import 'package:flutter/material.dart';
import 'model/tabel_item.dart';
import 'dart:math';

class TableController with ChangeNotifier {
  // Singleton instance
  static final TableController _instance = TableController._internal();
  factory TableController() => _instance;
  TableController._internal() {
    _initializeData();
  }

  final Random _random = Random();
  List<TableItem> _tableData = [];
  TableItem? _selectedItem;
  Map<String, dynamic> _filters = {};
  Map<String, dynamic> _sorting = {'field': 'name', 'ascending': true};
  Map<String, dynamic> _pageInfo = {'currentPage': 0, 'itemsPerPage': 10};

  // Getters
  List<TableItem> get tableData => _tableData;
  TableItem? get selectedItem => _selectedItem;
  Map<String, dynamic> get filters => _filters;
  Map<String, dynamic> get sorting => _sorting;
  Map<String, dynamic> get pageInfo => _pageInfo;

  void _initializeData() {
    final categories = ['Hardware', 'Software', 'Services', 'Infrastructure'];
    final statuses = ['Pending', 'Approved', 'Rejected', 'On Hold'];

    _tableData = List.generate(100, (index) {
      final categoryIndex = _random.nextInt(categories.length);
      return TableItem(
        id: 'ID-${1000 + index}',
        category: categories[categoryIndex],
        name: 'Item ${index + 1}',
        value: double.parse((_random.nextDouble() * 1000).toStringAsFixed(2)),
        date: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
        active: _random.nextBool(),
        status: statuses[_random.nextInt(statuses.length)],
        priority: _random.nextInt(5) + 1,
      );
    });
    notifyListeners();
  }

  // Setters
  void setSelectedItem(TableItem? item) {
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
  List<TableItem> getFilteredAndSortedData() {
    List<TableItem> filteredItems = List.from(_tableData);
    final sortField = _sorting['field'] ?? 'name';
    final ascending = _sorting['ascending'] ?? true;

    // Apply filters
    if (_filters.isNotEmpty) {
      filteredItems =
          filteredItems.where((item) {
            bool matchesAll = true;

            if (_filters.containsKey('category') &&
                _filters['category'] != null) {
              matchesAll = matchesAll && item.category == _filters['category'];
            }

            if (_filters.containsKey('active') && _filters['active'] != null) {
              matchesAll = matchesAll && item.active == _filters['active'];
            }

            if (_filters.containsKey('status') && _filters['status'] != null) {
              matchesAll = matchesAll && item.status == _filters['status'];
            }

            if (_filters.containsKey('search') && _filters['search'] != null) {
              final search = _filters['search'].toString().toLowerCase();
              matchesAll =
                  matchesAll &&
                  (item.name.toLowerCase().contains(search) ||
                      item.id.toLowerCase().contains(search) ||
                      item.category.toLowerCase().contains(search));
            }

            return matchesAll;
          }).toList();
    }

    // Apply sorting
    if (sortField.isNotEmpty) {
      filteredItems.sort((a, b) {
        dynamic aValue;
        dynamic bValue;

        switch (sortField) {
          case 'id':
            aValue = a.id;
            bValue = b.id;
            break;
          case 'name':
            aValue = a.name;
            bValue = b.name;
            break;
          case 'category':
            aValue = a.category;
            bValue = b.category;
            break;
          case 'value':
            aValue = a.value;
            bValue = b.value;
            break;
          case 'date':
            aValue = a.date;
            bValue = b.date;
            break;
          case 'priority':
            aValue = a.priority;
            bValue = b.priority;
            break;
          default:
            aValue = a.name;
            bValue = b.name;
        }

        int comparison;
        if (aValue is String && bValue is String) {
          comparison = aValue.compareTo(bValue);
        } else if (aValue is num && bValue is num) {
          comparison = aValue.compareTo(bValue);
        } else if (aValue is DateTime && bValue is DateTime) {
          comparison = aValue.compareTo(bValue);
        } else if (aValue is bool && bValue is bool) {
          comparison = aValue ? 1 : 0;
          comparison -= bValue ? 1 : 0;
        } else {
          comparison = 0;
        }

        return ascending ? comparison : -comparison;
      });
    }

    return filteredItems;
  }

  List<TableItem> getPaginatedData(List<TableItem> data) {
    final page = _pageInfo['currentPage'] ?? 0;
    final itemsPerPage = _pageInfo['itemsPerPage'] ?? 10;

    final startIndex = page * itemsPerPage;
    final endIndex = min(startIndex + itemsPerPage, data.length);

    if (startIndex >= data.length) {
      return [];
    }

    return data.sublist(startIndex, endIndex);
  }

  void updateItem(TableItem item) {
    _tableData = _tableData.map((e) => e.id == item.id ? item : e).toList();
    notifyListeners();
  }

  void addItem(TableItem item) {
    _tableData = [..._tableData, item];
    notifyListeners();
  }

  void deleteItem(String id) {
    _tableData = _tableData.where((item) => item.id != id).toList();
    notifyListeners();
  }
}
