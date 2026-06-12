import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_mobility_cadence_intervention_outcome_provider.dart';
import 'incoming_talent_mobility_cadence_intervention_outcome_form_actions.dart';
import 'incoming_talent_mobility_cadence_intervention_outcome_form_fields.dart';
import 'incoming_talent_mobility_cadence_intervention_outcome_picker.dart';
import 'incoming_talent_mobility_cadence_intervention_outcome_readiness.dart';

class IncomingTalentMobilityCadenceInterventionOutcomeForm
    extends ConsumerStatefulWidget {
  const IncomingTalentMobilityCadenceInterventionOutcomeForm({super.key});

  @override
  ConsumerState<IncomingTalentMobilityCadenceInterventionOutcomeForm>
  createState() => _IncomingTalentMobilityCadenceInterventionOutcomeFormState();
}

class _IncomingTalentMobilityCadenceInterventionOutcomeFormState
    extends
        ConsumerState<IncomingTalentMobilityCadenceInterventionOutcomeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _learningController;
  late final TextEditingController _actionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentMobilityCadenceInterventionOutcomeDraftProvider,
    );
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _evidenceController = TextEditingController(text: draft.evidenceSummary);
    _learningController = TextEditingController(text: draft.learningSummary);
    _actionController = TextEditingController(text: draft.nextCadenceAction);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _evidenceController.dispose();
    _learningController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentMobilityCadenceInterventionOutcomeDraftProvider,
    );
    final interventions = ref.watch(
      outcomeReadyMobilityCadenceInterventionsProvider,
    );
    final notifier = ref.read(
      incomingTalentMobilityCadenceInterventionOutcomeDraftProvider.notifier,
    );

    _sync(_reviewerController, draft.reviewerName);
    _sync(_evidenceController, draft.evidenceSummary);
    _sync(_learningController, draft.learningSummary);
    _sync(_actionController, draft.nextCadenceAction);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentMobilityCadenceInterventionOutcomePicker(
            draft: draft,
            interventions: interventions,
            onChanged: _selectIntervention,
          ),
          const SizedBox(height: 12),
          if (interventions.isEmpty)
            const HrisListSurface(
              child: Text('No resolved mobility interventions need outcome.'),
            )
          else ...[
            IncomingTalentMobilityCadenceInterventionOutcomeTextInput(
              controller: _reviewerController,
              label: 'Outcome reviewer',
              icon: Icons.badge_outlined,
              onChanged: notifier.setReviewerName,
              validator:
                  (value) =>
                      IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateRequired(
                        value,
                        'an outcome reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceInterventionOutcomeDateFields(
              draft: draft,
              onSelectReviewDate: _selectReviewDate,
              onSelectNextReviewDate: _selectNextReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceInterventionOutcomeSignalFields(
              draft: draft,
              onDecisionChanged: notifier.setDecision,
              onSustainabilityChanged: notifier.setSustainability,
              onResidualRiskChanged: notifier.setResidualRiskAfter,
              onConfidenceChanged: notifier.setHostConfidenceAfter,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceInterventionOutcomeTextInput(
              controller: _evidenceController,
              label: 'Evidence summary',
              icon: Icons.description_outlined,
              minLines: 3,
              onChanged: notifier.setEvidenceSummary,
              validator:
                  IncomingTalentMobilityCadenceInterventionOutcomeDraft
                      .validateEvidenceSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceInterventionOutcomeTextInput(
              controller: _learningController,
              label: 'Learning summary',
              icon: Icons.school_outlined,
              minLines: 3,
              onChanged: notifier.setLearningSummary,
              validator:
                  IncomingTalentMobilityCadenceInterventionOutcomeDraft
                      .validateLearningSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceInterventionOutcomeTextInput(
              controller: _actionController,
              label: 'Next cadence action',
              icon: Icons.route_outlined,
              minLines: 3,
              onChanged: notifier.setNextCadenceAction,
              validator:
                  IncomingTalentMobilityCadenceInterventionOutcomeDraft
                      .validateNextCadenceAction,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceInterventionOutcomeDraftReadiness(
              draft: draft,
            ),
            const SizedBox(height: 14),
            IncomingTalentMobilityCadenceInterventionOutcomeFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear: notifier.clear,
              onSubmit: _submitOutcome,
            ),
          ],
        ],
      ),
    );
  }

  void _selectIntervention(String? interventionId) {
    if (interventionId == null) return;
    final interventions = ref.read(
      outcomeReadyMobilityCadenceInterventionsProvider,
    );
    final intervention = interventions.firstWhere(
      (item) => item.id == interventionId,
    );
    ref
        .read(
          incomingTalentMobilityCadenceInterventionOutcomeDraftProvider
              .notifier,
        )
        .initializeFromIntervention(intervention);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(
      incomingTalentMobilityCadenceInterventionOutcomeDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.reviewDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(
          incomingTalentMobilityCadenceInterventionOutcomeDraftProvider
              .notifier,
        )
        .setReviewDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(
      incomingTalentMobilityCadenceInterventionOutcomeDraftProvider,
    );
    final reviewDate = draft.reviewDate ?? draft.asOfDate;
    final firstDate = reviewDate.add(const Duration(days: 1));
    final initialDate =
        draft.nextReviewDate != null &&
                draft.nextReviewDate!.isAfter(reviewDate)
            ? draft.nextReviewDate!
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
          incomingTalentMobilityCadenceInterventionOutcomeDraftProvider
              .notifier,
        )
        .setNextReviewDate(picked);
  }

  void _submitOutcome() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentMobilityCadenceInterventionOutcomeDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final outcome = ref
          .read(
            incomingTalentMobilityCadenceInterventionOutcomesProvider.notifier,
          )
          .submitDraft(draft);
      ref
          .read(
            incomingTalentMobilityCadenceInterventionOutcomeDraftProvider
                .notifier,
          )
          .clear();
      _showMessage('${outcome.id} submitted for ${outcome.candidateName}');
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
