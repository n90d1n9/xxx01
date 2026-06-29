import 'webhook_client_config.dart';

class WebhookConversion {
  final List<String>? conversionReviewVersions;
  final WebhookClientConfig? clientConfig;
  WebhookConversion({this.conversionReviewVersions, this.clientConfig});
  factory WebhookConversion.fromJson(Map<String, dynamic> json) {
    return WebhookConversion(
      conversionReviewVersions:
          json['conversionReviewVersions'] != null
              ? List<String>.from(json['conversionReviewVersions'])
              : null,
      clientConfig:
          json['clientConfig'] != null
              ? WebhookClientConfig.fromJson(json['clientConfig'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (conversionReviewVersions != null)
        'conversionReviewVersions': conversionReviewVersions,
      if (clientConfig != null) 'clientConfig': clientConfig!.toJson(),
    };
  }
}
