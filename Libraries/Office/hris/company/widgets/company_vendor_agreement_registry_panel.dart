import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_vendor_agreement.dart';
import 'company_status_styles.dart';

class CompanyVendorAgreementRegistryPanel extends StatelessWidget {
  final List<CompanyVendorAgreement> agreements;
  final DateTime asOfDate;
  final ValueChanged<String> onRenew;
  final ValueChanged<String> onCloseImplementation;

  const CompanyVendorAgreementRegistryPanel({
    super.key,
    required this.agreements,
    required this.asOfDate,
    required this.onRenew,
    required this.onCloseImplementation,
  });

  @override
  Widget build(BuildContext context) {
    final readyCount =
        agreements
            .where((agreement) => !agreement.requiresAttention(asOfDate))
            .length;

    return HrisSectionPanel(
      icon: Icons.handshake_outlined,
      title: 'Vendor Agreement Registry',
      subtitle:
          '$readyCount ready of ${agreements.length} HR vendor agreements',
      emptyMessage: 'No matching vendor agreements',
      children:
          agreements
              .map(
                (agreement) => _VendorAgreementTile(
                  agreement: agreement,
                  asOfDate: asOfDate,
                  onRenew: () => onRenew(agreement.id),
                  onCloseImplementation:
                      () => onCloseImplementation(agreement.id),
                ),
              )
              .toList(),
    );
  }
}

class _VendorAgreementTile extends StatelessWidget {
  final CompanyVendorAgreement agreement;
  final DateTime asOfDate;
  final VoidCallback onRenew;
  final VoidCallback onCloseImplementation;

  const _VendorAgreementTile({
    required this.agreement,
    required this.asOfDate,
    required this.onRenew,
    required this.onCloseImplementation,
  });

  @override
  Widget build(BuildContext context) {
    final issues = agreement.issues(asOfDate);
    final statusColor = companyVendorAgreementStatusColor(agreement.status);

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
                      agreement.vendorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${agreement.serviceName} - ${agreement.entityName}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: [
                  HrisStatusPill(
                    label: agreement.category.label,
                    color: Colors.indigo,
                  ),
                  HrisStatusPill(
                    label: agreement.status.label,
                    color: statusColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Owner', value: agreement.ownerName),
              HrisMetricStripItem(
                label: 'Account',
                value:
                    agreement.accountManagerName.trim().isEmpty
                        ? 'Missing'
                        : agreement.accountManagerName,
              ),
              HrisMetricStripItem(label: 'Ends', value: _endLabel()),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            agreement.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: HrisColors.ink),
          ),
          const SizedBox(height: 8),
          Text(
            agreement.slaSummary.trim().isEmpty
                ? 'SLA missing'
                : agreement.slaSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            agreement.dataProtectionSummary.trim().isEmpty
                ? 'DPA missing'
                : agreement.dataProtectionSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          if (agreement.linkedModule.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            HrisStatusPill(
              label: agreement.linkedModule,
              color: Colors.blueGrey,
            ),
          ],
          if (issues.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  issues
                      .map(
                        (issue) => HrisStatusPill(
                          label: issue.label,
                          color:
                              issue == CompanyVendorAgreementIssue.expired ||
                                      issue ==
                                          CompanyVendorAgreementIssue
                                              .reviewOverdue ||
                                      issue ==
                                          CompanyVendorAgreementIssue.suspended
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onCloseImplementation,
                  icon: const Icon(Icons.playlist_add_check_outlined),
                  label: const Text('Close implementation'),
                ),
                FilledButton.icon(
                  onPressed: onRenew,
                  icon: const Icon(Icons.autorenew_outlined),
                  label: const Text('Mark renewed'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _endLabel() {
    final days = agreement.daysUntilContractEnd(asOfDate);
    if (days < 0) return 'Expired ${days.abs()}d';
    if (days == 0) return 'Today';
    final month = agreement.contractEndDate.month.toString().padLeft(2, '0');
    final day = agreement.contractEndDate.day.toString().padLeft(2, '0');
    return '${agreement.contractEndDate.year}-$month-$day (${days}d)';
  }
}
