class QueuingConfiguration {
  final int? queues;
  final int? handSize;
  final int? queueLengthLimit;
  QueuingConfiguration({this.queues, this.handSize, this.queueLengthLimit});
  factory QueuingConfiguration.fromJson(Map<String, dynamic> json) {
    return QueuingConfiguration(
      queues: json['queues'],
      handSize: json['handSize'],
      queueLengthLimit: json['queueLengthLimit'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (queues != null) 'queues': queues,
      if (handSize != null) 'handSize': handSize,
      if (queueLengthLimit != null) 'queueLengthLimit': queueLengthLimit,
    };
  }
}
