// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPreferencesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colorScheme.surface,
      ),
      body: ListView(
        children: [
          // ── Appearance ───────────────────────────────────────────────────
          _SectionHeader('Appearance'),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            iconColor: Colors.indigo,
            title: 'Dark mode',
            subtitle: 'Switch between light and dark theme',
            trailing: Switch(
              value: prefs.isDarkMode,
              onChanged: (v) {
                ref.read(appPreferencesProvider.notifier).update((p) => p.copyWith(isDarkMode: v));
                ref.read(isDarkModeProvider.notifier).state = v;
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.grid_view_rounded,
            iconColor: Colors.blue,
            title: 'Grid columns',
            subtitle: 'Number of columns in grid view: ${prefs.gridColumns}',
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: prefs.gridColumns.toDouble(),
                min: 2, max: 5,
                divisions: 3,
                label: '${prefs.gridColumns}',
                onChanged: (v) {
                  ref.read(appPreferencesProvider.notifier)
                      .update((p) => p.copyWith(gridColumns: v.round()));
                  ref.read(gridColumnCountProvider.notifier).state = v.round();
                },
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.view_agenda_rounded,
            iconColor: Colors.teal,
            title: 'Default view',
            subtitle: 'View used when opening a folder',
            trailing: DropdownButton<String>(
              value: prefs.defaultView,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'grid', child: Text('Grid')),
                DropdownMenuItem(value: 'list', child: Text('List')),
                DropdownMenuItem(value: 'detail', child: Text('Detail')),
              ],
              onChanged: (v) {
                if (v == null) return;
                ref.read(appPreferencesProvider.notifier)
                    .update((p) => p.copyWith(defaultView: v));
                final mode = v == 'grid' ? ViewMode.grid
                    : v == 'list' ? ViewMode.list : ViewMode.detail;
                ref.read(viewModeProvider.notifier).state = mode;
              },
            ),
          ),

          // ── Files ────────────────────────────────────────────────────────
          _SectionHeader('Files'),
          _SettingsTile(
            icon: Icons.folder_rounded,
            iconColor: Colors.amber,
            title: 'Folders first',
            subtitle: 'Always show folders before files',
            trailing: Switch(
              value: prefs.groupFoldersFirst,
              onChanged: (v) => ref.read(appPreferencesProvider.notifier)
                  .update((p) => p.copyWith(groupFoldersFirst: v)),
            ),
          ),
          _SettingsTile(
            icon: Icons.label_outline_rounded,
            iconColor: Colors.green,
            title: 'Show file extensions',
            subtitle: 'Display .pdf, .docx etc. in file names',
            trailing: Switch(
              value: prefs.showFileExtensions,
              onChanged: (v) => ref.read(appPreferencesProvider.notifier)
                  .update((p) => p.copyWith(showFileExtensions: v)),
            ),
          ),
          _SettingsTile(
            icon: Icons.visibility_off_rounded,
            iconColor: Colors.grey,
            title: 'Show hidden files',
            subtitle: 'Display files starting with a dot',
            trailing: Switch(
              value: prefs.showHiddenFiles,
              onChanged: (v) => ref.read(appPreferencesProvider.notifier)
                  .update((p) => p.copyWith(showHiddenFiles: v)),
            ),
          ),

          // ── Behavior ─────────────────────────────────────────────────────
          _SectionHeader('Behavior'),
          _SettingsTile(
            icon: Icons.touch_app_rounded,
            iconColor: Colors.purple,
            title: 'Single tap to open',
            subtitle: 'Open files with a single tap (vs double tap)',
            trailing: Switch(
              value: prefs.autoOpenOnSingleTap,
              onChanged: (v) => ref.read(appPreferencesProvider.notifier)
                  .update((p) => p.copyWith(autoOpenOnSingleTap: v)),
            ),
          ),
          _SettingsTile(
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.red,
            title: 'Confirm before deleting',
            subtitle: 'Show confirmation dialog before moving to trash',
            trailing: Switch(
              value: prefs.confirmBeforeDelete,
              onChanged: (v) => ref.read(appPreferencesProvider.notifier)
                  .update((p) => p.copyWith(confirmBeforeDelete: v)),
            ),
          ),

          // ── Storage & Data ────────────────────────────────────────────────
          _SectionHeader('Storage & Data'),
          _SettingsTile(
            icon: Icons.storage_rounded,
            iconColor: Colors.blue,
            title: 'View storage',
            subtitle: 'See what\'s using your space',
            onTap: () => Navigator.pop(context),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          _SettingsTile(
            icon: Icons.history_rounded,
            iconColor: Colors.orange,
            title: 'Clear activity log',
            subtitle: 'Remove all activity history',
            onTap: () {
              ref.read(activityLogProvider.notifier).clear();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Activity log cleared'),
                behavior: SnackBarBehavior.floating,
              ));
            },
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          _SettingsTile(
            icon: Icons.search_off_rounded,
            iconColor: Colors.teal,
            title: 'Clear search history',
            subtitle: 'Remove recent search queries',
            onTap: () {
              ref.read(searchHistoryProvider.notifier).clear();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Search history cleared'),
                behavior: SnackBarBehavior.floating,
              ));
            },
            trailing: const Icon(Icons.chevron_right_rounded),
          ),

          // ── About ─────────────────────────────────────────────────────────
          _SectionHeader('About'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: Colors.blueGrey,
            title: 'FlutterDrive',
            subtitle: 'Version 2.0.0 • Built with Flutter & Riverpod',
            trailing: const SizedBox.shrink(),
          ),
          _SettingsTile(
            icon: Icons.code_rounded,
            iconColor: Colors.deepPurple,
            title: 'Open source',
            subtitle: 'View source code on GitHub',
            trailing: const Icon(Icons.open_in_new_rounded, size: 16),
            onTap: () {},
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  Text(subtitle,
                    style: TextStyle(
                      fontSize: 12, color: colorScheme.onSurfaceVariant),
                    maxLines: 2),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}
