class UserPermission {
  final String userId;
  final String role;

  UserPermission({required this.userId, required this.role});

  factory UserPermission.fromJson(Map<String, dynamic> json) {
    return UserPermission(
      userId: json['userId'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'role': role};
  }
}
