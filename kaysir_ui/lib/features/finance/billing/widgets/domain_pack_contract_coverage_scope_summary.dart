import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/domain_pack_contract_coverage_filter.dart';
import '../models/domain_pack_contract_coverage_view_state.dart';
import '../models/domain_pack_contract_domain_filter.dart';
import '../utils/billing_business_domain_packs.dart';
import '../utils/domain_pack_contract.dart';

/// Compact summary for the active billing domain-pack contract coverage scope.
class DomainPackContractCoverageScopeSummary extends StatelessWidget {
  final DomainPackContractCoverageViewState viewState;
  final VoidCallback? onResetFilters;

  const DomainPackContractCoverageScopeSummary({
    super.key,
    required this.viewState,
    this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('domain-pack-contract-coverage-scope-summary'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.visibility_outlined,
            size: 18,
            color: Color(0xFF475569),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              viewState.scopeSummaryLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (viewState.hasActiveControls && onResetFilters != null) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              key: const ValueKey(
                'domain-pack-contract-coverage-reset-filters',
              ),
              onPressed: onResetFilters,
              icon: const Icon(Icons.restart_alt_rounded, size: 16),
              label: const Text('Reset'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Domain pack contract coverage scope summary')
Widget domainPackContractCoverageScopeSummaryPreview() {
  final viewState = DomainPackContractCoverageViewState.resolve(
    report: DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    ),
    domainSelection: DomainPackContractDomainFilterSelection.domain(
      'construction',
    ),
    filter: DomainPackContractCoverageFilter.hardening,
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: DomainPackContractCoverageScopeSummary(
          viewState: viewState,
          onResetFilters: () {},
        ),
      ),
    ),
  );
}
