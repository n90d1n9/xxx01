import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/models/auth/user.dart';
import '../../../app/states/auth/auth_provider.dart';
import '../states/dashboard_provider.dart';
import '../states/provider.dart';
import '../states/sidebar_provider.dart';
import 'account_widget.dart';

class AdminHeader extends ConsumerWidget {
  const AdminHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final sidebarMode = ref.watch(sidebarModeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mobile drawer toggle
          if (MediaQuery.of(context).size.width < 600)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),

          // Desktop sidebar toggle
          if (MediaQuery.of(context).size.width >= 600)
            IconButton(
              icon: Icon(
                sidebarMode == SidebarMode.expanded
                    ? Icons.menu_open
                    : sidebarMode == SidebarMode.compact
                    ? Icons.menu
                    : Icons.menu,
              ),
              onPressed: () {
                ref
                    .read(sidebarModeProvider.notifier)
                    .state = switch (sidebarMode) {
                  SidebarMode.expanded => SidebarMode.compact,
                  SidebarMode.compact => SidebarMode.hidden,
                  SidebarMode.hidden => SidebarMode.expanded,
                };
              },
            ),

          // Page title
          Expanded(
            child: Text(
              currentPage,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          // Search
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),

          // Notifications
          Badge(
            label: const Text('3'),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ),

          // Theme toggle
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.wb_sunny_outlined
                  : Icons.nightlight_round,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
            },
          ),

          const SizedBox(width: 8),

          // User profile
          FutureBuilder<User?>(
            future: ref.read(authProvider.notifier).getUserProfile(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return AccountWidget(user: snapshot.data!);
              } else {
                return Text('data');
              }
            },
          ),
        ],
      ),
    );
  }
}
