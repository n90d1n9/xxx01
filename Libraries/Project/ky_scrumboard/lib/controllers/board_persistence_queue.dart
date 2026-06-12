/// Queues board persistence writes and tracks the latest persistence failure.
class BoardPersistenceQueue {
  Future<void> _pending = Future<void>.value();
  Object? _lastError;

  /// The current tail of the persistence queue.
  Future<void> get pending => _pending;

  /// The latest write or load failure reported by the board persistence layer.
  Object? get lastError => _lastError;

  /// Clears the tracked persistence failure.
  void clearError() {
    _lastError = null;
  }

  /// Stores a persistence failure from a caller-owned persistence operation.
  void setError(Object error) {
    _lastError = error;
  }

  /// Adds a write to the queue and reports error-state transitions.
  Future<void> queue(
    Future<void> Function() write, {
    void Function()? onErrorChanged,
  }) {
    final operation = _pending.then((_) => write());
    _pending = _track(operation, onErrorChanged);
    return _pending;
  }

  Future<void> _track(
    Future<void> operation,
    void Function()? onErrorChanged,
  ) async {
    try {
      await operation;
      if (_lastError != null) {
        _lastError = null;
        onErrorChanged?.call();
      }
    } catch (error) {
      _lastError = error;
      onErrorChanged?.call();
    }
  }
}
