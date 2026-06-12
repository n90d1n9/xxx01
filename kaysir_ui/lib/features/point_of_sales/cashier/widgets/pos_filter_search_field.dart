import 'package:flutter/material.dart';

import 'pos_ui.dart';

class POSFilterSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String clearTooltip;
  final ValueChanged<String> onChanged;

  const POSFilterSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.clearTooltip = 'Clear search',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasQuery = controller.text.trim().isNotEmpty;

    return SizedBox(
      height: POSUiTokens.controlHeight,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search, size: 18),
          suffixIcon:
              hasQuery
                  ? IconButton(
                    tooltip: clearTooltip,
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                  : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.55,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(POSUiTokens.radius),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(POSUiTokens.radius),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(POSUiTokens.radius),
            borderSide: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.65),
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
