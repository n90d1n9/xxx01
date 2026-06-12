import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_decision_models.dart';
import '../models/incoming_talent_risk_council_follow_up_models.dart';
import '../states/incoming_talent_risk_council_follow_up_provider.dart';
import 'incoming_talent_risk_council_follow_up_decision_picker.dart';
import 'incoming_talent_risk_council_follow_up_form_actions.dart';
import 'incoming_talent_risk_council_follow_up_form_fields.dart';

class IncomingTalentRiskCouncilFollowUpForm extends ConsumerStatefulWidget {
  final List<IncomingTalentRiskCouncilDecision> decisions;

  const IncomingTalentRiskCouncilFollowUpForm({
    super.key,
    required this.decisions,
  });

  @override
  ConsumerState<IncomingTalentRiskCouncilFollowUpForm> createState() =>
      _IncomingTalentRiskCouncilFollowUpFormState();
}

class _IncomingTalentRiskCouncilFollowUpFormState
    extends ConsumerState<IncomingTalentRiskCouncilFollowUpForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _actionController;
  late final TextEditingController _successController;
  late final TextEditingController _blockerController;
  late final TextEditingController _escalationController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentRiskCouncilFollowUpDraftProvider);
    _ownerController = TextEditingController(text: draft.followUpOwnerName);
    _actionController = TextEditingController(text: draft.actionPlan);
    _successController = TextEditingController(text: draft.successCriteria);
    _blockerController = TextEditingController(text: draft.blockerNote);
    _escalationController = TextEditingController(text: draft.escalationReason);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _actionController.dispose();
    _successController.dispose();
    _blockerController.dispose();
    _escalationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentRiskCouncilFollowUpDraftProvider);

    _sync(_ownerController, draft.followUpOwnerName);
    _sync(_actionController, draft.actionPlan);
    _sync(_successController, draft.successCriteria);
    _sync(_blockerController, draft.blockerNote);
    _sync(_escalationController, draft.escalationReason);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentRiskCouncilFollowUpDecisionPicker(
            draft: draft,
            decisions: widget.decisions,
            onChanged: _selectDecision,
          ),
          const SizedBox(height: 12),
          if (widget.decisions.isEmpty)
            const HrisListSurface(
              child: Text('No risk council decisions need follow-up yet.'),
            )
          else ...[
            IncomingTalentRiskCouncilFollowUpTextInput(
              controller: _ownerController,
              label: 'Follow-up owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilFollowUpDraftProvider.notifier,
                      )
                      .setFollowUpOwnerName,
              validator:
                  (value) => validateRiskCouncilFollowUpRequired(
                    value,
                    'a follow-up owner',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilFollowUpTypeAndDateFields(
              draft: draft,
              onTypeChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilFollowUpDraftProvider.notifier,
                      )
                      .setFollowUpType,
              onSelectDueDate: _selectDueDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilFollowUpTextInput(
              controller: _actionController,
              label: 'Action plan',
              icon: Icons.task_alt_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilFollowUpDraftProvider.notifier,
                      )
                      .setActionPlan,
              validator:
                  (value) =>
                      riskCouncilFollowUpLongTextError(value, 'action plan'),
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilFollowUpTextInput(
              controller: _successController,
              label: 'Success criteria',
              icon: Icons.flag_circle_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilFollowUpDraftProvider.notifier,
                      )
                      .setSuccessCriteria,
              validator:
                  (value) => riskCouncilFollowUpLongTextError(
                    value,
                    'success criteria',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilFollowUpTextInput(
              controller: _blockerController,
              label: 'Blocker note',
              icon: Icons.report_problem_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilFollowUpDraftProvider.notifier,
                      )
                      .setBlockerNote,
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilFollowUpTextInput(
              controller: _escalationController,
              label: 'Escalation reason',
              icon: Icons.trending_up_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilFollowUpDraftProvider.notifier,
                      )
                      .setEscalationReason,
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilFollowUpDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            IncomingTalentRiskCouncilFollowUpFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear:
                  ref
                      .read(
                        incomingTalentRiskCouncilFollowUpDraftProvider.notifier,
                      )
                      .clear,
              onSubmit: _submitFollowUp,
            ),
          ],
        ],
      ),
    );
  }

  void _selectDecision(String? decisionId) {
    if (decisionId == null) return;
    final decision = widget.decisions.firstWhere(
      (item) => item.id == decisionId,
    );
    ref
        .read(incomingTalentRiskCouncilFollowUpDraftProvider.notifier)
        .initializeFromDecision(decision);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(incomingTalentRiskCouncilFollowUpDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentRiskCouncilFollowUpDraftProvider.notifier)
        .setDueDate(picked);
  }

  void _submitFollowUp() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentRiskCouncilFollowUpDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final followUp = ref
          .read(incomingTalentRiskCouncilFollowUpsProvider.notifier)
          .submitDraft(draft);
      ref.read(incomingTalentRiskCouncilFollowUpDraftProvider.notifier).clear();
      _showMessage('${followUp.id} created for ${followUp.candidateName}');
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
