import 'daemon_set_update_strategy.dart';
import 'label_selector.dart';
import 'pod_template_spec.dart';

class DaemonSetSpec {
  final LabelSelector selector;
  final PodTemplateSpec template;
  final DaemonSetUpdateStrategy? updateStrategy;
  final int? minReadySeconds;
  final int? revisionHistoryLimit;
  DaemonSetSpec({
    required this.selector,
    required this.template,
    this.updateStrategy,
    this.minReadySeconds,
    this.revisionHistoryLimit,
  });
  factory DaemonSetSpec.fromJson(Map<String, dynamic> json) {
    return DaemonSetSpec(
      selector: LabelSelector.fromJson(json['selector']),
      template: PodTemplateSpec.fromJson(json['template']),
      updateStrategy:
          json['updateStrategy'] != null
              ? DaemonSetUpdateStrategy.fromJson(json['updateStrategy'])
              : null,
      minReadySeconds: json['minReadySeconds'],
      revisionHistoryLimit: json['revisionHistoryLimit'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'selector': selector.toJson(),
      'template': template.toJson(),
      if (updateStrategy != null) 'updateStrategy': updateStrategy!.toJson(),
      if (minReadySeconds != null) 'minReadySeconds': minReadySeconds,
      if (revisionHistoryLimit != null)
        'revisionHistoryLimit': revisionHistoryLimit,
    };
  }
}
