import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

class CheckoutField extends StatelessWidget {
  final String fieldKey;
  final String label;
  final String hint;
  final String initialValue;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;

  const CheckoutField({
    super.key,
    required this.fieldKey,
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.icon,
    required this.onChanged,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      key: ValueKey(fieldKey),
      initialValue: initialValue,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.36,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
