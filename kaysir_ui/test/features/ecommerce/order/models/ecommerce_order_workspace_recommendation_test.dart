import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_recommendation.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_view.dart';

void main() {
  test('recommendations prioritize actionable ecommerce workspaces', () {
    final recommendations = ecommerceOrderWorkspaceRecommendations(
      activeWorkspace: _workspace('all_orders'),
      workspaceViewCounts: const {
        'priority_queue': 1,
        'action_queue': 3,
        'ready_handoff': 2,
        'settlement_review': 1,
        'today_queue': 5,
      },
    );

    expect(recommendations.map((item) => item.id), [
      'priority_queue',
      'action_queue',
      'ready_handoff',
    ]);
    expect(recommendations.first.title, 'Review priority queue');
    expect(recommendations.first.badgeLabel, '1 order');
    expect(recommendations.first.tone, OrderWorkspaceRecommendationTone.danger);
  });

  test(
    'recommendations skip the active workspace and duplicate action queue',
    () {
      final recommendations = ecommerceOrderWorkspaceRecommendations(
        activeWorkspace: _workspace('priority_queue'),
        workspaceViewCounts: const {
          'priority_queue': 2,
          'action_queue': 2,
          'ready_handoff': 1,
          'settlement_review': 1,
        },
      );

      expect(recommendations.map((item) => item.id), [
        'ready_handoff',
        'settlement_review',
      ]);
    },
  );

  test('recommendations stay empty when queues have no work', () {
    final recommendations = ecommerceOrderWorkspaceRecommendations(
      activeWorkspace: _workspace('all_orders'),
      workspaceViewCounts: const {
        'priority_queue': 0,
        'action_queue': 0,
        'ready_handoff': 0,
        'settlement_review': 0,
        'today_queue': 0,
      },
    );

    expect(recommendations, isEmpty);
  });
}

OrderWorkspaceContext _workspace(String id) {
  final view = ecommerceDefaultOrderWorkspaceViews.singleWhere(
    (view) => view.id == id,
  );
  return OrderWorkspaceContext.fromView(view);
}
