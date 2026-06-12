import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

import '../models/project_custom_attribute.dart';
import '../models/project_custom_attribute_value.dart';
import 'project_custom_attribute_type_ui.dart';

class ProjectCustomAttributeValueField extends StatefulWidget {
  const ProjectCustomAttributeValueField({
    required this.attribute,
    required this.onChanged,
    this.label = 'Value',
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  final ProjectCustomAttribute attribute;
  final ValueChanged<String> onChanged;
  final String label;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<ProjectCustomAttributeValueField> createState() =>
      _ProjectCustomAttributeValueFieldState();
}

class _ProjectCustomAttributeValueFieldState
    extends State<ProjectCustomAttributeValueField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.attribute.value);
  }

  @override
  void didUpdateWidget(ProjectCustomAttributeValueField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.attribute.value) {
      _controller.text = widget.attribute.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.attribute.type) {
      case ProjectCustomAttributeType.boolean:
        return _selectField(
          context: context,
          icon: widget.attribute.type.icon,
          options: const [
            AppSelectOption(value: '', label: 'Not set'),
            AppSelectOption(value: 'Yes', label: 'Yes'),
            AppSelectOption(value: 'No', label: 'No'),
          ],
          value: projectCustomAttributeBooleanEditValue(widget.attribute.value),
        );
      case ProjectCustomAttributeType.choice:
        if (widget.attribute.options.isEmpty) {
          return _textField(
            context: context,
            icon: widget.attribute.type.icon,
            keyboardType: widget.attribute.type.keyboardType,
            hintText: widget.attribute.type.valueHint,
          );
        }

        return _selectField(
          context: context,
          icon: widget.attribute.type.icon,
          options: _choiceOptions(widget.attribute),
          value: _choiceValue(widget.attribute),
        );
      case ProjectCustomAttributeType.number:
      case ProjectCustomAttributeType.date:
      case ProjectCustomAttributeType.url:
      case ProjectCustomAttributeType.text:
        return _textField(
          context: context,
          icon: widget.attribute.type.icon,
          keyboardType: widget.attribute.type.keyboardType,
          hintText: widget.attribute.type.valueHint,
        );
    }
  }

  Widget _selectField({
    required BuildContext context,
    required IconData icon,
    required List<AppSelectOption<String>> options,
    required String value,
  }) {
    return AppSelectField<String>(
      label: widget.label,
      value: value,
      icon: icon,
      options: options,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
    );
  }

  Widget _textField({
    required BuildContext context,
    required IconData icon,
    required TextInputType keyboardType,
    String? hintText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: hintText,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: colorScheme.surface,
        border: border,
        enabledBorder: border,
      ),
      onChanged: widget.onChanged,
    );
  }

  List<AppSelectOption<String>> _choiceOptions(
    ProjectCustomAttribute attribute,
  ) {
    final currentValue = attribute.value.trim();
    final options = [
      const AppSelectOption(value: '', label: 'Not set'),
      for (final option in attribute.options)
        AppSelectOption(value: option, label: option),
    ];
    final knownValues = options.map((option) => option.value).toSet();

    if (currentValue.isEmpty || knownValues.contains(currentValue)) {
      return options;
    }

    return [
      ...options,
      AppSelectOption(value: currentValue, label: '$currentValue (custom)'),
    ];
  }

  String _choiceValue(ProjectCustomAttribute attribute) {
    final value = attribute.value.trim();
    if (value.isEmpty) return '';
    return value;
  }
}
