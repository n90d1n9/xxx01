import 'board_persistence_writer.dart';

/// Coordinates repository load lifecycle, loading state, and load errors.
class BoardLoadCoordinator {
  BoardLoadCoordinator({
    required BoardPersistenceWriter persistenceWriter,
    void Function()? onLoadingChanged,
  }) : _persistenceWriter = persistenceWriter,
       _onLoadingChanged = onLoadingChanged;

  final BoardPersistenceWriter _persistenceWriter;
  final void Function()? _onLoadingChanged;
  bool _isLoading = false;

  /// Whether a repository load is currently in progress.
  bool get isLoading => _isLoading;

  /// Loads a value, applies it, and tracks load errors through persistence state.
  Future<void> load<T>(
    Future<T> Function() read, {
    required void Function(T value) apply,
  }) async {
    _isLoading = true;
    _persistenceWriter.clearError();
    _onLoadingChanged?.call();

    try {
      final value = await read();
      apply(value);
    } catch (error) {
      _persistenceWriter.setError(error);
      rethrow;
    } finally {
      _isLoading = false;
      _onLoadingChanged?.call();
    }
  }
}
