import 'pod_condition.dart';
import 'container_status.dart';

class PodStatus {
  final String? phase;
  final List<PodCondition>? conditions;
  final String? message;
  final String? reason;
  final String? nominatedNodeName;
  final String? hostIP;
  final String? podIP;
  final List<String>? podIPs;
  final DateTime? startTime;
  final List<ContainerStatus>? containerStatuses;
  final List<ContainerStatus>? initContainerStatuses;
  final String? qosClass;
  PodStatus({
    this.phase,
    this.conditions,
    this.message,
    this.reason,
    this.nominatedNodeName,
    this.hostIP,
    this.podIP,
    this.podIPs,
    this.startTime,
    this.containerStatuses,
    this.initContainerStatuses,
    this.qosClass,
  });
  factory PodStatus.fromJson(Map<String, dynamic> json) {
    return PodStatus(
      phase: json['phase'],
      conditions:
          json['conditions'] != null
              ? (json['conditions'] as List)
                  .map((e) => PodCondition.fromJson(e))
                  .toList()
              : null,
      message: json['message'],
      reason: json['reason'],
      nominatedNodeName: json['nominatedNodeName'],
      hostIP: json['hostIP'],
      podIP: json['podIP'],
      podIPs: json['podIPs'] != null ? List<String>.from(json['podIPs']) : null,
      startTime:
          json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      containerStatuses:
          json['containerStatuses'] != null
              ? (json['containerStatuses'] as List)
                  .map((e) => ContainerStatus.fromJson(e))
                  .toList()
              : null,
      initContainerStatuses:
          json['initContainerStatuses'] != null
              ? (json['initContainerStatuses'] as List)
                  .map((e) => ContainerStatus.fromJson(e))
                  .toList()
              : null,
      qosClass: json['qosClass'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (phase != null) 'phase': phase,
      if (conditions != null)
        'conditions': conditions!.map((e) => e.toJson()).toList(),
      if (message != null) 'message': message,
      if (reason != null) 'reason': reason,
      if (nominatedNodeName != null) 'nominatedNodeName': nominatedNodeName,
      if (hostIP != null) 'hostIP': hostIP,
      if (podIP != null) 'podIP': podIP,
      if (podIPs != null) 'podIPs': podIPs,
      if (startTime != null) 'startTime': startTime!.toIso8601String(),
      if (containerStatuses != null)
        'containerStatuses': containerStatuses!.map((e) => e.toJson()).toList(),
      if (initContainerStatuses != null)
        'initContainerStatuses':
            initContainerStatuses!.map((e) => e.toJson()).toList(),
      if (qosClass != null) 'qosClass': qosClass,
    };
  }
}
