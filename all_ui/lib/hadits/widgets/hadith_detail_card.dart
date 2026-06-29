import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/hadith.dart';
import '../states/hadith_provider.dart';

class HadithDetailCard extends ConsumerWidget {
  final Hadith hadith;

  const HadithDetailCard({Key? key, required this.hadith}) : super(key: key);

  Color _getGradeColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'sahih':
        return Colors.green;
      case 'hasan':
        return Colors.orange;
      case 'daif':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final books = ref.watch(bookListProvider);
    final book = books.firstWhereOrNull((b) => b.id == hadith.bookId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book?.name.get(locale) ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${tr(ref, 'author')}: ${book?.author.get(locale) ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(hadith.grade),
                  backgroundColor: _getGradeColor(hadith.grade),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${hadith.chapter.get(locale)} - ${tr(ref, 'hadith_number')}${hadith.number}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const Divider(height: 24),
            Text(
              tr(ref, 'arabic_text'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hadith.arabicText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.8,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            Text(
              tr(ref, 'translation'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hadith.translation.get(locale),
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              tr(ref, 'explanation'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hadith.explanation.get(locale),
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  hadith.topics
                      .map(
                        (t) => Chip(
                          label: Text(t),
                          backgroundColor: Colors.blue.shade50,
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
