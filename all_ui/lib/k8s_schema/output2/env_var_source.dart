import 'config_map_key_selector.dart';
import 'secret_key_selector.dart';
import 'object_field_selector.dart';
import 'resource_field_selector.dart';

class EnvVarSource {
  final ConfigMapKeySelector? configMapKeyRef;
  final SecretKeySelector? secretKeyRef;
  final ObjectFieldSelector? fieldRef;
  final ResourceFieldSelector? resourceFieldRef;
  EnvVarSource({
    this.configMapKeyRef,
    this.secretKeyRef,
    this.fieldRef,
    this.resourceFieldRef,
  });
  factory EnvVarSource.fromJson(Map<String, dynamic> json) {
    return EnvVarSource(
      configMapKeyRef:
          json['configMapKeyRef'] != null
              ? ConfigMapKeySelector.fromJson(json['configMapKeyRef'])
              : null,
      secretKeyRef:
          json['secretKeyRef'] != null
              ? SecretKeySelector.fromJson(json['secretKeyRef'])
              : null,
      fieldRef:
          json['fieldRef'] != null
              ? ObjectFieldSelector.fromJson(json['fieldRef'])
              : null,
      resourceFieldRef:
          json['resourceFieldRef'] != null
              ? ResourceFieldSelector.fromJson(json['resourceFieldRef'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (configMapKeyRef != null) 'configMapKeyRef': configMapKeyRef!.toJson(),
      if (secretKeyRef != null) 'secretKeyRef': secretKeyRef!.toJson(),
      if (fieldRef != null) 'fieldRef': fieldRef!.toJson(),
      if (resourceFieldRef != null)
        'resourceFieldRef': resourceFieldRef!.toJson(),
    };
  }
}
