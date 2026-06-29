import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/hadith.dart';
import '../states/hadith_provider.dart';
import 'rawi_detail_dialog.dart';

class SanadGraph extends ConsumerWidget {
  final Hadith hadith;

  const SanadGraph({Key? key, required this.hadith}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawis = ref.watch(rawiListProvider);
    final locale = ref.watch(localeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(ref, 'chain_of_narrators'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...hadith.sanad.asMap().entries.map((entry) {
              final idx = entry.key;
              final rawiId = entry.value;
              final rawi = rawis.firstWhereOrNull((r) => r.id == rawiId);

              if (rawi == null) return const SizedBox.shrink();

              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      ref.read(selectedRawiProvider.notifier).state = rawi;
                      showDialog(
                        context: context,
                        builder: (_) => RawiDetailDialog(rawi: rawi),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rawi.name.get(locale),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  rawi.name.ar,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${rawi.birthYear} - ${rawi.deathYear}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                  if (idx < hadith.sanad.length - 1)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_downward, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(tr(ref, 'narrated_from')),
                        ],
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
