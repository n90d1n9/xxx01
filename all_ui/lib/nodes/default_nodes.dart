import 'package:flutter/material.dart';

class DefaultNodeShape extends StatelessWidget {
  final double width;
  final double height;
  final Color borderColor;
  final Color backgroundColor;
  const DefaultNodeShape({
    super.key,
    this.width = 266.0,
    this.height = 116.0,
    this.borderColor = const Color(0xFF979797),
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class CircleNodeShape extends StatelessWidget {
  final double width;
  final double height;
  final Color borderColor;
  final Color backgroundColor;
  const CircleNodeShape({
    super.key,
    this.width = 50.0,
    this.height = 50.0,
    this.borderColor = const Color(0xFF979797),
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
