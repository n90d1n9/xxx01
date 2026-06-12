import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/inventory_form_utils.dart';

class InventoryFormTextField extends StatelessWidget {
  const InventoryFormTextField({
    super.key,
    required this.label,
    this.alignLabelWithHint = false,
    this.autofillHints,
    this.contentPadding,
    this.controller,
    this.focusNode,
    this.helperText,
    this.icon,
    this.initialValue,
    this.inputFormatters,
    this.isDense = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.validator,
  });

  final TextEditingController? controller;
  final String label;
  final IconData? icon;
  final bool alignLabelWithHint;
  final Iterable<String>? autofillHints;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final String? helperText;
  final String? initialValue;
  final List<TextInputFormatter>? inputFormatters;
  final bool isDense;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      initialValue: initialValue,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: icon == null ? null : Icon(icon, size: 18),
        alignLabelWithHint: alignLabelWithHint,
        isDense: isDense,
        contentPadding: contentPadding,
        filled: true,
        fillColor: colorScheme.surface,
        border: border,
        enabledBorder: border,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      validator: validator,
    );
  }
}

class InventoryIntegerFormField extends StatelessWidget {
  const InventoryIntegerFormField({
    super.key,
    required this.label,
    this.allowZero = true,
    this.autofillHints,
    this.contentPadding,
    this.controller,
    this.focusNode,
    this.icon,
    this.initialValue,
    this.inputFormatters,
    this.isDense = false,
    this.onChanged,
    this.textInputAction,
    this.validator,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String label;
  final IconData? icon;
  final bool allowZero;
  final Iterable<String>? autofillHints;
  final EdgeInsetsGeometry? contentPadding;
  final String? initialValue;
  final List<TextInputFormatter>? inputFormatters;
  final bool isDense;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return InventoryFormTextField(
      controller: controller,
      focusNode: focusNode,
      initialValue: initialValue,
      label: label,
      icon: icon,
      autofillHints: autofillHints,
      contentPadding: contentPadding,
      inputFormatters: inputFormatters,
      isDense: isDense,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      textInputAction: textInputAction,
      validator:
          validator ??
          (value) => validateInventoryWholeNumber(value, allowZero: allowZero),
    );
  }
}

class InventoryFormError extends StatelessWidget {
  const InventoryFormError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.42),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: colorScheme.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
