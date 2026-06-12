import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/icon_action_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_details_button.dart';

void main() {
  testWidgets('ProfileDetailsButton renders reusable action', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileDetailsButton(
            profileId: 'marketplace_operations',
            keyPrefix: 'profile_details',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('profile_details_marketplace_operations')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.byType(IconActionButton), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('profile_details_marketplace_operations')),
    );
    await tester.pump();

    expect(pressed, isTrue);
    expect(tester.takeException(), isNull);
  });
}
