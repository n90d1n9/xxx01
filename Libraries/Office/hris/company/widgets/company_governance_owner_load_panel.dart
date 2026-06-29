import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_governance_owner_load.dart';

/// Summarizes company governance action ownership and routing pressure.
class CompanyGovernanceOwnerLoadPanel extends StatelessWidget {
  final List<CompanyGovernanceOwnerLoad> loads;
  final ValueChanged<String>? onOwnerSelected;

  const CompanyGovernanceOwnerLoadPanel({
    super.key,
    required this.loads,
    this.onOwnerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final criticalCount =
        loads
            .where(
              (load) => load.risk == CompanyGovernanceOwnerLoadRisk.critical,
            )
            .length;
    final unassignedCount =
        loads.where((load) => load.ownerLabel == 'Unassigned owner').length;

    return HrisSectionPanel(
      icon: Icons.groups_2_outlined,
      title: 'Governance Owner Load',
      subtitle:
          loads.isEmpty
              ? 'No owner load from governance actions'
              : '$criticalCount critical owner lanes, $unassignedCount unassigned',
      emptyMessage: 'No governance owner load',
      children:
          loads.isEmpty
              ? const []
              : [
                _OwnerLoadSummary(loads: loads),
                for (final load in loads)
                  _OwnerLoadTile(
                    load: load,
                    onOwnerSelected:
                        onOwnerSelected == null
                            ? null
                            : () => onOwnerSelected!(load.ownerLabel),
                  ),
              ],
    );
  }
}

/// Compact rollup metrics for governance ownership.
class _OwnerLoadSummary extends StatelessWidget {
  final List<CompanyGovernanceOwnerLoad> loads;

  const _OwnerLoadSummary({required this.loads});

  @override
  Widget build(BuildContext context) {
    final actionCount = loads.fold<int>(
      0,
      (total, load) => total + load.actionCount,
    );
    final criticalCount = loads.fold<int>(
      0,
      (total, load) => total + load.criticalCount,
    );
    final highCount = loads.fold<int>(
      0,
      (total, load) => total + load.highCount,
    );

    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Owners', value: '${loads.length}'),
        HrisMetricStripItem(label: 'Actions', value: '$actionCount'),
        HrisMetricStripItem(label: 'Critical', value: '$criticalCount'),
        HrisMetricStripItem(label: 'High', value: '$highCount'),
      ],
    );
  }
}

/// One owner lane in the governance ownership summary.
class _OwnerLoadTile extends StatelessWidget {
  final CompanyGovernanceOwnerLoad load;
  final VoidCallback? onOwnerSelected;

  const _OwnerLoadTile({required this.load, required this.onOwnerSelected});

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor(load.risk);
    return HrisListSurface(
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
                      load.ownerLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      load.sourceSummary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: load.risk.label, color: riskColor),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Actions',
                value: '${load.actionCount}',
              ),
              HrisMetricStripItem(
                label: 'Critical',
                value: '${load.criticalCount}',
              ),
              HrisMetricStripItem(label: 'Next', value: load.nextDueLabel),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: riskColor.withValues(alpha: 0.22)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.assignment_ind_outlined, color: riskColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    load.primaryActionLabel,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onOwnerSelected != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                key: Key('company-governance-owner-${load.ownerLabel}'),
                onPressed: onOwnerSelected,
                icon: const Icon(Icons.manage_accounts_outlined),
                label: const Text('Review owner'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Color _riskColor(CompanyGovernanceOwnerLoadRisk risk) {
  switch (risk) {
    case CompanyGovernanceOwnerLoadRisk.critical:
      return Colors.red;
    case CompanyGovernanceOwnerLoadRisk.high:
      return Colors.orange;
    case CompanyGovernanceOwnerLoadRisk.steady:
      return Colors.green;
  }
}

@Preview(name: 'Company governance owner load panel')
Widget companyGovernanceOwnerLoadPanelPreview() {
  final asOfDate = DateTime(2026, 6, 10);
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompanyGovernanceOwnerLoadPanel(
          loads: [
            CompanyGovernanceOwnerLoad(
              ownerName: 'People Operations',
              actionCount: 3,
              criticalCount: 1,
              highCount: 2,
              mediumCount: 0,
              filingCount: 1,
              employerAccountCount: 1,
              vendorAgreementCount: 0,
              signatoryCount: 1,
              nextDueDate: asOfDate.subtract(const Duration(days: 3)),
              nextDueLabel: 'Overdue 3d',
              primaryActionLabel: 'Submit labor report receipt',
              risk: CompanyGovernanceOwnerLoadRisk.critical,
            ),
            CompanyGovernanceOwnerLoad(
              ownerName: 'Legal Operations',
              actionCount: 1,
              criticalCount: 0,
              highCount: 1,
              mediumCount: 0,
              filingCount: 0,
              employerAccountCount: 0,
              vendorAgreementCount: 1,
              signatoryCount: 0,
              nextDueDate: asOfDate.add(const Duration(days: 12)),
              nextDueLabel: 'Contract ends in 12d',
              primaryActionLabel: 'Renew e-signature agreement',
              risk: CompanyGovernanceOwnerLoadRisk.high,
            ),
          ],
          onOwnerSelected: _previewOwnerSelected,
        ),
      ),
    ),
  );
}

void _previewOwnerSelected(String ownerName) {}
