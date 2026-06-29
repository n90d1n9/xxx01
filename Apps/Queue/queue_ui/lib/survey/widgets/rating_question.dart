// lib/widgets/question_widgets/rating_question.dart
import 'package:flutter/material.dart';

import '../models/question.dart';

class RatingQuestion extends StatelessWidget {
  final Question question;
  final Function(int) onChanged;

  const RatingQuestion({
    super.key,
    required this.question,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final minRating = question.minRating ?? 1;
    final maxRating = question.maxRating ?? 5;
    final ratingValue = (question.answer as int?) ?? minRating;
    final ratingCount = maxRating - minRating + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          value: ratingValue.toDouble(),
          min: minRating.toDouble(),
          max: maxRating.toDouble(),
          divisions: maxRating - minRating,
          label: ratingValue.toString(),
          onChanged: (value) {
            onChanged(value.round());
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(ratingCount, (index) {
            final rating = minRating + index;
            return Text(
              rating.toString(),
              style: TextStyle(
                color: rating == ratingValue ? Colors.deepPurple : Colors.grey,
                fontWeight:
                    rating == ratingValue ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }),
        ),
      ],
    );
  }
}
