import 'package:flutter/material.dart';

import '../utils/billing_business_domain_module_readiness.dart';
import 'billing_domain_module_catalog_model.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_domain_module_readiness_badge.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_empty_state.dart';

class BillingDomainModuleCatalogPanel extends StatelessWidget {
  final BillingDomainModuleRegistryReadinessReport report;

  const BillingDomainModuleCatalogPanel({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final entries = billingDomainModuleCatalogEntries(report);
    final uniqueCapabilities =
        entries.expand((entry) => entry.capabilityLabels).toSet().length;

    return BillingReadinessPanelScaffold(
      title: 'Domain catalog',
      summary: 'Reusable billing domains, capabilities, and release contracts.',
      icon: Icons.category_outlined,
      iconColor: const Color(0xFF2563EB),
      iconBackgroundColor: const Color(0xFFEFF6FF),
      metrics: [
        BillingReadinessMetric(
          label: 'Domains',
          value: '${entries.length}',
          icon: Icons.business_center_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Capabilities',
          value: '$uniqueCapabilities',
          icon: Icons.extension_outlined,
          color: const Color(0xFF7C3AED),
        ),
        BillingReadinessMetric(
          label: 'Ready',
          value: '${report.readyDomainKeys.length}',
          icon: Icons.verified_outlined,
          color: const Color(0xFF059669),
        ),
      ],
      child:
          entries.isEmpty
              ? const _CatalogEmptyState()
              : LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 820;
                  final itemWidth =
                      isWide
                          ? (constraints.maxWidth - 12) / 2
                          : constraints.maxWidth;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        entries
                            .map(
                              (entry) => SizedBox(
                                width: itemWidth,
                                child: _CatalogModuleTile(entry: entry),
                              ),
                            )
                            .toList(),
                  );
                },
              ),
    );
  }
}

class _CatalogModuleTile extends StatelessWidget {
  final BillingDomainModuleCatalogEntry entry;

  const _CatalogModuleTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final capabilities = entry.capabilityLabels;

    return Container(
      constraints: const BoxConstraints(minHeight: 268),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.domainLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.domainKey} · ${entry.sourceLabel}',
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
              const SizedBox(width: 8),
              BillingDomainModuleReadinessBadge(report: entry.readinessReport),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                capabilities
                    .map((capability) => _CapabilityChip(label: capability))
                    .toList(),
          ),
          const SizedBox(height: 14),
          Column(
            children:
                entry.contracts
                    .map((contract) => _ContractRow(contract: contract))
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class _CapabilityChip extends StatelessWidget {
  final String label;

  const _CapabilityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1D4ED8),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ContractRow extends StatelessWidget {
  final BillingDomainModuleCatalogContract contract;

  const _ContractRow({required this.contract});

  @override
  Widget build(BuildContext context) {
    final color =
        contract.isReady ? const Color(0xFF059669) : const Color(0xFFD97706);
    final background =
        contract.isReady ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7);
    final icon =
        contract.isReady
            ? Icons.check_circle_outline
            : Icons.info_outline_rounded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              contract.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            contract.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogEmptyState extends StatelessWidget {
  const _CatalogEmptyState();

  @override
  Widget build(BuildContext context) {
    return const BillingEmptyState(
      message: 'No reusable billing domain modules are registered yet.',
      icon: Icons.category_outlined,
    );
  }
}
