import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_activation_escalation_provider.dart';
import 'incoming_talent_succession_activation_escalation_form_fields.dart';

class IncomingTalentSuccessionActivationEscalationForm
    extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionActivationEscalationForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionActivationEscalationForm>
  createState() => _IncomingTalentSuccessionActivationEscalationFormState();
}

class _IncomingTalentSuccessionActivationEscalationFormState
    extends ConsumerState<IncomingTalentSuccessionActivationEscalationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _reasonController;
  late final TextEditingController _decisionController;
  late final TextEditingController _sponsorController;
  late final TextEditingController _successController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentSuccessionActivationEscalationDraftProvider,
    );
    _ownerController = TextEditingController(text: draft.ownerName);
    _reasonController = TextEditingController(text: draft.escalationReason);
    _decisionController = TextEditingController(text: draft.decisionNeeded);
    _sponsorController = TextEditingController(text: draft.sponsorCommitment);
    _successController = TextEditingController(text: draft.successCriteria);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _reasonController.dispose();
    _decisionController.dispose();
    _sponsorController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentSuccessionActivationEscalationDraftProvider,
    );
    final checkIns = ref.watch(
      escalationReadySuccessionActivationCheckInsProvider,
    );

    _sync(_ownerController, draft.ownerName);
    _sync(_reasonController, draft.escalationReason);
    _sync(_decisionController, draft.decisionNeeded);
    _sync(_sponsorController, draft.sponsorCommitment);
    _sync(_successController, draft.successCriteria);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('succession-escalation-${draft.checkInId}'),
            initialValue:
                _checkInExists(checkIns, draft.checkInId)
                    ? draft.checkInId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Attention check-in',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.warning_amber_outlined),
            ),
            items:
                checkIns
                    .map(
                      (checkIn) => DropdownMenuItem(
                        value: checkIn.id,
                        child: Text(
                          '${checkIn.candidateName} - ${checkIn.trend.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: checkIns.isEmpty ? null : _selectCheckIn,
            validator:
                (value) =>
                    IncomingTalentSuccessionActivationEscalationDraft.validateRequired(
                      value,
                      'an attention check-in',
                    ),
          ),
          const SizedBox(height: 12),
          if (checkIns.isEmpty)
            const HrisListSurface(
              child: Text('No watched succession check-ins need escalation.'),
            )
          else ...[
            IncomingTalentSuccessionActivationEscalationTextInput(
              controller: _ownerController,
              label: 'Escalation owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationEscalationDraftProvider
                            .notifier,
                      )
                      .setOwnerName,
              validator:
                  (value) =>
                      IncomingTalentSuccessionActivationEscalationDraft.validateRequired(
                        value,
                        'an owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationEscalationPriorityFields(
              draft: draft,
              onPriorityChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationEscalationDraftProvider
                            .notifier,
                      )
                      .setPriority,
              onSelectDueDate: _selectDueDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationEscalationTextInput(
              controller: _reasonController,
              label: 'Escalation reason',
              icon: Icons.report_problem_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationEscalationDraftProvider
                            .notifier,
                      )
                      .setEscalationReason,
              validator:
                  IncomingTalentSuccessionActivationEscalationDraft
                      .validateEscalationReason,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationEscalationTextInput(
              controller: _decisionController,
              label: 'Decision needed',
              icon: Icons.rule_folder_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationEscalationDraftProvider
                            .notifier,
                      )
                      .setDecisionNeeded,
              validator:
                  IncomingTalentSuccessionActivationEscalationDraft
                      .validateDecisionNeeded,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationEscalationTextInput(
              controller: _sponsorController,
              label: 'Sponsor commitment',
              icon: Icons.handshake_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationEscalationDraftProvider
                            .notifier,
                      )
                      .setSponsorCommitment,
              validator:
                  IncomingTalentSuccessionActivationEscalationDraft
                      .validateSponsorCommitment,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationEscalationTextInput(
              controller: _successController,
              label: 'Success criteria',
              icon: Icons.flag_circle_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationEscalationDraftProvider
                            .notifier,
                      )
                      .setSuccessCriteria,
              validator:
                  IncomingTalentSuccessionActivationEscalationDraft
                      .validateSuccessCriteria,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationEscalationDraftReadiness(
              draft: draft,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentSuccessionActivationEscalationDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key(
                    'incoming-talent-succession-escalation-submit',
                  ),
                  onPressed: draft.isReadyToSubmit ? _submitEscalation : null,
                  icon: const Icon(Icons.escalator_warning_outlined),
                  label: const Text('Create escalation'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectCheckIn(String? checkInId) {
    if (checkInId == null) return;
    final checkIns = ref.read(
      escalationReadySuccessionActivationCheckInsProvider,
    );
    final checkIn = checkIns.firstWhere((item) => item.id == checkInId);
    ref
        .read(
          incomingTalentSuccessionActivationEscalationDraftProvider.notifier,
        )
        .initializeFromCheckIn(checkIn);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(
      incomingTalentSuccessionActivationEscalationDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(
          incomingTalentSuccessionActivationEscalationDraftProvider.notifier,
        )
        .setDueDate(picked);
  }

  void _submitEscalation() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentSuccessionActivationEscalationDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final escalation = ref
          .read(incomingTalentSuccessionActivationEscalationsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(
            incomingTalentSuccessionActivationEscalationDraftProvider.notifier,
          )
          .clear();
      _showMessage('${escalation.id} created for ${escalation.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _checkInExists(
    List<IncomingTalentSuccessionActivationCheckIn> checkIns,
    String checkInId,
  ) {
    return checkIns.any((checkIn) => checkIn.id == checkInId);
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }
}
