import 'deployment_endpoint.dart';
import '../config/scaling_config.dart';

class Deployment {
  final String? environment;
  final ScalingConfig? scalingConfig;
  final List<DeploymentEndpoint>? endpoints;

  Deployment({
    this.environment = 'development',
    this.scalingConfig,
    this.endpoints,
  });

  factory Deployment.fromJson(Map<String, dynamic> json) {
    return Deployment(
      environment: json['environment'] as String?,
      scalingConfig: json['scalingConfig'] != null
          ? ScalingConfig.fromJson(
              json['scalingConfig'] as Map<String, dynamic>,
            )
          : null,
      endpoints: json['endpoints'] != null
          ? (json['endpoints'] as List)
                .map(
                  (e) => DeploymentEndpoint.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (environment != null) 'environment': environment,
      if (scalingConfig != null) 'scalingConfig': scalingConfig!.toJson(),
      if (endpoints != null)
        'endpoints': endpoints!.map((e) => e.toJson()).toList(),
    };
  }
}
