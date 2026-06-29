import '../response/response.dart';

class SecureSurveyRepository {
  final SurveyRepository _repository;
  final EncryptionService _encryptionService;

  SecureSurveyRepository(this._repository, this._encryptionService);

  Future<void> saveSurveyResponse(SurveyResponse response) async {
    final encryptedAnswers = response.answers.map(
      (key, value) => MapEntry(key, _encryptionService.encrypt(json.encode(value))),
    );

    final encryptedResponse = SurveyResponse(
      id: response.id,
      surveyId: response.surveyId,
      respondentId: response.respondentId,
      answers: encryptedAnswers,
      submittedAt: response.submittedAt,
      fileUploads: response.fileUploads,
    );

    await _repository.saveSurveyResponse(encryptedResponse);
  }

  Future<SurveyResponse> getSurveyResponse(String id) async {
    final encryptedResponse = await _repository.getSurveyResponse(id);
    final decryptedAnswers = encryptedResponse.answers.map(
      (key, value) => MapEntry(
        key,
        json.decode(_encryptionService.decrypt(value)),
      ),
    );

    return SurveyResponse(
      id: encryptedResponse.id,
      surveyId: encryptedResponse.surveyId,
      respondentId: encryptedResponse.respondentId,
      answers: decryptedAnswers,
      submittedAt: encryptedResponse.submittedAt,
      fileUploads: encryptedResponse.fileUploads,
    );
  }
}
