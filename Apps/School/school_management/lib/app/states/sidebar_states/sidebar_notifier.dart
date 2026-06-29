import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/features/feature_routes.dart';
import 'sidebar_state.dart';

final sidebarProvider = StateNotifierProvider<SidebarNotifier, SidebarStates>(
  (ref) => SidebarNotifier(),
);

class SidebarNotifier extends StateNotifier<SidebarStates> {
  SidebarNotifier()
    : super(SidebarStates(selectedMenu: FeatureRoutes(), menuList: []));

  get selectedMenu => state.selectedMenu;

  get menuList => state.menuList;

  void addMenu(FeatureRoutes menu) {
    state = state.copyWith(menuList: [...state.menuList, menu]);
  }

  void removeMenu(FeatureRoutes menu) {
    state = state.copyWith(
      menuList: state.menuList.where((element) => element != menu).toList(),
    );
  }

  void removeMenuById(int id) {
    state = state.copyWith(
      menuList: state.menuList.where((element) => element.id != id).toList(),
    );
  }

  void updateMenu(FeatureRoutes menu) {
    state = state.copyWith(
      menuList: state.menuList.map((e) => e.id == menu.id ? menu : e).toList(),
    );
  }

  void addMenuList(List<FeatureRoutes> menuList) {
    state = state.copyWith(menuList: [...state.menuList, ...menuList]);
  }

  void selectMenu(FeatureRoutes menu) {
    state = state.copyWith(selectedMenu: menu);
  }

  void selectMode(SidebarMode mode) {
    state = state.copyWith(mode: mode);
  }

  get mode => state.mode;

  void toggleMode() {
    switch (state.mode) {
      case SidebarMode.full:
        state = state.copyWith(mode: SidebarMode.collapsed);
        break;
      case SidebarMode.collapsed:
        state = state.copyWith(mode: SidebarMode.overlay);
        break;
      case SidebarMode.overlay:
        state = state.copyWith(mode: SidebarMode.full);
        break;
    }
  }
}
