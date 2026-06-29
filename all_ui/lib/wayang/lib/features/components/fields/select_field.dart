import 'package:flutter/material.dart';

class SelectField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final void Function(String) onChanged;
  final bool required;

  const SelectField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.options,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              if (required)
                const Text(
                  ' *',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              // border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value.isEmpty ? null : value,
                isExpanded: true,

                style: const TextStyle(fontSize: 13),
                items: options.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) onChanged(newValue);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
