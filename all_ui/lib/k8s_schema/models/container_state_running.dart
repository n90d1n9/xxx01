
class ContainerStateRunning {final DateTime? startedAt; ContainerStateRunning({this.startedAt}); factory ContainerStateRunning.fromJson(Map<String, dynamic> json) {return ContainerStateRunning(startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null);} Map<String, dynamic> toJson() {return {if (startedAt != null) 'startedAt' : startedAt!.toIso8601String()};}}
