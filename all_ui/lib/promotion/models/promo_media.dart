import 'dart:convert';

import 'enums.dart';

class PromoMedia {
  final PromoMediaType type;

  PromoMedia({required this.type});

  PromoMedia copyWith({PromoMediaType? type}) {
    return PromoMedia(type: type ?? this.type);
  }

  Map<String, dynamic> toMap() {
    return {'type': type.toString()};
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'PromoMedia(type: $type)';
  }
}
