// Create a new survey
  final survey = Survey(
    id: 'survey-123',
    title: 'Customer Satisfaction Survey',
    description: 'Help us improve our services',
    createdAt: DateTime.now(),
    createdBy: 'user-123',
    sections: [
      SurveySection(
        id: 'section-1',
        title: 'General Information',
        orderIndex: 0,
        questions: [
          Question(
            id: 'q1',
            text: 'How satisfied are you with our service?',
            type: QuestionType.rating,
            orderIndex: 0,
            options: QuestionOptions(
              ratingOptions: RatingOptions(
                maxRating: 5,
                labels: ['Very Unsatisfied', 'Very Satisfied'],
              ),
            ),
          ),
          // Add more questions...
        ],
      ),
      // Add more sections...
    ],
    settings: SurveySettings(
      allowAnonymous: true,
      requireAuthentication: false,
      responseLimit: null,
    ),
    metadata: SurveyMetadata(
      category: 'Customer Feedback',
      tags: ['satisfaction', 'service'],
    ),
  );

  try {
    final createdSurvey = await surveyService.createSurvey(survey);
    print('Survey created successfully: ${createdSurvey.id}');
  } catch (e) {
    print('Error creating survey: $e');
  }
}
