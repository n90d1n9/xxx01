import 'label_selector.dart';
import 'pod_template_spec.dart';

class JobSpec {
  final int? parallelism;
  final int? completions;
  final int? activeDeadlineSeconds;
  final int? backoffLimit;
  final LabelSelector? selector;
  final bool? manualSelector;
  final PodTemplateSpec template;
  final int? ttlSecondsAfterFinished;
  final String? completionMode;
  final bool? suspend;
  JobSpec({
    this.parallelism,
    this.completions,
    this.activeDeadlineSeconds,
    this.backoffLimit,
    this.selector,
    this.manualSelector,
    required this.template,
    this.ttlSecondsAfterFinished,
    this.completionMode,
    this.suspend,
  });
  factory JobSpec.fromJson(Map<String, dynamic> json) {
    return JobSpec(
      parallelism: json['parallelism'],
      completions: json['completions'],
      activeDeadlineSeconds: json['activeDeadlineSeconds'],
      backoffLimit: json['backoffLimit'],
      selector:
          json['selector'] != null
              ? LabelSelector.fromJson(json['selector'])
              : null,
      manualSelector: json['manualSelector'],
      template: PodTemplateSpec.fromJson(json['template']),
      ttlSecondsAfterFinished: json['ttlSecondsAfterFinished'],
      completionMode: json['completionMode'],
      suspend: json['suspend'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (parallelism != null) 'parallelism': parallelism,
      if (completions != null) 'completions': completions,
      if (activeDeadlineSeconds != null)
        'activeDeadlineSeconds': activeDeadlineSeconds,
      if (backoffLimit != null) 'backoffLimit': backoffLimit,
      if (selector != null) 'selector': selector!.toJson(),
      if (manualSelector != null) 'manualSelector': manualSelector,
      'template': template.toJson(),
      if (ttlSecondsAfterFinished != null)
        'ttlSecondsAfterFinished': ttlSecondsAfterFinished,
    };
  }
}
