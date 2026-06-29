import 'package:flutter/material.dart';

class ColorButton extends StatelessWidget {
  final Color color;
  final VoidCallback? onPressed;

  const ColorButton({super.key, required this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Background Color',
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
