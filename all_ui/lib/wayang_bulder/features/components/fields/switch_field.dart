import 'package:flutter/material.dart';

class SwitchField extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;

  const SwitchField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
