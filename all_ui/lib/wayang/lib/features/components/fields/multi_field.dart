import 'package:flutter/material.dart';

class MultilineField extends StatelessWidget {
  final String label;
  final String value;
  final String? placeholder;
  final void Function(String) onChanged;
  final bool required;

  const MultilineField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.placeholder,
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
          TextField(
            controller: TextEditingController(text: value),
            style: const TextStyle(fontSize: 13),
            maxLines: 5,
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,

              hintText: placeholder,
              hintStyle: const TextStyle(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
