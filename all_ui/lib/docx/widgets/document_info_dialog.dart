import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/provider.dart';
import 'info_row.dart';

class DocumentInfoDialog extends ConsumerWidget {
  const DocumentInfoDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docState = ref.read(documentProvider);
    final stats = ref.read(statisticsProvider);
    return AlertDialog(
      title: const Text('Document Information'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoRow('Title', docState.metadata.title),
            InfoRow('Author', docState.metadata.author),
            InfoRow('Created', _formatDateTime(docState.metadata.createdAt)),
            InfoRow('Modified', _formatDateTime(docState.metadata.modifiedAt)),
            const Divider(),
            InfoRow('Words', stats.wordCount.toString()),
            InfoRow('Characters', stats.characterCount.toString()),
            InfoRow(
              'Characters (no spaces)',
              stats.characterCountNoSpaces.toString(),
            ),
            InfoRow('Paragraphs', stats.paragraphCount.toString()),
            InfoRow('Sentences', stats.sentenceCount.toString()),
            InfoRow(
              'Est. Reading Time',
              '${stats.estimatedReadingTime.inMinutes} minutes',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
