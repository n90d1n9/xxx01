import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/features/feature_routes.dart';
import '../../../../core/features/features_registry.dart';
import '../../states/sidebar_provider.dart';
import '../../states/dashboard_provider.dart';
import '../../services/admin_route_branch_matcher.dart';
import '../../services/admin_shell_layout_resolver.dart';
import '../../../../widgets/ui/app_action_button.dart';
import '../../../../widgets/ui/app_dialog_actions.dart';
import 'admin_sidebar_brand.dart';
import 'admin_sidebar_footer.dart';
import 'sidebar_menu.dart';

class AdminSidebar extends ConsumerWidget {
  final bool isDrawer;
  final StatefulNavigationShell? navigationShell;

  const AdminSidebar({super.key, this.isDrawer = false, this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SidebarMode sidebarMode = ref.watch(sidebarModeProvider);
    final effectiveSidebarMode = isDrawer ? SidebarMode.expanded : sidebarMode;
    final isCompact = effectiveSidebarMode == SidebarMode.compact;
    final colorScheme = Theme.of(context).colorScheme;
    final features = FeaturesRegistry.getFeatures();
    final currentLocation = GoRouterState.of(context).uri.toString();
    final selectedMenu = _findSelectedMenu(features, currentLocation);
    final sidebarWidth = resolveAdminSidebarWidth(
      mode: effectiveSidebarMode,
      isDrawer: isDrawer,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          AdminSidebarBrand(isCompact: isCompact),

          Expanded(
            child: SidebarMenuWidget(
              displayMode: effectiveSidebarMode,
              menuItems: features,
              selectedMenu: selectedMenu,
              backgroundColor: Colors.transparent,
              borderRadius: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              onMenuSelected: (menu) => _navigateToMenu(
                context: context,
                ref: ref,
                menu: menu,
                currentPath: currentLocation,
              ),
            ),
          ),

          AdminSidebarFooter(
            isCompact: isCompact,
            onHelpPressed: () => _openHelpDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _openHelpDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaysir support'),
        content: const Text(
          'For workspace assistance, contact your Kaysir administrator.',
        ),
        actions: [
          AppDialogActions(
            confirmLabel: 'Close',
            confirmVariant: AppActionButtonVariant.text,
            onConfirm: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  FeatureRoutes? _findSelectedMenu(List<FeatureRoutes> items, String path) {
    FeatureRoutes? bestMatch;
    var bestScore = -1;

    void visit(List<FeatureRoutes> routes) {
      for (final item in routes) {
        visit(item.items);

        final score = adminRouteLocationMatchScore(path, item.path);
        if (score > bestScore) {
          bestScore = score;
          bestMatch = item;
        }
      }
    }

    visit(items);
    return bestMatch;
  }

  void _navigateToMenu({
    required BuildContext context,
    required WidgetRef ref,
    required FeatureRoutes menu,
    required String currentPath,
  }) {
    final path = menu.path?.trim();
    if (path == null || path.isEmpty) return;

    if (isDrawer) {
      Scaffold.maybeOf(context)?.closeDrawer();
    }

    if (path == currentPath) return;

    ref.read(currentPageProvider.notifier).state =
        menu.title ?? menu.name ?? 'Dashboard';

    final branchPaths = navigationShell?.route.branches
        .map((branch) => branch.defaultRoute?.path)
        .toList();
    final branchIndex = branchPaths == null
        ? null
        : findBestMatchingBranchPathIndex(path, branchPaths);
    if (branchIndex != null) {
      final branchPath = branchPaths![branchIndex];
      if (adminRouteIsBranchDefaultRequest(path, branchPath)) {
        navigationShell!.goBranch(branchIndex, initialLocation: true);
        return;
      }

      context.go(path);
      return;
    }

    context.go(path);
  }
}
