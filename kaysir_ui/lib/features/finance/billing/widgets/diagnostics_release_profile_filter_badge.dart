import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../states/billing_diagnostics_release_profile_filter_provider.dart';
import 'release_profile_domain_filter.dart';
import 'release_profile_status_filter.dart';

/// Compact app-bar action for visible diagnostics release profile filters.
class BillingDiagnosticsReleaseProfileFilterBadge extends StatelessWidget {
  final BillingDiagnosticsReleaseProfileFilterSnapshot snapshot;
  final VoidCallback? onClear;

  const BillingDiagnosticsReleaseProfileFilterBadge({
    super.key,
    required this.snapshot,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (!snapshot.hasActiveFilters) return const SizedBox.shrink();

    final tooltip =
        onClear == null
            ? 'Release profile filters. ${snapshot.detailLabel}'
            : 'Clear release profile filters. ${snapshot.detailLabel}';

    return Padding(
      key: const ValueKey('billing-diagnostics-release-profile-filter-badge'),
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        label: tooltip,
        button: true,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              key: const ValueKey(
                'billing-diagnostics-release-profile-filter-badge-button',
              ),
              tooltip: tooltip,
              onPressed: onClear,
              icon: const Icon(Icons.filter_alt_off_outlined),
              color: const Color(0xFF2563EB),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: _ActiveFilterCountBadge(count: snapshot.activeFilterCount),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Diagnostics release profile filter badge')
Widget diagnosticsReleaseProfileFilterBadgePreview() {
  final snapshot = BillingDiagnosticsReleaseProfileFilterSnapshot(
    scope: BillingDiagnosticsReleaseProfileFilterScope(
      tenantId: 'tenant-a',
      businessDomain: 'commerce',
    ),
    state: BillingDiagnosticsReleaseProfileFilterState(
      statusOption: BillingReleaseProfileStatusFilterOption.standard,
      domainSelection: BillingReleaseProfileDomainFilterSelection.domain(
        'retail',
      ),
    ),
  );

  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Billing Diagnostics'),
        actions: [
          BillingDiagnosticsReleaseProfileFilterBadge(
            snapshot: snapshot,
            onClear: () {},
          ),
        ],
      ),
    ),
  );
}

class _ActiveFilterCountBadge extends StatelessWidget {
  final int count;

  const _ActiveFilterCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
