import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/app/models/auth/user.dart';
import 'package:kaysir/features/admin/widgets/account_widget.dart';

void main() {
  const user = User(
    id: 1,
    firstName: 'Aisyah',
    lastName: 'Rahman',
    username: 'aisyah',
    email: 'aisyah@example.com',
    role: UserRole.admin,
  );

  testWidgets('wide account widget shows identity and reports menu actions', (
    tester,
  ) async {
    AccountMenuAction? selectedAction;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(900, 600)),
          child: Scaffold(
            body: Center(
              child: AccountWidget(
                user: user,
                onSelected: (action) => selectedAction = action,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Aisyah Rahman'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);

    await tester.tap(find.byType(AccountWidget));
    await tester.pumpAndSettle();

    expect(find.text('aisyah@example.com'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(selectedAction, AccountMenuAction.profile);
  });

  testWidgets('compact account widget keeps copy out of the header', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(500, 600)),
          child: Scaffold(body: Center(child: AccountWidget(user: user))),
        ),
      ),
    );

    expect(find.text('AR'), findsOneWidget);
    expect(find.text('Aisyah Rahman'), findsNothing);
    expect(find.text('Admin'), findsNothing);
  });
}
