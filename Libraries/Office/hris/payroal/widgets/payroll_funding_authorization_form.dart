import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollFundingAuthorizationForm extends StatefulWidget {
  final PayrollFundingAuthorizationDraft draft;
  final ValueChanged<String> onAuthorizedByChanged;
  final ValueChanged<String> onReferenceCodeChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const PayrollFundingAuthorizationForm({
    super.key,
    required this.draft,
    required this.onAuthorizedByChanged,
    required this.onReferenceCodeChanged,
    required this.onNotesChanged,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<PayrollFundingAuthorizationForm> createState() =>
      _PayrollFundingAuthorizationFormState();
}

class _PayrollFundingAuthorizationFormState
    extends State<PayrollFundingAuthorizationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _authorizedByController;
  late final TextEditingController _referenceController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _authorizedByController = TextEditingController(
      text: widget.draft.authorizedBy,
    );
    _referenceController = TextEditingController(
      text: widget.draft.referenceCode,
    );
    _notesController = TextEditingController(text: widget.draft.notes);
  }

  @override
  void didUpdateWidget(covariant PayrollFundingAuthorizationForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_authorizedByController, widget.draft.authorizedBy);
    _sync(_referenceController, widget.draft.referenceCode);
    _sync(_notesController, widget.draft.notes);
  }

  @override
  void dispose() {
    _authorizedByController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.draft.accountLabel.isEmpty) {
      return HrisListSurface(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.fact_check_outlined,
              color: HrisColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Select a ready funding account to prepare authorization evidence.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return HrisListSurface(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                HrisStatusPill(
                  label: widget.draft.accountLabel,
                  color: HrisColors.primary,
                ),
                Text(
                  'Authorization evidence',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final fields = [
                  TextFormField(
                    controller: _authorizedByController,
                    decoration: const InputDecoration(
                      labelText: 'Authorizer',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.how_to_reg_outlined),
                    ),
                    onChanged: widget.onAuthorizedByChanged,
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter an authorizer'
                                : null,
                  ),
                  TextFormField(
                    controller: _referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Reference',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                    ),
                    onChanged: widget.onReferenceCodeChanged,
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter an authorization reference'
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
            TextFormField(
              controller: _notesController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Authorization notes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              onChanged: widget.onNotesChanged,
              validator:
                  (value) =>
                      value == null || value.trim().length < 12
                          ? 'Enter authorization notes'
                          : null,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: widget.draft.isReadyToSubmit ? _submit : null,
                  icon: const Icon(Icons.verified_user_outlined),
                  label: const Text('Authorize funding'),
                ),
              ],
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
