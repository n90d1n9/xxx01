import '../models/scrum_board_config.dart';
import '../models/scrum_board_filter.dart';

/// Mutable presentation state for the active board filter.
class BoardFilterState {
  BoardFilterState({required ScrumBoardConfig config})
    : _filter = initialFilterFor(config);

  ScrumBoardFilter _filter;

  /// The active filter applied to board lanes and toolbar controls.
  ScrumBoardFilter get filter => _filter;

  /// Replaces the active filter after a toolbar or filter-bar interaction.
  void setFilter(ScrumBoardFilter filter) {
    _filter = filter;
  }

  /// Removes filter values that are no longer valid for the current config.
  void reconcileConfig(ScrumBoardConfig config) {
    final status = _filter.status;
    if (status != null && !config.includesStatus(status)) {
      _filter = _filter.withStatus(null);
    }
  }

  /// Builds the initial filter from a configured preset or status fallback.
  static ScrumBoardFilter initialFilterFor(ScrumBoardConfig config) {
    final initialPresetId = config.initialViewPresetId;
    if (initialPresetId != null) {
      final preset = config.presetById(initialPresetId);
      if (preset != null) return preset.filter;
    }

    final initialStatus = config.initialStatusFilter;
    if (initialStatus == null || !config.includesStatus(initialStatus)) {
      return const ScrumBoardFilter();
    }
    return ScrumBoardFilter(status: initialStatus);
  }
}
