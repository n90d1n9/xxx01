import '../../models/scrum_task_status.dart';

/// Handles task creation requests from board lanes.
typedef ScrumTaskCreateRequest = void Function({ScrumTaskStatus? status});

/// Handles collapse state changes for one board lane.
typedef ScrumColumnCollapseChanged =
    void Function(ScrumTaskStatus status, bool collapsed);

/// Handles bulk collapse state changes for the currently visible lanes.
typedef ScrumVisibleColumnsCollapseChanged =
    void Function(Iterable<ScrumTaskStatus> statuses, bool collapsed);
