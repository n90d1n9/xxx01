import 'rolling_update_deployment.dart';

class DeploymentStrategy {
  final String? type;
  final RollingUpdateDeployment? rollingUpdate;
  DeploymentStrategy({this.type, this.rollingUpdate});
  factory DeploymentStrategy.fromJson(Map<String, dynamic> json) {
    return DeploymentStrategy(
      type: json['type'],
      rollingUpdate:
          json['rollingUpdate'] != null
              ? RollingUpdateDeployment.fromJson(json['rollingUpdate'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      if (rollingUpdate != null) 'rollingUpdate': rollingUpdate!.toJson(),
    };
  }
}
