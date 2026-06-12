import 'package:flutter/material.dart';

import '../utils/billing_business_domain_pack_readiness.dart';
import '../utils/domain_pack_contract.dart';
import 'billing_business_domain_pack_readiness_badge.dart';
import 'domain_pack_contract_requirement_list.dart';

/// Tile that summarizes one billing business-domain pack readiness contract.
class BillingBusinessDomainPackReadinessTile extends StatelessWidget {
  final BillingBusinessDomainPackReadinessReport report;
  final int maxVisiblePackIssues;

  const BillingBusinessDomainPackReadinessTile({
    super.key,
    required this.report,
    this.maxVisiblePackIssues = 2,
  });

  @override
  Widget build(BuildContext context) {
    final contractReport = DomainPackContractReport.fromReadiness(report);
    final maxVisibleRequirements =
        maxVisiblePackIssues < contractReport.requirements.length
            ? contractReport.requirements.length
            : maxVisiblePackIssues;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.domainLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${report.packId} · ${report.domainKey}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              BillingBusinessDomainPackReadinessBadge(report: report),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            report.summaryLabel,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          DomainPackContractRequirementList(
            requirements: contractReport.requirements,
            maxVisibleRequirements: maxVisibleRequirements,
          ),
        ],
      ),
    );
  }
}
