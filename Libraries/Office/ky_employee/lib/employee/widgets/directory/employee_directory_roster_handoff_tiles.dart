import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_roster_handoff_models.dart';

/// Actionable recipient tile for roster release handoff acknowledgement.
class EmployeeDirectoryRosterHandoffRecipientTile extends StatelessWidget {
  final EmployeeDirectoryRosterHandoffRecipient recipient;
  final ValueChanged<EmployeeDirectoryRosterHandoffRecipient> onAcknowledge;
  final ValueChanged<EmployeeDirectoryRosterHandoffRecipient> onResend;
  final ValueChanged<EmployeeDirectoryRosterHandoffRecipient> onEscalate;

  const EmployeeDirectoryRosterHandoffRecipientTile({
    super.key,
    required this.recipient,
    required this.onAcknowledge,
    required this.onResend,
    required this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(recipient.status);

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
                child: Icon(_channelIcon(recipient.channel), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          recipient.teamName,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        HrisStatusPill(
                          label: recipient.statusLabel,
                          color: color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      recipient.note,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RosterHandoffMetaChip(
                icon: Icons.person_outline,
                label: recipient.owner,
              ),
              _RosterHandoffMetaChip(
                icon: Icons.account_tree_outlined,
                label: recipient.channel.label,
              ),
              _RosterHandoffMetaChip(
                icon: Icons.event_available_outlined,
                label: 'Due ${_formatDate(recipient.dueAt)}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                key: ValueKey(
                  'employee-directory-roster-handoff-acknowledge-${recipient.id}',
                ),
                onPressed:
                    recipient.isAcknowledged
                        ? null
                        : () => onAcknowledge(recipient),
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Acknowledge'),
              ),
              OutlinedButton.icon(
                key: ValueKey(
                  'employee-directory-roster-handoff-resend-${recipient.id}',
                ),
                onPressed:
                    recipient.isAcknowledged ? null : () => onResend(recipient),
                icon: const Icon(Icons.mark_email_unread_outlined),
                label: const Text('Resend'),
              ),
              TextButton.icon(
                key: ValueKey(
                  'employee-directory-roster-handoff-escalate-${recipient.id}',
                ),
                onPressed:
                    recipient.isAcknowledged || recipient.isEscalated
                        ? null
                        : () => onEscalate(recipient),
                icon: const Icon(Icons.priority_high_outlined),
                label: const Text('Escalate'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small metadata chip used by roster handoff recipient tiles.
class _RosterHandoffMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RosterHandoffMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: HrisColors.muted),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee roster handoff recipient')
Widget employeeDirectoryRosterHandoffRecipientTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterHandoffRecipientTile(
          recipient: EmployeeDirectoryRosterHandoffRecipient(
            id: 'payroll',
            teamName: 'Payroll Operations',
            owner: 'Payroll Lead',
            channel: EmployeeDirectoryRosterHandoffChannel.payrollSystem,
            dueAt: DateTime(2026, 5, 31),
            status: EmployeeDirectoryRosterHandoffStatus.pending,
            note: 'Validate payroll sync for 2026.05.30-001.',
          ),
          onAcknowledge: (_) {},
          onResend: (_) {},
          onEscalate: (_) {},
        ),
      ),
    ),
  );
}

IconData _channelIcon(EmployeeDirectoryRosterHandoffChannel channel) {
  return switch (channel) {
    EmployeeDirectoryRosterHandoffChannel.payrollSystem =>
      Icons.payments_outlined,
    EmployeeDirectoryRosterHandoffChannel.financeTask =>
      Icons.account_balance_wallet_outlined,
    EmployeeDirectoryRosterHandoffChannel.hrWorkspace =>
      Icons.business_center_outlined,
  };
}

Color _statusColor(EmployeeDirectoryRosterHandoffStatus status) {
  return switch (status) {
    EmployeeDirectoryRosterHandoffStatus.pending => const Color(0xFFD97706),
    EmployeeDirectoryRosterHandoffStatus.acknowledged => const Color(
      0xFF15803D,
    ),
    EmployeeDirectoryRosterHandoffStatus.escalated => const Color(0xFFB91C1C),
  };
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
