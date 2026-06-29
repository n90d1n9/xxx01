// Dialog for hadith details in network view
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/hadith.dart';
import '../states/hadith_provider.dart';

class HadithNetworkDialog extends ConsumerWidget {
  final Hadith hadith;

  const HadithNetworkDialog({Key? key, required this.hadith}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final books = ref.watch(bookListProvider);
    final book = books.firstWhereOrNull((b) => b.id == hadith.bookId);

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${tr(ref, 'hadith_number')}${hadith.number}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(hadith.grade),
                    backgroundColor: _getGradeColor(hadith.grade),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  hadith.arabicText,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.8,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                hadith.translation.get(locale),
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(ref, 'explanation'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hadith.explanation.get(locale),
                      style: const TextStyle(height: 1.5),
                    ),
                  ],
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
                            backgroundColor: Colors.teal.shade50,
                            labelStyle: TextStyle(color: Colors.teal.shade700),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'mutawatir':
        return Colors.green;
      case 'sahih':
        return Colors.blue;
      case 'hasan':
        return Colors.orange;
      case 'daif':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
