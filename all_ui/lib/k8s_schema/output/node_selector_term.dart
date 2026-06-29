import 'node_selector_requirement.dart';

class NodeSelectorTerm {
  final List<NodeSelectorRequirement>? matchExpressions;
  final List<NodeSelectorRequirement>? matchFields;
  NodeSelectorTerm({this.matchExpressions, this.matchFields});
  factory NodeSelectorTerm.fromJson(Map<String, dynamic> json) {
    return NodeSelectorTerm(
      matchExpressions:
          json['matchExpressions'] != null
              ? (json['matchExpressions'] as List)
                  .map((e) => NodeSelectorRequirement.fromJson(e))
                  .toList()
              : null,
      matchFields:
          json['matchFields'] != null
              ? (json['matchFields'] as List)
                  .map((e) => NodeSelectorRequirement.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (matchExpressions != null)
        'matchExpressions': matchExpressions!.map((e) => e.toJson()).toList(),
      if (matchFields != null)
        'matchFields': matchFields!.map((e) => e.toJson()).toList(),
    };
  }
}
