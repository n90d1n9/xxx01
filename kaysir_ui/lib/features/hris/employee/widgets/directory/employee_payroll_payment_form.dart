import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_payment_models.dart';

class EmployeePayrollPaymentForm extends StatelessWidget {
  final EmployeePayrollPaymentProfile profile;
  final EmployeePayrollPaymentDraft draft;
  final TextEditingController ownerController;
  final TextEditingController referenceController;
  final TextEditingController noteController;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onReferenceChanged;
  final ValueChanged<String> onNoteChanged;
  final ValueChanged<DateTime> onScheduledForChanged;
  final VoidCallback onSchedule;
  final VoidCallback onHold;
  final VoidCallback onReopen;
  final VoidCallback onMarkPaid;

  const EmployeePayrollPaymentForm({
    super.key,
    required this.profile,
    required this.draft,
    required this.ownerController,
    required this.referenceController,
    required this.noteController,
    required this.onOwnerChanged,
    required this.onReferenceChanged,
    required this.onNoteChanged,
    required this.onScheduledForChanged,
    required this.onSchedule,
    required this.onHold,
    required this.onReopen,
    required this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    final errors = [
      if (!profile.canSchedule &&
          profile.status != EmployeePayrollPaymentStatus.scheduled)
        profile.nextAction,
      ...draft.validationErrors,
    ];
    final readyToSchedule = profile.canSchedule && draft.isReadyToSchedule;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment schedule',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ownerController,
            enabled: profile.status != EmployeePayrollPaymentStatus.paid,
            decoration: const InputDecoration(
              labelText: 'Payment owner',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: referenceController,
            enabled: profile.status != EmployeePayrollPaymentStatus.paid,
            decoration: const InputDecoration(
              labelText: 'Payment reference',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag_outlined),
            ),
            onChanged: onReferenceChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            enabled: profile.status != EmployeePayrollPaymentStatus.paid,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Payment note',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onNoteChanged,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _ScheduleChip(date: draft.scheduledFor),
              OutlinedButton.icon(
                onPressed:
                    profile.status == EmployeePayrollPaymentStatus.paid
                        ? null
                        : () => onScheduledForChanged(profile.payDate),
                icon: const Icon(Icons.event_available_outlined),
                label: const Text('Use pay date'),
              ),
              OutlinedButton.icon(
                onPressed:
                    profile.status == EmployeePayrollPaymentStatus.paid
                        ? null
                        : () => onScheduledForChanged(profile.asOfDate),
                icon: const Icon(Icons.today_outlined),
                label: const Text('Use today'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                readyToSchedule ? const Color(0xFF15803D) : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% ready',
          ),
          if (errors.isNotEmpty &&
              profile.status != EmployeePayrollPaymentStatus.scheduled &&
              profile.status != EmployeePayrollPaymentStatus.paid) ...[
            const SizedBox(height: 8),
            Text(
              errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (profile.status == EmployeePayrollPaymentStatus.held ||
                  profile.status == EmployeePayrollPaymentStatus.scheduled)
                OutlinedButton.icon(
                  onPressed: onReopen,
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Reopen'),
                ),
              OutlinedButton.icon(
                onPressed:
                    profile.canSchedule || profile.canMarkPaid ? onHold : null,
                icon: const Icon(Icons.pause_circle_outline),
                label: const Text('Hold'),
              ),
              FilledButton.icon(
                onPressed: readyToSchedule ? onSchedule : null,
                icon: const Icon(Icons.schedule_send_outlined),
                label: const Text('Schedule payment'),
              ),
              FilledButton.tonalIcon(
                onPressed: profile.canMarkPaid ? onMarkPaid : null,
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Mark paid'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleChip extends StatelessWidget {
  final DateTime? date;

  const _ScheduleChip({required this.date});

  @override
  Widget build(BuildContext context) {
    final label =
        date == null
            ? 'No schedule date'
            : 'Scheduled ${DateFormat('d MMM y').format(date!)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: HrisColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_outlined, size: 16, color: HrisColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
