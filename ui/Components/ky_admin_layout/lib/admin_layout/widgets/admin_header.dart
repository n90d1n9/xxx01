import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/admin_provider.dart';
import '../states/admin_state.dart';

class AdminHeader extends ConsumerStatefulWidget {
  const AdminHeader({super.key});

  @override
  ConsumerState<AdminHeader> createState() => _AdminHeaderState();
}

class _AdminHeaderState extends ConsumerState<AdminHeader> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final theme = Theme.of(context);

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildMenuButton(context, ref),
          const SizedBox(width: 16),
          _buildSearchBar(context, ref, adminState),
          const SizedBox(width: 16),
          _buildHeaderActions(context, ref, adminState),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return IconButton(
      icon: Icon(Icons.menu, color: theme.colorScheme.onSurface),
      onPressed: () => ref.read(adminProvider.notifier).toggleSidebar(),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    WidgetRef ref,
    AdminState state,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        height: 40,
        constraints: const BoxConstraints(maxWidth: 400),
        child: GlobalSearchField(
          controller: _searchController,
          hintText: 'Search...',
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          fillColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
          borderRadius: 20,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onChanged: (value) {
            ref.read(adminProvider.notifier).setSearchQuery(value);
          },
          onClear: () {
            _searchController.clear();
            ref.read(adminProvider.notifier).setSearchQuery('');
          },
        ),
      ),
    );
  }

  Widget _buildHeaderActions(
    BuildContext context,
    WidgetRef ref,
    AdminState state,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        IconButton(
          icon: Icon(
            state.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
            color: theme.colorScheme.onSurface,
          ),
          tooltip: state.isFullscreen
              ? 'Exit Fullscreen (ESC)'
              : 'Enter Fullscreen (F11)',
          onPressed: () => ref.read(adminProvider.notifier).toggleFullscreen(),
        ),
        const SizedBox(width: 8),
        _buildNotificationButton(context, ref),
        const SizedBox(width: 8),
        _buildSettingsButton(context, ref),
      ],
    );
  }

  Widget _buildNotificationButton(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications, color: theme.colorScheme.onSurface),
          onPressed: () {
            // Handle notifications
          },
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.colorScheme.error,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsButton(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      icon: Icon(Icons.settings, color: theme.colorScheme.onSurface),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'theme',
          child: Row(
            children: [
              Icon(Icons.palette, size: 20),
              const SizedBox(width: 12),
              Text('Theme'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'language',
          child: Row(
            children: [
              Icon(Icons.language, size: 20),
              const SizedBox(width: 12),
              Text('Language'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, size: 20),
              const SizedBox(width: 12),
              Text('Settings'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'theme':
            _showThemeDialog(context, ref);
            break;
          case 'language':
            _showLanguageDialog(context, ref);
            break;
          case 'settings':
            // Navigate to settings
            break;
        }
      },
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.brightness_auto),
              title: Text('System'),
              onTap: () {
                ref.read(adminProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.brightness_high),
              title: Text('Light'),
              onTap: () {
                ref.read(adminProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.brightness_low),
              title: Text('Dark'),
              onTap: () {
                ref.read(adminProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Text('🇺🇸'),
              title: Text('English'),
              onTap: () {
                ref.read(adminProvider.notifier).setLocale(Locale('en', 'US'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Text('🇪🇸'),
              title: Text('Español'),
              onTap: () {
                ref.read(adminProvider.notifier).setLocale(Locale('es', 'ES'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Text('🇫🇷'),
              title: Text('Français'),
              onTap: () {
                ref.read(adminProvider.notifier).setLocale(Locale('fr', 'FR'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
