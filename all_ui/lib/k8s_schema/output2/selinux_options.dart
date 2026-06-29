class SELinuxOptions {
  final String? user;
  final String? role;
  final String? type;
  final String? level;
  SELinuxOptions({this.user, this.role, this.type, this.level});
  factory SELinuxOptions.fromJson(Map<String, dynamic> json) {
    return SELinuxOptions(
      user: json['user'],
      role: json['role'],
      type: json['type'],
      level: json['level'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (user != null) 'user': user,
      if (role != null) 'role': role,
      if (type != null) 'type': type,
      if (level != null) 'level': level,
    };
  }
}
