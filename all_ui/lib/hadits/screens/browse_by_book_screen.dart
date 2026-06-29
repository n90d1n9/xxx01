// Browse Screens
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/hadith.dart';
import '../states/hadith_provider.dart';

class BrowseByBookScreen extends ConsumerWidget {
  const BrowseByBookScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hadiths = ref.watch(hadithListProvider);
    final books = ref.watch(bookListProvider);
    final locale = ref.watch(localeProvider);

    final bookGroups = <String, List<Hadith>>{};
    for (final hadith in hadiths) {
      bookGroups.putIfAbsent(hadith.bookId, () => []).add(hadith);
    }

    return Scaffold(
      appBar: AppBar(title: Text(tr(ref, 'browse_by_book'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children:
            bookGroups.entries.map((entry) {
              final book = books.firstWhereOrNull((b) => b.id == entry.key);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(
                    book?.name.get(locale) ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tr(ref, 'author')}: ${book?.author.get(locale) ?? ''}',
                      ),
                      Text('${entry.value.length} ${tr(ref, 'hadiths')}'),
                    ],
                  ),
                  children:
                      entry.value.map((h) {
                        return ListTile(
                          title: Text(
                            h.translation.get(locale),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${tr(ref, 'hadith_number')}${h.number}',
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
