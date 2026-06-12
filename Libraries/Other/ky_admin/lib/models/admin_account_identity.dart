import '../../../app/models/auth/user.dart';

class AdminAccountIdentity {
  const AdminAccountIdentity({
    required this.displayName,
    required this.roleLabel,
    required this.emailLabel,
    required this.usernameLabel,
    required this.initials,
    this.imageUrl,
  });

  final String displayName;
  final String roleLabel;
  final String emailLabel;
  final String usernameLabel;
  final String initials;
  final String? imageUrl;

  factory AdminAccountIdentity.fromUser(User user) {
    final displayName =
        _joinedName(user.firstName, user.lastName) ??
        _firstNonBlank([user.username, user.login, user.email]) ??
        'Kaysir User';
    final roleLabel = _roleLabel(user.role);
    final emailLabel = _firstNonBlank([user.email]) ?? 'operator@kaysir.local';
    final usernameLabel =
        _firstNonBlank([user.username, user.login, user.email]) ?? 'kaysir';
    final imageUrl = _firstNonBlank([user.imageUrl]);

    return AdminAccountIdentity(
      displayName: displayName,
      roleLabel: roleLabel,
      emailLabel: emailLabel,
      usernameLabel: usernameLabel,
      initials: _initials(displayName),
      imageUrl: imageUrl,
    );
  }

  static String? _joinedName(String? firstName, String? lastName) {
    final parts = [firstName, lastName]
        .map((value) => value?.trim())
        .where((value) => value != null && value.isNotEmpty)
        .cast<String>()
        .toList(growable: false);

    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  static String? _firstNonBlank(List<String?> values) {
    for (final value in values) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) return normalized;
    }

    return null;
  }

  static String _roleLabel(UserRole? role) {
    if (role == null) return 'Operator';

    return role.name
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  static String _initials(String displayName) {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) return 'K';
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}
