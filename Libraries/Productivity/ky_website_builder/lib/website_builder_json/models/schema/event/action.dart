import '../action_timing.dart';

class Action {
  final String
  type; // navigate, setState, api, animation, scrollTo, openModal, etc.
  final Map<String, dynamic>? params;
  final String? target; // Target component or page
  final ActionTiming? timing;

  Action({required this.type, this.params, this.target, this.timing});

  factory Action.fromJson(Map<String, dynamic> json) {
    return Action(
      type: json['type'] as String,
      params: json['params'] as Map<String, dynamic>?,
      target: json['target'] as String?,
      timing:
          json['timing'] != null
              ? ActionTiming.fromJson(json['timing'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    if (params != null) 'params': params,
    if (target != null) 'target': target,
    if (timing != null) 'timing': timing!.toJson(),
  };
}
