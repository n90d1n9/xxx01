class LimitRangeItem {
  final String? type;
  final Map<String, String>? max;
  final Map<String, String>? min;
  final Map<String, String>? defaultLimit;
  final Map<String, String>? defaultRequest;
  final Map<String, String>? maxLimitRequestRatio;
  LimitRangeItem({
    this.type,
    this.max,
    this.min,
    this.defaultLimit,
    this.defaultRequest,
    this.maxLimitRequestRatio,
  });
  factory LimitRangeItem.fromJson(Map<String, dynamic> json) {
    return LimitRangeItem(
      type: json['type'],
      max: json['max'] != null ? Map<String, String>.from(json['max']) : null,
      min: json['min'] != null ? Map<String, String>.from(json['min']) : null,
      defaultLimit:
          json['default'] != null
              ? Map<String, String>.from(json['default'])
              : null,
      defaultRequest:
          json['defaultRequest'] != null
              ? Map<String, String>.from(json['defaultRequest'])
              : null,
      maxLimitRequestRatio:
          json['maxLimitRequestRatio'] != null
              ? Map<String, String>.from(json['maxLimitRequestRatio'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      if (max != null) 'max': max,
      if (min != null) 'min': min,
      if (defaultLimit != null) 'default': defaultLimit,
      if (defaultRequest != null) 'defaultRequest': defaultRequest,
      if (maxLimitRequestRatio != null)
        'maxLimitRequestRatio': maxLimitRequestRatio,
    };
  }
}
