import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/notification/services/admin_notification.dart';
import 'package:kaysir/features/notification/widgets/notification_tile.dart';

void main() {
  testWidgets('notification tile renders unread content and handles taps', (
    tester,
  ) async {
    var tapped = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationTile(
            notification: AdminNotification(
              id: 'order-1',
              title: 'New order received',
              message: 'Order #2458 was placed.',
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              type: NotificationType.order,
              isRead: false,
            ),
            onTap: () => tapped += 1,
            onDismiss: () {},
          ),
        ),
      ),
    );

    expect(find.text('New order received'), findsOneWidget);
    expect(find.text('Order #2458 was placed.'), findsOneWidget);
    expect(find.text('2h ago'), findsOneWidget);

    await tester.tap(find.text('New order received'));

    expect(tapped, 1);
  });
}
