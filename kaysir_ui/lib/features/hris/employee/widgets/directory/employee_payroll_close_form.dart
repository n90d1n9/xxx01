import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_close_models.dart';

class EmployeePayrollCloseForm extends StatelessWidget {
  final EmployeePayrollCloseProfile profile;
  final EmployeePayrollCloseDraft draft;
  final TextEditingController ownerController;
  final TextEditingController journalBatchController;
  final TextEditingController noteController;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onJournalBatchChanged;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onPost;
  final VoidCallback onClose;
  final VoidCallback onReopen;

  const EmployeePayrollCloseForm({
    super.key,
    required this.profile,
    required this.draft,
    required this.ownerController,
    required this.journalBatchController,
    required this.noteController,
    required this.onOwnerChanged,
    required this.onJournalBatchChanged,
    required this.onNoteChanged,
    required this.onPost,
    required this.onClose,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final errors = [
      if (!profile.canPost &&
          profile.status != EmployeePayrollCloseStatus.posted)
        profile.nextAction,
      ...draft.validationErrors,
    ];
    final readyToPost = profile.canPost && draft.isReadyToPost;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accounting handoff',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ownerController,
            enabled: profile.status != EmployeePayrollCloseStatus.closed,
            decoration: const InputDecoration(
              labelText: 'Close owner',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: journalBatchController,
            enabled: profile.status != EmployeePayrollCloseStatus.closed,
            decoration: const InputDecoration(
              labelText: 'Journal batch',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.book_outlined),
            ),
            onChanged: onJournalBatchChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            enabled: profile.status != EmployeePayrollCloseStatus.closed,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Close note',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onNoteChanged,
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: draft.completionRatio,
            color: readyToPost ? const Color(0xFF15803D) : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% ready',
          ),
          if (errors.isNotEmpty &&
              profile.status != EmployeePayrollCloseStatus.posted &&
              profile.status != EmployeePayrollCloseStatus.closed) ...[
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
              if (profile.status == EmployeePayrollCloseStatus.posted)
                OutlinedButton.icon(
                  onPressed: onReopen,
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Reopen'),
                ),
              FilledButton.icon(
                onPressed: readyToPost ? onPost : null,
                icon: const Icon(Icons.post_add_outlined),
                label: const Text('Post journal'),
              ),
              FilledButton.tonalIcon(
                onPressed: profile.canClose ? onClose : null,
                icon: const Icon(Icons.lock_outline),
                label: const Text('Close period'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
