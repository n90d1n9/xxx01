import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_commitment_action_models.dart';
import '../models/incoming_talent_risk_council_commitment_log_models.dart';
import '../states/incoming_talent_risk_council_commitment_action_provider.dart';
import 'incoming_talent_risk_council_commitment_action_commitment_picker.dart';
import 'incoming_talent_risk_council_commitment_action_form_actions.dart';
import 'incoming_talent_risk_council_commitment_action_form_fields.dart';

class IncomingTalentRiskCouncilCommitmentActionForm
    extends ConsumerStatefulWidget {
  final List<IncomingTalentRiskCouncilCommitmentLogItem> commitments;

  const IncomingTalentRiskCouncilCommitmentActionForm({
    super.key,
    required this.commitments,
  });

  @override
  ConsumerState<IncomingTalentRiskCouncilCommitmentActionForm> createState() =>
      _IncomingTalentRiskCouncilCommitmentActionFormState();
}

class _IncomingTalentRiskCouncilCommitmentActionFormState
    extends ConsumerState<IncomingTalentRiskCouncilCommitmentActionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _actionController;
  late final TextEditingController _evidenceExpectationController;
  late final TextEditingController _evidenceNoteController;
  late final TextEditingController _cadenceController;
  late final TextEditingController _blockerController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentRiskCouncilCommitmentActionDraftProvider,
    );
    _ownerController = TextEditingController(text: draft.ownerName);
    _actionController = TextEditingController(text: draft.actionPlan);
    _evidenceExpectationController = TextEditingController(
      text: draft.evidenceExpectation,
    );
    _evidenceNoteController = TextEditingController(text: draft.evidenceNote);
    _cadenceController = TextEditingController(text: draft.followUpCadence);
    _blockerController = TextEditingController(text: draft.blockerNote);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _actionController.dispose();
    _evidenceExpectationController.dispose();
    _evidenceNoteController.dispose();
    _cadenceController.dispose();
    _blockerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentRiskCouncilCommitmentActionDraftProvider,
    );

    _sync(_ownerController, draft.ownerName);
    _sync(_actionController, draft.actionPlan);
    _sync(_evidenceExpectationController, draft.evidenceExpectation);
    _sync(_evidenceNoteController, draft.evidenceNote);
    _sync(_cadenceController, draft.followUpCadence);
    _sync(_blockerController, draft.blockerNote);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentRiskCouncilCommitmentActionCommitmentPicker(
            draft: draft,
            commitments: widget.commitments,
            onChanged: _selectCommitment,
          ),
          const SizedBox(height: 12),
          if (widget.commitments.isEmpty)
            const HrisListSurface(
              child: Text('No council commitments are ready for action.'),
            )
          else ...[
            IncomingTalentRiskCouncilCommitmentActionTextInput(
              controller: _ownerController,
              label: 'Action owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilCommitmentActionDraftProvider
                            .notifier,
                      )
                      .setOwnerName,
              validator:
                  (value) => validateRiskCouncilCommitmentActionRequired(
                    value,
                    'an action owner',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilCommitmentActionDueDateField(
              draft: draft,
              onSelectDueDate: _selectDueDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilCommitmentActionTextInput(
              controller: _actionController,
              label: 'Action plan',
              icon: Icons.task_alt_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilCommitmentActionDraftProvider
                            .notifier,
                      )
                      .setActionPlan,
              validator:
                  (value) => riskCouncilCommitmentActionLongTextError(
                    value,
                    'action plan',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilCommitmentActionTextInput(
              controller: _evidenceExpectationController,
              label: 'Evidence expectation',
              icon: Icons.article_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilCommitmentActionDraftProvider
                            .notifier,
                      )
                      .setEvidenceExpectation,
              validator:
                  (value) => riskCouncilCommitmentActionLongTextError(
                    value,
                    'evidence expectation',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilCommitmentActionTextInput(
              controller: _evidenceNoteController,
              label: 'Evidence note',
              icon: Icons.verified_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilCommitmentActionDraftProvider
                            .notifier,
                      )
                      .setEvidenceNote,
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilCommitmentActionTextInput(
              controller: _cadenceController,
              label: 'Follow-up cadence',
              icon: Icons.repeat_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilCommitmentActionDraftProvider
                            .notifier,
                      )
                      .setFollowUpCadence,
              validator:
                  (value) => riskCouncilCommitmentActionLongTextError(
                    value,
                    'follow-up cadence',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilCommitmentActionTextInput(
              controller: _blockerController,
              label: 'Blocker note',
              icon: Icons.report_problem_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilCommitmentActionDraftProvider
                            .notifier,
                      )
                      .setBlockerNote,
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilCommitmentActionDraftReadiness(
              draft: draft,
            ),
            const SizedBox(height: 14),
            IncomingTalentRiskCouncilCommitmentActionFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear:
                  ref
                      .read(
                        incomingTalentRiskCouncilCommitmentActionDraftProvider
                            .notifier,
                      )
                      .clear,
              onSubmit: _submitAction,
            ),
          ],
        ],
      ),
    );
  }

  void _selectCommitment(String? commitmentId) {
    if (commitmentId == null) return;
    final commitment = widget.commitments.firstWhere(
      (item) => item.id == commitmentId,
    );
    ref
        .read(incomingTalentRiskCouncilCommitmentActionDraftProvider.notifier)
        .initializeFromCommitment(commitment);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(
      incomingTalentRiskCouncilCommitmentActionDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentRiskCouncilCommitmentActionDraftProvider.notifier)
        .setDueDate(picked);
  }

  void _submitAction() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentRiskCouncilCommitmentActionDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final action = ref
          .read(incomingTalentRiskCouncilCommitmentActionsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentRiskCouncilCommitmentActionDraftProvider.notifier)
          .clear();
      _showMessage('${action.id} created for ${action.ownerName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
