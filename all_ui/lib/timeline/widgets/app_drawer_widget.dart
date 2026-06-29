import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../states/timeline_provider.dart';
import '../states/user_profile_provider.dart';
import 'achievement_dialog.dart';
import 'export_dialog.dart';
import 'quiz_dialog.dart';
import 'recently_viewed_dialog.dart';
import 'settings_dialog.dart';
import 'tutorial_dialog.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Drawer(
      backgroundColor: const Color(0xFF1A1A2E),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C63FF),
                    const Color(0xFF6C63FF).withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User ${userProfile.userId}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Member since ${DateFormat('MMM yyyy').format(userProfile.joinDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.favorite,
                    title: 'Favorites',
                    count: userProfile.favoriteEventIds.length,
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(timelineProvider.notifier).toggleShowFavorites();
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.bookmark,
                    title: 'Bookmarks',
                    count: userProfile.bookmarkedEventIds.length,
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(timelineProvider.notifier).toggleShowBookmarks();
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.history,
                    title: 'Recently Viewed',
                    count: userProfile.recentlyViewed.length,
                    onTap: () {
                      Navigator.pop(context);
                      _showRecentlyViewed(context, ref);
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _DrawerItem(
                    icon: Icons.quiz,
                    title: 'Quiz Mode',
                    onTap: () {
                      Navigator.pop(context);
                      _showQuizMode(context, ref);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.emoji_events,
                    title: 'Achievements',
                    count: userProfile.achievements.length,
                    onTap: () {
                      Navigator.pop(context);
                      _showAchievements(context, ref);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.compare_arrows,
                    title: 'Comparison Mode',
                    trailing: Switch(
                      value: ref.watch(timelineProvider).comparisonMode,
                      onChanged: (_) {
                        ref
                            .read(timelineProvider.notifier)
                            .toggleComparisonMode();
                      },
                      activeColor: const Color(0xFF6C63FF),
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  _DrawerItem(
                    icon: Icons.download,
                    title: 'Export Timeline',
                    onTap: () {
                      Navigator.pop(context);
                      _showExportOptions(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      _showSettings(context, ref);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.help,
                    title: 'Help & Tutorial',
                    onTap: () {
                      Navigator.pop(context);
                      _showTutorial(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecentlyViewed(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const RecentlyViewedDialog(),
    );
  }

  void _showQuizMode(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => const QuizDialog());
  }

  void _showAchievements(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AchievementsDialog(),
    );
  }

  void _showExportOptions(BuildContext context) {
    showDialog(context: context, builder: (context) => const ExportDialog());
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => const SettingsDialog());
  }

  void _showTutorial(BuildContext context) {
    showDialog(context: context, builder: (context) => const TutorialDialog());
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int? count;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.count,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6C63FF)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing:
          trailing ??
          (count != null
              ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
              : null),
      onTap: onTap,
    );
  }
}
