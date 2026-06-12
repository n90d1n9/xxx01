import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../history/history_manager_provider.dart';
import '../model/field_config.dart';
import 'form_field_provider.dart';

final filterManagerProvider = StateNotifierProvider<FilterManager, FilterState>(
  (ref) {
    return FilterManager();
  },
);

final showFilterPanelProvider = StateProvider<bool>((ref) => false);

final filteredFieldsProvider = Provider<List<FieldConfig>>((ref) {
  final fields = ref.watch(formFieldsProvider);
  final filterState = ref.watch(filterManagerProvider);

  if (!ref.read(filterManagerProvider.notifier).hasActiveFilters) {
    return fields;
  }

  return fields.where((field) => filterState.matchesField(field)).toList();
});

// Field type statistics
final fieldTypeStatsProvider = Provider<Map<String, int>>((ref) {
  final fields = ref.watch(formFieldsProvider);
  final stats = <String, int>{};

  for (final field in fields) {
    stats[field.type] = (stats[field.type] ?? 0) + 1;
  }

  return stats;
});

extension FormFieldsNotifierExtension on FormFieldsNotifier {}

class FilterManager extends StateNotifier<FilterState> {
  FilterManager() : super(FilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleFieldType(String type) {
    final newTypes = Set<String>.from(state.fieldTypes);
    if (newTypes.contains(type)) {
      newTypes.remove(type);
    } else {
      newTypes.add(type);
    }
    state = state.copyWith(fieldTypes: newTypes);
  }

  void setRequiredFilter(RequiredFilter filter) {
    state = state.copyWith(requiredFilter: filter);
  }

  void setValidationFilter(bool hasValidation) {
    state = state.copyWith(hasValidation: hasValidation);
  }

  void setContainerFilter(bool containersOnly) {
    state = state.copyWith(containersOnly: containersOnly);
  }

  void clearAllFilters() {
    state = FilterState();
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  bool get hasActiveFilters =>
      state.searchQuery.isNotEmpty ||
      state.fieldTypes.isNotEmpty ||
      state.requiredFilter != RequiredFilter.all ||
      state.hasValidation != null ||
      state.containersOnly;
}

enum RequiredFilter { all, required, optional }

class FilterState {
  final String searchQuery;
  final Set<String> fieldTypes;
  final RequiredFilter requiredFilter;
  final bool? hasValidation;
  final bool containersOnly;

  FilterState({
    this.searchQuery = '',
    this.fieldTypes = const {},
    this.requiredFilter = RequiredFilter.all,
    this.hasValidation,
    this.containersOnly = false,
  });

  FilterState copyWith({
    String? searchQuery,
    Set<String>? fieldTypes,
    RequiredFilter? requiredFilter,
    bool? hasValidation,
    bool? containersOnly,
  }) {
    return FilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      fieldTypes: fieldTypes ?? this.fieldTypes,
      requiredFilter: requiredFilter ?? this.requiredFilter,
      hasValidation: hasValidation ?? this.hasValidation,
      containersOnly: containersOnly ?? this.containersOnly,
    );
  }

  bool matchesField(FieldConfig field) {
    // Search query filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      final label = field.label?.toLowerCase() ?? '';
      final name = field.name?.toLowerCase() ?? '';
      final type = field.type.toLowerCase();
      final description = field.description?.toLowerCase() ?? '';

      if (!label.contains(query) &&
          !name.contains(query) &&
          !type.contains(query) &&
          !description.contains(query)) {
        return false;
      }
    }

    // Field type filter
    if (fieldTypes.isNotEmpty && !fieldTypes.contains(field.type)) {
      return false;
    }

    // Required filter
    if (requiredFilter == RequiredFilter.required && !field.required) {
      return false;
    }
    if (requiredFilter == RequiredFilter.optional && field.required) {
      return false;
    }

    // Validation filter
    if (hasValidation != null) {
      final fieldHasValidation =
          field.options is Map && (field.options as Map)['validation'] != null;
      if (hasValidation! && !fieldHasValidation) {
        return false;
      }
      if (!hasValidation! && fieldHasValidation) {
        return false;
      }
    }

    // Container filter
    if (containersOnly && !field.isContainer) {
      return false;
    }

    return true;
  }
}
