// fact.dart
class Fact {
  final String type;
  final Map<String, dynamic> data;

  Fact(this.type, Map<String, dynamic>? initialData)
    : data = Map<String, dynamic>.from(initialData ?? {});

  dynamic get(String key) => data[key];

  @override
  String toString() => 'Fact<$type>${data.toString()}';
}
