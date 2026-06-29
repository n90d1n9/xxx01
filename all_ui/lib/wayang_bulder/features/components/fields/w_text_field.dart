import 'package:flutter/material.dart';

class WTextField extends StatelessWidget {
  final String label;
  final String value;
  final void Function(String)? onChanged;
  final bool obscureText;
  final String? placeholder;
  final bool required;
  final bool readOnly;
  const WTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,

    this.obscureText = false,
    this.placeholder,
    this.required = false,
    this.readOnly = false,
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
            controller: TextEditingController(text: value)
              ..selection = TextSelection.collapsed(offset: value.length),
            style: const TextStyle(fontSize: 13),
            obscureText: obscureText,
            readOnly: readOnly,
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,

              hintText: placeholder,
              hintStyle: const TextStyle(color: Colors.white38),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
