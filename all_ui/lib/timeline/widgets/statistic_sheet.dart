import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/statistics_provider.dart';

class StatisticsSheet extends ConsumerWidget {
  const StatisticsSheet({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);
    return Container(
      padding: const EdgeInsets.all(24),
      height: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Statistics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Total Events: ${stats['count']}',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'Avg Popularity: ${(stats['avgPopularity'] as double).toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'Avg Impact: ${(stats['avgImpact'] as double).toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
