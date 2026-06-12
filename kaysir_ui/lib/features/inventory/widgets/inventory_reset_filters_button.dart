import 'package:flutter/material.dart';

class InventoryResetFiltersButton extends StatelessWidget {
  const InventoryResetFiltersButton({
    super.key,
    required this.onPressed,
    this.label = 'Reset filters',
    this.icon = Icons.refresh_rounded,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
