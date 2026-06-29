import 'dart:convert';
import 'dart:math';

class Fact {
  final String type;
  final Map<String, dynamic> attributes;
  final String id;
  Fact(this.type, this.attributes) : id = _generateId();
  static String _generateId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(10000)}';
  dynamic operator [](String key) => attributes[key];
  void operator []=(String key, dynamic value) => attributes[key] = value;
  dynamic get(String key) => attributes[key];
  void set(String key, dynamic value) => attributes[key] = value;
  bool has(String key) => attributes.containsKey(key);
  @override
  String toString() => 'Fact($type, $attributes)';
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fact && runtimeType == other.runtimeType && id == other.id;
  @override
  int get hashCode => id.hashCode;
}
