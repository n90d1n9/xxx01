class Role {
  final String name;
  final List<String> permissions;

  Role({required this.name, required this.permissions});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      name: json['name'] as String,
      permissions: List<String>.from(json['permissions'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'permissions': permissions};
  }
}
