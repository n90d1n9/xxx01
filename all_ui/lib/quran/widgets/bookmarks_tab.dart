import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../states/quran_provider.dart';

class BookmarksTab extends ConsumerWidget {
  const BookmarksTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);
    return bookmarksAsync.when(
      data: (bookmarks) {
        if (bookmarks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No bookmarks yet'),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = bookmarks[index];
            return Dismissible(
              key: Key('${bookmark.surahNumber}-${bookmark.ayahNumber}'),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                ref
                    .read(bookmarkServiceProvider)
                    .removeBookmark(bookmark.surahNumber, bookmark.ayahNumber);
                ref.invalidate(bookmarksProvider);
              },
              child: ListTile(
                leading: const Icon(Icons.bookmark),
                title: Text(bookmark.surahName),
                subtitle: Text(
                  'Ayah ${bookmark.ayahNumber} • ${DateFormat.yMd().add_jm().format(bookmark.timestamp)}',
                ),
                onTap: () {},
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
