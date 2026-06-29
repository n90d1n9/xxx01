import 'topology_selector_label_requirement.dart';

class TopologySelectorTerm {
  final List<TopologySelectorLabelRequirement>? matchLabelExpressions;
  TopologySelectorTerm({this.matchLabelExpressions});
  factory TopologySelectorTerm.fromJson(Map<String, dynamic> json) {
    return TopologySelectorTerm(
      matchLabelExpressions:
          json['matchLabelExpressions'] != null
              ? (json['matchLabelExpressions'] as List)
                  .map((e) => TopologySelectorLabelRequirement.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (matchLabelExpressions != null)
        'matchLabelExpressions':
            matchLabelExpressions!.map((e) => e.toJson()).toList(),
    };
  }
}
