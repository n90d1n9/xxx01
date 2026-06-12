import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_insight_notice.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_preview_pill.dart';

void main() {
  testWidgets('insight next step renders reusable action guidance', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            child: POSInsightNextStep(
              message: 'Confirm channel handoff before rollout.',
              tone: POSSwitchPreviewTone.warning,
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Next: Confirm channel handoff before rollout.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.route_outlined), findsOneWidget);
  });

  test('insight notice visuals expose shared severity styles', () {
    expect(
      POSInsightNoticeVisuals.ready.previewTone,
      POSSwitchPreviewTone.positive,
    );
    expect(
      POSInsightNoticeVisuals.review.previewTone,
      POSSwitchPreviewTone.warning,
    );
    expect(
      POSInsightNoticeVisuals.attention.previewTone,
      POSSwitchPreviewTone.danger,
    );
  });
}
