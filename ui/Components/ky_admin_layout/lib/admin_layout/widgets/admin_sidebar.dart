import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../models/menu_item.dart';
import '../states/admin_provider.dart';
import '../states/admin_state.dart';
import 'sidebar_item.dart';
import 'sidebar_header.dart';

class AdminSidebar extends ConsumerWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);
    final theme = Theme.of(context);

    return Container(
      width: _getSidebarWidth(adminState.sidebarMode),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context, ref, adminState),
          Expanded(
            child: FutureBuilder<String>(
              future: jsonFromFile('assets/data/menu_sidebar.json'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No data available'));
                }

                // Parse the JSON and convert to List<MenuItem>
                try {
                  final jsonData = jsonDecode(snapshot.data!);
                  final List<MenuItem> menuItems =
                      (jsonData['menuItems'] as List)
                          .map((item) => MenuItem.fromJson(item))
                          .toList();

                  return _buildMenuList(context, menuItems, adminState);
                } catch (e) {
                  return Center(child: Text('Error parsing menu: $e'));
                }
              },
            ),
          ),
          _buildFooter(context, ref, adminState),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, AdminState state) {
    final theme = Theme.of(context);
    final isMinimized = state.sidebarMode == SidebarMode.minimized;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!isMinimized) ...[
            _buildSidebarModeSelector(context, ref, state),
            const SizedBox(height: 16),
          ],
          _buildUserProfile(context, ref, state),
          // Add compact mode selector for minimized state
          if (isMinimized) ...[
            const SizedBox(height: 12),
            _buildCompactModeSelector(context, ref, state),
          ],
        ],
      ),
    );
  }

  double _getSidebarWidth(SidebarMode mode) {
    switch (mode) {
      case SidebarMode.expanded:
        return 280;
      case SidebarMode.minimized:
        return 80;
      case SidebarMode.overlay:
        return 280;
    }
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AdminState state) {
    final theme = Theme.of(context);
    final isMinimized = state.sidebarMode == SidebarMode.minimized;

    return SidebarHeader(
      isMinimized: isMinimized,
      theme: theme,
      onPressed: () =>
          ref.read(adminProvider.notifier).setSidebarMode(SidebarMode.expanded),
    );
  }

  Widget _buildMenuList(
      BuildContext context, List<MenuItem> menuItems, AdminState state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return SidebarItem(
            item: menuItems[index],
            isMinimized: state.sidebarMode == SidebarMode.minimized);
      },
    );
  }

  Widget _buildCompactModeSelector(
    BuildContext context,
    WidgetRef ref,
    AdminState state,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Tooltip(
          message: 'Expand',
          child: IconButton(
            icon: Icon(Icons.keyboard_arrow_right, size: 20),
            onPressed: () => ref
                .read(adminProvider.notifier)
                .setSidebarMode(SidebarMode.expanded),
          ),
        ),
        const SizedBox(height: 4),
        Tooltip(
          message: 'Overlay',
          child: IconButton(
            icon: Icon(Icons.layers, size: 20),
            onPressed: () => ref
                .read(adminProvider.notifier)
                .setSidebarMode(SidebarMode.overlay),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarModeSelector(
    BuildContext context,
    WidgetRef ref,
    AdminState state,
  ) {
    return Row(
      children: [
        _buildModeButton(
          context,
          ref,
          Icons.menu_open,
          SidebarMode.expanded,
          state.sidebarMode == SidebarMode.expanded,
        ),
        const SizedBox(width: 8),
        _buildModeButton(
          context,
          ref,
          Icons.menu,
          SidebarMode.minimized,
          state.sidebarMode == SidebarMode.minimized,
        ),
        const SizedBox(width: 8),
        _buildModeButton(
          context,
          ref,
          Icons.layers,
          SidebarMode.overlay,
          state.sidebarMode == SidebarMode.overlay,
        ),
      ],
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    SidebarMode mode,
    bool isSelected,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      child: Material(
        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => ref.read(adminProvider.notifier).setSidebarMode(mode),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(
    BuildContext context,
    WidgetRef ref,
    AdminState state,
  ) {
    final theme = Theme.of(context);
    final isMinimized = state.sidebarMode == SidebarMode.minimized;

    return Tooltip(
      message: isMinimized ? 'John Doe - Administrator' : '',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 18,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            if (!isMinimized) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Administrator',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
