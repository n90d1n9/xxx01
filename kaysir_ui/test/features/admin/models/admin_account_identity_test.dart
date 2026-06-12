import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/app/models/auth/user.dart';
import 'package:kaysir/features/admin/models/admin_account_identity.dart';

void main() {
  test('AdminAccountIdentity derives display labels from profile names', () {
    final identity = AdminAccountIdentity.fromUser(
      const User(
        id: 1,
        firstName: 'Aisyah',
        lastName: 'Rahman',
        username: 'aisyah',
        email: 'aisyah@example.com',
        role: UserRole.manager,
      ),
    );

    expect(identity.displayName, 'Aisyah Rahman');
    expect(identity.roleLabel, 'Manager');
    expect(identity.emailLabel, 'aisyah@example.com');
    expect(identity.usernameLabel, 'aisyah');
    expect(identity.initials, 'AR');
  });

  test('AdminAccountIdentity falls back safely for sparse user data', () {
    final identity = AdminAccountIdentity.fromUser(
      const User(id: 2, email: 'operator@example.com'),
    );

    expect(identity.displayName, 'operator@example.com');
    expect(identity.roleLabel, 'Operator');
    expect(identity.emailLabel, 'operator@example.com');
    expect(identity.usernameLabel, 'operator@example.com');
    expect(identity.initials, 'O');
  });
}
