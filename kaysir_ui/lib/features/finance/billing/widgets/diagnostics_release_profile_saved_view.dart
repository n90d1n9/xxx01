import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_business_domain_profile.dart';
import '../states/billing_diagnostics_release_profile_filter_provider.dart';
import 'release_profile_contract_coverage.dart';
import 'release_profile_domain_filter.dart';
import 'release_profile_status_filter.dart';
import 'standard_release_workspace_profiles.dart';

const billingDiagnosticsReleaseProfileAllSavedViewId = 'all-profiles';
const billingDiagnosticsReleaseProfileCurrentDomainSavedViewId =
    'current-domain';
const billingDiagnosticsReleaseProfileStandardSavedViewId = 'standard-profiles';
const billingDiagnosticsReleaseProfileExtendedSavedViewId = 'extended-profiles';
const billingDiagnosticsReleaseProfileConstrainedSavedViewId =
    'constrained-profiles';
const billingDiagnosticsReleaseProfileTailoredSavedViewId = 'tailored-profiles';

/// Domain scoping behavior for a diagnostics release profile saved view.
enum BillingDiagnosticsReleaseProfileSavedViewDomainScope {
  all,
  focusedBusinessDomain,
}

/// Saved diagnostics filter preset for release workspace profile contracts.
class BillingDiagnosticsReleaseProfileSavedView {
  final String id;
  final String label;
  final String description;
  final BillingReleaseProfileStatusFilterOption statusOption;
  final BillingDiagnosticsReleaseProfileSavedViewDomainScope domainScope;
  final IconData icon;
  final Color accentColor;

  const BillingDiagnosticsReleaseProfileSavedView({
    required this.id,
    required this.label,
    required this.description,
    this.statusOption = BillingReleaseProfileStatusFilterOption.all,
    this.domainScope = BillingDiagnosticsReleaseProfileSavedViewDomainScope.all,
    this.icon = Icons.bookmark_border_rounded,
    this.accentColor = const Color(0xFF334155),
  });

  BillingDiagnosticsReleaseProfileFilterState resolve({
    String? focusedBusinessDomain,
  }) {
    return BillingDiagnosticsReleaseProfileFilterState(
      statusOption: statusOption,
      domainSelection: _domainSelection(focusedBusinessDomain),
    );
  }

  bool matchesState(
    BillingDiagnosticsReleaseProfileFilterState state, {
    String? focusedBusinessDomain,
  }) {
    return resolve(focusedBusinessDomain: focusedBusinessDomain) == state;
  }

  bool isAvailable(
    BillingReleaseWorkspaceProfileContractCoverage coverage, {
    String? focusedBusinessDomain,
  }) {
    if (coverage.isEmpty) return false;

    final state = resolve(focusedBusinessDomain: focusedBusinessDomain);
    if (domainScope ==
            BillingDiagnosticsReleaseProfileSavedViewDomainScope
                .focusedBusinessDomain &&
        state.domainSelection.isAll) {
      return false;
    }

    return count(coverage, focusedBusinessDomain: focusedBusinessDomain) > 0;
  }

  int count(
    BillingReleaseWorkspaceProfileContractCoverage coverage, {
    String? focusedBusinessDomain,
  }) {
    final state = resolve(focusedBusinessDomain: focusedBusinessDomain);

    return coverage
        .prioritizedContracts(
          includedStatuses: state.statusOption.includedStatuses,
          scopedBusinessDomain: state.domainSelection.domainKey,
        )
        .length;
  }

  BillingReleaseProfileDomainFilterSelection _domainSelection(
    String? focusedBusinessDomain,
  ) {
    if (domainScope ==
        BillingDiagnosticsReleaseProfileSavedViewDomainScope.all) {
      return const BillingReleaseProfileDomainFilterSelection.all();
    }

    final key = billingBusinessDomainKey(focusedBusinessDomain ?? '');
    if (key.isEmpty) {
      return const BillingReleaseProfileDomainFilterSelection.all();
    }

    return BillingReleaseProfileDomainFilterSelection.domain(key);
  }
}

const billingDiagnosticsReleaseProfileAllSavedView =
    BillingDiagnosticsReleaseProfileSavedView(
      id: billingDiagnosticsReleaseProfileAllSavedViewId,
      label: 'All profiles',
      description: 'Show every release workspace profile contract',
      icon: Icons.layers_outlined,
      accentColor: Color(0xFF334155),
    );

const billingDiagnosticsReleaseProfileCurrentDomainSavedView =
    BillingDiagnosticsReleaseProfileSavedView(
      id: billingDiagnosticsReleaseProfileCurrentDomainSavedViewId,
      label: 'Current domain',
      description: 'Show profiles that cover the selected billing domain',
      domainScope:
          BillingDiagnosticsReleaseProfileSavedViewDomainScope
              .focusedBusinessDomain,
      icon: Icons.domain_outlined,
      accentColor: Color(0xFF0F766E),
    );

const billingDiagnosticsReleaseProfileStandardSavedView =
    BillingDiagnosticsReleaseProfileSavedView(
      id: billingDiagnosticsReleaseProfileStandardSavedViewId,
      label: 'Standard profiles',
      description: 'Show profiles that use the standard release workspace',
      statusOption: BillingReleaseProfileStatusFilterOption.standard,
      icon: Icons.verified_outlined,
      accentColor: Color(0xFF2563EB),
    );

const billingDiagnosticsReleaseProfileExtendedSavedView =
    BillingDiagnosticsReleaseProfileSavedView(
      id: billingDiagnosticsReleaseProfileExtendedSavedViewId,
      label: 'Extended profiles',
      description: 'Show profiles with domain-specific release extensions',
      statusOption: BillingReleaseProfileStatusFilterOption.extended,
      icon: Icons.extension_outlined,
      accentColor: Color(0xFF7C3AED),
    );

const billingDiagnosticsReleaseProfileConstrainedSavedView =
    BillingDiagnosticsReleaseProfileSavedView(
      id: billingDiagnosticsReleaseProfileConstrainedSavedViewId,
      label: 'Constrained profiles',
      description: 'Show profiles with hidden standard release decks',
      statusOption: BillingReleaseProfileStatusFilterOption.constrained,
      icon: Icons.block_outlined,
      accentColor: Color(0xFFDC2626),
    );

const billingDiagnosticsReleaseProfileTailoredSavedView =
    BillingDiagnosticsReleaseProfileSavedView(
      id: billingDiagnosticsReleaseProfileTailoredSavedViewId,
      label: 'Tailored profiles',
      description: 'Show profiles with both custom additions and constraints',
      statusOption: BillingReleaseProfileStatusFilterOption.tailored,
      icon: Icons.tune_outlined,
      accentColor: Color(0xFFEA580C),
    );

const billingDiagnosticsReleaseProfileDefaultSavedViews =
    <BillingDiagnosticsReleaseProfileSavedView>[
      billingDiagnosticsReleaseProfileAllSavedView,
      billingDiagnosticsReleaseProfileCurrentDomainSavedView,
      billingDiagnosticsReleaseProfileStandardSavedView,
      billingDiagnosticsReleaseProfileExtendedSavedView,
      billingDiagnosticsReleaseProfileConstrainedSavedView,
      billingDiagnosticsReleaseProfileTailoredSavedView,
    ];

/// Returns saved views that can produce visible release profile contracts.
List<BillingDiagnosticsReleaseProfileSavedView>
billingDiagnosticsReleaseProfileSavedViewsFor({
  required BillingReleaseWorkspaceProfileContractCoverage coverage,
  String? focusedBusinessDomain,
  Iterable<BillingDiagnosticsReleaseProfileSavedView> views =
      billingDiagnosticsReleaseProfileDefaultSavedViews,
}) {
  return List.unmodifiable(
    views.where(
      (view) => view.isAvailable(
        coverage,
        focusedBusinessDomain: focusedBusinessDomain,
      ),
    ),
  );
}

/// Horizontal selector for reusable diagnostics release profile filter presets.
class BillingDiagnosticsReleaseProfileSavedViewBar extends StatelessWidget {
  final BillingReleaseWorkspaceProfileContractCoverage coverage;
  final BillingDiagnosticsReleaseProfileFilterState selectedState;
  final ValueChanged<BillingDiagnosticsReleaseProfileFilterState> onSelected;
  final String? focusedBusinessDomain;
  final List<BillingDiagnosticsReleaseProfileSavedView> views;

  const BillingDiagnosticsReleaseProfileSavedViewBar({
    super.key,
    required this.coverage,
    required this.selectedState,
    required this.onSelected,
    this.focusedBusinessDomain,
    this.views = billingDiagnosticsReleaseProfileDefaultSavedViews,
  });

  @override
  Widget build(BuildContext context) {
    final availableViews = billingDiagnosticsReleaseProfileSavedViewsFor(
      coverage: coverage,
      focusedBusinessDomain: focusedBusinessDomain,
      views: views,
    );
    if (availableViews.length < 2) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile views',
          style: TextStyle(
            color: Color(0xFF334155),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final view = availableViews[index];

              return _DiagnosticsReleaseProfileSavedViewPill(
                view: view,
                count: view.count(
                  coverage,
                  focusedBusinessDomain: focusedBusinessDomain,
                ),
                selected: view.matchesState(
                  selectedState,
                  focusedBusinessDomain: focusedBusinessDomain,
                ),
                onTap:
                    () => onSelected(
                      view.resolve(
                        focusedBusinessDomain: focusedBusinessDomain,
                      ),
                    ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemCount: availableViews.length,
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Diagnostics release profile saved views')
Widget diagnosticsReleaseProfileSavedViewBarPreview() {
  final coverage = BillingReleaseWorkspaceProfileContractCoverage(
    contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BillingDiagnosticsReleaseProfileSavedViewBar(
          coverage: coverage,
          focusedBusinessDomain: 'construction',
          selectedState: billingDiagnosticsReleaseProfileCurrentDomainSavedView
              .resolve(focusedBusinessDomain: 'construction'),
          onSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Tappable saved-view chip that previews filter intent and result count.
class _DiagnosticsReleaseProfileSavedViewPill extends StatelessWidget {
  final BillingDiagnosticsReleaseProfileSavedView view;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _DiagnosticsReleaseProfileSavedViewPill({
    required this.view,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : view.accentColor;

    return Semantics(
      button: true,
      selected: selected,
      label: '${view.label}, ${_countLabel(count, 'profile')}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('billing-diagnostics-release-profile-view-${view.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            constraints: const BoxConstraints(minWidth: 148, maxWidth: 190),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: selected ? view.accentColor : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? view.accentColor : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: selected ? 0.10 : 0.04),
                  blurRadius: selected ? 14 : 8,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(view.icon, size: 17, color: foreground),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    view.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                _SavedViewCountBadge(count: count, selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact count badge used inside a diagnostics saved-view chip.
class _SavedViewCountBadge extends StatelessWidget {
  final int count;
  final bool selected;

  const _SavedViewCountBadge({required this.count, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:
            selected
                ? Colors.white.withValues(alpha: 0.18)
                : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF334155),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _countLabel(int count, String noun) {
  final suffix = count == 1 ? noun : '${noun}s';
  return '$count $suffix';
}
