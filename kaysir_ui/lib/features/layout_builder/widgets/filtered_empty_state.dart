import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_filtered_empty_state.dart';

class FilteredEmptyState extends AppFilteredEmptyState {
  const FilteredEmptyState({
    super.key,
    required super.title,
    super.icon = Icons.search_off_outlined,
    super.actionLabel = 'Clear filters',
    super.onAction,
  });
}
