import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_export_clear_finished_confirmation.dart';

class RecentReportClearFinishedDialog extends StatelessWidget {
  final ReportExportClearFinishedConfirmation confirmation;

  const RecentReportClearFinishedDialog({
    super.key,
    required this.confirmation,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.done_all_rounded, color: HrisColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(confirmation.title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(confirmation.primaryMessage),
          const SizedBox(height: 10),
          _ConfirmationNotice(text: confirmation.statusBreakdown),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.delete_sweep_outlined, size: 18),
          label: Text(confirmation.confirmLabel),
        ),
      ],
    );
  }
}

class _ConfirmationNotice extends StatelessWidget {
  final String text;

  const _ConfirmationNotice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HrisColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: HrisColors.muted,
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
