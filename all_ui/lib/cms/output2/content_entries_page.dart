import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'models/content_type_schema.dart';

import 'content_type_schema.dart';

class ContentEntriesPage extends ConsumerWidget {
  final ContentTypeSchema contentType;
  const ContentEntriesPage({super.key, required this.contentType});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(contentEntriesProvider(contentType.id));
    return Scaffold(
      appBar: AppBar(title: Text(contentType.name)),
      body: entriesAsync.when(
        data:
            (entries) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    entries.isEmpty
                        ? 'No entries yet'
                        : '${entries.length} entries',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
