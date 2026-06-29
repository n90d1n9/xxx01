import 'package:flutter/material.dart';

class GIconButton extends StatelessWidget {
  final Function onPressed;
  final String? label;
  final IconData? icon;
  final Size size;
  final double radius;
  const GIconButton(
      {super.key,
      this.label,
      this.icon,
      this.radius = 0,
      required this.onPressed,
      this.size = const Size(150, 50)});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        style: ButtonStyle(
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(radius)))),
            fixedSize: WidgetStateProperty.all(size)),
        onPressed: () => onPressed,
        icon: Icon(icon!),
        label: Text(label!));
  }
}
