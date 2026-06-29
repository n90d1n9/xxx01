class Logging {
  final String? level;
  final String? destination;
  final bool? includePayload;

  Logging({
    this.level = 'info',
    this.destination = 'console',
    this.includePayload = false,
  });

  factory Logging.fromJson(Map<String, dynamic> json) {
    return Logging(
      level: json['level'] as String?,
      destination: json['destination'] as String?,
      includePayload: json['includePayload'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (level != null) 'level': level,
      if (destination != null) 'destination': destination,
      if (includePayload != null) 'includePayload': includePayload,
    };
  }
}
