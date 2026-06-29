import 'daemon_set_condition.dart';

class DaemonSetStatus {
  final int currentNumberScheduled;
  final int numberMisscheduled;
  final int desiredNumberScheduled;
  final int numberReady;
  final int? observedGeneration;
  final int? updatedNumberScheduled;
  final int? numberAvailable;
  final int? numberUnavailable;
  final int? collisionCount;
  final List<DaemonSetCondition>? conditions;
  DaemonSetStatus({
    required this.currentNumberScheduled,
    required this.numberMisscheduled,
    required this.desiredNumberScheduled,
    required this.numberReady,
    this.observedGeneration,
    this.updatedNumberScheduled,
    this.numberAvailable,
    this.numberUnavailable,
    this.collisionCount,
    this.conditions,
  });
  factory DaemonSetStatus.fromJson(Map<String, dynamic> json) {
    return DaemonSetStatus(
      currentNumberScheduled: json['currentNumberScheduled'],
      numberMisscheduled: json['numberMisscheduled'],
      desiredNumberScheduled: json['desiredNumberScheduled'],
      numberReady: json['numberReady'],
      observedGeneration: json['observedGeneration'],
      updatedNumberScheduled: json['updatedNumberScheduled'],
      numberAvailable: json['numberAvailable'],
      numberUnavailable: json['numberUnavailable'],
      collisionCount: json['collisionCount'],
      conditions:
          json['conditions'] != null
              ? (json['conditions'] as List)
                  .map((e) => DaemonSetCondition.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'currentNumberScheduled': currentNumberScheduled,
      'numberMisscheduled': numberMisscheduled,
      'desiredNumberScheduled': desiredNumberScheduled,
      'numberReady': numberReady,
      if (observedGeneration != null) 'observedGeneration': observedGeneration,
      if (updatedNumberScheduled != null)
        'updatedNumberScheduled': updatedNumberScheduled,
      if (numberAvailable != null) 'numberAvailable': numberAvailable,
      if (numberUnavailable != null) 'numberUnavailable': numberUnavailable,
      if (collisionCount != null) 'collisionCount': collisionCount,
      if (conditions != null)
        'conditions': conditions!.map((e) => e.toJson()).toList(),
    };
  }
}
