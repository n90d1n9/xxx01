import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payslip_delivery_models.dart';

class EmployeePayslipReleaseForm extends StatelessWidget {
  final EmployeePayslipDeliveryProfile profile;
  final EmployeePayslipReleaseDraft draft;
  final TextEditingController ownerController;
  final TextEditingController noteController;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onNoteChanged;
  final ValueChanged<bool> onNotifyEmployeeChanged;
  final ValueChanged<bool> onArchiveCopyChanged;
  final VoidCallback onRelease;
  final VoidCallback onSuppress;
  final VoidCallback onReopen;

  const EmployeePayslipReleaseForm({
    super.key,
    required this.profile,
    required this.draft,
    required this.ownerController,
    required this.noteController,
    required this.onOwnerChanged,
    required this.onNoteChanged,
    required this.onNotifyEmployeeChanged,
    required this.onArchiveCopyChanged,
    required this.onRelease,
    required this.onSuppress,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final errors = [
      if (!profile.canRelease) profile.nextAction,
      ...draft.validationErrors,
    ];
    final readyToRelease = profile.canRelease && draft.isReadyToRelease;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payslip release',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ownerController,
            enabled: profile.status != EmployeePayslipDeliveryStatus.published,
            decoration: const InputDecoration(
              labelText: 'Release owner',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            enabled: profile.status != EmployeePayslipDeliveryStatus.published,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Release note',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onNoteChanged,
          ),
          const SizedBox(height: 8),
          _ReleaseToggle(
            value: draft.notifyEmployee,
            icon: Icons.mark_email_unread_outlined,
            label: 'Notify employee after release',
            onChanged: onNotifyEmployeeChanged,
          ),
          _ReleaseToggle(
            value: draft.archiveCopy,
            icon: Icons.inventory_2_outlined,
            label: 'Store payroll archive copy',
            onChanged: onArchiveCopyChanged,
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                readyToRelease ? const Color(0xFF15803D) : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% ready',
          ),
          if (errors.isNotEmpty &&
              profile.status != EmployeePayslipDeliveryStatus.published) ...[
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
              if (profile.status == EmployeePayslipDeliveryStatus.suppressed ||
                  profile.status == EmployeePayslipDeliveryStatus.published)
                OutlinedButton.icon(
                  onPressed: onReopen,
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Reopen'),
                ),
              OutlinedButton.icon(
                onPressed: profile.canRelease ? onSuppress : null,
                icon: const Icon(Icons.visibility_off_outlined),
                label: const Text('Suppress'),
              ),
              FilledButton.icon(
                onPressed: readyToRelease ? onRelease : null,
                icon: const Icon(Icons.publish_outlined),
                label: const Text('Release payslip'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReleaseToggle extends StatelessWidget {
  final bool value;
  final IconData icon;
  final String label;
  final ValueChanged<bool> onChanged;

  const _ReleaseToggle({
    required this.value,
    required this.icon,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (next) => onChanged(next ?? false),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 18, color: HrisColors.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
