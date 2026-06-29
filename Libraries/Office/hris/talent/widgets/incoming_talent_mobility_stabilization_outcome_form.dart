import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_mobility_stabilization_outcome_provider.dart';
import 'incoming_talent_mobility_stabilization_outcome_action_picker.dart';
import 'incoming_talent_mobility_stabilization_outcome_form_actions.dart';
import 'incoming_talent_mobility_stabilization_outcome_form_fields.dart';
import 'incoming_talent_mobility_stabilization_outcome_readiness.dart';

class IncomingTalentMobilityStabilizationOutcomeForm
    extends ConsumerStatefulWidget {
  const IncomingTalentMobilityStabilizationOutcomeForm({super.key});

  @override
  ConsumerState<IncomingTalentMobilityStabilizationOutcomeForm> createState() =>
      _IncomingTalentMobilityStabilizationOutcomeFormState();
}

class _IncomingTalentMobilityStabilizationOutcomeFormState
    extends ConsumerState<IncomingTalentMobilityStabilizationOutcomeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _learningController;
  late final TextEditingController _cadenceController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentMobilityStabilizationOutcomeDraftProvider,
    );
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _evidenceController = TextEditingController(text: draft.evidenceSummary);
    _learningController = TextEditingController(text: draft.learningSummary);
    _cadenceController = TextEditingController(text: draft.nextCadenceAction);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _evidenceController.dispose();
    _learningController.dispose();
    _cadenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentMobilityStabilizationOutcomeDraftProvider,
    );
    final actions = ref.watch(outcomeReadyMobilityStabilizationActionsProvider);
    final notifier = ref.read(
      incomingTalentMobilityStabilizationOutcomeDraftProvider.notifier,
    );

    _sync(_reviewerController, draft.reviewerName);
    _sync(_evidenceController, draft.evidenceSummary);
    _sync(_learningController, draft.learningSummary);
    _sync(_cadenceController, draft.nextCadenceAction);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentMobilityStabilizationOutcomeActionPicker(
            draft: draft,
            actions: actions,
            onChanged: _selectAction,
          ),
          const SizedBox(height: 12),
          if (actions.isEmpty)
            const HrisListSurface(
              child: Text(
                'No completed mobility stabilization actions are ready.',
              ),
            )
          else ...[
            IncomingTalentMobilityStabilizationOutcomeTextInput(
              controller: _reviewerController,
              label: 'Outcome reviewer',
              icon: Icons.badge_outlined,
              onChanged: notifier.setReviewerName,
              validator:
                  (value) =>
                      IncomingTalentMobilityStabilizationOutcomeDraft.validateRequired(
                        value,
                        'an outcome reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityStabilizationOutcomeDateFields(
              draft: draft,
              onSelectOutcomeDate: _selectOutcomeDate,
              onSelectNextReviewDate: _selectNextReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityStabilizationOutcomeSignalFields(
              draft: draft,
              onDecisionChanged: notifier.setDecision,
              onResidualRiskChanged: notifier.setResidualRisk,
              onConfidenceChanged: notifier.setHostConfidenceAfter,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityStabilizationOutcomeTextInput(
              controller: _evidenceController,
              label: 'Evidence summary',
              icon: Icons.description_outlined,
              minLines: 3,
              onChanged: notifier.setEvidenceSummary,
              validator:
                  IncomingTalentMobilityStabilizationOutcomeDraft
                      .validateEvidenceSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityStabilizationOutcomeTextInput(
              controller: _learningController,
              label: 'Learning summary',
              icon: Icons.school_outlined,
              minLines: 3,
              onChanged: notifier.setLearningSummary,
              validator:
                  IncomingTalentMobilityStabilizationOutcomeDraft
                      .validateLearningSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityStabilizationOutcomeTextInput(
              controller: _cadenceController,
              label: 'Next cadence action',
              icon: Icons.route_outlined,
              minLines: 3,
              onChanged: notifier.setNextCadenceAction,
              validator:
                  IncomingTalentMobilityStabilizationOutcomeDraft
                      .validateNextCadenceAction,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityStabilizationOutcomeDraftReadiness(
              draft: draft,
            ),
            const SizedBox(height: 14),
            IncomingTalentMobilityStabilizationOutcomeFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear: notifier.clear,
              onSubmit: _submitOutcome,
            ),
          ],
        ],
      ),
    );
  }

  void _selectAction(String? actionId) {
    if (actionId == null) return;
    final actions = ref.read(outcomeReadyMobilityStabilizationActionsProvider);
    final action = actions.firstWhere((item) => item.id == actionId);
    ref
        .read(incomingTalentMobilityStabilizationOutcomeDraftProvider.notifier)
        .initializeFromAction(action);
  }

  Future<void> _selectOutcomeDate() async {
    final draft = ref.read(
      incomingTalentMobilityStabilizationOutcomeDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.outcomeDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentMobilityStabilizationOutcomeDraftProvider.notifier)
        .setOutcomeDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(
      incomingTalentMobilityStabilizationOutcomeDraftProvider,
    );
    final outcomeDate = draft.outcomeDate ?? draft.asOfDate;
    final firstDate = outcomeDate.add(const Duration(days: 1));
    final initialDate =
        draft.nextReviewDate != null &&
                draft.nextReviewDate!.isAfter(outcomeDate)
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
        .read(incomingTalentMobilityStabilizationOutcomeDraftProvider.notifier)
        .setNextReviewDate(picked);
  }

  void _submitOutcome() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentMobilityStabilizationOutcomeDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final outcome = ref
          .read(incomingTalentMobilityStabilizationOutcomesProvider.notifier)
          .submitDraft(draft);
      ref
          .read(
            incomingTalentMobilityStabilizationOutcomeDraftProvider.notifier,
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
