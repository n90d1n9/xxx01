import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

/// Captures reviewer receipt details for a delivered audit package.
class AuditReviewerReceiptForm extends StatefulWidget {
  final AuditReviewerReceiptDraft draft;
  final bool enabled;
  final ValueChanged<String> onReviewerChanged;
  final ValueChanged<String> onReviewerRoleChanged;
  final ValueChanged<AuditReviewerReceiptDecision> onDecisionChanged;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onSubmit;

  const AuditReviewerReceiptForm({
    super.key,
    required this.draft,
    required this.enabled,
    required this.onReviewerChanged,
    required this.onReviewerRoleChanged,
    required this.onDecisionChanged,
    required this.onNoteChanged,
    required this.onSubmit,
  });

  @override
  State<AuditReviewerReceiptForm> createState() =>
      _AuditReviewerReceiptFormState();
}

class _AuditReviewerReceiptFormState extends State<AuditReviewerReceiptForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _roleController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _reviewerController = TextEditingController(text: widget.draft.reviewer);
    _roleController = TextEditingController(text: widget.draft.reviewerRole);
    _noteController = TextEditingController(text: widget.draft.note);
  }

  @override
  void didUpdateWidget(covariant AuditReviewerReceiptForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_reviewerController, widget.draft.reviewer);
    _sync(_roleController, widget.draft.reviewerRole);
    _sync(_noteController, widget.draft.note);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _roleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reviewer receipt',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final fields = [
                  TextFormField(
                    enabled: widget.enabled,
                    controller: _reviewerController,
                    decoration: const InputDecoration(
                      labelText: 'Reviewer',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_search_outlined),
                    ),
                    onChanged: widget.onReviewerChanged,
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter a reviewer'
                                : null,
                  ),
                  TextFormField(
                    enabled: widget.enabled,
                    controller: _roleController,
                    decoration: const InputDecoration(
                      labelText: 'Reviewer role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    onChanged: widget.onReviewerRoleChanged,
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter a reviewer role'
                                : null,
                  ),
                ];

                if (constraints.maxWidth < 720) {
                  return Column(
                    children: [
                      fields.first,
                      const SizedBox(height: 12),
                      fields.last,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: fields.first),
                    const SizedBox(width: 12),
                    Expanded(child: fields.last),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AuditReviewerReceiptDecision>(
              initialValue: widget.draft.decision,
              decoration: const InputDecoration(
                labelText: 'Decision',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.rule_folder_outlined),
              ),
              items: [
                for (final decision in AuditReviewerReceiptDecision.values)
                  DropdownMenuItem(
                    value: decision,
                    child: Text(decision.label),
                  ),
              ],
              onChanged:
                  widget.enabled
                      ? (value) {
                        if (value == null) return;
                        widget.onDecisionChanged(value);
                      }
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              enabled: widget.enabled,
              controller: _noteController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reviewer note',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              onChanged: widget.onNoteChanged,
              validator:
                  (value) =>
                      value == null || value.trim().length < 16
                          ? 'Enter reviewer notes'
                          : null,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed:
                    widget.enabled && widget.draft.isReadyToSubmit
                        ? _submit
                        : null,
                icon: const Icon(Icons.mark_email_read_outlined),
                label: const Text('Record receipt'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onSubmit();
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}
