import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/hadith.dart';
import '../states/hadith_provider.dart';

class BrowseByTopicScreen extends ConsumerWidget {
  const BrowseByTopicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hadiths = ref.watch(hadithListProvider);
    final locale = ref.watch(localeProvider);
    final allTopics = <String, List<Hadith>>{};

    for (final h in hadiths) {
      for (final topic in h.topics) {
        allTopics.putIfAbsent(topic, () => []).add(h);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(tr(ref, 'browse_by_topic'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children:
            allTopics.entries.map((entry) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${entry.value.length} ${tr(ref, 'hadiths')}'),
                  children:
                      entry.value.map((h) {
                        return ListTile(
                          title: Text(
                            h.translation.get(locale),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${h.grade} - ${tr(ref, 'hadith_number')}${h.number}',
                          ),
                          onTap: () {
                            ref.read(selectedHadithProvider.notifier).state = h;
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                ),
              );
            }).toList(),
      ),
    );
  }
}
