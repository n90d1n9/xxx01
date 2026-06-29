import 'package:queue_ui/devportal/models/enums.dart';

class ApiUsageData {
  final String? endpoint;
  final int requests;
  final int successCount;
  final int errorCount;
  final double latency;
  final DateTime? date;

  final dynamic calls;

  final String? name;

  final dynamic growth;

  ApiUsageData({
    this.endpoint,
    this.requests = 0,
    this.successCount = 0,
    this.errorCount = 0,
    this.latency = 0,
    this.date,
    this.calls,
    this.name,
    this.growth,
  });

  // Convert from JSON
  factory ApiUsageData.fromJson(Map<String, dynamic> json) {
    return ApiUsageData(
      endpoint: json['endpoint'] as String,
      requests: json['requests'] as int,
      successCount: json['successCount'] as int,
      errorCount: json['errorCount'] as int,
      latency: (json['latency'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'endpoint': endpoint,
      'requests': requests,
      'successCount': successCount,
      'errorCount': errorCount,
      'latency': latency,
      'date': date!.toIso8601String(),
    };
  }
}

// Project class to represent a developer project
class Project {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final List<String>? apiKeyIds;
  final ProjectStatus? status;
  final Map<String, dynamic>? settings;

  final DateTime? lastUpdated;

  final List<String>? apis;

  Project({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.apiKeyIds,
    this.status,
    this.settings,
    this.lastUpdated,
    this.apis,
  });

  // Convert from JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      apiKeyIds: List<String>.from(json['apiKeyIds'] as List),
      status:
          json['status'] != null
              ? ProjectStatus.values.firstWhere(
                (e) => e.toString() == 'ProjectStatus.${json['status']}',
              )
              : null,
      settings: json['settings'] as Map<String, dynamic>,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt!.toIso8601String(),
      'apiKeyIds': apiKeyIds,
      'status': status,
      'settings': settings,
    };
  }
}
