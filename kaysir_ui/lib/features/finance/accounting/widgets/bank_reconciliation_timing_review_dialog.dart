import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/bank_reconciliation_timing_register.dart';
import '../models/bank_reconciliation_timing_review.dart';

Future<BankReconciliationTimingReview?> showBankTimingReviewDialog(
  BuildContext context, {
  required BankReconciliationTimingRegisterItem item,
  required BankReconciliationTimingReview review,
  required NumberFormat currency,
  required DateFormat dateFormat,
}) {
  return showDialog<BankReconciliationTimingReview>(
    context: context,
    builder:
        (context) => _BankTimingReviewDialog(
          item: item,
          review: review,
          currency: currency,
          dateFormat: dateFormat,
        ),
  );
}

class _BankTimingReviewDialog extends StatefulWidget {
  final BankReconciliationTimingRegisterItem item;
  final BankReconciliationTimingReview review;
  final NumberFormat currency;
  final DateFormat dateFormat;

  const _BankTimingReviewDialog({
    required this.item,
    required this.review,
    required this.currency,
    required this.dateFormat,
  });

  @override
  State<_BankTimingReviewDialog> createState() =>
      _BankTimingReviewDialogState();
}

class _BankTimingReviewDialogState extends State<_BankTimingReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _noteController;
  late BankReconciliationTimingReviewStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.review.status;
    _ownerController = TextEditingController(text: widget.review.ownerLabel);
    _noteController = TextEditingController(text: widget.review.note);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timing review evidence',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                _TimingReviewContextCard(
                  item: widget.item,
                  currency: widget.currency,
                  dateFormat: widget.dateFormat,
                ),
                const SizedBox(height: 14),
                AppSelectField<BankReconciliationTimingReviewStatus>(
                  label: 'Review status',
                  value: _status,
                  icon: Icons.fact_check_outlined,
                  options: [
                    for (final status
                        in BankReconciliationTimingReviewStatus.values)
                      AppSelectOption(value: status, label: status.label),
                  ],
                  onChanged: (value) => setState(() => _status = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ownerController,
                  decoration: _inputDecoration(
                    context,
                    label: 'Owner',
                    icon: Icons.person_outline,
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    context,
                    label: 'Review note',
                    hintText:
                        'Document follow-up, clearing evidence, or reason.',
                    icon: Icons.notes_outlined,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 18),
                AppDialogActions(
                  cancelLabel: 'Cancel',
                  cancelIcon: Icons.close_rounded,
                  onCancel: () => Navigator.of(context).pop(),
                  confirmLabel: 'Save Review',
                  confirmIcon: Icons.check_rounded,
                  onConfirm: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
    String? hintText,
    bool alignLabelWithHint = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      alignLabelWithHint: alignLabelWithHint,
      prefixIcon: Icon(icon, size: 18),
      filled: true,
      fillColor: colorScheme.surface,
      border: border,
      enabledBorder: border,
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      BankReconciliationTimingReview(
        reference: widget.item.reference,
        status: _status,
        owner: _ownerController.text.trim(),
        note: _noteController.text.trim(),
        reviewedAt: DateTime.now(),
      ),
    );
  }
}

class _TimingReviewContextCard extends StatelessWidget {
  final BankReconciliationTimingRegisterItem item;
  final NumberFormat currency;
  final DateFormat dateFormat;

  const _TimingReviewContextCard({
    required this.item,
    required this.currency,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  item.reference,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppStatusPill(
                  label: item.deadlineStatusLabel,
                  color: _deadlineColor(item.deadlineStatus),
                ),
                AppStatusPill(
                  label: item.bucketLabel,
                  color: _bucketColor(item.bucket),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${item.typeLabel} / ${currency.format(item.amount)} / '
              'clear by ${dateFormat.format(item.clearByDate)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.suggestedAction,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _deadlineColor(BankReconciliationTimingDeadlineStatus status) {
    switch (status) {
      case BankReconciliationTimingDeadlineStatus.onTrack:
        return Colors.teal;
      case BankReconciliationTimingDeadlineStatus.dueSoon:
        return Colors.amber.shade800;
      case BankReconciliationTimingDeadlineStatus.overdue:
        return Colors.redAccent;
    }
  }

  Color _bucketColor(BankReconciliationTimingBucket bucket) {
    switch (bucket) {
      case BankReconciliationTimingBucket.current:
        return Colors.teal;
      case BankReconciliationTimingBucket.watch:
        return Colors.amber.shade800;
      case BankReconciliationTimingBucket.stale:
        return Colors.redAccent;
    }
  }
}
