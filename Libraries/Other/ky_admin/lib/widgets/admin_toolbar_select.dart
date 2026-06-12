import 'package:flutter/material.dart';

import '../../../widgets/ui/app_select_field.dart';

class AdminToolbarSelectOption<T> extends AppSelectOption<T> {
  const AdminToolbarSelectOption({required super.value, required super.label});
}

class AdminToolbarSelect<T> extends StatelessWidget {
  const AdminToolbarSelect({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon,
    this.width = 220,
  });

  final String label;
  final T value;
  final List<AdminToolbarSelectOption<T>> options;
  final ValueChanged<T> onChanged;
  final IconData? icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<T>(
      label: label,
      value: value,
      options: options,
      onChanged: onChanged,
      icon: icon,
      width: width,
    );
  }
}
