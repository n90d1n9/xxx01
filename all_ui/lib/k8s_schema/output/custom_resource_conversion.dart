import 'webhook_conversion.dart';

class CustomResourceConversion {
  final String strategy;
  final WebhookConversion? webhook;
  CustomResourceConversion({required this.strategy, this.webhook});
  factory CustomResourceConversion.fromJson(Map<String, dynamic> json) {
    return CustomResourceConversion(
      strategy: json['strategy'],
      webhook:
          json['webhook'] != null
              ? WebhookConversion.fromJson(json['webhook'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'strategy': strategy,
      if (webhook != null) 'webhook': webhook!.toJson(),
    };
  }
}
