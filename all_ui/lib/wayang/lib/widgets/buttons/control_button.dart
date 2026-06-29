// Custom button widget for controls
import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const ControlButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[700]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: Colors.grey[300],
          iconSize: 20,
        ),
      ),
    );
  }
}
