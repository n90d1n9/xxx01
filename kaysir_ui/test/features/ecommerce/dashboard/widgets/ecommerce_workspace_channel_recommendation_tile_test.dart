import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/channel_recommendation.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/channel_recommendation_tile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/detail_row.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/inset_surface.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/text_badge.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  const paymentRecommendation = ChannelRecommendation(
    type: ChannelRecommendationType.addPaymentChannel,
    title: 'Add payment-capable channel',
    detail: 'Add at least one sales channel that can capture payment.',
    actionLabel: 'Add payment',
    priority: 30,
    coverageRequirementId: 'payments',
  );

  testWidgets('ChannelRecommendationTile renders playbook', (tester) async {
    await tester.pumpWorkspaceWidget(
      const ChannelRecommendationTile(recommendation: paymentRecommendation),
    );

    expect(
      find.byKey(const ValueKey('channel_recommendation_payments')),
      findsOneWidget,
    );
    expect(find.text('Add payment-capable channel'), findsOneWidget);
    expect(
      find.text('Add at least one sales channel that can capture payment.'),
      findsOneWidget,
    );
    expect(find.text('Add payment'), findsOneWidget);
    expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    expect(find.byType(InsetSurface), findsOneWidget);
    expect(find.byType(DetailRow), findsOneWidget);
    expect(find.byType(TextBadge), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('channelRecommendationIcon maps custom requirement', () {
    expect(
      channelRecommendationIcon(
        ChannelRecommendationType.addChannelRequirementCoverage,
      ),
      Icons.fact_check_outlined,
    );
  });
}
