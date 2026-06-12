import '../api_config.dart';
import '../email_config.dart';
import '../event/action.dart';

class FormSubmission {
  final String type; // api, email, webhook, custom
  final ApiConfig? apiConfig;
  final EmailConfig? emailConfig;
  final List<Action>? onSuccess;
  final List<Action>? onError;
  final bool resetOnSuccess;

  FormSubmission({
    required this.type,
    this.apiConfig,
    this.emailConfig,
    this.onSuccess,
    this.onError,
    this.resetOnSuccess = false,
  });

  factory FormSubmission.fromJson(Map<String, dynamic> json) {
    return FormSubmission(
      type: json['type'] as String,
      apiConfig:
          json['apiConfig'] != null
              ? ApiConfig.fromJson(json['apiConfig'] as Map<String, dynamic>)
              : null,
      emailConfig:
          json['emailConfig'] != null
              ? EmailConfig.fromJson(
                json['emailConfig'] as Map<String, dynamic>,
              )
              : null,
      onSuccess:
          json['onSuccess'] != null
              ? (json['onSuccess'] as List)
                  .map((a) => Action.fromJson(a as Map<String, dynamic>))
                  .toList()
              : null,
      onError:
          json['onError'] != null
              ? (json['onError'] as List)
                  .map((a) => Action.fromJson(a as Map<String, dynamic>))
                  .toList()
              : null,
      resetOnSuccess: json['resetOnSuccess'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    if (apiConfig != null) 'apiConfig': apiConfig!.toJson(),
    if (emailConfig != null) 'emailConfig': emailConfig!.toJson(),
    if (onSuccess != null)
      'onSuccess': onSuccess!.map((a) => a.toJson()).toList(),
    if (onError != null) 'onError': onError!.map((a) => a.toJson()).toList(),
    'resetOnSuccess': resetOnSuccess,
  };
}
