import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/hadith_provider.dart';

class MyGridView extends ConsumerWidget {
  const MyGridView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hadiths = ref.watch(filteredHadithsProvider);
    final locale = ref.watch(localeProvider);
    final books = ref.watch(bookListProvider);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: hadiths.length,
      itemBuilder: (context, idx) {
        final hadith = hadiths[idx];
        final book = books.firstWhereOrNull((b) => b.id == hadith.bookId);
        return Card(
          child: InkWell(
            onTap: () {
              ref.read(selectedHadithProvider.notifier).state = hadith;
              ref.read(viewModeProvider.notifier).state = ViewMode.graph;
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(hadith.grade),
                    backgroundColor: Colors.green,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book?.name.get(locale) ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hadith.translation.get(locale),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '${hadith.sanad.length} ${tr(ref, 'narrators')}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
