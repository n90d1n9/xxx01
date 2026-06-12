import 'package:flutter/material.dart';

import '../../../widgets/ui/app_search_field.dart';

class InventorySearchField extends StatelessWidget {
  const InventorySearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.clearTooltip = 'Clear search',
    this.width,
    this.height = 44,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final String clearTooltip;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hasQuery = controller.text.trim().isNotEmpty;

    return AppSearchField(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      width: width,
      height: height,
      trailing:
          hasQuery
              ? IconButton(
                tooltip: clearTooltip,
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
              : null,
    );
  }
}
