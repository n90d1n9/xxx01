import '../../models/scrum_task_move_preview.dart';
import '../../models/scrum_task_move_result.dart';
import 'board_action_feedback.dart';

/// Prepares applied bulk move results for selection updates and feedback.
class BoardTaskMoveOutcomePlanner {
  const BoardTaskMoveOutcomePlanner({
    this.feedback = const BoardActionFeedback(),
  });

  /// Feedback formatter used for move result messages.
  final BoardActionFeedback feedback;

  /// Task ids that should be sent to the controller after a move preview.
  List<String> movableTaskIds(ScrumTaskMovePreview preview) {
    return [for (final result in preview.changedResults) result.taskId];
  }

  /// Summarizes controller move results for UI state updates.
  BoardTaskMoveOutcome summarize({
    required Iterable<ScrumTaskMoveResult> results,
    required String statusLabel,
  }) {
    final resultList = List<ScrumTaskMoveResult>.unmodifiable(results);
    final blockedResults = resultList
        .where((result) => !result.accepted)
        .toList(growable: false);
    final changedTaskIds = [
      for (final result in resultList)
        if (result.changed) result.taskId,
    ];

    return BoardTaskMoveOutcome(
      results: resultList,
      blockedResults: blockedResults,
      changedTaskIds: changedTaskIds,
      message: blockedResults.isNotEmpty
          ? feedback.blockedMoveResults(blockedResults)
          : feedback.movedTasks(changedTaskIds.length, statusLabel),
    );
  }
}

/// UI-ready outcome of applying a bulk task move.
class BoardTaskMoveOutcome {
  const BoardTaskMoveOutcome({
    required this.results,
    required this.blockedResults,
    required this.changedTaskIds,
    required this.message,
  });

  /// Full results returned by the board controller.
  final List<ScrumTaskMoveResult> results;

  /// Results that were rejected while applying the move.
  final List<ScrumTaskMoveResult> blockedResults;

  /// Task ids whose selection should be cleared after a successful move.
  final List<String> changedTaskIds;

  /// Feedback message to show after applying the move.
  final String message;

  /// Whether any attempted move was blocked.
  bool get hasBlockedResults => blockedResults.isNotEmpty;
}
