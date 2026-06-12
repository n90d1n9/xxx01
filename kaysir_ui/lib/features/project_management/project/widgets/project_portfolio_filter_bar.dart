import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_search_field.dart';

import '../models/project_portfolio_item.dart';
import '../services/project_domain_gap_focus_service.dart';
import '../services/project_portfolio_view_service.dart';
import '../services/project_priority_service.dart';
import 'project_domain_gap_focus_select.dart';
import 'project_portfolio_filter_selects.dart';

class ProjectPortfolioFilterBar extends StatelessWidget {
  const ProjectPortfolioFilterBar({
    required this.searchController,
    required this.searchFocusNode,
    required this.searchHintText,
    required this.healthFilter,
    required this.domainReadinessFilter,
    required this.domainGapFocus,
    required this.sortOption,
    required this.onSearchChanged,
    required this.onHealthChanged,
    required this.onDomainReadinessChanged,
    required this.onDomainGapFocusChanged,
    required this.onSortChanged,
    this.leadingControls = const [],
    this.searchWidth = 260,
    this.healthWidth = 180,
    this.domainGapFieldKey,
    super.key,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final String searchHintText;
  final ProjectHealth? healthFilter;
  final ProjectDomainReadinessFilter domainReadinessFilter;
  final ProjectDomainGapFocus domainGapFocus;
  final ProjectPortfolioSortOption sortOption;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ProjectHealth?> onHealthChanged;
  final ValueChanged<ProjectDomainReadinessFilter> onDomainReadinessChanged;
  final ValueChanged<ProjectDomainGapFocus> onDomainGapFocusChanged;
  final ValueChanged<ProjectPortfolioSortOption> onSortChanged;
  final List<Widget> leadingControls;
  final double searchWidth;
  final double healthWidth;
  final Key? domainGapFieldKey;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...leadingControls,
        AppSearchField(
          hintText: searchHintText,
          controller: searchController,
          focusNode: searchFocusNode,
          width: searchWidth,
          onChanged: onSearchChanged,
        ),
        ProjectHealthFilterSelect(
          value: healthFilter,
          width: healthWidth,
          onChanged: onHealthChanged,
        ),
        ProjectDomainReadinessFilterSelect(
          value: domainReadinessFilter,
          onChanged: onDomainReadinessChanged,
        ),
        ProjectDomainGapFocusSelect(
          fieldKey: domainGapFieldKey,
          value: domainGapFocus,
          onChanged: onDomainGapFocusChanged,
        ),
        ProjectPortfolioSortSelect(value: sortOption, onChanged: onSortChanged),
      ],
    );
  }
}
