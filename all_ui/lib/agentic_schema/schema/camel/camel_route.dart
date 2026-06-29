import 'camel_error_handler.dart';
import 'camel_from.dart';
import 'camel_step.dart';

class CamelRoute {
  final String id;
  final String name;
  final String? description;
  final CamelFrom from;
  final List<CamelStep>? steps;
  final CamelErrorHandler? errorHandler;

  CamelRoute({
    required this.id,
    required this.name,
    this.description,
    required this.from,
    this.steps,
    this.errorHandler,
  });

  factory CamelRoute.fromJson(Map<String, dynamic> json) {
    return CamelRoute(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      from: CamelFrom.fromJson(json['from'] as Map<String, dynamic>),
      steps: json['steps'] != null
          ? (json['steps'] as List)
                .map((e) => CamelStep.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      errorHandler: json['errorHandler'] != null
          ? CamelErrorHandler.fromJson(
              json['errorHandler'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'from': from.toJson(),
      if (steps != null) 'steps': steps!.map((e) => e.toJson()).toList(),
      if (errorHandler != null) 'errorHandler': errorHandler!.toJson(),
    };
  }
}
