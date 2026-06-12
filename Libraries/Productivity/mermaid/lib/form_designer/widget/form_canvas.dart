import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/form_theme.dart';
import '../states/form_field_provider.dart';
import 'field_card_wrapper.dart';

class FormCanvas extends ConsumerWidget {
  final FormTheme? theme;
  const FormCanvas({super.key, this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = ref.watch(formFieldsProvider);
    final previewMode = ref.watch(previewModeProvider);

    if (fields.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'Start Building Your Form',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add components from the left panel to get started',
              style: TextStyle(color: Colors.white.withOpacity(0.3)),
            ),
            const Icon(Icons.inbox, size: 80, color: Colors.white24),
            const SizedBox(height: 24),
            const Text(
              '✨ Undo/Redo with Ctrl+Z / Ctrl+Y',
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Container(
      color: const Color(0xFF1E1E1E),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ReorderableListView.builder(
              key: ValueKey(DateTime.now().millisecond),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: previewMode
                  ? (_, __) {}
                  : (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;
                      ref
                          .read(formFieldsProvider.notifier)
                          .reorderField(oldIndex, newIndex);
                    },
              itemCount: fields.length,
              itemBuilder: (context, index) {
                final field = fields[index];
                return FieldCardWrapper(
                  key: ValueKey(field.id),
                  field: field,
                  index: index,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
