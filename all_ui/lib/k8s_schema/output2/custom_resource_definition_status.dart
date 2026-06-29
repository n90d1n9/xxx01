import 'custom_resource_definition_names.dart';
import 'custom_resource_definition_condition.dart';

class CustomResourceDefinitionStatus {
  final List<CustomResourceDefinitionCondition>? conditions;
  final CustomResourceDefinitionNames? acceptedNames;
  final List<String>? storedVersions;
  CustomResourceDefinitionStatus({
    this.conditions,
    this.acceptedNames,
    this.storedVersions,
  });
  factory CustomResourceDefinitionStatus.fromJson(Map<String, dynamic> json) {
    return CustomResourceDefinitionStatus(
      conditions:
          json['conditions'] != null
              ? (json['conditions'] as List)
                  .map((e) => CustomResourceDefinitionCondition.fromJson(e))
                  .toList()
              : null,
      acceptedNames:
          json['acceptedNames'] != null
              ? CustomResourceDefinitionNames.fromJson(json['acceptedNames'])
              : null,
      storedVersions:
          json['storedVersions'] != null
              ? List<String>.from(json['storedVersions'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (conditions != null)
        'conditions': conditions!.map((e) => e.toJson()).toList(),
      if (acceptedNames != null) 'acceptedNames': acceptedNames!.toJson(),
      if (storedVersions != null) 'storedVersions': storedVersions,
    };
  }
}
