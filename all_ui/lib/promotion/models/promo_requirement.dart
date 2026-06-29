import 'dart:convert';

class PromoRequirement {
  final String name;

  PromoRequirement({required this.name});

  PromoRequirement copyWith({String? name}) {
    return PromoRequirement(name: name ?? this.name);
  }

  Map<String, dynamic> toMap() {
    return {'name': name};
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'PromoRequirement(name: $name)';
  }
}
