import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

import '../models/project_portfolio_item.dart';
import '../services/project_portfolio_view_service.dart';
import '../services/project_priority_service.dart';

class ProjectHealthFilterSelect extends StatelessWidget {
  const ProjectHealthFilterSelect({
    required this.value,
    required this.onChanged,
    this.fieldKey,
    this.width = 180,
    super.key,
  });

  final ProjectHealth? value;
  final ValueChanged<ProjectHealth?> onChanged;
  final Key? fieldKey;
  final double width;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<String>(
      key: fieldKey,
      label: 'Health',
      value: value?.name ?? 'all',
      width: width,
      icon: Icons.monitor_heart_outlined,
      options: const [
        AppSelectOption(value: 'all', label: 'All Health'),
        AppSelectOption(value: 'onTrack', label: 'On Track'),
        AppSelectOption(value: 'atRisk', label: 'At Risk'),
        AppSelectOption(value: 'blocked', label: 'Blocked'),
      ],
      onChanged:
          (selected) => onChanged(
            selected == 'all'
                ? null
                : ProjectHealth.values.firstWhere(
                  (health) => health.name == selected,
                ),
          ),
    );
  }
}

class ProjectDomainReadinessFilterSelect extends StatelessWidget {
  const ProjectDomainReadinessFilterSelect({
    required this.value,
    required this.onChanged,
    this.fieldKey,
    this.width = 190,
    super.key,
  });

  final ProjectDomainReadinessFilter value;
  final ValueChanged<ProjectDomainReadinessFilter> onChanged;
  final Key? fieldKey;
  final double width;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<ProjectDomainReadinessFilter>(
      key: fieldKey,
      label: 'Domain',
      value: value,
      width: width,
      icon: Icons.extension_outlined,
      options: [
        for (final filter in ProjectDomainReadinessFilter.values)
          AppSelectOption(value: filter, label: filter.label),
      ],
      onChanged: onChanged,
    );
  }
}

class ProjectPortfolioSortSelect extends StatelessWidget {
  const ProjectPortfolioSortSelect({
    required this.value,
    required this.onChanged,
    this.fieldKey,
    this.width = 190,
    super.key,
  });

  final ProjectPortfolioSortOption value;
  final ValueChanged<ProjectPortfolioSortOption> onChanged;
  final Key? fieldKey;
  final double width;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<ProjectPortfolioSortOption>(
      key: fieldKey,
      label: 'Sort',
      value: value,
      width: width,
      icon: value.icon,
      options: [
        for (final option in ProjectPortfolioSortOption.values)
          AppSelectOption(value: option, label: option.label),
      ],
      onChanged: onChanged,
    );
  }
}
