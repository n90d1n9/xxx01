import 'accounting_menu_search.dart';
import 'accounting_workspace_role_preset.dart';
import 'accounting_workspace_work_queue_detail_section.dart';
import 'accounting_workspace_work_queue_focus.dart';
import 'accounting_workspace_work_queue_sort.dart';
import 'work_queue_resolution_filter.dart';
import 'work_queue_saved_view.dart';

/// Filters saved-view manager rows by the fields accountants remember.
List<AccountingWorkspaceWorkQueueSavedView>
filterWorkQueueSavedViewManagerViews({
  required Iterable<AccountingWorkspaceWorkQueueSavedView> views,
  required String query,
}) {
  final terms = _searchTerms(query);
  final viewList = views.toList(growable: false);
  if (terms.isEmpty) {
    return List<AccountingWorkspaceWorkQueueSavedView>.unmodifiable(viewList);
  }

  return List<AccountingWorkspaceWorkQueueSavedView>.unmodifiable([
    for (final view in viewList)
      if (workQueueSavedViewManagerViewMatchesQuery(view, terms)) view,
  ]);
}

/// Returns true when a saved view matches every normalized manager search term.
bool workQueueSavedViewManagerViewMatchesQuery(
  AccountingWorkspaceWorkQueueSavedView view,
  Iterable<String> terms,
) {
  final normalizedText = _normalizedViewSearchText(view);

  return terms.every(normalizedText.contains);
}

String _normalizedViewSearchText(AccountingWorkspaceWorkQueueSavedView view) {
  return [
    view.label,
    view.description,
    view.icon,
    view.rolePreset.label,
    view.rolePreset.shortLabel,
    view.rolePreset.storageValue,
    view.scope.label,
    view.scope.queryValue,
    _focusLabel(view.focus),
    view.focus.queryValue,
    view.sort.label,
    view.sort.queryValue,
    view.ownerFilter,
    view.resolutionFilter.label,
    view.resolutionFilter.storageValue,
    view.selectedQueueId,
    _detailSectionLabel(view.detailSection),
    view.detailSection.queryValue,
  ].whereType<String>().join(' ').toLowerCase();
}

List<String> _searchTerms(String query) {
  return query
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty)
      .toList(growable: false);
}

String _focusLabel(AccountingWorkspaceWorkQueueFocus focus) {
  switch (focus) {
    case AccountingWorkspaceWorkQueueFocus.all:
      return 'All';
    case AccountingWorkspaceWorkQueueFocus.blocked:
      return 'Blocked';
    case AccountingWorkspaceWorkQueueFocus.review:
      return 'Review';
    case AccountingWorkspaceWorkQueueFocus.monitor:
      return 'Monitor';
  }
}

String _detailSectionLabel(
  AccountingWorkspaceWorkQueueDetailSection detailSection,
) {
  switch (detailSection) {
    case AccountingWorkspaceWorkQueueDetailSection.overview:
      return 'Overview';
    case AccountingWorkspaceWorkQueueDetailSection.controls:
      return 'Controls';
    case AccountingWorkspaceWorkQueueDetailSection.request:
      return 'Request';
    case AccountingWorkspaceWorkQueueDetailSection.activity:
      return 'Activity';
  }
}
