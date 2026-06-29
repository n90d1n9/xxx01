import '../../response/response.dart';
import 'survey.dart';

abstract class SurveyRepository {
  Future<Survey> createSurvey(Survey survey);
  Future<Survey> updateSurvey(Survey survey);
  Future<void> deleteSurvey(String id);
  Future<Survey> getSurveyById(String id);
  Future<List<Survey>> getSurveysByUser(String userId);
  Future<SurveyResponse> saveResponse(SurveyResponse response);
  Future<List<SurveyResponse>> getResponsesBySurvey(String surveyId);
}
