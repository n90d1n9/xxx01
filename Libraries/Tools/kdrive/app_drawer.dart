// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/file_provider.dart';
import '../screens/activity_screen.dart';
import '../screens/gallery_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/storage_screen.dart';
import '../screens/trash_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(drawerSectionProvider);
    final trashedCount = ref.watch(trashedFilesProvider).length;
    final prefs = ref.watch(appPreferencesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(16))),
      child: Column(
        children: [
          // Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.tertiary],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.drive_folder_upload_rounded,
                        color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FlutterDrive',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
                          Text('user@example.com',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    // Dark mode quick toggle
                    IconButton(
                      onPressed: () {
                        ref.read(isDarkModeProvider.notifier).state = !prefs.isDarkMode;
                        ref.read(appPreferencesProvider.notifier)
                            .update((p) => p.copyWith(isDarkMode: !p.isDarkMode));
                      },
                      icon: Icon(
                        prefs.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: colorScheme.onSurfaceVariant, size: 20,
                      ),
                      tooltip: prefs.isDarkMode ? 'Light mode' : 'Dark mode',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Storage bar
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const StorageScreen()));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('8.2 GB of 15 GB used',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                          Text('View storage →',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.55, minHeight: 6,
                          backgroundColor: colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              children: [
                _DrawerItem(icon: Icons.drive_folder_upload_rounded, label: 'My Drive',
                  selected: section == DrawerSection.myDrive,
                  onTap: () {
                    ref.read(drawerSectionProvider.notifier).state = DrawerSection.myDrive;
                    ref.read(navigationStackProvider.notifier).navigateToIndex(0);
                    Navigator.pop(context);
                  }),
                _DrawerItem(icon: Icons.access_time_rounded, label: 'Recent',
                  selected: section == DrawerSection.recent,
                  onTap: () {
                    ref.read(drawerSectionProvider.notifier).state = DrawerSection.recent;
                    Navigator.pop(context);
                  }),
                _DrawerItem(icon: Icons.star_rounded, label: 'Starred',
                  selected: section == DrawerSection.starred,
                  onTap: () {
                    ref.read(drawerSectionProvider.notifier).state = DrawerSection.starred;
                    Navigator.pop(context);
                  }),
                _DrawerItem(icon: Icons.people_rounded, label: 'Shared with me',
                  selected: section == DrawerSection.shared,
                  onTap: () {
                    ref.read(drawerSectionProvider.notifier).state = DrawerSection.shared;
                    Navigator.pop(context);
                  }),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 4),
                  child: Text('TOOLS', style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    letterSpacing: 0.8)),
                ),

                _DrawerItem(icon: Icons.photo_library_rounded, label: 'Gallery',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const GalleryScreen()));
                  }),
                _DrawerItem(icon: Icons.storage_rounded, label: 'Storage',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const StorageScreen()));
                  }),
                _DrawerItem(icon: Icons.history_rounded, label: 'Activity',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const ActivityScreen()));
                  }),
                _DrawerItem(
                  icon: Icons.delete_outline_rounded, label: 'Trash',
                  selected: section == DrawerSection.trash,
                  badge: trashedCount > 0 ? trashedCount : null,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const TrashScreen()));
                  }),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Column(
              children: [
                Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
                ListTile(
                  leading: Icon(Icons.settings_rounded,
                    color: colorScheme.onSurfaceVariant, size: 20),
                  title: Text('Settings',
                    style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const SettingsScreen()));
                  },
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                FilledButton.tonal(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Get more storage'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int? badge;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.label,
    required this.selected, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon,
            color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant, size: 22),
          if (badge != null)
            Positioned(
              top: -5, right: -5,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text('$badge',
                  style: const TextStyle(color: Colors.white, fontSize: 9,
                    fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
      title: Text(label, style: TextStyle(
        color: selected ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 14,
      )),
      selected: selected,
      selectedTileColor: colorScheme.primaryContainer.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap,
      dense: true,
    );
  }
}
