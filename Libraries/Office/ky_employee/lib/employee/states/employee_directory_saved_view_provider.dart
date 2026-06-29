import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_saved_view_models.dart';
import 'employee_directory_provider.dart';
import 'employee_directory_quality_provider.dart';
import 'employee_directory_table_layout_provider.dart';
import 'employee_directory_table_provider.dart';

final employeeDirectorySavedViewsProvider = StateNotifierProvider<
  EmployeeDirectorySavedViewsNotifier,
  List<EmployeeDirectorySavedView>
>((ref) => EmployeeDirectorySavedViewsNotifier());

final employeeDirectorySavedViewDraftProvider = StateNotifierProvider<
  EmployeeDirectorySavedViewDraftNotifier,
  EmployeeDirectorySavedViewDraft
>((ref) => EmployeeDirectorySavedViewDraftNotifier());

final employeeDirectoryActiveSavedViewIdProvider = StateProvider<String?>(
  (ref) => null,
);

final employeeDirectoryActiveSavedViewProvider =
    Provider<EmployeeDirectorySavedView?>((ref) {
      final activeId = ref.watch(employeeDirectoryActiveSavedViewIdProvider);
      if (activeId == null) return null;

      return ref
          .watch(employeeDirectorySavedViewsProvider)
          .where((view) => view.id == activeId)
          .firstOrNull;
    });

final employeeDirectorySavedViewControllerProvider =
    Provider<EmployeeDirectorySavedViewController>(
      EmployeeDirectorySavedViewController.new,
    );

class EmployeeDirectorySavedViewsNotifier
    extends StateNotifier<List<EmployeeDirectorySavedView>> {
  EmployeeDirectorySavedViewsNotifier() : super(const []);

  void add(EmployeeDirectorySavedView view) {
    state = [...state, view]..sort(_compareSavedViews);
  }

  void remove(String viewId) {
    state = state.where((view) => view.id != viewId).toList();
  }
}

class EmployeeDirectorySavedViewDraftNotifier
    extends StateNotifier<EmployeeDirectorySavedViewDraft> {
  EmployeeDirectorySavedViewDraftNotifier()
    : super(const EmployeeDirectorySavedViewDraft());

  void setName(String value) {
    state = state.copyWith(name: value);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value);
  }

  void setPinned(bool value) {
    state = state.copyWith(pinned: value);
  }

  void clear() {
    state = const EmployeeDirectorySavedViewDraft();
  }
}

class EmployeeDirectorySavedViewController {
  final Ref _ref;

  const EmployeeDirectorySavedViewController(this._ref);

  EmployeeDirectorySavedViewSaveResult saveCurrentView() {
    final draft = _ref.read(employeeDirectorySavedViewDraftProvider);
    final savedViews = _ref.read(employeeDirectorySavedViewsProvider);
    final errors = draft.validationErrors(savedViews);
    if (errors.isNotEmpty) {
      return EmployeeDirectorySavedViewSaveResult.failure(errors);
    }

    final view = EmployeeDirectorySavedView(
      id: _nextSavedViewId(savedViews),
      name: draft.trimmedName,
      description:
          draft.trimmedDescription.isEmpty
              ? 'Captured from the current employee directory view.'
              : draft.trimmedDescription,
      searchQuery: _ref.read(employeeDirectorySearchQueryProvider),
      selectedDepartment: _ref.read(
        employeeDirectorySelectedDepartmentProvider,
      ),
      highPerformerOnly: _ref.read(employeeDirectoryHighPerformerOnlyProvider),
      statusFilter: _ref.read(employeeDirectoryTableStatusFilterProvider),
      qualityFilter: _ref.read(employeeDirectoryQualityFilterProvider),
      sort: _ref.read(employeeDirectoryTableSortProvider),
      layout: _ref.read(employeeDirectoryTableLayoutProvider),
      pinned: draft.pinned,
      capturedAt: _ref.read(employeeDirectoryAsOfDateProvider),
    );

    _ref.read(employeeDirectorySavedViewsProvider.notifier).add(view);
    _ref.read(employeeDirectorySavedViewDraftProvider.notifier).clear();
    _ref.read(employeeDirectoryTableActivePresetProvider.notifier).state = null;
    _ref.read(employeeDirectoryActiveSavedViewIdProvider.notifier).state =
        view.id;
    _ref.read(employeeDirectoryTableSelectedIdsProvider.notifier).clear();

    return EmployeeDirectorySavedViewSaveResult.success(view);
  }

  void apply(EmployeeDirectorySavedView view) {
    _ref.read(employeeDirectorySearchQueryProvider.notifier).state =
        view.searchQuery;
    _ref.read(employeeDirectorySelectedDepartmentProvider.notifier).state =
        view.selectedDepartment;
    _ref.read(employeeDirectoryHighPerformerOnlyProvider.notifier).state =
        view.highPerformerOnly;
    _ref.read(employeeDirectoryTableStatusFilterProvider.notifier).state =
        view.statusFilter;
    _ref.read(employeeDirectoryQualityFilterProvider.notifier).state =
        view.qualityFilter;
    _ref.read(employeeDirectoryTableSortProvider.notifier).state = view.sort;
    _ref
        .read(employeeDirectoryTableLayoutProvider.notifier)
        .setLayout(view.layout);
    _ref.read(employeeDirectoryTableSelectedIdsProvider.notifier).clear();
    _ref.read(employeeDirectoryTableActivePresetProvider.notifier).state = null;
    _ref.read(employeeDirectoryActiveSavedViewIdProvider.notifier).state =
        view.id;
  }

  void delete(String viewId) {
    _ref.read(employeeDirectorySavedViewsProvider.notifier).remove(viewId);
    if (_ref.read(employeeDirectoryActiveSavedViewIdProvider) == viewId) {
      clearActive();
    }
  }

  void clearActive() {
    _ref.read(employeeDirectoryActiveSavedViewIdProvider.notifier).state = null;
  }
}

int _compareSavedViews(
  EmployeeDirectorySavedView first,
  EmployeeDirectorySavedView second,
) {
  if (first.pinned != second.pinned) {
    return first.pinned ? -1 : 1;
  }
  return first.name.toLowerCase().compareTo(second.name.toLowerCase());
}

String _nextSavedViewId(List<EmployeeDirectorySavedView> savedViews) {
  final existingIds = savedViews.map((view) => view.id).toSet();
  var index = savedViews.length + 1;
  var id = 'custom-view-$index';
  while (existingIds.contains(id)) {
    index += 1;
    id = 'custom-view-$index';
  }
  return id;
}
