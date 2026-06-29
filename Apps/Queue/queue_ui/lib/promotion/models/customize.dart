import 'dart:convert';

import 'promotion.dart';

class Customize {
  final String conditionLogic;
  final Promotion promotion;

  Customize({required this.conditionLogic, required this.promotion});

  Customize copyWith({String? conditionLogic, Promotion? promotion}) {
    return Customize(
      conditionLogic: conditionLogic ?? this.conditionLogic,
      promotion: promotion ?? this.promotion,
    );
  }

  Map<String, dynamic> toMap() {
    return {'conditionLogic': conditionLogic, 'promotion': promotion.toMap()};
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Customize(conditionLogic: $conditionLogic, promotion: $promotion)';
  }
}
