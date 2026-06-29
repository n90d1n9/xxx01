import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_coverage_action_outcome_provider.dart';
import 'incoming_talent_succession_coverage_action_outcome_action_picker.dart';
import 'incoming_talent_succession_coverage_action_outcome_date_fields.dart';
import 'incoming_talent_succession_coverage_action_outcome_form_actions.dart';
import 'incoming_talent_succession_coverage_action_outcome_form_fields.dart';
import 'incoming_talent_succession_coverage_action_outcome_readiness.dart';
import 'incoming_talent_succession_coverage_action_outcome_signal_fields.dart';

class IncomingTalentSuccessionCoverageActionOutcomeForm
    extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionCoverageActionOutcomeForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionCoverageActionOutcomeForm>
  createState() => _IncomingTalentSuccessionCoverageActionOutcomeFormState();
}

class _IncomingTalentSuccessionCoverageActionOutcomeFormState
    extends ConsumerState<IncomingTalentSuccessionCoverageActionOutcomeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _learningController;
  late final TextEditingController _actionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentSuccessionCoverageActionOutcomeDraftProvider,
    );
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _evidenceController = TextEditingController(text: draft.evidenceSummary);
    _learningController = TextEditingController(text: draft.learningSummary);
    _actionController = TextEditingController(text: draft.nextCoverageAction);
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
      incomingTalentSuccessionCoverageActionOutcomeDraftProvider,
    );
    final actions = ref.watch(outcomeReadySuccessionCoverageActionsProvider);

    _sync(_reviewerController, draft.reviewerName);
    _sync(_evidenceController, draft.evidenceSummary);
    _sync(_learningController, draft.learningSummary);
    _sync(_actionController, draft.nextCoverageAction);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentSuccessionCoverageActionOutcomeActionPicker(
            draft: draft,
            actions: actions,
            onChanged: _selectAction,
          ),
          const SizedBox(height: 12),
          if (actions.isEmpty)
            const HrisListSurface(
              child: Text(
                'No resolved coverage actions are ready for outcome review.',
              ),
            )
          else ...[
            IncomingTalentSuccessionCoverageActionOutcomeTextInput(
              controller: _reviewerController,
              label: 'Outcome reviewer',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageActionOutcomeDraftProvider
                            .notifier,
                      )
                      .setReviewerName,
              validator:
                  (value) => validateCoverageActionOutcomeRequired(
                    value,
                    'an outcome reviewer',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageActionOutcomeDateFields(
              draft: draft,
              onSelectReviewDate: _selectReviewDate,
              onSelectNextReviewDate: _selectNextReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageActionOutcomeSignalFields(
              draft: draft,
              onDecisionChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageActionOutcomeDraftProvider
                            .notifier,
                      )
                      .setDecision,
              onRiskChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageActionOutcomeDraftProvider
                            .notifier,
                      )
                      .setResidualRisk,
              onCoverageScoreChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageActionOutcomeDraftProvider
                            .notifier,
                      )
                      .setCoverageScoreAfter,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageActionOutcomeTextInput(
              controller: _evidenceController,
              label: 'Evidence summary',
              icon: Icons.description_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageActionOutcomeDraftProvider
                            .notifier,
                      )
                      .setEvidenceSummary,
              validator:
                  (value) => coverageActionOutcomeLongTextError(
                    value,
                    'evidence summary',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageActionOutcomeTextInput(
              controller: _learningController,
              label: 'Learning summary',
              icon: Icons.school_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageActionOutcomeDraftProvider
                            .notifier,
                      )
                      .setLearningSummary,
              validator:
                  (value) => coverageActionOutcomeLongTextError(
                    value,
                    'learning summary',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageActionOutcomeTextInput(
              controller: _actionController,
              label: 'Next coverage action',
              icon: Icons.route_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageActionOutcomeDraftProvider
                            .notifier,
                      )
                      .setNextCoverageAction,
              validator:
                  (value) => coverageActionOutcomeLongTextError(
                    value,
                    'next coverage action',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageActionOutcomeDraftReadiness(
              draft: draft,
            ),
            const SizedBox(height: 14),
            IncomingTalentSuccessionCoverageActionOutcomeFormActions(
              draft: draft,
              onClear:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageActionOutcomeDraftProvider
                            .notifier,
                      )
                      .clear,
              onSubmit: _submitOutcome,
            ),
          ],
        ],
      ),
    );
  }

  void _selectAction(String? actionId) {
    if (actionId == null) return;
    final actions = ref.read(outcomeReadySuccessionCoverageActionsProvider);
    final action = actions.firstWhere((item) => item.id == actionId);
    ref
        .read(
          incomingTalentSuccessionCoverageActionOutcomeDraftProvider.notifier,
        )
        .initializeFromAction(action);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(
      incomingTalentSuccessionCoverageActionOutcomeDraftProvider,
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
          incomingTalentSuccessionCoverageActionOutcomeDraftProvider.notifier,
        )
        .setReviewDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(
      incomingTalentSuccessionCoverageActionOutcomeDraftProvider,
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
          incomingTalentSuccessionCoverageActionOutcomeDraftProvider.notifier,
        )
        .setNextReviewDate(picked);
  }

  void _submitOutcome() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentSuccessionCoverageActionOutcomeDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final outcome = ref
          .read(incomingTalentSuccessionCoverageActionOutcomesProvider.notifier)
          .submitDraft(draft);
      ref
          .read(
            incomingTalentSuccessionCoverageActionOutcomeDraftProvider.notifier,
          )
          .clear();
      _showMessage('${outcome.id} submitted for ${outcome.scopeLabel}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
