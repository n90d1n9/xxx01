import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/component_stats_provider.dart';

class StatsDialog extends StatelessWidget {
  const StatsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor,
              child: const Row(
                children: [
                  Icon(Icons.bar_chart, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Component Statistics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final stats = ref.watch(componentStatsProvider);

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Most Used Components',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...stats.mostUsedComponents.map((compId) {
                        final usage = stats.componentUsage[compId] ?? 0;
                        return Card(
                          child: ListTile(
                            title: Text(compId),
                            trailing: Chip(label: Text('$usage uses')),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      const Text(
                        'Unused Components',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...stats.unusedComponents.take(5).map((compId) {
                        return Card(
                          child: ListTile(
                            title: Text(compId),
                            trailing: const Chip(label: Text('0 uses')),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
