import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/document_theme.dart';
import '../states/provider.dart';

class ThemeDialog extends ConsumerWidget {
  const ThemeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(documentProvider).currentTheme;
    return AlertDialog(
      title: const Text('Document Theme'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: DocumentTheme.predefinedThemes.length,
          itemBuilder: (context, index) {
            final theme = DocumentTheme.predefinedThemes[index];
            final isSelected = theme.name == currentTheme!.name;

            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.accentColor],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              title: Text(theme.name),
              subtitle: Text('Font: ${theme.defaultFont}'),
              trailing:
                  isSelected
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
              selected: isSelected,
              onTap: () {
                ref.read(documentProvider.notifier).applyTheme(theme);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Theme "${theme.name}" applied')),
                );
              },
            );
          },
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
}
