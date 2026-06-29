class PieSeries{
  double? value;
  String? name;
  String? color;

  PieSeries({this.value, this.name});

  /// Converts a PieSeries instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'name': name,
    };
  }

  /// Creates a PieSeries instance from a JSON map.
  factory PieSeries.fromJson(Map<String, dynamic> json) {
    return PieSeries(
      value: (json['value'] as num?)?.toDouble(),
      name: json['name'] as String?,
    );
  }

  @override
  String toString() {
    return 'PieSeries(value: $value, name: $name)';
  }
}
