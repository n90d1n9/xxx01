import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dashboard_item.dart';

class DashboardService {
  static const String _storageKey = 'dashboard_items';

  Future<List<DashboardItem>> getDashboardItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString(_storageKey);

      if (itemsJson == null) {
        return _getDefaultDashboardItems();
      }

      final List<dynamic> decodedList = jsonDecode(itemsJson);
      return decodedList.map((item) {
        return DashboardItem(
          id: item['id'],
          title: item['title'],
          type: DashboardItemType.values[item['type']],
          data: Map<String, dynamic>.from(item['data']),
          gridWidth: item['gridWidth'] ?? 1,
          gridHeight: item['gridHeight'] ?? 1,
        );
      }).toList();
    } catch (e) {
      // Return default items if there's an error
      return _getDefaultDashboardItems();
    }
  }

  Future<void> saveDashboardItems(List<DashboardItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedList =
          items.map((item) {
            return {
              'id': item.id,
              'title': item.title,
              'type': item.type.index,
              'data': item.data,
              'gridWidth': item.gridWidth,
              'gridHeight': item.gridHeight,
            };
          }).toList();

      await prefs.setString(_storageKey, jsonEncode(encodedList));
    } catch (e) {
      // Handle error
    }
  }

  List<DashboardItem> _getDefaultDashboardItems() {
    return [
      DashboardItem(
        id: 'default-1',
        title: 'Revenue Trend',
        type: DashboardItemType.lineChart,
        data: {
          'labels': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
          'datasets': [
            {
              'label': 'Revenue',
              'data': [12, 19, 15, 25, 22, 30],
              'color': 0xFF4CAF50,
            },
            {
              'label': 'Costs',
              'data': [5, 12, 10, 14, 20, 15],
              'color': 0xFFFF5722,
            },
          ],
        },
      ),
      DashboardItem(
        id: 'default-2',
        title: 'Monthly Sales',
        type: DashboardItemType.barChart,
        data: {
          'labels': ['Q1', 'Q2', 'Q3', 'Q4'],
          'datasets': [
            {
              'label': 'Sales 2023',
              'data': [45, 58, 65, 71],
              'color': 0xFF2196F3,
            },
            {
              'label': 'Sales 2024',
              'data': [51, 63, 70, 78],
              'color': 0xFFAB47BC,
            },
          ],
        },
      ),
      DashboardItem(
        id: 'default-3',
        title: 'Traffic Sources',
        type: DashboardItemType.pieChart,
        data: {
          'datasets': [
            {
              'data': [35, 25, 20, 15, 5],
              'colors': [
                0xFF4CAF50,
                0xFF2196F3,
                0xFFFFC107,
                0xFFFF5722,
                0xFF9E9E9E,
              ],
              'labels': ['Organic', 'Social', 'Email', 'Referral', 'Other'],
            },
          ],
        },
      ),
      DashboardItem(
        id: 'default-4',
        title: 'Active Users',
        type: DashboardItemType.statCard,
        data: {
          'value': '2,451',
          'change': '+15.3%',
          'isPositive': true,
          'icon': 'people',
          'subtitle': 'vs last month',
        },
      ),
    ];
  }
}
