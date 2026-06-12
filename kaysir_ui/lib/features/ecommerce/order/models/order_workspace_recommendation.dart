import 'order_workspace_view.dart';

enum OrderWorkspaceRecommendationTone { info, success, warning, danger }

class OrderWorkspaceRecommendation {
  final String id;
  final String title;
  final String description;
  final String badgeLabel;
  final String targetWorkspaceViewId;
  final OrderWorkspaceRecommendationTone tone;

  const OrderWorkspaceRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.badgeLabel,
    required this.targetWorkspaceViewId,
    required this.tone,
  });
}

List<OrderWorkspaceRecommendation> ecommerceOrderWorkspaceRecommendations({
  required OrderWorkspaceContext activeWorkspace,
  required Map<String, int> workspaceViewCounts,
  int limit = 3,
}) {
  final recommendations = <OrderWorkspaceRecommendation>[];
  final priorityCount = _count(workspaceViewCounts, 'priority_queue');
  final actionCount = _count(workspaceViewCounts, 'action_queue');
  final readyCount = _count(workspaceViewCounts, 'ready_handoff');
  final settlementCount = _count(workspaceViewCounts, 'settlement_review');
  final todayCount = _count(workspaceViewCounts, 'today_queue');

  void addIfAvailable({
    required String viewId,
    required int count,
    required String title,
    required String description,
    required OrderWorkspaceRecommendationTone tone,
  }) {
    if (count <= 0 || activeWorkspace.id == viewId) return;

    recommendations.add(
      OrderWorkspaceRecommendation(
        id: viewId,
        title: title,
        description: description,
        badgeLabel: _countLabel(count),
        targetWorkspaceViewId: viewId,
        tone: tone,
      ),
    );
  }

  addIfAvailable(
    viewId: 'priority_queue',
    count: priorityCount,
    title: 'Review priority queue',
    description:
        '$priorityCount high-priority ${_noun(priorityCount, 'order')} ${_verb(priorityCount)} waiting for operator attention.',
    tone: OrderWorkspaceRecommendationTone.danger,
  );

  final remainingActionCount = actionCount - priorityCount;
  addIfAvailable(
    viewId: 'action_queue',
    count: remainingActionCount > 0 ? actionCount : 0,
    title: 'Work action queue',
    description:
        '$actionCount actionable ${_noun(actionCount, 'order')} ${_verb(actionCount)} ready to be cleared.',
    tone: OrderWorkspaceRecommendationTone.warning,
  );

  addIfAvailable(
    viewId: 'ready_handoff',
    count: readyCount,
    title: 'Prepare handoff',
    description:
        '$readyCount ready ${_noun(readyCount, 'order')} ${_verb(readyCount)} waiting for pickup, courier, or dispatch.',
    tone: OrderWorkspaceRecommendationTone.info,
  );

  addIfAvailable(
    viewId: 'settlement_review',
    count: settlementCount,
    title: 'Review settlements',
    description:
        '$settlementCount externally settled ${_noun(settlementCount, 'order')} ${_verb(settlementCount)} ready for reconciliation.',
    tone: OrderWorkspaceRecommendationTone.warning,
  );

  addIfAvailable(
    viewId: 'today_queue',
    count: todayCount,
    title: 'Focus today',
    description:
        '$todayCount ${_noun(todayCount, 'order')} ${_verb(todayCount)} in today\'s ecommerce queue.',
    tone: OrderWorkspaceRecommendationTone.success,
  );

  return List.unmodifiable(recommendations.take(limit));
}

int _count(Map<String, int> counts, String key) {
  return counts[key] ?? 0;
}

String _countLabel(int count) {
  return '$count ${count == 1 ? 'order' : 'orders'}';
}

String _noun(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}

String _verb(int count) {
  return count == 1 ? 'is' : 'are';
}
