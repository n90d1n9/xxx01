class SharedUser {
  final String email;
  final String role;
  final String? avatarUrl;
  final DateTime joinedAt;

  SharedUser({
    required this.email,
    required this.role,
    this.avatarUrl,
    required this.joinedAt,
  });

  SharedUser copyWith({
    String? email,
    String? role,
    String? avatarUrl,
    DateTime? joinedAt,
  }) {
    return SharedUser(
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
