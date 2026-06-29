import 'limited_priority_level_configuration.dart';

class PriorityLevelConfigurationSpec {
  final String type;
  final LimitedPriorityLevelConfiguration? limited;
  PriorityLevelConfigurationSpec({required this.type, this.limited});
  factory PriorityLevelConfigurationSpec.fromJson(Map<String, dynamic> json) {
    return PriorityLevelConfigurationSpec(
      type: json['type'],
      limited:
          json['limited'] != null
              ? LimitedPriorityLevelConfiguration.fromJson(json['limited'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {'type': type, if (limited != null) 'limited': limited!.toJson()};
  }
}
