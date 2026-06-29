import 'package:flutter/material.dart';

class NumberField extends StatelessWidget {
  final String label;
  final num value;
  final void Function(num) onChanged;
  final double? min;
  final double? max;
  final bool required;

  const NumberField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.max,
    this.min,
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
            controller: TextEditingController(text: value.toString()),
            style: const TextStyle(fontSize: 13),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) {
              final parsed = num.tryParse(val);
              if (parsed != null) {
                var finalValue = parsed;
                if (min != null && finalValue < min!) finalValue = min!;
                if (max != null && finalValue > max!) finalValue = max!;
                onChanged(finalValue);
              }
            },
            decoration: InputDecoration(
              filled: true,

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
