import 'package:flutter/material.dart';

class ReportGenerationPicker<T> extends StatelessWidget {
  final Key fieldKey;
  final String label;
  final IconData icon;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T?> onChanged;

  const ReportGenerationPicker({
    super.key,
    required this.fieldKey,
    required this.label,
    required this.icon,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      key: fieldKey,
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items:
          values
              .map(
                (option) => DropdownMenuItem<T>(
                  value: option,
                  child: Text(labelFor(option)),
                ),
              )
              .toList(),
      onChanged: onChanged,
    );
  }
}
