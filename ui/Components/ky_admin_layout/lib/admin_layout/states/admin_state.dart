import 'package:flutter/material.dart';

enum SidebarMode { expanded, minimized, overlay }

class AdminState {
  final SidebarMode sidebarMode;
  final bool isFullscreen;
  final String searchQuery;
  final ThemeMode themeMode;
  final Locale locale;
  final bool sidebarVisible;

  const AdminState({
    this.sidebarMode = SidebarMode.expanded,
    this.isFullscreen = false,
    this.searchQuery = '',
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en', 'US'),
    this.sidebarVisible = true,
  });

  AdminState copyWith({
    SidebarMode? sidebarMode,
    bool? isFullscreen,
    String? searchQuery,
    ThemeMode? themeMode,
    Locale? locale,
    bool? sidebarVisible,
  }) {
    return AdminState(
      sidebarMode: sidebarMode ?? this.sidebarMode,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      searchQuery: searchQuery ?? this.searchQuery,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      sidebarVisible: sidebarVisible ?? this.sidebarVisible,
    );
  }
}
