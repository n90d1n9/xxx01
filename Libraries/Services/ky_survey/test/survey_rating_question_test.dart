import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_rating_scale.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/widgets/rating_question.dart';

void main() {
  group('SurveyRatingScale', () {
    test('normalizes numeric, decimal, and string answers', () {
      expect(SurveyRatingScale.parseAnswer(3), 3);
      expect(SurveyRatingScale.parseAnswer(3.6), 4);
      expect(SurveyRatingScale.parseAnswer('4.2'), 4);
      expect(SurveyRatingScale.parseAnswer('invalid'), isNull);
    });

    test('clamps values and recovers invalid scale bounds', () {
      final clamped = SurveyRatingScale.resolve(
        minRating: 1,
        maxRating: 5,
        answer: '9',
      );

      expect(clamped.minRating, 1);
      expect(clamped.maxRating, 5);
      expect(clamped.value, 5);
      expect(clamped.markerValues, [1, 2, 3, 4, 5]);

      final recovered = SurveyRatingScale.resolve(
        minRating: 5,
        maxRating: 5,
        answer: null,
      );

      expect(recovered.minRating, 5);
      expect(recovered.maxRating, 6);
      expect(recovered.value, 5);
      expect(recovered.divisions, 1);
    });
  });

  group('RatingQuestion', () {
    testWidgets(
      'renders normalized rating values and forwards slider changes',
      (tester) async {
        int? selectedRating;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RatingQuestion(
                question: Question(
                  id: 'satisfaction',
                  text: 'Satisfaction',
                  type: QuestionType.rating,
                  required: true,
                  minRating: 1,
                  maxRating: 5,
                  answer: '4.7',
                ),
                onChanged: (value) => selectedRating = value,
              ),
            ),
          ),
        );

        final slider = tester.widget<Slider>(find.byType(Slider));

        expect(slider.value, 5);
        expect(slider.min, 1);
        expect(slider.max, 5);
        expect(slider.divisions, 4);
        expect(find.text('5'), findsOneWidget);

        slider.onChanged?.call(2.6);

        expect(selectedRating, 3);
      },
    );
  });
}
