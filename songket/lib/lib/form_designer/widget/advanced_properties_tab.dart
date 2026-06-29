// Basic and Advanced tabs (simplified)
import 'package:flutter/material.dart';

import '../model/field_config.dart';
import '../model/form_theme.dart';

class BasicPropertiesTab extends StatelessWidget {
  final FormTheme theme;
  final FieldConfig field;

  const BasicPropertiesTab({Key? key, required this.theme, required this.field})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Label', style: TextStyle(color: theme.colors.text)),
        TextField(
          controller: TextEditingController(text: field.label),
          style: TextStyle(color: theme.colors.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colors.inputBackground,
          ),
        ),
      ],
    );
  }
}

class AdvancedPropertiesTab extends StatelessWidget {
  final FormTheme theme;
  final FieldConfig field;

  const AdvancedPropertiesTab({
    Key? key,
    required this.theme,
    required this.field,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Advanced Settings', style: TextStyle(color: theme.colors.text)),
      ],
    );
  }
}
