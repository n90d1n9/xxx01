// Sidebar mode enum
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SidebarMode { expanded, compact, hidden }

// Sidebar mode provider
final sidebarModeProvider = StateProvider<SidebarMode>(
  (ref) => SidebarMode.expanded,
);

// Sidebar state provider
final sidebarExpandedProvider = StateProvider<bool>((ref) => true);
