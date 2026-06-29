import 'service_reference.dart';

class WebhookClientConfig {
  final String? url;
  final ServiceReference? service;
  final String? caBundle;
  WebhookClientConfig({this.url, this.service, this.caBundle});
  factory WebhookClientConfig.fromJson(Map<String, dynamic> json) {
    return WebhookClientConfig(
      url: json['url'],
      service:
          json['service'] != null
              ? ServiceReference.fromJson(json['service'])
              : null,
      caBundle: json['caBundle'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (url != null) 'url': url,
      if (service != null) 'service': service!.toJson(),
      if (caBundle != null) 'caBundle': caBundle,
    };
  }
}
