import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_coverage_council_follow_up_provider.dart';
import 'incoming_talent_succession_coverage_council_follow_up_decision_picker.dart';
import 'incoming_talent_succession_coverage_council_follow_up_form_actions.dart';
import 'incoming_talent_succession_coverage_council_follow_up_form_fields.dart';

class IncomingTalentSuccessionCoverageCouncilFollowUpForm
    extends ConsumerStatefulWidget {
  final List<IncomingTalentSuccessionCoverageCouncilDecision> decisions;

  const IncomingTalentSuccessionCoverageCouncilFollowUpForm({
    super.key,
    required this.decisions,
  });

  @override
  ConsumerState<IncomingTalentSuccessionCoverageCouncilFollowUpForm>
  createState() => _IncomingTalentSuccessionCoverageCouncilFollowUpFormState();
}

class _IncomingTalentSuccessionCoverageCouncilFollowUpFormState
    extends ConsumerState<IncomingTalentSuccessionCoverageCouncilFollowUpForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _actionController;
  late final TextEditingController _successController;
  late final TextEditingController _blockerController;
  late final TextEditingController _escalationController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider,
    );
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
    final draft = ref.watch(
      incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider,
    );

    _sync(_ownerController, draft.followUpOwnerName);
    _sync(_actionController, draft.actionPlan);
    _sync(_successController, draft.successCriteria);
    _sync(_blockerController, draft.blockerNote);
    _sync(_escalationController, draft.escalationReason);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentSuccessionCoverageCouncilFollowUpDecisionPicker(
            draft: draft,
            decisions: widget.decisions,
            onChanged: _selectDecision,
          ),
          const SizedBox(height: 12),
          if (widget.decisions.isEmpty)
            const HrisListSurface(
              child: Text('No council decisions need follow-up yet.'),
            )
          else ...[
            IncomingTalentSuccessionCoverageCouncilFollowUpTextInput(
              controller: _ownerController,
              label: 'Follow-up owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider
                            .notifier,
                      )
                      .setFollowUpOwnerName,
              validator:
                  (value) => validateCoverageCouncilFollowUpRequired(
                    value,
                    'a follow-up owner',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageCouncilFollowUpTypeAndDateFields(
              draft: draft,
              onTypeChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider
                            .notifier,
                      )
                      .setFollowUpType,
              onSelectDueDate: _selectDueDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageCouncilFollowUpTextInput(
              controller: _actionController,
              label: 'Action plan',
              icon: Icons.task_alt_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider
                            .notifier,
                      )
                      .setActionPlan,
              validator:
                  (value) => coverageCouncilFollowUpLongTextError(
                    value,
                    'action plan',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageCouncilFollowUpTextInput(
              controller: _successController,
              label: 'Success criteria',
              icon: Icons.flag_circle_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider
                            .notifier,
                      )
                      .setSuccessCriteria,
              validator:
                  (value) => coverageCouncilFollowUpLongTextError(
                    value,
                    'success criteria',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageCouncilFollowUpTextInput(
              controller: _blockerController,
              label: 'Blocker note',
              icon: Icons.report_problem_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider
                            .notifier,
                      )
                      .setBlockerNote,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageCouncilFollowUpTextInput(
              controller: _escalationController,
              label: 'Escalation reason',
              icon: Icons.trending_up_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider
                            .notifier,
                      )
                      .setEscalationReason,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageCouncilFollowUpDraftReadiness(
              draft: draft,
            ),
            const SizedBox(height: 14),
            IncomingTalentSuccessionCoverageCouncilFollowUpFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider
                            .notifier,
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
        .read(
          incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider.notifier,
        )
        .initializeFromDecision(decision);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(
      incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider,
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
          incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider.notifier,
        )
        .setDueDate(picked);
  }

  void _submitFollowUp() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final followUp = ref
          .read(
            incomingTalentSuccessionCoverageCouncilFollowUpsProvider.notifier,
          )
          .submitDraft(draft);
      ref
          .read(
            incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider
                .notifier,
          )
          .clear();
      _showMessage('${followUp.id} created for ${followUp.scopeLabel}');
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
    controller.text = value;
  }
}
