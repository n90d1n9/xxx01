import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/domain_pack_contract_coverage_filter.dart';
import '../utils/billing_business_domain_packs.dart';
import '../utils/domain_pack_contract.dart';

/// Segmented filter for focusing billing domain-pack contract coverage.
class DomainPackContractCoverageFilterBar extends StatelessWidget {
  final DomainPackContractCoverageFilterSummary summary;
  final DomainPackContractCoverageFilter selectedFilter;
  final ValueChanged<DomainPackContractCoverageFilter> onFilterSelected;
  final bool showZeroFilters;

  const DomainPackContractCoverageFilterBar({
    super.key,
    required this.summary,
    required this.selectedFilter,
    required this.onFilterSelected,
    this.showZeroFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox.shrink();

    final filters = domainPackContractCoverageFilterOptions(
      summary,
      showZeroFilters: showZeroFilters,
    );
    final resolvedFilter = selectedFilter.resolveFor(
      summary,
      showZeroFilters: showZeroFilters,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contract focus',
          style: TextStyle(
            color: Color(0xFF334155),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<DomainPackContractCoverageFilter>(
            showSelectedIcon: false,
            segments: [
              for (final filter in filters)
                ButtonSegment(
                  value: filter,
                  icon: Icon(_filterIcon(filter)),
                  label: Text(filter.labelFor(summary)),
                  tooltip: filter.tooltipFor(summary),
                ),
            ],
            selected: {resolvedFilter},
            onSelectionChanged: (selection) {
              if (selection.isEmpty) return;
              onFilterSelected(selection.first);
            },
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Domain pack contract coverage filter bar')
Widget domainPackContractCoverageFilterBarPreview() {
  final summary = DomainPackContractCoverageFilterSummary.fromRegistryReport(
    DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    ),
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: DomainPackContractCoverageFilterBar(
          summary: summary,
          selectedFilter: DomainPackContractCoverageFilter.hardening,
          onFilterSelected: (_) {},
          showZeroFilters: true,
        ),
      ),
    ),
  );
}

IconData _filterIcon(DomainPackContractCoverageFilter filter) {
  return switch (filter) {
    DomainPackContractCoverageFilter.all => Icons.filter_list_outlined,
    DomainPackContractCoverageFilter.blocked => Icons.error_outline,
    DomainPackContractCoverageFilter.hardening => Icons.tune_outlined,
    DomainPackContractCoverageFilter.complete => Icons.verified_outlined,
  };
}
