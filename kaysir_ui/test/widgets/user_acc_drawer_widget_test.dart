import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/user_acc_drawer_widget.dart';

void main() {
  testWidgets('renders safe account defaults without an image', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: UserAccountsDrawer())),
    );

    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('No email configured'), findsOneWidget);
    expect(find.text('G'), findsOneWidget);

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isNull);
  });

  testWidgets('uses provided account details and avatar asset path', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UserAccountsDrawer(
            accountName: 'Aisyah',
            accountEmail: 'aisyah@example.com',
            imgPath: 'assets/images/profile.png',
          ),
        ),
      ),
    );

    expect(find.text('Aisyah'), findsOneWidget);
    expect(find.text('aisyah@example.com'), findsOneWidget);

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isA<AssetImage>());
  });
}
