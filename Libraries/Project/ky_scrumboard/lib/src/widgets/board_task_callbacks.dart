/// Handles a task drop with an optional task id that the task should precede.
typedef ScrumTaskDropHandler =
    void Function(String taskId, String? beforeTaskId);

/// Handles selection changes for one task in a board lane.
typedef ScrumTaskSelectionHandler = void Function(String taskId, bool selected);

/// Handles selection changes for all visible tasks in a board lane.
typedef ScrumTaskBatchSelectionHandler =
    void Function(Iterable<String> taskIds, bool selected);
