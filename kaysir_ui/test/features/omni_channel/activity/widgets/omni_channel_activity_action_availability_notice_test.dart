import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/widgets/omni_channel_activity_action_availability_notice.dart';

void main() {
  testWidgets(
    'omni-channel action availability notice explains disabled action',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OmniChannelActivityActionAvailabilityNotice(
              actions: [
                OmniChannelActivityAction(
                  label: 'Open sync queue',
                  location: '/cashier',
                  tooltip: 'Retry failed sync',
                  intent: OmniChannelActivityActionIntent.retry,
                  enabled: false,
                  disabledReason: 'Sync is already running.',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Unavailable actions'), findsOneWidget);
      expect(find.text('Open sync queue'), findsOneWidget);
      expect(find.text('Sync is already running.'), findsOneWidget);
      expect(find.byIcon(Icons.replay_circle_filled_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'omni-channel action availability notice hides without disabled actions',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OmniChannelActivityActionAvailabilityNotice(
              actions: [
                OmniChannelActivityAction(
                  label: 'Open orders',
                  location: '/commerce/orders',
                  tooltip: 'Open orders workspace',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Unavailable actions'), findsNothing);
      expect(find.text('Open orders'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
