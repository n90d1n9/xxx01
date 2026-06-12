import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/domain_pack_contract_coverage_filter.dart';
import '../models/domain_pack_contract_coverage_sort.dart';
import '../models/domain_pack_contract_coverage_view_state.dart';
import '../models/domain_pack_contract_domain_filter.dart';
import '../utils/billing_business_domain_pack_readiness.dart';
import '../utils/billing_business_domain_pack_remediation.dart';
import '../utils/billing_business_domain_packs.dart';
import '../utils/domain_pack_contract.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_empty_state.dart';
import 'billing_navigation_destination.dart';
import 'domain_pack_contract_action_strip.dart';
import 'domain_pack_contract_coverage_filter_bar.dart';
import 'domain_pack_contract_coverage_scope_summary.dart';
import 'domain_pack_contract_coverage_sort_menu.dart';
import 'domain_pack_contract_domain_filter.dart';
import 'domain_pack_contract_requirement_list.dart';

/// Diagnostics panel for auditing reusable billing domain-pack contracts.
class DomainPackContractCoveragePanel extends StatefulWidget {
  final DomainPackContractRegistryReport report;
  final BillingBusinessDomainPackRegistryRemediationPlan? remediationPlan;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;
  final DomainPackContractCoverageFilter? selectedFilter;
  final DomainPackContractCoverageFilter initialFilter;
  final ValueChanged<DomainPackContractCoverageFilter>? onFilterSelected;
  final DomainPackContractCoverageSort? selectedSort;
  final DomainPackContractCoverageSort initialSort;
  final ValueChanged<DomainPackContractCoverageSort>? onSortSelected;
  final DomainPackContractDomainFilterSelection? selectedDomainSelection;
  final DomainPackContractDomainFilterSelection initialDomainSelection;
  final ValueChanged<DomainPackContractDomainFilterSelection>? onDomainSelected;
  final int maxVisibleContracts;
  final int maxVisibleRequirements;
  final int maxVisibleActions;
  final bool showFilterBar;
  final bool showDomainFilter;
  final bool showSortMenu;
  final bool showScopeSummary;
  final bool showZeroFilters;
  final VoidCallback? onFiltersReset;

  const DomainPackContractCoveragePanel({
    super.key,
    required this.report,
    this.remediationPlan,
    this.onDestinationSelected,
    this.selectedFilter,
    this.initialFilter = DomainPackContractCoverageFilter.all,
    this.onFilterSelected,
    this.selectedSort,
    this.initialSort = DomainPackContractCoverageSort.registry,
    this.onSortSelected,
    this.selectedDomainSelection,
    this.initialDomainSelection =
        const DomainPackContractDomainFilterSelection.all(),
    this.onDomainSelected,
    this.maxVisibleContracts = 4,
    this.maxVisibleRequirements = 3,
    this.maxVisibleActions = 2,
    this.showFilterBar = true,
    this.showDomainFilter = true,
    this.showSortMenu = true,
    this.showScopeSummary = true,
    this.showZeroFilters = false,
    this.onFiltersReset,
  }) : assert(maxVisibleContracts > 0),
       assert(maxVisibleRequirements > 0),
       assert(maxVisibleActions > 0);

  @override
  State<DomainPackContractCoveragePanel> createState() {
    return _DomainPackContractCoveragePanelState();
  }
}

class _DomainPackContractCoveragePanelState
    extends State<DomainPackContractCoveragePanel> {
  late DomainPackContractCoverageFilter _selectedFilter;
  late DomainPackContractCoverageSort _selectedSort;
  late DomainPackContractDomainFilterSelection _selectedDomainSelection;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _selectedSort = widget.initialSort;
    _selectedDomainSelection = widget.initialDomainSelection;
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final viewState = DomainPackContractCoverageViewState.resolve(
      report: report,
      domainSelection:
          widget.selectedDomainSelection ?? _selectedDomainSelection,
      filter: widget.selectedFilter ?? _selectedFilter,
      sort: widget.selectedSort ?? _selectedSort,
      showZeroFilters: widget.showZeroFilters,
    );
    final visuals = _CoverageVisuals.fromReport(report);
    final visibleReports =
        viewState.visibleReports(widget.maxVisibleContracts).toList();
    final hiddenCount = viewState.hiddenCountAfter(visibleReports.length);

    return BillingReadinessPanelScaffold(
      title: 'Domain-pack contracts',
      summary: report.summaryLabel,
      icon: visuals.icon,
      iconColor: visuals.foreground,
      iconBackgroundColor: visuals.background,
      metrics: _contractMetrics(report),
      child: _buildCoverageContent(
        viewState: viewState,
        visibleReports: visibleReports,
        hiddenCount: hiddenCount,
      ),
    );
  }

  Widget _buildCoverageContent({
    required DomainPackContractCoverageViewState viewState,
    required List<DomainPackContractReport> visibleReports,
    required int hiddenCount,
  }) {
    if (widget.report.isEmpty) {
      return const BillingEmptyState(
        message: 'No domain-pack contracts are registered yet.',
        padding: EdgeInsets.all(14),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showDomainFilter ||
            widget.showFilterBar ||
            widget.showSortMenu) ...[
          _DomainPackContractCoverageControls(
            domainSummary: viewState.domainSummary,
            selectedDomainSelection: viewState.domainSelection,
            onDomainSelected: _handleDomainSelected,
            filterSummary: viewState.filterSummary,
            selectedFilter: viewState.filter,
            onFilterSelected: _handleFilterSelected,
            selectedSort: viewState.sort,
            onSortSelected: _handleSortSelected,
            showDomainFilter: widget.showDomainFilter,
            showFilterBar: widget.showFilterBar,
            showSortMenu: widget.showSortMenu,
            showZeroFilters: widget.showZeroFilters,
          ),
          const SizedBox(height: 14),
        ],
        if (widget.showScopeSummary) ...[
          DomainPackContractCoverageScopeSummary(
            viewState: viewState,
            onResetFilters: _handleFiltersReset,
          ),
          const SizedBox(height: 14),
        ],
        if (visibleReports.isEmpty)
          BillingEmptyState(
            message: viewState.emptyLabel,
            padding: const EdgeInsets.all(14),
          )
        else ...[
          for (final contractReport in visibleReports)
            DomainPackContractCoverageTile(
              report: contractReport,
              remediationPlan: widget.remediationPlan?.planForDomain(
                contractReport.domainKey,
              ),
              onDestinationSelected: widget.onDestinationSelected,
              maxVisibleRequirements: widget.maxVisibleRequirements,
              maxVisibleActions: widget.maxVisibleActions,
            ),
          if (hiddenCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '+$hiddenCount more domain-pack '
                '${_plural(hiddenCount, 'contract')} hidden',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ],
    );
  }

  void _handleFilterSelected(DomainPackContractCoverageFilter filter) {
    if (widget.selectedFilter == null) {
      setState(() {
        _selectedFilter = filter;
      });
    }
    widget.onFilterSelected?.call(filter);
  }

  void _handleDomainSelected(
    DomainPackContractDomainFilterSelection selection,
  ) {
    if (widget.selectedDomainSelection == null) {
      setState(() {
        _selectedDomainSelection = selection;
      });
    }
    widget.onDomainSelected?.call(selection);
  }

  void _handleSortSelected(DomainPackContractCoverageSort sort) {
    if (widget.selectedSort == null) {
      setState(() {
        _selectedSort = sort;
      });
    }
    widget.onSortSelected?.call(sort);
  }

  void _handleFiltersReset() {
    const domainSelection = DomainPackContractDomainFilterSelection.all();
    const filter = DomainPackContractCoverageFilter.all;
    const sort = DomainPackContractCoverageSort.registry;

    setState(() {
      if (widget.selectedDomainSelection == null) {
        _selectedDomainSelection = domainSelection;
      }
      if (widget.selectedFilter == null) {
        _selectedFilter = filter;
      }
      if (widget.selectedSort == null) {
        _selectedSort = sort;
      }
    });

    widget.onDomainSelected?.call(domainSelection);
    widget.onFilterSelected?.call(filter);
    widget.onSortSelected?.call(sort);
    widget.onFiltersReset?.call();
  }
}

class _DomainPackContractCoverageControls extends StatelessWidget {
  final DomainPackContractDomainFilterSummary domainSummary;
  final DomainPackContractDomainFilterSelection selectedDomainSelection;
  final ValueChanged<DomainPackContractDomainFilterSelection> onDomainSelected;
  final DomainPackContractCoverageFilterSummary filterSummary;
  final DomainPackContractCoverageFilter selectedFilter;
  final ValueChanged<DomainPackContractCoverageFilter> onFilterSelected;
  final DomainPackContractCoverageSort selectedSort;
  final ValueChanged<DomainPackContractCoverageSort> onSortSelected;
  final bool showDomainFilter;
  final bool showFilterBar;
  final bool showSortMenu;
  final bool showZeroFilters;

  const _DomainPackContractCoverageControls({
    required this.domainSummary,
    required this.selectedDomainSelection,
    required this.onDomainSelected,
    required this.filterSummary,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.selectedSort,
    required this.onSortSelected,
    required this.showDomainFilter,
    required this.showFilterBar,
    required this.showSortMenu,
    required this.showZeroFilters,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 920;
        final domainWidth = isWide ? 260.0 : constraints.maxWidth;
        final sortWidth = isWide ? 204.0 : constraints.maxWidth;
        final filterWidth =
            isWide && showFilterBar
                ? (constraints.maxWidth -
                        (showDomainFilter ? domainWidth + 12 : 0) -
                        (showSortMenu ? sortWidth + 12 : 0))
                    .clamp(280.0, constraints.maxWidth)
                    .toDouble()
                : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            if (showDomainFilter)
              SizedBox(
                width: domainWidth,
                child: DomainPackContractDomainFilter(
                  summary: domainSummary,
                  selectedSelection: selectedDomainSelection,
                  onSelectionSelected: onDomainSelected,
                ),
              ),
            if (showSortMenu)
              SizedBox(
                width: sortWidth,
                child: DomainPackContractCoverageSortMenu(
                  value: selectedSort,
                  onChanged: onSortSelected,
                ),
              ),
            if (showFilterBar)
              SizedBox(
                width: filterWidth,
                child: DomainPackContractCoverageFilterBar(
                  summary: filterSummary,
                  selectedFilter: selectedFilter,
                  onFilterSelected: onFilterSelected,
                  showZeroFilters: showZeroFilters,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Compact per-domain contract audit tile for billing domain packs.
class DomainPackContractCoverageTile extends StatelessWidget {
  final DomainPackContractReport report;
  final BillingBusinessDomainPackRemediationPlan? remediationPlan;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;
  final int maxVisibleRequirements;
  final int maxVisibleActions;

  const DomainPackContractCoverageTile({
    super.key,
    required this.report,
    this.remediationPlan,
    this.onDestinationSelected,
    this.maxVisibleRequirements = 3,
    this.maxVisibleActions = 2,
  }) : assert(maxVisibleRequirements > 0),
       assert(maxVisibleActions > 0);

  @override
  Widget build(BuildContext context) {
    final visuals = _CoverageVisuals.fromContract(report);
    final requirements =
        report.openRequirements.isEmpty
            ? report.requirements
            : report.openRequirements;
    final actions =
        remediationPlan?.actions ??
        const <BillingBusinessDomainPackRemediationAction>[];

    return Container(
      key: ValueKey('domain-pack-contract-coverage-${report.domainKey}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BillingReadinessStatusIcon(
                icon: visuals.icon,
                color: visuals.foreground,
                backgroundColor: visuals.background,
                size: 34,
                iconSize: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            report.domainLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ContractStatusBadge(visuals: visuals),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Pack ${report.packId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      report.summaryLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DomainPackContractRequirementList(
            requirements: requirements,
            maxVisibleRequirements: maxVisibleRequirements,
          ),
          if (actions.isNotEmpty && onDestinationSelected != null) ...[
            const SizedBox(height: 8),
            DomainPackContractActionStrip(
              actions: actions,
              onDestinationSelected: onDestinationSelected,
              maxVisibleActions: maxVisibleActions,
            ),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Domain pack contract coverage panel')
Widget domainPackContractCoveragePanelPreview() {
  final registryReadiness =
      BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
        standardBillingDomainPackRegistry(),
      );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: 680,
          child: DomainPackContractCoveragePanel(
            report: DomainPackContractRegistryReport.fromReadiness(
              registryReadiness,
            ),
            remediationPlan:
                BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
                  registryReadiness,
                ),
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    ),
  );
}

@Preview(name: 'Domain pack contract coverage tile')
Widget domainPackContractCoverageTilePreview() {
  final registryReadiness =
      BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
        standardBillingDomainPackRegistry(),
      );
  final contractReport = DomainPackContractRegistryReport.fromReadiness(
    registryReadiness,
  ).requireReportForDomain('commerce');
  final remediationPlan =
      BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
        registryReadiness,
      ).planForDomain('commerce');

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 620,
          child: DomainPackContractCoverageTile(
            report: contractReport,
            remediationPlan: remediationPlan,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    ),
  );
}

class _ContractStatusBadge extends StatelessWidget {
  final _CoverageVisuals visuals;

  const _ContractStatusBadge({required this.visuals});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 24, minWidth: 86),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: visuals.badgeBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: visuals.foreground.withValues(alpha: 0.14)),
      ),
      alignment: Alignment.center,
      child: Text(
        visuals.statusLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: visuals.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _CoverageVisuals {
  final String statusLabel;
  final IconData icon;
  final Color foreground;
  final Color background;
  final Color badgeBackground;

  const _CoverageVisuals({
    required this.statusLabel,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.badgeBackground,
  });

  factory _CoverageVisuals.fromReport(DomainPackContractRegistryReport report) {
    if (!report.isReleaseReady) {
      return _CoverageVisuals.needsAttention();
    }

    if (!report.isFullySpecified) {
      return _CoverageVisuals.releaseReady();
    }

    return _CoverageVisuals.fullySpecified();
  }

  factory _CoverageVisuals.fromContract(DomainPackContractReport report) {
    if (!report.isReleaseReady) {
      return _CoverageVisuals.needsAttention();
    }

    if (!report.isFullySpecified) {
      return _CoverageVisuals.releaseReady();
    }

    return _CoverageVisuals.fullySpecified();
  }

  factory _CoverageVisuals.needsAttention() {
    return const _CoverageVisuals(
      statusLabel: 'Needs attention',
      icon: Icons.assignment_late_outlined,
      foreground: Color(0xFFB91C1C),
      background: Color(0xFFFEE2E2),
      badgeBackground: Color(0xFFFEF2F2),
    );
  }

  factory _CoverageVisuals.releaseReady() {
    return const _CoverageVisuals(
      statusLabel: 'Release ready',
      icon: Icons.rule_folder_outlined,
      foreground: Color(0xFFB45309),
      background: Color(0xFFFEF3C7),
      badgeBackground: Color(0xFFFFFBEB),
    );
  }

  factory _CoverageVisuals.fullySpecified() {
    return const _CoverageVisuals(
      statusLabel: 'Fully specified',
      icon: Icons.verified_outlined,
      foreground: Color(0xFF047857),
      background: Color(0xFFD1FAE5),
      badgeBackground: Color(0xFFECFDF5),
    );
  }
}

List<BillingReadinessMetric> _contractMetrics(
  DomainPackContractRegistryReport report,
) {
  return [
    BillingReadinessMetric(
      label: 'Contracts',
      value: '${report.packReports.length}',
      icon: Icons.rule_folder_outlined,
      color: const Color(0xFF2563EB),
    ),
    BillingReadinessMetric(
      label: 'Open',
      value: '${report.openRequirementCount}',
      icon: Icons.pending_actions_outlined,
      color: const Color(0xFF7C3AED),
    ),
    BillingReadinessMetric(
      label: 'Blocked',
      value: '${report.blockedRequirementCount}',
      icon: Icons.error_outline,
      color: const Color(0xFFDC2626),
    ),
    BillingReadinessMetric(
      label: 'Hardening',
      value: '${report.warningRequirementCount}',
      icon: Icons.tune_outlined,
      color: const Color(0xFFD97706),
    ),
  ];
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
