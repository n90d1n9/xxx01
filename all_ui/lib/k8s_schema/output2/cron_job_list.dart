import 'cron_job.dart';
import 'list_meta.dart';

class CronJobList {
  final String apiVersion;
  final String kind;
  final ListMeta? metadata;
  final List<CronJob> items;
  CronJobList({
    this.apiVersion = 'batch/v1',
    this.kind = 'CronJobList',
    this.metadata,
    required this.items,
  });
  factory CronJobList.fromJson(Map<String, dynamic> json) {
    return CronJobList(
      apiVersion: json['apiVersion'] ?? 'batch/v1',
      kind: json['kind'] ?? 'CronJobList',
      metadata:
          json['metadata'] != null ? ListMeta.fromJson(json['metadata']) : null,
      items: (json['items'] as List).map((e) => CronJob.fromJson(e)).toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      if (metadata != null) 'metadata': metadata!.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
