import 'label_selector.dart';
import 'pod_template_spec.dart';

class ReplicaSetSpec {
  final int? replicas;
  final int? minReadySeconds;
  final LabelSelector selector;
  final PodTemplateSpec? template;
  ReplicaSetSpec({
    this.replicas,
    this.minReadySeconds,
    required this.selector,
    this.template,
  });
  factory ReplicaSetSpec.fromJson(Map<String, dynamic> json) {
    return ReplicaSetSpec(
      replicas: json['replicas'],
      minReadySeconds: json['minReadySeconds'],
      selector: LabelSelector.fromJson(json['selector']),
      template:
          json['template'] != null
              ? PodTemplateSpec.fromJson(json['template'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (replicas != null) 'replicas': replicas,
      if (minReadySeconds != null) 'minReadySeconds': minReadySeconds,
      'selector': selector.toJson(),
      if (template != null) 'template': template!.toJson(),
    };
  }
}
