import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/admin/states/notification_provider.dart';

void main() {
  test('notification state updates unread badge count', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(unreadNotificationsCountProvider), 2);

    container
        .read(notificationServiceProvider.notifier)
        .markAsRead(container.read(notificationsProvider).first.id);

    expect(container.read(unreadNotificationsCountProvider), 1);

    container.read(notificationServiceProvider.notifier).markAllAsRead();

    expect(container.read(unreadNotificationsCountProvider), 0);
  });
}
