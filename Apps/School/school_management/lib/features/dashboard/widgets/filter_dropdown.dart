import 'package:flutter/material.dart';

class FilterDropdown extends StatelessWidget {
  final Function(String) onChanged;
  final String initialValue;

  const FilterDropdown(
      {super.key, required this.onChanged, required this.initialValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: initialValue,
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
        items: const [
          DropdownMenuItem(value: 'This Week', child: Text('This Week')),
          DropdownMenuItem(value: 'Last Week', child: Text('Last Week')),
          DropdownMenuItem(value: 'This Month', child: Text('This Month')),
          DropdownMenuItem(value: 'Last Month', child: Text('Last Month')),
        ],
        underline: const SizedBox(),
      ),
    );
  }
}
