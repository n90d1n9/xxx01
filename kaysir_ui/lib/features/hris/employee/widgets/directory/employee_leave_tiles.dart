import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_leave_models.dart';
import 'employee_leave_styles.dart';

class EmployeeLeaveSummaryStrip extends StatelessWidget {
  final EmployeeLeaveProfile profile;

  const EmployeeLeaveSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Pending',
          value: '${profile.pendingRequestCount}',
        ),
        HrisMetricStripItem(
          label: 'Approved',
          value: '${profile.approvedUpcomingCount}',
        ),
        HrisMetricStripItem(
          label: 'Conflicts',
          value: '${profile.blackoutConflictCount}',
        ),
        HrisMetricStripItem(label: 'Low', value: '${profile.lowBalanceCount}'),
      ],
    );
  }
}

class EmployeeLeaveBalancesCard extends StatelessWidget {
  final List<EmployeeLeaveBalance> balances;

  const EmployeeLeaveBalancesCard({super.key, required this.balances});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leave balances',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ..._balanceRows(balances),
        ],
      ),
    );
  }

  List<Widget> _balanceRows(List<EmployeeLeaveBalance> balances) {
    final rows = <Widget>[];
    for (var index = 0; index < balances.length; index++) {
      if (index > 0) rows.add(const SizedBox(height: 12));
      rows.add(_LeaveBalanceRow(balance: balances[index]));
    }
    return rows;
  }
}

class _LeaveBalanceRow extends StatelessWidget {
  final EmployeeLeaveBalance balance;

  const _LeaveBalanceRow({required this.balance});

  @override
  Widget build(BuildContext context) {
    final color = balance.isLow ? const Color(0xFFB45309) : HrisColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(employeeLeaveTypeIcon(balance.type), size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                balance.type.label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${balance.availableDays} available',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        HrisProgressBar(
          value: balance.usageRatio.clamp(0, 1),
          color: color,
          label:
              '${balance.usedDays}/${balance.accruedDays} used, ${balance.pendingDays} pending',
        ),
      ],
    );
  }
}

class EmployeeLeaveRiskTile extends StatelessWidget {
  final EmployeeLeaveRiskSignal risk;

  const EmployeeLeaveRiskTile({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    final color = employeeLeaveRiskColor(risk.type);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              employeeLeaveRiskIcon(risk.type),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        risk.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(label: risk.type.label, color: color),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  risk.detail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeLeaveBlackoutTile extends StatelessWidget {
  final EmployeeLeaveBlackoutPeriod blackout;

  const EmployeeLeaveBlackoutTile({super.key, required this.blackout});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFB45309).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.event_busy_outlined,
              color: Color(0xFFB45309),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blackout.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(blackout.startDate)} - ${_formatDate(blackout.endDate)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                _MetaChip(icon: Icons.person_outline, label: blackout.owner),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeLeaveRequestTile extends StatelessWidget {
  final EmployeeLeaveRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onCancel;

  const EmployeeLeaveRequestTile({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeLeaveRequestStatusColor(request.status);

    return HrisListSurface(
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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeLeaveTypeIcon(request.type),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.type.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: request.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request.reason,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.ink),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(
                  icon: Icons.calendar_today_outlined,
                  label:
                      '${request.durationDays} day${request.durationDays == 1 ? '' : 's'}',
                ),
                _MetaChip(
                  icon: Icons.person_outline,
                  label: request.coverageOwner,
                ),
                if (request.canApprove)
                  FilledButton.tonalIcon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Approve'),
                  ),
                if (request.canReject)
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.block_outlined),
                    label: const Text('Reject'),
                  ),
                if (request.canCancel)
                  OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: HrisColors.muted),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: HrisColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime value) {
  return DateFormat('MMM d, yyyy').format(value);
}
