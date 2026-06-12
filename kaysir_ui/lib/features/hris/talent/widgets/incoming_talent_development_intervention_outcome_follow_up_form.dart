import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_intervention_outcome_follow_up_models.dart';
import '../states/incoming_talent_development_intervention_outcome_follow_up_provider.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_form_fields.dart';

class IncomingTalentDevelopmentInterventionOutcomeFollowUpForm
    extends ConsumerStatefulWidget {
  const IncomingTalentDevelopmentInterventionOutcomeFollowUpForm({super.key});

  @override
  ConsumerState<IncomingTalentDevelopmentInterventionOutcomeFollowUpForm>
  createState() =>
      _IncomingTalentDevelopmentInterventionOutcomeFollowUpFormState();
}

class _IncomingTalentDevelopmentInterventionOutcomeFollowUpFormState
    extends
        ConsumerState<
          IncomingTalentDevelopmentInterventionOutcomeFollowUpForm
        > {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _actionController;
  late final TextEditingController _successCriteriaController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider,
    );
    _ownerController = TextEditingController(text: draft.ownerName);
    _actionController = TextEditingController(text: draft.action);
    _successCriteriaController = TextEditingController(
      text: draft.successCriteria,
    );
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _actionController.dispose();
    _successCriteriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider,
    );
    final readyOutcomes = ref.watch(
      followUpReadyDevelopmentInterventionOutcomesProvider,
    );
    final notifier = ref.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider
          .notifier,
    );

    _sync(_ownerController, draft.ownerName);
    _sync(_actionController, draft.action);
    _sync(_successCriteriaController, draft.successCriteria);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentDevelopmentInterventionOutcomeFollowUpPicker(
            draft: draft,
            outcomes: readyOutcomes,
            onChanged: _selectOutcome,
          ),
          const SizedBox(height: 12),
          if (readyOutcomes.isEmpty)
            const _EmptyFollowUpSource()
          else ...[
            IncomingTalentDevelopmentInterventionOutcomeFollowUpTextInput(
              controller: _ownerController,
              label: 'Follow-up owner',
              icon: Icons.badge_outlined,
              onChanged: notifier.setOwnerName,
              validator:
                  (value) =>
                      IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft.validateRequired(
                        value,
                        'a follow-up owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeFollowUpControls(
              draft: draft,
              onSelectDueDate: _selectDueDate,
              onStatusChanged: notifier.setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeFollowUpTextInput(
              controller: _actionController,
              label: 'Follow-up action',
              icon: Icons.route_outlined,
              minLines: 3,
              onChanged: notifier.setAction,
              validator:
                  IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft
                      .validateAction,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeFollowUpTextInput(
              controller: _successCriteriaController,
              label: 'Success criteria',
              icon: Icons.fact_check_outlined,
              minLines: 3,
              onChanged: notifier.setSuccessCriteria,
              validator:
                  IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft
                      .validateSuccessCriteria,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeFollowUpReadiness(
              draft: draft,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: notifier.clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key(
                    'incoming-talent-intervention-outcome-follow-up-submit',
                  ),
                  onPressed: draft.isReadyToSubmit ? _submitFollowUp : null,
                  icon: const Icon(Icons.add_task_outlined),
                  label: const Text('Create follow-up'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectOutcome(String? outcomeId) {
    if (outcomeId == null) return;
    final outcomes = ref.read(
      followUpReadyDevelopmentInterventionOutcomesProvider,
    );
    final outcome = outcomes.firstWhere((item) => item.id == outcomeId);
    ref
        .read(
          incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider
              .notifier,
        )
        .initializeFromOutcome(outcome);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider,
    );
    final firstDate = draft.outcomeReviewDate ?? draft.asOfDate;
    final initialDate =
        draft.dueDate != null && !draft.dueDate!.isBefore(firstDate)
            ? draft.dueDate!
            : firstDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(
          incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider
              .notifier,
        )
        .setDueDate(picked);
  }

  void _submitFollowUp() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final followUp = ref
          .read(
            incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider
                .notifier,
          )
          .submitDraft(draft);
      ref
          .read(
            incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider
                .notifier,
          )
          .clear();
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

class _EmptyFollowUpSource extends StatelessWidget {
  const _EmptyFollowUpSource();

  @override
  Widget build(BuildContext context) {
    return const HrisListSurface(
      child: Text('No intervention outcomes need follow-up planning.'),
    );
  }
}
