import 'package:flutter/material.dart';
import 'package:ky_admin/widgets/admin_toolbar_select.dart';

import '../states/dashboard_provider.dart';

const _dashboardFilterOptions = [
  AdminToolbarSelectOption<String>(
    value: DashboardFilters.thisWeek,
    label: DashboardFilters.thisWeek,
  ),
  AdminToolbarSelectOption<String>(
    value: DashboardFilters.lastWeek,
    label: DashboardFilters.lastWeek,
  ),
  AdminToolbarSelectOption<String>(
    value: DashboardFilters.thisMonth,
    label: DashboardFilters.thisMonth,
  ),
  AdminToolbarSelectOption<String>(
    value: DashboardFilters.lastMonth,
    label: DashboardFilters.lastMonth,
  ),
];

class FilterDropdown extends StatelessWidget {
  final Function(String) onChanged;
  final String initialValue;

  const FilterDropdown({
    super.key,
    required this.onChanged,
    required this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return AdminToolbarSelect<String>(
      label: 'Period',
      icon: Icons.calendar_month_outlined,
      value: initialValue,
      width: 220,
      options: _dashboardFilterOptions,
      onChanged: onChanged,
    );
  }
}
