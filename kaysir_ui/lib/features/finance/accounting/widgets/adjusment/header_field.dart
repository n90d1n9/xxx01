import 'package:flutter/material.dart';

class HeaderField extends StatelessWidget {
  final String label;
  final Widget child;

  const HeaderField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
          ),
        ),
        child,
      ],
    );
  }
}
