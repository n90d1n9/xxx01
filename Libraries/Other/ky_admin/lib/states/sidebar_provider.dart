// Sidebar mode enum
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum SidebarMode { expanded, compact, hidden }

SidebarMode nextSidebarMode(SidebarMode mode) {
  return switch (mode) {
    SidebarMode.expanded => SidebarMode.compact,
    SidebarMode.compact => SidebarMode.hidden,
    SidebarMode.hidden => SidebarMode.expanded,
  };
}

// Sidebar mode provider
final sidebarModeProvider = StateProvider<SidebarMode>(
  (ref) => SidebarMode.expanded,
);

// Sidebar state provider
final sidebarExpandedProvider = StateProvider<bool>((ref) => true);
