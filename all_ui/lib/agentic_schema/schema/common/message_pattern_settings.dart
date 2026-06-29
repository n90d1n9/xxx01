class MessagePatternSettings {
  final String? queueName;
  final String? topicName;
  final String? exchangeName;
  final String? routingKey;
  final String? replyTo;
  final int? timeout;
  final bool? persistent;

  MessagePatternSettings({
    this.queueName,
    this.topicName,
    this.exchangeName,
    this.routingKey,
    this.replyTo,
    this.timeout,
    this.persistent,
  });

  factory MessagePatternSettings.fromJson(Map<String, dynamic> json) {
    return MessagePatternSettings(
      queueName: json['queueName'] as String?,
      topicName: json['topicName'] as String?,
      exchangeName: json['exchangeName'] as String?,
      routingKey: json['routingKey'] as String?,
      replyTo: json['replyTo'] as String?,
      timeout: json['timeout'] as int?,
      persistent: json['persistent'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (queueName != null) 'queueName': queueName,
      if (topicName != null) 'topicName': topicName,
      if (exchangeName != null) 'exchangeName': exchangeName,
      if (routingKey != null) 'routingKey': routingKey,
      if (replyTo != null) 'replyTo': replyTo,
      if (timeout != null) 'timeout': timeout,
      if (persistent != null) 'persistent': persistent,
    };
  }
}
