class ResponseAnswer {
  final String questionId;
  final dynamic value;
  final DateTime answeredAt;

  const ResponseAnswer({
    required this.questionId,
    required this.value,
    required this.answeredAt,
  });

  bool get hasValue => hasMeaningfulValue(value);

  ResponseAnswer copyWith({
    String? questionId,
    dynamic value,
    DateTime? answeredAt,
  }) {
    return ResponseAnswer(
      questionId: questionId ?? this.questionId,
      value: value ?? this.value,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  factory ResponseAnswer.fromJson(Map<String, dynamic> json) {
    return ResponseAnswer(
      questionId: json['questionId'] as String,
      value: json['value'],
      answeredAt: DateTime.parse(json['answeredAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'value': value,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  static bool hasMeaningfulValue(dynamic value) {
    if (value == null) {
      return false;
    }

    if (value is String) {
      return value.trim().isNotEmpty;
    }

    if (value is Iterable) {
      return value.isNotEmpty;
    }

    if (value is Map) {
      return value.isNotEmpty;
    }

    return true;
  }
}
