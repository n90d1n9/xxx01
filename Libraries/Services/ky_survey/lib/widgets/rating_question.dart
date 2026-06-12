// lib/widgets/question_widgets/rating_question.dart
import 'package:flutter/material.dart';

import '../logic/survey_rating_scale.dart';
import '../models/question.dart';

/// Renders a bounded survey rating response control with accessible markers.
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
    final scale = SurveyRatingScale.resolve(
      minRating: question.minRating,
      maxRating: question.maxRating,
      answer: question.answer,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          value: scale.value.toDouble(),
          min: scale.minRating.toDouble(),
          max: scale.maxRating.toDouble(),
          divisions: scale.divisions,
          label: scale.valueLabel,
          semanticFormatterCallback: (value) => value.round().toString(),
          onChanged: (value) {
            onChanged(value.round());
          },
        ),
        Row(
          children: [
            for (final entry in scale.markerValues.indexed)
              Expanded(
                child: Align(
                  alignment: _markerAlignment(
                    entry.$1,
                    scale.markerValues.length,
                  ),
                  child: Text(
                    entry.$2.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: textTheme.labelMedium?.copyWith(
                      color: entry.$2 == scale.value
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: entry.$2 == scale.value
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Alignment _markerAlignment(int index, int markerCount) {
    if (index == 0) {
      return Alignment.centerLeft;
    }

    if (index == markerCount - 1) {
      return Alignment.centerRight;
    }

    return Alignment.center;
  }
}
