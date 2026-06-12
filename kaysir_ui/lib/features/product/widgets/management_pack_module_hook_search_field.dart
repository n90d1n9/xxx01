import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Search field for module names, hook titles, reasons, and outputs.
class ProductManagementPackModuleHookSearchField extends StatelessWidget {
  const ProductManagementPackModuleHookSearchField({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        suffixIcon:
            query.trim().isEmpty
                ? null
                : IconButton(
                  tooltip: 'Clear module search',
                  icon: const Icon(Icons.close_rounded),
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 36,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: onClear,
                ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        hintText: 'Search modules, hooks, reasons, or outputs',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

@Preview(name: 'Management pack module hook search')
Widget productManagementPackModuleHookSearchFieldPreview() {
  final controller = TextEditingController(text: 'launch');

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackModuleHookSearchField(
          controller: controller,
          query: controller.text,
          onChanged: (_) {},
          onClear: () {},
        ),
      ),
    ),
  );
}
