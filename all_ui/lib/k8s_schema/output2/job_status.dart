import 'job_condition.dart';

class JobStatus {
  final List<JobCondition>? conditions;
  final DateTime? startTime;
  final DateTime? completionTime;
  final int? active;
  final int? succeeded;
  final int? failed;
  JobStatus({
    this.conditions,
    this.startTime,
    this.completionTime,
    this.active,
    this.succeeded,
    this.failed,
  });
  factory JobStatus.fromJson(Map<String, dynamic> json) {
    return JobStatus(
      conditions:
          json['conditions'] != null
              ? (json['conditions'] as List)
                  .map((e) => JobCondition.fromJson(e))
                  .toList()
              : null,
      startTime:
          json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      completionTime:
          json['completionTime'] != null
              ? DateTime.parse(json['completionTime'])
              : null,
      active: json['active'],
      succeeded: json['succeeded'],
      failed: json['failed'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (conditions != null)
        'conditions': conditions!.map((e) => e.toJson()).toList(),
      if (startTime != null) 'startTime': startTime!.toIso8601String(),
      if (completionTime != null)
        'completionTime': completionTime!.toIso8601String(),
      if (active != null) 'active': active,
      if (succeeded != null) 'succeeded': succeeded,
      if (failed != null) 'failed': failed,
    };
  }
}
