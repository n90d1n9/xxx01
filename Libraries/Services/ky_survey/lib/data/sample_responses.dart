import '../models/answer.dart';
import '../models/survey_response.dart';

final List<SurveyResponse> sampleResponses = [
  _submittedResponse(
    id: 'cs-r1',
    surveyId: '1',
    respondentId: 'customer-1',
    respondentName: 'Alya',
    collectorId: 'surveyor-ari',
    collectorName: 'Ari',
    daysAgo: 7,
    answers: {
      '1': 5,
      '2': '3',
      '3': ['1', '2'],
      '4': 'Checkout was fast and staff were helpful.',
    },
  ),
  _submittedResponse(
    id: 'cs-r2',
    surveyId: '1',
    respondentId: 'customer-2',
    respondentName: 'Bima',
    collectorId: 'surveyor-nadia',
    collectorName: 'Nadia',
    daysAgo: 6,
    answers: {
      '1': 4,
      '2': '4',
      '3': ['2', '4'],
    },
  ),
  _submittedResponse(
    id: 'cs-r3',
    surveyId: '1',
    respondentId: 'customer-3',
    respondentName: 'Citra',
    collectorId: 'surveyor-raka',
    collectorName: 'Raka',
    daysAgo: 5,
    answers: {
      '1': 3,
      '2': '2',
      '3': ['1'],
      '4': 'Need clearer shelf labels.',
    },
  ),
  _submittedResponse(
    id: 'cs-r4',
    surveyId: '1',
    respondentId: 'customer-4',
    respondentName: 'Dewi',
    collectorId: 'surveyor-ari',
    collectorName: 'Ari',
    daysAgo: 4,
    answers: {
      '1': 5,
      '2': '3',
      '3': ['1', '3'],
    },
  ),
  _submittedResponse(
    id: 'cs-r5',
    surveyId: '1',
    respondentId: 'customer-5',
    respondentName: 'Eko',
    collectorId: 'surveyor-nadia',
    collectorName: 'Nadia',
    daysAgo: 3,
    answers: {'1': 4, '2': '5', '4': 'Would like more payment options.'},
  ),
  _draftResponse(
    id: 'cs-draft-1',
    surveyId: '1',
    respondentId: 'customer-draft-1',
    respondentName: 'Draft Customer',
    collectorId: 'surveyor-raka',
    collectorName: 'Raka',
    answers: {'1': 4},
  ),
  _submittedResponse(
    id: 'pf-r1',
    surveyId: '2',
    respondentId: 'reviewer-1',
    respondentName: 'Fajar',
    collectorId: 'surveyor-dimas',
    collectorName: 'Dimas',
    daysAgo: 5,
    answers: {
      '1': 'Kaysir POS Terminal',
      '2': _isoDaysAgo(40),
      '3': 9,
      '4': 'Add a brighter screen mode for outdoor kiosks.',
    },
  ),
  _submittedResponse(
    id: 'pf-r2',
    surveyId: '2',
    respondentId: 'reviewer-2',
    respondentName: 'Gita',
    collectorId: 'surveyor-maya',
    collectorName: 'Maya',
    daysAgo: 4,
    answers: {'1': 'Inventory Scanner', '2': _isoDaysAgo(24), '3': 8},
  ),
  _submittedResponse(
    id: 'pf-r3',
    surveyId: '2',
    respondentId: 'reviewer-3',
    respondentName: 'Hana',
    collectorId: 'surveyor-dimas',
    collectorName: 'Dimas',
    daysAgo: 3,
    answers: {
      '1': 'Self Checkout Tablet',
      '2': _isoDaysAgo(16),
      '3': 7,
      '4': 'Battery life could be longer.',
    },
  ),
  _submittedResponse(
    id: 'pf-r4',
    surveyId: '2',
    respondentId: 'reviewer-4',
    respondentName: 'Iqbal',
    collectorId: 'surveyor-maya',
    collectorName: 'Maya',
    daysAgo: 2,
    answers: {'1': 'Kitchen Display', '2': _isoDaysAgo(18), '3': 8},
  ),
  _draftResponse(
    id: 'pf-draft-1',
    surveyId: '2',
    respondentId: 'reviewer-draft-1',
    respondentName: 'Draft Reviewer',
    collectorId: 'surveyor-dimas',
    collectorName: 'Dimas',
    answers: {'1': 'Receipt Printer'},
  ),
];

int submittedSampleResponseCount(String surveyId) {
  return sampleResponses
      .where(
        (response) =>
            response.surveyId == surveyId &&
            response.status == SurveyResponseStatus.submitted,
      )
      .length;
}

SurveyResponse _submittedResponse({
  required String id,
  required String surveyId,
  required String respondentId,
  required String respondentName,
  required String collectorId,
  required String collectorName,
  required int daysAgo,
  required Map<String, dynamic> answers,
}) {
  return SurveyResponse(
    id: id,
    surveyId: surveyId,
    respondentId: respondentId,
    respondentName: respondentName,
    collectorId: collectorId,
    collectorName: collectorName,
    status: SurveyResponseStatus.submitted,
    startedAt: _daysAgo(daysAgo, minutes: 22),
    submittedAt: _daysAgo(daysAgo),
    answers: _answers(answers, daysAgo),
  );
}

SurveyResponse _draftResponse({
  required String id,
  required String surveyId,
  required String respondentId,
  required String respondentName,
  required String collectorId,
  required String collectorName,
  required Map<String, dynamic> answers,
}) {
  return SurveyResponse(
    id: id,
    surveyId: surveyId,
    respondentId: respondentId,
    respondentName: respondentName,
    collectorId: collectorId,
    collectorName: collectorName,
    startedAt: DateTime.now().subtract(const Duration(hours: 3)),
    answers: answers.entries.map((entry) {
      return ResponseAnswer(
        questionId: entry.key,
        value: entry.value,
        answeredAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
    }).toList(),
  );
}

List<ResponseAnswer> _answers(Map<String, dynamic> values, int daysAgo) {
  var index = 0;
  return values.entries.map((entry) {
    index += 1;
    return ResponseAnswer(
      questionId: entry.key,
      value: entry.value,
      answeredAt: _daysAgo(daysAgo, minutes: 22 - (index * 3)),
    );
  }).toList();
}

DateTime _daysAgo(int days, {int minutes = 0}) {
  return DateTime.now().subtract(Duration(days: days, minutes: minutes));
}

String _isoDaysAgo(int days) => _daysAgo(days).toIso8601String();
