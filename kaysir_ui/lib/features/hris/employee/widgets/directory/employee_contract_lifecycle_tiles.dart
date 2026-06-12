import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_contract_lifecycle_models.dart';
import 'employee_contract_lifecycle_styles.dart';

class EmployeeContractLifecycleSummaryStrip extends StatelessWidget {
  final EmployeeContractLifecycleProfile profile;

  const EmployeeContractLifecycleSummaryStrip({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Type', value: profile.contract.type.label),
        HrisMetricStripItem(
          label: 'Status',
          value: profile.contract.status.label,
        ),
        HrisMetricStripItem(
          label: 'Submitted',
          value: '${profile.submittedChangeCount}',
        ),
        HrisMetricStripItem(
          label: 'Signed',
          value: '${profile.signedChangeCount}',
        ),
      ],
    );
  }
}

class EmployeeContractTermsCard extends StatelessWidget {
  final EmployeeContractRecord contract;
  final DateTime asOfDate;
  final VoidCallback onCompleteProbation;
  final VoidCallback onMarkRenewed;

  const EmployeeContractTermsCard({
    super.key,
    required this.contract,
    required this.asOfDate,
    required this.onCompleteProbation,
    required this.onMarkRenewed,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeContractStatusColor(contract.status);
    final showProbationAction = contract.isProbationDue(asOfDate);
    final showRenewalAction =
        contract.isRenewalDue(asOfDate) || contract.isExpired(asOfDate);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: employeeContractTypeIcon(contract.type),
            title: '${contract.type.label} agreement',
            subtitle: '${contract.owner} - version ${contract.version}',
            color: color,
            status: HrisStatusPill(label: contract.status.label, color: color),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.play_circle_outline,
                label: 'Start ${_formatDate(contract.startDate)}',
              ),
              _MetaChip(
                icon: Icons.event_busy_outlined,
                label:
                    contract.endDate == null
                        ? 'No end date'
                        : 'End ${_formatDate(contract.endDate!)}',
                color:
                    contract.isExpired(asOfDate)
                        ? const Color(0xFFB91C1C)
                        : null,
              ),
              if (contract.probationEndDate != null)
                _MetaChip(
                  icon: Icons.hourglass_top_outlined,
                  label: 'Probation ${_formatDate(contract.probationEndDate!)}',
                  color: showProbationAction ? const Color(0xFFB45309) : null,
                ),
              if (contract.renewalDueDate != null)
                _MetaChip(
                  icon: Icons.autorenew_outlined,
                  label: 'Renewal ${_formatDate(contract.renewalDueDate!)}',
                  color:
                      contract.isRenewalDue(asOfDate)
                          ? const Color(0xFFB45309)
                          : null,
                ),
              _MetaChip(
                icon: Icons.draw_outlined,
                label:
                    contract.signedAt == null
                        ? 'Signature pending'
                        : 'Signed ${_formatDate(contract.signedAt!)}',
                color:
                    contract.status == EmployeeContractStatus.pendingSignature
                        ? const Color(0xFF7C3AED)
                        : null,
              ),
            ],
          ),
          if (showProbationAction || showRenewalAction) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (showProbationAction)
                  FilledButton.tonalIcon(
                    onPressed: onCompleteProbation,
                    icon: const Icon(Icons.task_alt_outlined),
                    label: const Text('Complete probation'),
                  ),
                if (showRenewalAction)
                  FilledButton.icon(
                    onPressed: onMarkRenewed,
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
}

class EmployeeContractChangeRequestTile extends StatelessWidget {
  final EmployeeContractChangeRequest request;
  final VoidCallback onApprove;
  final VoidCallback onSign;
  final VoidCallback onActivate;
  final VoidCallback onReject;

  const EmployeeContractChangeRequestTile({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onSign,
    required this.onActivate,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeContractChangeStatusColor(request.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: employeeContractChangeTypeIcon(request.type),
            title: request.title,
            subtitle: '${request.type.label} - ${request.requestedBy}',
            color: color,
            status: HrisStatusPill(label: request.status.label, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            request.detail,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.event_available_outlined,
                label: 'Effective ${_formatDate(request.effectiveDate)}',
              ),
              _MetaChip(
                icon: Icons.inbox_outlined,
                label: 'Submitted ${_formatDate(request.submittedAt)}',
              ),
            ],
          ),
          if (request.canApprove ||
              request.canSign ||
              request.canActivate ||
              request.canReject) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (request.canReject)
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_outlined),
                    label: const Text('Reject'),
                  ),
                if (request.canApprove)
                  FilledButton.tonalIcon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Approve'),
                  ),
                if (request.canSign)
                  FilledButton.tonalIcon(
                    onPressed: onSign,
                    icon: const Icon(Icons.draw_outlined),
                    label: const Text('Sign'),
                  ),
                if (request.canActivate)
                  FilledButton.icon(
                    onPressed: onActivate,
                    icon: const Icon(Icons.done_all_outlined),
                    label: const Text('Activate'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TileHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget status;

  const _TileHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        status,
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? HrisColors.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}
