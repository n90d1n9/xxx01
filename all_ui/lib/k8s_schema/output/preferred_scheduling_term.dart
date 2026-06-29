import 'node_selector_term.dart';

class PreferredSchedulingTerm {
  final int weight;
  final NodeSelectorTerm preference;
  PreferredSchedulingTerm({required this.weight, required this.preference});
  factory PreferredSchedulingTerm.fromJson(Map<String, dynamic> json) {
    return PreferredSchedulingTerm(
      weight: json['weight'],
      preference: NodeSelectorTerm.fromJson(json['preference']),
    );
  }
  Map<String, dynamic> toJson() {
    return {'weight': weight, 'preference': preference.toJson()};
  }
}
