import '../config/endpoint_pattern_config.dart';
import '../config/message_patter_config.dart';
import '../route/routing_pattern_config.dart';
import '../transformation/transformation_pattern_config.dart';

class IntegrationPattern {
  final RoutingPatternConfig? routing;
  final TransformationPatternConfig? transformation;
  final EndpointPatternConfig? endpoint;
  final MessagePatternConfig? message;

  IntegrationPattern({
    this.routing,
    this.transformation,
    this.endpoint,
    this.message,
  });

  factory IntegrationPattern.fromJson(Map<String, dynamic> json) {
    return IntegrationPattern(
      routing: json['routing'] != null
          ? RoutingPatternConfig.fromJson(
              json['routing'] as Map<String, dynamic>,
            )
          : null,
      transformation: json['transformation'] != null
          ? TransformationPatternConfig.fromJson(
              json['transformation'] as Map<String, dynamic>,
            )
          : null,
      endpoint: json['endpoint'] != null
          ? EndpointPatternConfig.fromJson(
              json['endpoint'] as Map<String, dynamic>,
            )
          : null,
      message: json['message'] != null
          ? MessagePatternConfig.fromJson(
              json['message'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (routing != null) 'routing': routing!.toJson(),
      if (transformation != null) 'transformation': transformation!.toJson(),
      if (endpoint != null) 'endpoint': endpoint!.toJson(),
      if (message != null) 'message': message!.toJson(),
    };
  }
}
