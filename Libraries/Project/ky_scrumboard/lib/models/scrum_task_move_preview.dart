import 'scrum_task_move_result.dart';
import 'scrum_task_status.dart';

class ScrumTaskMovePreview {
  ScrumTaskMovePreview({
    required this.toStatus,
    required Iterable<ScrumTaskMoveResult> results,
  }) : results = List<ScrumTaskMoveResult>.unmodifiable(results);

  final ScrumTaskStatus toStatus;
  final List<ScrumTaskMoveResult> results;

  int get totalCount => results.length;

  int get acceptedCount => acceptedResults.length;

  int get changedCount => changedResults.length;

  int get blockedCount => blockedResults.length;

  int get unchangedCount => unchangedResults.length;

  bool get hasBlocks => blockedCount > 0;

  bool get canApply => changedCount > 0;

  List<ScrumTaskMoveResult> get acceptedResults {
    return results.where((result) => result.accepted).toList(growable: false);
  }

  List<ScrumTaskMoveResult> get changedResults {
    return results.where((result) => result.changed).toList(growable: false);
  }

  List<ScrumTaskMoveResult> get blockedResults {
    return results.where((result) => !result.accepted).toList(growable: false);
  }

  List<ScrumTaskMoveResult> get unchangedResults {
    return results
        .where((result) => result.accepted && !result.changed)
        .toList(growable: false);
  }
}
