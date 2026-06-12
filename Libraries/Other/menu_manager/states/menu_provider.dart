// Providers
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/menu_item.dart';
import '../services/menu_storage.dart';

final menuProvider = StateNotifierProvider<MenuNotifier, List<MenuItem>>((ref) {
  return MenuNotifier();
});

final selectedMenuItemProvider = StateProvider<MenuItem?>((ref) => null);

class MenuNotifier extends StateNotifier<List<MenuItem>> {
  MenuNotifier()
    : super([
        MenuItem(
          id: 'dashboard',
          title: 'Dashboard',
          icon: Icons.dashboard_outlined,
          route: '/dashboard',
          allowedRoles: ['admin', 'user'],
        ),
        MenuItem(
          id: 'analytics',
          title: 'Analytics',
          icon: Icons.analytics_outlined,
          route: '/analytics',
          allowedRoles: ['admin'],
        ),
        MenuItem(
          id: 'settings',
          title: 'Settings',
          icon: Icons.settings_outlined,
          route: '/settings',
          allowedRoles: ['admin'],
        ),
      ]) {
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    state = await MenuLocalStorageService.loadMenuItems();
  }

  void addMenuItem(MenuItem item) {
    state = [...state, item];
    _saveMenuItems();
  }

  void removeMenuItem(String id) {
    state = state.where((item) => item.id != id).toList();
    _saveMenuItems();
  }

  void updateMenuItem(MenuItem updatedItem) {
    state = state
        .map((item) => item.id == updatedItem.id ? updatedItem : item)
        .toList();
    _saveMenuItems();
  }

  void _saveMenuItems() {
    MenuLocalStorageService.saveMenuItems(state);
  }
}
