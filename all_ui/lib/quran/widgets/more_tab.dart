import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/surah.dart';
import '../states/quran_provider.dart';
import 'dhikr_screen.dart';
import '../screens/reciters_screen.dart';
import '../screens/detailed_statistics_screen.dart';
import '../screens/prayer_times_screen.dart';
import '../screens/qibla_screen.dart';
import '../models/prayer.dart';
import 'bookmarks_tab.dart';

class MoreTab extends ConsumerWidget {
  const MoreTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(readingStatisticsProvider);
    final prayerTimes = ref.watch(prayerTimesProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          stats.when(
            data: (statistics) => _StatisticsCard(statistics: statistics),
            loading:
                () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            error: (error, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          prayerTimes.when(
            data: (times) {
              if (times == null) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.mosque),
                    title: const Text('Prayer Times'),
                    subtitle: const Text('Set your location'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrayerTimesScreen(),
                        ),
                      );
                    },
                  ),
                );
              }
              final next = times.getNextPrayer();
              final timeUntil = times.getTimeUntilNext();
              return Card(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrayerTimesScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.mosque, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              'Next Prayer: ${_getPrayerName(next)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'In ${_formatDuration(timeUntil)}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          Text('Islamic Tools', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _ToolCard(
                icon: Icons.my_location,
                label: 'Qibla',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QiblaScreen(),
                    ),
                  );
                },
              ),
              _ToolCard(
                icon: Icons.lock_clock,
                label: 'Dhikr',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DhikrScreen(),
                    ),
                  );
                },
              ),
              _ToolCard(
                icon: Icons.bookmark,
                label: 'Bookmarks',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookmarksTab(),
                    ),
                  );
                },
              ),
              _ToolCard(
                icon: Icons.record_voice_over,
                label: 'Reciters',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecitersScreen(),
                    ),
                  );
                },
              ),
              _ToolCard(
                icon: Icons.timeline,
                label: 'Statistics',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailedStatisticsScreen(),
                    ),
                  );
                },
              ),
              _ToolCard(
                icon: Icons.info,
                label: 'About',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Quran Reader Pro',
                    applicationVersion: '2.0.0',
                    applicationIcon: const Icon(Icons.menu_book, size: 48),
                    children: [
                      const Text(
                        'A comprehensive Quran reading, memorization, and study app.',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  final ReadingStatistics statistics;
  const _StatisticsCard({required this.statistics});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (statistics.currentStreak > 0)
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${statistics.currentStreak} day streak!',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(
                  label: 'Verses',
                  value: '${statistics.totalVersesRead}',
                  icon: Icons.format_quote,
                ),
                _MiniStat(
                  label: 'Pages',
                  value: '${statistics.totalPagesRead}',
                  icon: Icons.menu_book,
                ),
                _MiniStat(
                  label: 'Time',
                  value: '${statistics.totalTimeSpent.inHours}h',
                  icon: Icons.timer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ToolCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
