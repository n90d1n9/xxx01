import 'mutating_webhook.dart';
import 'object_meta.dart';

class MutatingWebhookConfiguration {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final List<MutatingWebhook>? webhooks;
  MutatingWebhookConfiguration({
    this.apiVersion = 'admissionregistration.k8s.io/v1',
    this.kind = 'MutatingWebhookConfiguration',
    required this.metadata,
    this.webhooks,
  });
  factory MutatingWebhookConfiguration.fromJson(Map<String, dynamic> json) {
    return MutatingWebhookConfiguration(
      apiVersion: json['apiVersion'] ?? 'admissionregistration.k8s.io/v1',
      kind: json['kind'] ?? 'MutatingWebhookConfiguration',
      metadata: ObjectMeta.fromJson(json['metadata']),
      webhooks:
          json['webhooks'] != null
              ? (json['webhooks'] as List)
                  .map((e) => MutatingWebhook.fromJson(e))
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
