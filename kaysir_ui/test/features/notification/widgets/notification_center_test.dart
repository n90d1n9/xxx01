import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/notification/widgets/notification_center.dart';

void main() {
  testWidgets('notification center marks all notifications as read', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: NotificationCenter())),
      ),
    );

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('2 unread of 4'), findsOneWidget);
    expect(find.text('4 notifications'), findsOneWidget);

    await tester.tap(find.text('Mark all read'));
    await tester.pump();

    expect(find.text('2 unread of 4'), findsNothing);
    expect(find.text('All caught up'), findsOneWidget);
  });

  testWidgets('notification center adapts on narrow surfaces', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(320, 600)),
            child: Scaffold(body: NotificationCenter()),
          ),
        ),
      ),
    );

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.byTooltip('Mark all read'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
