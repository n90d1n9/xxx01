class SurveyValidator {
  Future<ValidationResult> validateSurvey(Survey survey) async {
    final errors = <ValidationError>[];
    
    // Validate basic properties
    if (survey.title.isEmpty) {
      errors.add(ValidationError('title', 'Survey title is required'));
    }
    
    // Validate sections
    for (var section in survey.sections) {
      errors.addAll(await _validateSection(section));
    }
    
    // Validate logic
    errors.addAll(await _validateSurveyLogic(survey));
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  Future<ValidationResult> validateResponse(SurveyResponse response) async {
    final errors = <ValidationError>[];
    final survey = await _getSurvey(response.surveyId);
    
    // Validate required questions
    for (var section in survey.sections) {
      for (var question in section.questions) {
        if (question.isRequired && !response.answers.containsKey(question.id)) {
          errors.add(ValidationError(
            question.id,
            'Answer is required for this question',
          ));
        }
      }
    }
    
    // Validate answer values
    for (var entry in response.answers.entries) {
      errors.addAll(await _validateAnswer(entry.key, entry.value, survey));
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}
