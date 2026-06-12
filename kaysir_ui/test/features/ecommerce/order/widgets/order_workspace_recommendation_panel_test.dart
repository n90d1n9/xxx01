import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_view.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_workspace_recommendation_panel.dart';

void main() {
  testWidgets(
    'OrderWorkspaceRecommendationPanel renders next workspace moves',
    (tester) async {
      OrderWorkspaceView? selectedView;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              child: OrderWorkspaceRecommendationPanel(
                activeWorkspace: OrderWorkspaceContext.fromView(
                  ecommerceAllOrdersWorkspaceView,
                ),
                workspaceViews: ecommerceDefaultOrderWorkspaceViews,
                workspaceViewCounts: const {
                  'priority_queue': 1,
                  'action_queue': 3,
                  'ready_handoff': 2,
                },
                onWorkspaceViewSelected: (view) => selectedView = view,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Recommended next moves'), findsOneWidget);
      expect(find.text('Review priority queue'), findsOneWidget);
      expect(find.text('Work action queue'), findsOneWidget);
      expect(find.text('Prepare handoff'), findsOneWidget);
      expect(find.text('1 order'), findsOneWidget);

      await tester.tap(find.text('Prepare handoff'));
      await tester.pumpAndSettle();

      expect(selectedView?.id, 'ready_handoff');
    },
  );

  testWidgets('OrderWorkspaceRecommendationPanel hides empty queues', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderWorkspaceRecommendationPanel(
            activeWorkspace: OrderWorkspaceContext.fromView(
              ecommerceAllOrdersWorkspaceView,
            ),
            workspaceViews: ecommerceDefaultOrderWorkspaceViews,
            workspaceViewCounts: const {},
            onWorkspaceViewSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Recommended next moves'), findsNothing);
    expect(
      find.byKey(const ValueKey('order_recommendation_priority_queue')),
      findsNothing,
    );
  });
}
