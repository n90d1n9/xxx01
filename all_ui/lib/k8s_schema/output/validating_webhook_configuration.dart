import 'validating_webhook.dart';
import 'object_meta.dart';

class ValidatingWebhookConfiguration {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final List<ValidatingWebhook>? webhooks;
  ValidatingWebhookConfiguration({
    this.apiVersion = 'admissionregistration.k8s.io/v1',
    this.kind = 'ValidatingWebhookConfiguration',
    required this.metadata,
    this.webhooks,
  });
  factory ValidatingWebhookConfiguration.fromJson(Map<String, dynamic> json) {
    return ValidatingWebhookConfiguration(
      apiVersion: json['apiVersion'] ?? 'admissionregistration.k8s.io/v1',
      kind: json['kind'] ?? 'ValidatingWebhookConfiguration',
      metadata: ObjectMeta.fromJson(json['metadata']),
      webhooks:
          json['webhooks'] != null
              ? (json['webhooks'] as List)
                  .map((e) => ValidatingWebhook.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      if (webhooks != null)
        'webhooks': webhooks!.map((e) => e.toJson()).toList(),
    };
  }
}
