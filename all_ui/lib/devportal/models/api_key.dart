import 'enums.dart';

class ApiKey {
  final String id;
  final String? key;
  final String? name;
  final String? projectId;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final List<String>? permissions;
  final Map<String, dynamic>? restrictions;

  final ApiKeyStatus? status;

  final DateTime? created;

  final DateTime? expires;
  final DateTime? lastUsed;

  ApiKey({
    required this.id,
    this.key,
    this.name,
    this.projectId,
    this.createdAt,
    this.expiresAt,
    this.isActive = false,
    this.permissions,
    this.restrictions,
    this.status,
    this.created,
    this.expires,
    this.lastUsed,
  });

  // Convert from JSON
  factory ApiKey.fromJson(Map<String, dynamic> json) {
    return ApiKey(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      projectId: json['projectId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt:
          json['expiresAt'] != null
              ? DateTime.parse(json['expiresAt'] as String)
              : null,
      isActive: json['isActive'] as bool,
      permissions: List<String>.from(json['permissions'] as List),
      restrictions: json['restrictions'] as Map<String, dynamic>,
      status:
          json['status'] != null
              ? ApiKeyStatus.values.firstWhere(
                (e) => e.toString() == 'ApiKeyStatus.${json['status']}',
              )
              : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'projectId': projectId,
      'createdAt': createdAt!.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
      'permissions': permissions,
      'restrictions': restrictions,
    };
  }

  // Mask key to show only last 4 characters
  String get maskedKey => '••••${key!.substring(key!.length - 4)}';
}
