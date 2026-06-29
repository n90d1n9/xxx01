import 'object_reference.dart';

class CronJobStatus {
  final List<ObjectReference>? active;
  final DateTime? lastScheduleTime;
  final DateTime? lastSuccessfulTime;
  CronJobStatus({this.active, this.lastScheduleTime, this.lastSuccessfulTime});
  factory CronJobStatus.fromJson(Map<String, dynamic> json) {
    return CronJobStatus(
      active:
          json['active'] != null
              ? (json['active'] as List)
                  .map((e) => ObjectReference.fromJson(e))
                  .toList()
              : null,
      lastScheduleTime:
          json['lastScheduleTime'] != null
              ? DateTime.parse(json['lastScheduleTime'])
              : null,
      lastSuccessfulTime:
          json['lastSuccessfulTime'] != null
              ? DateTime.parse(json['lastSuccessfulTime'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (active != null) 'active': active!.map((e) => e.toJson()).toList(),
      if (lastScheduleTime != null)
        'lastScheduleTime': lastScheduleTime!.toIso8601String(),
      if (lastSuccessfulTime != null)
        'lastSuccessfulTime': lastSuccessfulTime!.toIso8601String(),
    };
  }
}
