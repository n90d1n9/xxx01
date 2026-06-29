class SurveySettings {
  final bool allowAnonymousResponses;
  final bool requireAuthentication;
  final bool allowMultipleResponses;
  final bool showProgressBar;
  final bool showQuestionNumbers;
  final bool shuffleQuestions;
  final bool shuffleOptions;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? responseLimit;
  final String? thankYouMessage;
  final String? customCss;
  final String? customLogo;

  SurveySettings({
    required this.allowAnonymousResponses,
    required this.requireAuthentication,
    required this.allowMultipleResponses,
    required this.showProgressBar,
    required this.showQuestionNumbers,
    required this.shuffleQuestions,
    required this.shuffleOptions,
    this.startDate,
    this.endDate,
    this.responseLimit,
    this.thankYouMessage,
    this.customCss,
    this.customLogo,
  });

  Map<String, dynamic> toJson() => {
        'allowAnonymousResponses': allowAnonymousResponses,
        'requireAuthentication': requireAuthentication,
        'allowMultipleResponses': allowMultipleResponses,
        'showProgressBar': showProgressBar,
        'showQuestionNumbers': showQuestionNumbers,
        'shuffleQuestions': shuffleQuestions,
        'shuffleOptions': shuffleOptions,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'responseLimit': responseLimit,
        'thankYouMessage': thankYouMessage,
        'customCss': customCss,
        'customLogo': customLogo,
      };

  factory SurveySettings.fromJson(Map<String, dynamic> json) => SurveySettings(
        allowAnonymousResponses: json['allowAnonymousResponses'],
        requireAuthentication: json['requireAuthentication'],
        allowMultipleResponses: json['allowMultipleResponses'],
        showProgressBar: json['showProgressBar'],
        showQuestionNumbers: json['showQuestionNumbers'],
        shuffleQuestions: json['shuffleQuestions'],
        shuffleOptions: json['shuffleOptions'],
        startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        responseLimit: json['responseLimit'],
        thankYouMessage: json['thankYouMessage'],
        customCss: json['customCss'],
        customLogo: json['customLogo'],
      );
}
