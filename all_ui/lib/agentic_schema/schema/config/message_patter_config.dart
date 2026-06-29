import '../common/message_pattern_settings.dart';

enum MessagePattern {
  pointToPoint,
  publishSubscribe,
  requestReply,
  fireAndForget,
  pollingConsumer,
  eventDrivenConsumer,
  competingConsumers,
  messageDispatcher,
  selectiveConsumer,
  durableSubscriber,
}

class MessagePatternConfig {
  final MessagePattern pattern;
  final MessagePatternSettings? config;

  MessagePatternConfig({required this.pattern, this.config});

  factory MessagePatternConfig.fromJson(Map<String, dynamic> json) {
    return MessagePatternConfig(
      pattern: _parseMessagePattern(json['pattern']),
      config: json['config'] != null
          ? MessagePatternSettings.fromJson(
              json['config'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pattern': pattern.name,
      if (config != null) 'config': config!.toJson(),
    };
  }

  static MessagePattern _parseMessagePattern(dynamic value) {
    if (value is MessagePattern) return value;
    final stringValue = value.toString();
    return MessagePattern.values.firstWhere((e) => e.name == stringValue);
  }
}
