class SurveyService {
  final SurveyRepository _repository;
  final SurveyValidator _validator;

  SurveyService({
    required SurveyRepository repository,
    required SurveyValidator validator,
  }) : _repository = repository,
       _validator = validator;

  Future<Survey> createSurvey(Survey survey) async {
    final validationResult = await _validator.validateSurvey(survey);
    if (!validationResult.isValid) {
      throw SurveyValidationException(validationResult.errors);
    }
    
    return await _repository.createSurvey(survey);
  }

  Future<SurveyResponse> submitResponse(SurveyResponse response) async {
    final validationResult = await _validator.validateResponse(response);
    if (!validationResult.isValid) {
      throw ResponseValidationException(validationResult.errors);
    }
    
    return await _repository.saveResponse(response);
  }

  Future<List<Survey>> getSurveysByUser(String userId) async {
    return await _repository.getSurveysByUser(userId);
  }

  Future<SurveyAnalytics> analyzeSurvey(String surveyId) async {
    final responses = await _repository.getResponsesBySurvey(surveyId);
    final analyzer = SurveyAnalyzer();
    return await analyzer.analyze(responses);
  }
}
