import 'cron_job_spec.dart';
import 'cron_job_status.dart';
import 'object_meta.dart';

class CronJob {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final CronJobSpec spec;
  final CronJobStatus? status;
  CronJob({
    this.apiVersion = 'batch/v1',
    this.kind = 'CronJob',
    required this.metadata,
    required this.spec,
    this.status,
  });
  factory CronJob.fromJson(Map<String, dynamic> json) {
    return CronJob(
      apiVersion: json['apiVersion'] ?? 'batch/v1',
      kind: json['kind'] ?? 'CronJob',
      metadata: ObjectMeta.fromJson(json['metadata']),
      spec: CronJobSpec.fromJson(json['spec']),
      status:
          json['status'] != null
              ? CronJobStatus.fromJson(json['status'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      'spec': spec.toJson(),
      if (status != null) 'status': status!.toJson(),
    };
  }
}
