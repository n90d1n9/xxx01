import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/hadith_provider.dart';

class RelatedHadithsSection extends ConsumerWidget {
  final List<String> hadithIds;

  const RelatedHadithsSection({Key? key, required this.hadithIds})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHadiths = ref.watch(hadithListProvider);
    final locale = ref.watch(localeProvider);
    final books = ref.watch(bookListProvider);
    final relatedHadiths =
        allHadiths.where((h) => hadithIds.contains(h.id)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(ref, 'related_hadiths'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...relatedHadiths.map((h) {
              final book = books.firstWhereOrNull((b) => b.id == h.bookId);
              return ListTile(
                title: Text(
                  h.translation.get(locale),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('${book?.name.get(locale) ?? ''} - ${h.grade}'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  ref.read(selectedHadithProvider.notifier).state = h;
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
