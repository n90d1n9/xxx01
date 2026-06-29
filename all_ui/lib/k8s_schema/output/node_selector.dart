import 'node_selector_term.dart';

class NodeSelector {
  final List<NodeSelectorTerm> nodeSelectorTerms;
  NodeSelector({required this.nodeSelectorTerms});
  factory NodeSelector.fromJson(Map<String, dynamic> json) {
    return NodeSelector(
      nodeSelectorTerms:
          (json['nodeSelectorTerms'] as List)
              .map((e) => NodeSelectorTerm.fromJson(e))
              .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'nodeSelectorTerms': nodeSelectorTerms.map((e) => e.toJson()).toList(),
    };
  }
}
