import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/management_pack.dart';
import '../models/management_pack_field_validation.dart';
import 'management_pack_field_input_helper.dart';
import 'management_pack_field_input_metadata.dart';

/// Reusable input control for a single product management pack field.
class ProductManagementPackFieldInput extends StatelessWidget {
  const ProductManagementPackFieldInput({
    super.key,
    required this.field,
    this.controller,
    this.value = false,
    this.autofocus = false,
    this.focusNode,
    this.onToggleChanged,
  });

  final ProductManagementPackField field;
  final TextEditingController? controller;
  final bool value;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onToggleChanged;

  @override
  Widget build(BuildContext context) {
    final metadata = ProductManagementPackFieldInputMetadata.fromField(field);

    return switch (field.type) {
      ProductManagementFieldType.toggle => _PackToggleField(
        field: field,
        metadata: metadata,
        value: value,
        autofocus: autofocus,
        focusNode: focusNode,
        onChanged: onToggleChanged,
      ),
      ProductManagementFieldType.select => _PackSelectField(
        field: field,
        metadata: metadata,
        controller: _requiredController,
        autofocus: autofocus,
        focusNode: focusNode,
      ),
      ProductManagementFieldType.text ||
      ProductManagementFieldType.number ||
      ProductManagementFieldType.date => _PackTextField(
        field: field,
        metadata: metadata,
        controller: _requiredController,
        autofocus: autofocus,
        focusNode: focusNode,
      ),
    };
  }

  TextEditingController get _requiredController {
    final resolvedController = controller;
    assert(
      resolvedController != null,
      'Non-toggle management pack fields require a controller.',
    );

    return resolvedController!;
  }
}

@Preview(name: 'Management pack field input')
Widget productManagementPackFieldInputPreview() {
  final expiryController = TextEditingController(text: '2026-07-01');
  final statusController = TextEditingController(text: 'Monitor');

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ProductManagementPackFieldInput(
              field: groceryFreshGoodsFields.first,
              controller: expiryController,
            ),
            const SizedBox(height: 16),
            ProductManagementPackFieldInput(
              field: groceryFreshGoodsFields.last,
              controller: statusController,
            ),
            const SizedBox(height: 16),
            ProductManagementPackFieldInput(
              field: groceryFreshGoodsFields[2],
              value: true,
              onToggleChanged: (_) {},
            ),
          ],
        ),
      ),
    ),
  );
}

/// Text, number, or date field contributed by a management pack.
class _PackTextField extends StatelessWidget {
  const _PackTextField({
    required this.field,
    required this.metadata,
    required this.controller,
    required this.autofocus,
    this.focusNode,
  });

  final ProductManagementPackField field;
  final ProductManagementPackFieldInputMetadata metadata;
  final TextEditingController controller;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: metadata.inputKey,
      controller: controller,
      autofocus: autofocus,
      focusNode: focusNode,
      keyboardType: metadata.keyboardType,
      textInputAction: metadata.textInputAction,
      decoration: InputDecoration(
        labelText: field.label,
        helper: ProductManagementPackFieldInputHelper(metadata: metadata),
        hintText: metadata.hintText,
        prefixIcon: Icon(metadata.icon),
        suffixText: metadata.suffixText,
        suffixIcon: _textFieldAffordance,
        border: const OutlineInputBorder(),
      ),
      validator:
          (value) => validateProductManagementPackFieldInput(field, value),
    );
  }

  Widget? get _textFieldAffordance {
    if (!metadata.supportsDatePicker && !metadata.supportsNumberStepper) {
      return null;
    }

    return _TextFieldAffordance(
      field: field,
      metadata: metadata,
      controller: controller,
    );
  }
}

/// Optional trailing action for date and number product management fields.
class _TextFieldAffordance extends StatelessWidget {
  const _TextFieldAffordance({
    required this.field,
    required this.metadata,
    required this.controller,
  });

  final ProductManagementPackField field;
  final ProductManagementPackFieldInputMetadata metadata;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    if (metadata.supportsDatePicker) {
      return IconButton(
        tooltip: 'Pick ${field.label}',
        icon: const Icon(Icons.calendar_month_rounded),
        onPressed: () => _pickProductManagementFieldDate(context, controller),
      );
    }

    if (metadata.supportsNumberStepper) {
      return SizedBox(
        width: 88,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              tooltip: 'Decrease ${field.label}',
              constraints: const BoxConstraints.tightFor(width: 40, height: 48),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove_rounded),
              onPressed: () => _adjustNumber(-1),
            ),
            IconButton(
              tooltip: 'Increase ${field.label}',
              constraints: const BoxConstraints.tightFor(width: 40, height: 48),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _adjustNumber(1),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _adjustNumber(int delta) {
    final currentValue = double.tryParse(controller.text.trim()) ?? 0;
    final nextValue = currentValue + delta;
    controller.text = _formatNumber(nextValue);
  }
}

Future<void> _pickProductManagementFieldDate(
  BuildContext context,
  TextEditingController controller,
) async {
  final now = DateTime.now();
  final initialDate = DateTime.tryParse(controller.text.trim()) ?? now;
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  if (pickedDate == null) return;

  controller.text = _formatDate(pickedDate);
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}

String _formatNumber(double value) {
  if (value % 1 == 0) return value.toInt().toString();

  return value.toString();
}

/// Select field contributed by a management pack.
class _PackSelectField extends StatelessWidget {
  const _PackSelectField({
    required this.field,
    required this.metadata,
    required this.controller,
    required this.autofocus,
    this.focusNode,
  });

  final ProductManagementPackField field;
  final ProductManagementPackFieldInputMetadata metadata;
  final TextEditingController controller;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final value =
        field.options.contains(controller.text) ? controller.text : null;

    return DropdownButtonFormField<String>(
      key: metadata.inputKey,
      initialValue: value,
      autofocus: autofocus,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: field.label,
        helper: ProductManagementPackFieldInputHelper(metadata: metadata),
        prefixIcon: Icon(metadata.icon),
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final option in field.options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: (value) => controller.text = value ?? '',
      validator:
          (_) =>
              validateProductManagementPackFieldInput(field, controller.text),
    );
  }
}

/// Toggle field contributed by a management pack.
class _PackToggleField extends StatelessWidget {
  const _PackToggleField({
    required this.field,
    required this.metadata,
    required this.value,
    required this.autofocus,
    this.focusNode,
    this.onChanged,
  });

  final ProductManagementPackField field;
  final ProductManagementPackFieldInputMetadata metadata;
  final bool value;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: SwitchListTile.adaptive(
          key: metadata.inputKey,
          value: value,
          autofocus: autofocus,
          focusNode: focusNode,
          onChanged: onChanged,
          title: Text(
            field.label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          subtitle: ProductManagementPackFieldInputHelper(
            metadata: metadata,
            maxDescriptionLines: 1,
          ),
          secondary: Icon(metadata.icon, color: colorScheme.primary),
        ),
      ),
    );
  }
}
