import 'package:flutter/material.dart';

import '../states/billing_diagnostics_release_profile_filter_provider.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_navigation_destination.dart';
import 'diagnostics_release_profile_saved_view.dart';
import 'diagnostics_release_profile_saved_view_registry.dart';
import 'release_profile_contract_coverage.dart';
import 'release_profile_contract_list.dart';
import 'release_profile_domain_filter.dart';
import 'release_profile_filter_summary.dart';
import 'release_profile_status_filter.dart';

/// Summarizes release profile contract coverage for the billing diagnostics
/// workspace, including domain fit, registry counts, and drill-down details.
class BillingReleaseWorkspaceProfileContractCoveragePanel
    extends StatefulWidget {
  final BillingReleaseWorkspaceProfileContractCoverage coverage;
  final String? focusedBusinessDomain;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;
  final int maxVisibleProfiles;
  final BillingReleaseProfileStatusFilterOption initialStatusOption;
  final BillingReleaseProfileStatusFilterOption? selectedStatusOption;
  final ValueChanged<BillingReleaseProfileStatusFilterOption>?
  onStatusOptionSelected;
  final bool showZeroStatusOptions;
  final BillingReleaseProfileDomainFilterSelection initialDomainSelection;
  final BillingReleaseProfileDomainFilterSelection? selectedDomainSelection;
  final ValueChanged<BillingReleaseProfileDomainFilterSelection>?
  onDomainSelectionSelected;
  final BillingDiagnosticsReleaseProfileSavedViewRegistry
  releaseProfileSavedViewRegistry;
  final List<BillingDiagnosticsReleaseProfileSavedView>?
  releaseProfileSavedViews;
  final bool showReleaseProfileSavedViewBar;

  const BillingReleaseWorkspaceProfileContractCoveragePanel({
    super.key,
    required this.coverage,
    this.focusedBusinessDomain,
    this.onDestinationSelected,
    this.maxVisibleProfiles = 3,
    this.initialStatusOption = BillingReleaseProfileStatusFilterOption.all,
    this.selectedStatusOption,
    this.onStatusOptionSelected,
    this.showZeroStatusOptions = false,
    this.initialDomainSelection =
        const BillingReleaseProfileDomainFilterSelection.all(),
    this.selectedDomainSelection,
    this.onDomainSelectionSelected,
    this.releaseProfileSavedViewRegistry =
        standardBillingDiagnosticsReleaseProfileSavedViewRegistry,
    this.releaseProfileSavedViews,
    this.showReleaseProfileSavedViewBar = true,
  });

  @override
  State<BillingReleaseWorkspaceProfileContractCoveragePanel> createState() =>
      _BillingReleaseWorkspaceProfileContractCoveragePanelState();
}

class _BillingReleaseWorkspaceProfileContractCoveragePanelState
    extends State<BillingReleaseWorkspaceProfileContractCoveragePanel> {
  late BillingReleaseProfileStatusFilterOption _localStatusOption;
  late BillingReleaseProfileDomainFilterSelection _localDomainSelection;

  bool get _isStatusOptionControlled => widget.selectedStatusOption != null;

  bool get _isDomainSelectionControlled =>
      widget.selectedDomainSelection != null;

  BillingReleaseProfileStatusFilterOption get _rawStatusOption {
    return widget.selectedStatusOption ?? _localStatusOption;
  }

  BillingReleaseProfileDomainFilterSelection get _rawDomainSelection {
    return widget.selectedDomainSelection ?? _localDomainSelection;
  }

  @override
  void initState() {
    super.initState();
    _localStatusOption = widget.initialStatusOption;
    _localDomainSelection = widget.initialDomainSelection;
  }

  @override
  void didUpdateWidget(
    covariant BillingReleaseWorkspaceProfileContractCoveragePanel oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (!_isStatusOptionControlled &&
        oldWidget.initialStatusOption != widget.initialStatusOption) {
      _localStatusOption = widget.initialStatusOption;
    }

    if (!_isStatusOptionControlled) {
      _localStatusOption = _localStatusOption.resolveFor(
        widget.coverage.statusSummary,
        showZeroStatuses: widget.showZeroStatusOptions,
      );
    }

    if (!_isDomainSelectionControlled &&
        oldWidget.initialDomainSelection != widget.initialDomainSelection) {
      _localDomainSelection = widget.initialDomainSelection;
    }

    if (!_isDomainSelectionControlled) {
      _localDomainSelection = _localDomainSelection.resolveFor(widget.coverage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final focus = _focusedDomainCoverage();
    final statusSummary = widget.coverage.statusSummary;
    final selectedStatusOption = _rawStatusOption.resolveFor(
      statusSummary,
      showZeroStatuses: widget.showZeroStatusOptions,
    );
    final selectedDomainSelection = _rawDomainSelection.resolveFor(
      widget.coverage,
    );
    final selectedFilterState = BillingDiagnosticsReleaseProfileFilterState(
      statusOption: selectedStatusOption,
      domainSelection: selectedDomainSelection,
    );
    final hasActiveFilter =
        selectedStatusOption != BillingReleaseProfileStatusFilterOption.all ||
        !selectedDomainSelection.isAll;

    return BillingReadinessFrame(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.dashboard_customize_outlined,
                  color: Color(0xFF0F766E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Release profile coverage',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.coverage.summaryLabel,
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
          const SizedBox(height: 14),
          BillingReadinessMetricStrip(
            metrics: _coverageMetrics(widget.coverage),
          ),
          if (!statusSummary.isEmpty) ...[
            const SizedBox(height: 12),
            if (widget.showReleaseProfileSavedViewBar) ...[
              BillingDiagnosticsReleaseProfileSavedViewBar(
                coverage: widget.coverage,
                focusedBusinessDomain: widget.focusedBusinessDomain,
                selectedState: selectedFilterState,
                views:
                    widget.releaseProfileSavedViews ??
                    widget.releaseProfileSavedViewRegistry.views,
                onSelected: _selectSavedView,
              ),
              const SizedBox(height: 12),
            ],
            BillingReleaseProfileStatusFilter(
              summary: statusSummary,
              selectedOption: selectedStatusOption,
              onOptionSelected: _selectStatusOption,
              showZeroStatuses: widget.showZeroStatusOptions,
            ),
            const SizedBox(height: 10),
            BillingReleaseProfileDomainFilter(
              coverage: widget.coverage,
              selectedSelection: selectedDomainSelection,
              onSelectionSelected: _selectDomainSelection,
            ),
            const SizedBox(height: 8),
            BillingReleaseProfileFilterSummary(
              coverage: widget.coverage,
              selectedOption: selectedStatusOption,
              focusedBusinessDomain: widget.focusedBusinessDomain,
              filteredBusinessDomain: selectedDomainSelection.domainKey,
              onClearFilter: hasActiveFilter ? _clearFilters : null,
            ),
          ],
          if (focus != null) ...[
            const SizedBox(height: 12),
            _FocusedDomainCoverageBanner(
              focus: focus,
              onDestinationSelected: widget.onDestinationSelected,
            ),
          ],
          const SizedBox(height: 12),
          _CoverageCustomizationBanner(coverage: widget.coverage),
          if (!widget.coverage.isEmpty) ...[
            const SizedBox(height: 12),
            BillingReleaseWorkspaceProfileContractList(
              coverage: widget.coverage,
              focusedBusinessDomain: widget.focusedBusinessDomain,
              maxVisibleProfiles: widget.maxVisibleProfiles,
              includedStatuses: selectedStatusOption.includedStatuses,
              filteredBusinessDomain: selectedDomainSelection.domainKey,
              emptyLabel: selectedStatusOption.emptyLabel,
            ),
          ],
        ],
      ),
    );
  }

  void _selectStatusOption(BillingReleaseProfileStatusFilterOption option) {
    widget.onStatusOptionSelected?.call(option);

    if (_isStatusOptionControlled) return;

    setState(() => _localStatusOption = option);
  }

  void _selectDomainSelection(
    BillingReleaseProfileDomainFilterSelection selection,
  ) {
    widget.onDomainSelectionSelected?.call(selection);

    if (_isDomainSelectionControlled) return;

    setState(() => _localDomainSelection = selection);
  }

  void _selectSavedView(BillingDiagnosticsReleaseProfileFilterState state) {
    widget.onStatusOptionSelected?.call(state.statusOption);
    widget.onDomainSelectionSelected?.call(state.domainSelection);

    if (_isStatusOptionControlled && _isDomainSelectionControlled) return;

    setState(() {
      if (!_isStatusOptionControlled) {
        _localStatusOption = state.statusOption;
      }
      if (!_isDomainSelectionControlled) {
        _localDomainSelection = state.domainSelection;
      }
    });
  }

  void _clearFilters() {
    _selectStatusOption(BillingReleaseProfileStatusFilterOption.all);
    _selectDomainSelection(
      const BillingReleaseProfileDomainFilterSelection.all(),
    );
  }

  BillingReleaseWorkspaceFocusedDomainCoverage? _focusedDomainCoverage() {
    final domain = widget.focusedBusinessDomain?.trim();
    if (domain == null || domain.isEmpty) return null;

    return widget.coverage.focusedDomain(domain);
  }
}

List<BillingReadinessMetric> _coverageMetrics(
  BillingReleaseWorkspaceProfileContractCoverage coverage,
) {
  return [
    BillingReadinessMetric(
      label: 'Profiles',
      value: '${coverage.profileCount}',
      icon: Icons.layers_outlined,
      color: const Color(0xFF2563EB),
    ),
    BillingReadinessMetric(
      label: 'Domains',
      value: '${coverage.domainCount}',
      icon: Icons.domain_outlined,
      color: const Color(0xFF0F766E),
    ),
    BillingReadinessMetric(
      label: 'Deck slots',
      value: '${coverage.deckRegistrationCount}',
      icon: Icons.view_agenda_outlined,
      color: const Color(0xFF7C3AED),
    ),
    BillingReadinessMetric(
      label: 'Saved views',
      value: '${coverage.savedViewRegistrationCount}',
      icon: Icons.bookmarks_outlined,
      color: const Color(0xFFD97706),
    ),
  ];
}

/// Highlights whether the active coverage set is pure standard baseline or
/// includes domain-specific release workspace customizations.
class _CoverageCustomizationBanner extends StatelessWidget {
  final BillingReleaseWorkspaceProfileContractCoverage coverage;

  const _CoverageCustomizationBanner({required this.coverage});

  @override
  Widget build(BuildContext context) {
    final color =
        coverage.hasCustomizations
            ? const Color(0xFF7C3AED)
            : const Color(0xFF059669);
    final icon =
        coverage.hasCustomizations
            ? Icons.extension_outlined
            : Icons.verified_outlined;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              coverage.customizationLabel,
              style: TextStyle(
                color: color,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows whether the current tenant business domain has a dedicated release
/// profile or must use the standard fallback contract.
class _FocusedDomainCoverageBanner extends StatelessWidget {
  final BillingReleaseWorkspaceFocusedDomainCoverage focus;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const _FocusedDomainCoverageBanner({
    required this.focus,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final action = focus.remediationAction;
    final color =
        focus.isCovered ? const Color(0xFF059669) : const Color(0xFFD97706);
    final background =
        focus.isCovered ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB);
    final icon =
        focus.isCovered
            ? Icons.check_circle_outline
            : Icons.info_outline_rounded;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${focus.domainLabel} · ${focus.statusLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  focus.summaryLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    action.detail,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (onDestinationSelected != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        key: ValueKey(
                          'billing-release-profile-coverage-open-${action.id}',
                        ),
                        onPressed:
                            () => onDestinationSelected?.call(
                              BillingNavigationDestinationId.diagnostics,
                            ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('Open diagnostics'),
                        style: TextButton.styleFrom(
                          foregroundColor: color,
                          minimumSize: const Size(0, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
