class IDRange {
  final int min;
  final int max;
  IDRange({required this.min, required this.max});
  factory IDRange.fromJson(Map<String, dynamic> json) {
    return IDRange(min: json['min'], max: json['max']);
  }
  Map<String, dynamic> toJson() {
    return {'min': min, 'max': max};
  }
}
