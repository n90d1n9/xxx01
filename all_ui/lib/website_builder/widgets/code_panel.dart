import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/provider.dart';

class CodePanel extends ConsumerWidget {
  const CodePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final json = ref.read(designerProvider.notifier).saveProject();

    return Container(
      width: 400,
      color: Colors.grey.shade900,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Code Export',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: json));
                },
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                json,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
