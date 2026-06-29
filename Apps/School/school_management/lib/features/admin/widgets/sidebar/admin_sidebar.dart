import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/features/features_registry.dart';
import '../../states/sidebar_provider.dart';
import 'sidebar_menu.dart';

class AdminSidebar extends ConsumerWidget {
  final bool isDrawer;

  const AdminSidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarMode = ref.watch(sidebarModeProvider);
    final isCompact = sidebarMode == SidebarMode.compact && !isDrawer;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: SidebarMode.expanded == sidebarMode ? 280 : 72,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Logo area
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 12),
                  Text(
                    'Kaysir',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: SidebarMenuWidget(
              displayMode: ref.watch(sidebarModeProvider),
              menuItems: FeaturesRegistry.getFeatures(),
              onMenuSelected: (menu) {
                //ref.read(currentPageProvider.notifier).state = menu.title!;
                context.go(menu.path!);
              },
            ),
          ),

          // Bottom section with version and help
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child:
                isCompact
                    ? IconButton(
                      icon: const Icon(Icons.help_outline),
                      onPressed: () {},
                    )
                    : Row(
                      children: [
                        Text(
                          'v1.0.0',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.help_outline, size: 16),
                          label: const Text('Help'),
                          onPressed: () {},
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
