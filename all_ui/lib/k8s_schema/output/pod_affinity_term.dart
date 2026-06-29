import 'label_selector.dart';

class PodAffinityTerm {
  final LabelSelector? labelSelector;
  final List<String>? namespaces;
  final String topologyKey;
  final LabelSelector? namespaceSelector;
  PodAffinityTerm({
    this.labelSelector,
    this.namespaces,
    required this.topologyKey,
    this.namespaceSelector,
  });
  factory PodAffinityTerm.fromJson(Map<String, dynamic> json) {
    return PodAffinityTerm(
      labelSelector:
          json['labelSelector'] != null
              ? LabelSelector.fromJson(json['labelSelector'])
              : null,
      namespaces:
          json['namespaces'] != null
              ? List<String>.from(json['namespaces'])
              : null,
      topologyKey: json['topologyKey'],
      namespaceSelector:
          json['namespaceSelector'] != null
              ? LabelSelector.fromJson(json['namespaceSelector'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (labelSelector != null) 'labelSelector': labelSelector!.toJson(),
      if (namespaces != null) 'namespaces': namespaces,
      'topologyKey': topologyKey,
      if (namespaceSelector != null)
        'namespaceSelector': namespaceSelector!.toJson(),
    };
  }
}
