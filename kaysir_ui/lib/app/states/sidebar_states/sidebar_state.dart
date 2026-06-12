import 'package:ky_core/core/features/feature_routes.dart';

enum SidebarMode { full, collapsed, overlay }

class SidebarStates {
  final FeatureRoutes selectedMenu;
  final List<FeatureRoutes> menuList;
  final SidebarMode mode;

  SidebarStates({
    this.mode = SidebarMode.full,
    required this.selectedMenu,
    required this.menuList,
  });

  SidebarStates copyWith({
    FeatureRoutes? selectedMenu,
    List<FeatureRoutes>? menuList,
    SidebarMode? mode,
  }) {
    return SidebarStates(
      selectedMenu: selectedMenu ?? this.selectedMenu,
      menuList: menuList ?? this.menuList,
      mode: mode ?? this.mode,
    );
  }
}
