import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/quran_provider.dart';
import '../models/memorization.dart';

class MemorizationProgressScreen extends ConsumerWidget {
  const MemorizationProgressScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(memorizationEntriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Memorization Progress')),
      body: entriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('No memorization entries yet'));
          }
          final Map<int, List<MemorizationEntry>> bySurah = {};
          for (var entry in entries) {
            bySurah.putIfAbsent(entry.surahNumber, () => []).add(entry);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bySurah.length,
            itemBuilder: (context, index) {
              final surahNumber = bySurah.keys.elementAt(index);
              final surahEntries = bySurah[surahNumber]!;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text('Surah $surahNumber'),
                  subtitle: Text('${surahEntries.length} ayahs'),
                  children:
                      surahEntries.map((entry) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(entry.status),
                            child: Text('${entry.ayahNumber}'),
                          ),
                          title: Text('Ayah ${entry.ayahNumber}'),
                          subtitle: LinearProgressIndicator(
                            value: entry.strength,
                            backgroundColor: Colors.grey[200],
                          ),
                          trailing: Text(
                            '${(entry.strength * 100).toInt()}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
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

  Color _getStatusColor(MemorizationStatus status) {
    switch (status) {
      case MemorizationStatus.mastered:
        return Colors.green;
      case MemorizationStatus.reviewing:
        return Colors.blue;
      case MemorizationStatus.learning:
        return Colors.orange;
      case MemorizationStatus.struggling:
        return Colors.red;
    }
  }
}
