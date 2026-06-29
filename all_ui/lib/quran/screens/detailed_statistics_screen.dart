import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../states/quran_provider.dart';

class DetailedStatisticsScreen extends ConsumerWidget {
  const DetailedStatisticsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(readingStatisticsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Reading Statistics')),
      body: statsAsync.when(
        data: (stats) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 64,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${stats.currentStreak} Day Streak',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Longest: ${stats.longestStreak} days',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _StatCard(
                      icon: Icons.format_quote,
                      label: 'Verses Read',
                      value: '${stats.totalVersesRead}',
                      color: Colors.blue,
                    ),
                    _StatCard(
                      icon: Icons.menu_book,
                      label: 'Pages Read',
                      value: '${stats.totalPagesRead}',
                      color: Colors.green,
                    ),
                    _StatCard(
                      icon: Icons.timer,
                      label: 'Time Spent',
                      value: '${stats.totalTimeSpent.inHours}h',
                      color: Colors.orange,
                    ),
                    _StatCard(
                      icon: Icons.check_circle,
                      label: 'Surahs Completed',
                      value: '${stats.completedSurahs.length}',
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (stats.lastReadDate != null) ...[
                  Text(
                    'Activity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Last Read'),
                      subtitle: Text(
                        DateFormat.yMMMd().add_jm().format(stats.lastReadDate!),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
