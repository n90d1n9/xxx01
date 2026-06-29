import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/hadith_provider.dart';

class MyListView extends ConsumerWidget {
  const MyListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hadiths = ref.watch(filteredHadithsProvider);
    final locale = ref.watch(localeProvider);
    final books = ref.watch(bookListProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hadiths.length,
      itemBuilder: (context, idx) {
        final hadith = hadiths[idx];
        final book = books.firstWhereOrNull((b) => b.id == hadith.bookId);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              hadith.translation.get(locale),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('${book?.name.get(locale) ?? ''} - ${hadith.grade}'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              ref.read(selectedHadithProvider.notifier).state = hadith;
              ref.read(viewModeProvider.notifier).state = ViewMode.graph;
            },
          ),
        );
      },
    );
  }
}
