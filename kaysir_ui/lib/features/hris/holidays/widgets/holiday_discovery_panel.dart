import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_filter_models.dart';
import '../models/holiday_models.dart';
import 'holiday_type_filter_bar.dart';

class HolidayDiscoveryPanel extends StatefulWidget {
  final String searchQuery;
  final HolidayCalendarQuickView selectedQuickView;
  final HolidayCalendarViewCounts viewCounts;
  final HolidayType? selectedType;
  final HolidaySummary summary;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<HolidayCalendarQuickView> onQuickViewChanged;
  final ValueChanged<HolidayType?> onTypeChanged;
  final VoidCallback onClearFilters;

  const HolidayDiscoveryPanel({
    super.key,
    required this.searchQuery,
    required this.selectedQuickView,
    required this.viewCounts,
    required this.selectedType,
    required this.summary,
    required this.onSearchChanged,
    required this.onQuickViewChanged,
    required this.onTypeChanged,
    required this.onClearFilters,
  });

  @override
  State<HolidayDiscoveryPanel> createState() => _HolidayDiscoveryPanelState();
}

class _HolidayDiscoveryPanelState extends State<HolidayDiscoveryPanel> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(HolidayDiscoveryPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
      _searchController.selection = TextSelection.collapsed(
        offset: _searchController.text.length,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        widget.searchQuery.trim().isNotEmpty ||
        widget.selectedQuickView != HolidayCalendarQuickView.all ||
        widget.selectedType != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: hrisPanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: HrisColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.manage_search_outlined,
                      color: HrisColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calendar discovery',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Find rules by date, scope, risk, or type',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: HrisColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final clearAction = TextButton.icon(
                onPressed: hasActiveFilters ? widget.onClearFilters : null,
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: const Text('Clear'),
              );

              if (constraints.maxWidth < 680) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading,
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerLeft, child: clearAction),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 16),
                  clearAction,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          TextField(
            key: const Key('holiday-search-field'),
            controller: _searchController,
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_outlined),
              hintText: 'Search holidays',
              suffixIcon:
                  widget.searchQuery.trim().isEmpty
                      ? null
                      : IconButton(
                        tooltip: 'Clear holiday search',
                        icon: const Icon(Icons.close_outlined),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                        },
                      ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final view in HolidayCalendarQuickView.values)
                FilterChip(
                  key: Key('holiday-view-${view.name}'),
                  avatar: Icon(_viewIcon(view), size: 18),
                  label: Text(
                    '${view.label} (${widget.viewCounts.countFor(view)})',
                  ),
                  selected: widget.selectedQuickView == view,
                  onSelected: (_) => widget.onQuickViewChanged(view),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Holiday types',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          HolidayTypeFilterBar(
            selectedType: widget.selectedType,
            summary: widget.summary,
            onChanged: widget.onTypeChanged,
          ),
        ],
      ),
    );
  }
}

IconData _viewIcon(HolidayCalendarQuickView view) {
  return switch (view) {
    HolidayCalendarQuickView.all => Icons.calendar_view_month_outlined,
    HolidayCalendarQuickView.upcoming => Icons.upcoming_outlined,
    HolidayCalendarQuickView.coverage => Icons.health_and_safety_outlined,
    HolidayCalendarQuickView.policyIssues => Icons.rule_folder_outlined,
    HolidayCalendarQuickView.unpaidCustom => Icons.money_off_csred_outlined,
  };
}
