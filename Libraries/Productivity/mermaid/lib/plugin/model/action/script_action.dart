import 'action_definition.dart';

class ScriptAction extends ActionDefinition {
  final String language;
  final String code;
  final Map<String, dynamic>? environment;

  ScriptAction({required this.language, required this.code, this.environment})
    : super('script');

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'language': language,
    'code': code,
    'environment': environment,
  };

  factory ScriptAction.fromJson(Map<String, dynamic> json) => ScriptAction(
    language: json['language'],
    code: json['code'],
    environment: json['environment'],
  );
}
