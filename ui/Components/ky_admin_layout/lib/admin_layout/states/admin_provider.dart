import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'admin_state.dart';

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier();
});

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier() : super(const AdminState());

  void toggleSidebar() {
    state = state.copyWith(sidebarVisible: !state.sidebarVisible);
  }

  void setSidebarMode(SidebarMode mode) {
    state = state.copyWith(sidebarMode: mode);
  }

  void toggleFullscreen() {
    state = state.copyWith(isFullscreen: !state.isFullscreen);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }
}
