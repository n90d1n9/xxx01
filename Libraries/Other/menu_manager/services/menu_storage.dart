import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/menu_item.dart';

class MenuLocalStorageService {
  static const String _menuItemsKey = 'menu_items';

  // Save menu items to local storage
  static Future<void> saveMenuItems(List<MenuItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonItems = items.map((item) => item.toJson()).toList();
    await prefs.setString(_menuItemsKey, json.encode(jsonItems));
  }

  // Load menu items from local storage
  static Future<List<MenuItem>> loadMenuItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_menuItemsKey);

    if (jsonString != null) {
      final List<dynamic> jsonItems = json.decode(jsonString);
      return jsonItems.map((item) => MenuItem.fromJson(item)).toList();
    }

    // Default menu items if nothing is saved
    return [
      MenuItem(
        id: '1',
        title: 'Dashboard',
        icon: Icons.dashboard_outlined,
        route: '/dashboard',
      ),
      MenuItem(
        id: '2',
        title: 'Analytics',
        icon: Icons.analytics_outlined,
        route: '/analytics',
      ),
      MenuItem(
        id: '3',
        title: 'Settings',
        icon: Icons.settings_outlined,
        route: '/settings',
      ),
    ];
  }
}
