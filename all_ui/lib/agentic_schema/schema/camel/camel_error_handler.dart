import '../common/redelivery_policy.dart';

class CamelErrorHandler {
  final String type;
  final String? deadLetterUri;
  final RedeliveryPolicy? redeliveryPolicy;

  CamelErrorHandler({
    required this.type,
    this.deadLetterUri,
    this.redeliveryPolicy,
  });

  factory CamelErrorHandler.fromJson(Map<String, dynamic> json) {
    return CamelErrorHandler(
      type: json['type'] as String,
      deadLetterUri: json['deadLetterUri'] as String?,
      redeliveryPolicy: json['redeliveryPolicy'] != null
          ? RedeliveryPolicy.fromJson(
              json['redeliveryPolicy'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (deadLetterUri != null) 'deadLetterUri': deadLetterUri,
      if (redeliveryPolicy != null)
        'redeliveryPolicy': redeliveryPolicy!.toJson(),
    };
  }
}
