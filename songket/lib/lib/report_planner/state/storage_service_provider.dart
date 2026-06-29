// Storage Service
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/agenda_item.dart';

class StorageService {
  static const String _itemsKey = 'agenda_items';

  static const String _themeKey = 'theme_mode';

  Future<void> saveItems(List<AgendaItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_itemsKey, jsonList);
  }

  Future<List<AgendaItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_itemsKey) ?? [];
    return jsonList
        .map((jsonStr) => AgendaItem.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  Future<void> saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString());
  }

  Future<ThemeMode> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(_themeKey);
    if (themeStr == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == themeStr,
      orElse: () => ThemeMode.system,
    );
  }
}

// Agenda Items Provider
final storageServiceProvider = Provider((ref) => StorageService());
