import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/priority.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.day);
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoriesProvider = StateProvider<Set<String>>((ref) => {});
final showCompletedProvider = StateProvider<bool>((ref) => true);
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
