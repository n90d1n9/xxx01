import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/dhikr_detail_screen.dart';
import '../states/quran_provider.dart';

class DhikrScreen extends ConsumerWidget {
  const DhikrScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dhikrList = ref.watch(dhikrListProvider);
    final countsAsync = ref.watch(dhikrCountsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dhikr Counter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await ref.read(dhikrServiceProvider).resetAllDhikr();
              ref.invalidate(dhikrCountsProvider);
            },
            tooltip: 'Reset All',
          ),
        ],
      ),
      body: countsAsync.when(
        data: (counts) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dhikrList.length,
            itemBuilder: (context, index) {
              final dhikr = dhikrList[index];
              final currentCount = counts[dhikr.id] ?? 0;
              final progress =
                  dhikr.targetCount != null
                      ? currentCount / dhikr.targetCount!
                      : 0.0;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DhikrDetailScreen(
                              dhikr: dhikr,
                              initialCount: currentCount,
                            ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dhikr.arabic,
                          style: const TextStyle(
                            fontFamily: 'Scheherazade',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dhikr.transliteration,
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dhikr.translation,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (dhikr.targetCount != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$currentCount / ${dhikr.targetCount}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ] else
                          Text(
                            'Count: $currentCount',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
