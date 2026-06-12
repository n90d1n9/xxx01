import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

/// Captures signer details for final payroll audit close attestation.
class AuditCloseAttestationForm extends StatefulWidget {
  final AuditCloseAttestationDraft draft;
  final bool enabled;
  final ValueChanged<String> onSignedByChanged;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onSubmit;

  const AuditCloseAttestationForm({
    super.key,
    required this.draft,
    required this.enabled,
    required this.onSignedByChanged,
    required this.onRoleChanged,
    required this.onNoteChanged,
    required this.onSubmit,
  });

  @override
  State<AuditCloseAttestationForm> createState() =>
      _AuditCloseAttestationFormState();
}

class _AuditCloseAttestationFormState extends State<AuditCloseAttestationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _signedByController;
  late final TextEditingController _roleController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _signedByController = TextEditingController(text: widget.draft.signedBy);
    _roleController = TextEditingController(text: widget.draft.role);
    _noteController = TextEditingController(text: widget.draft.note);
  }

  @override
  void didUpdateWidget(covariant AuditCloseAttestationForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_signedByController, widget.draft.signedBy);
    _sync(_roleController, widget.draft.role);
    _sync(_noteController, widget.draft.note);
  }

  @override
  void dispose() {
    _signedByController.dispose();
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
              'Final attestation',
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
                    controller: _signedByController,
                    decoration: const InputDecoration(
                      labelText: 'Signer',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.how_to_reg_outlined),
                    ),
                    onChanged: widget.onSignedByChanged,
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter a signer'
                                : null,
                  ),
                  TextFormField(
                    enabled: widget.enabled,
                    controller: _roleController,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    onChanged: widget.onRoleChanged,
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter a signer role'
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
              enabled: widget.enabled,
              controller: _noteController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Attestation note',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fact_check_outlined),
              ),
              onChanged: widget.onNoteChanged,
              validator:
                  (value) =>
                      value == null || value.trim().length < 16
                          ? 'Enter an attestation note'
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
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('Sign audit close'),
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
