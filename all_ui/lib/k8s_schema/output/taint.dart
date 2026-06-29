class Taint {
  final String key;
  final String? value;
  final String effect;
  final DateTime? timeAdded;
  Taint({required this.key, this.value, required this.effect, this.timeAdded});
  factory Taint.fromJson(Map<String, dynamic> json) {
    return Taint(
      key: json['key'],
      value: json['value'],
      effect: json['effect'],
      timeAdded:
          json['timeAdded'] != null ? DateTime.parse(json['timeAdded']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      if (value != null) 'value': value,
      'effect': effect,
      if (timeAdded != null) 'timeAdded': timeAdded!.toIso8601String(),
    };
  }
}
