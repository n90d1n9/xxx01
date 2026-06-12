import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Shared text field styling for project workflow forms.
class ProjectWorkflowTextField extends StatelessWidget {
  const ProjectWorkflowTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.fieldKey,
    this.width,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    super.key,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final double? width;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      key: fieldKey,
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: _decoration(context),
      onChanged: onChanged,
    );

    if (width == null) return field;
    return SizedBox(width: width, child: field);
  }

  InputDecoration _decoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18),
      filled: true,
      fillColor: colorScheme.surface,
      border: border,
      enabledBorder: border,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}

@Preview(name: 'Project workflow text field')
Widget projectWorkflowTextFieldPreview() {
  final controller = TextEditingController(text: 'Sponsor recovery response');

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProjectWorkflowTextField(
          controller: controller,
          label: 'Response title',
          icon: Icons.health_and_safety_outlined,
          onChanged: (_) {},
        ),
      ),
    ),
  );
}
