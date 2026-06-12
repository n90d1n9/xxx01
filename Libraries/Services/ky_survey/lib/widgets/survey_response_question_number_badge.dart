import 'package:flutter/material.dart';

/// Shows the stable numbered question affordance for response forms.
class SurveyResponseQuestionNumberBadge extends StatelessWidget {
  final int number;
  final Color color;
  final Color foregroundColor;

  const SurveyResponseQuestionNumberBadge({
    super.key,
    required this.number,
    required this.color,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 13,
      backgroundColor: color,
      child: Text(
        number.toString(),
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
