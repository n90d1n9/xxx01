import 'package:flutter/material.dart';

class BasmalahWidget extends StatelessWidget {
  final double fontSize;
  const BasmalahWidget({super.key, required this.fontSize});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Scheherazade',
          fontSize: fontSize + 2,
          fontWeight: FontWeight.bold,
          height: 2.0,
        ),
      ),
    );
  }
}
