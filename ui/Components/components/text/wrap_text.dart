import 'package:flutter/material.dart';

class WrapLongText extends StatelessWidget {
  final String text;
  final TextStyle style;
  const WrapLongText(this.text,{
    super.key,
    this.style = const TextStyle(
      fontSize: 13.0,
      fontFamily: 'Roboto',
      color: Color(0xFF212121),
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.only(right: 13.0),
        child: Text(text, overflow: TextOverflow.ellipsis, style: style),
      ),
    );
  }
}
