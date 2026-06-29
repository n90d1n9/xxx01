import '../response/response.dart';

class SurveyAnalyzer {
  Future<SurveyAnalytics> analyze(List<SurveyResponse> responses) async {
    final analytics = SurveyAnalytics();
    
    // Calculate response rates
    analytics.responseRate = _calculateResponseRate(responses);
    
    // Analyze completion times
    analytics.completionTimeStats = _analyzeCompletionTimes(responses);
    
    // Analyze questions
    analytics.questionAnalytics = await _analyzeQuestions(responses);
    
    // Generate insights
    analytics.insights = await _generateInsights(responses);
    
    return analytics;
  }

  Future<Map<String, QuestionAnalytics>> _analyzeQuestions(
    List<SurveyResponse> responses
  ) async {
    final questionAnalytics = <String, QuestionAnalytics>{};
    
    for (var response in responses) {
      for (var answer in response.answers.entries) {
        final analytics = questionAnalytics[answer.key] ??= QuestionAnalytics();
        await _updateQuestionAnalytics(analytics, answer.value);
      }
    }
    
    return questionAnalytics;
  }
}
