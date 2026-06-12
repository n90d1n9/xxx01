import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_intervention_outcome_models.dart';
import '../states/incoming_talent_development_intervention_outcome_provider.dart';
import 'incoming_talent_development_intervention_outcome_form_fields.dart';

class IncomingTalentDevelopmentInterventionOutcomeForm
    extends ConsumerStatefulWidget {
  const IncomingTalentDevelopmentInterventionOutcomeForm({super.key});

  @override
  ConsumerState<IncomingTalentDevelopmentInterventionOutcomeForm>
  createState() => _IncomingTalentDevelopmentInterventionOutcomeFormState();
}

class _IncomingTalentDevelopmentInterventionOutcomeFormState
    extends ConsumerState<IncomingTalentDevelopmentInterventionOutcomeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _learningController;
  late final TextEditingController _nextActionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentDevelopmentInterventionOutcomeDraftProvider,
    );
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _evidenceController = TextEditingController(text: draft.evidenceSummary);
    _learningController = TextEditingController(text: draft.learningSummary);
    _nextActionController = TextEditingController(text: draft.nextAction);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _evidenceController.dispose();
    _learningController.dispose();
    _nextActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentDevelopmentInterventionOutcomeDraftProvider,
    );
    final interventions = ref.watch(
      outcomeReadyDevelopmentInterventionsProvider,
    );
    final notifier = ref.read(
      incomingTalentDevelopmentInterventionOutcomeDraftProvider.notifier,
    );

    _sync(_reviewerController, draft.reviewerName);
    _sync(_evidenceController, draft.evidenceSummary);
    _sync(_learningController, draft.learningSummary);
    _sync(_nextActionController, draft.nextAction);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentDevelopmentInterventionOutcomePicker(
            draft: draft,
            interventions: interventions,
            onChanged: _selectIntervention,
          ),
          const SizedBox(height: 12),
          if (interventions.isEmpty)
            const _EmptyOutcomeSource()
          else ...[
            IncomingTalentDevelopmentInterventionOutcomeTextInput(
              controller: _reviewerController,
              label: 'Outcome reviewer',
              icon: Icons.badge_outlined,
              onChanged: notifier.setReviewerName,
              validator:
                  (value) =>
                      IncomingTalentDevelopmentInterventionOutcomeDraft.validateRequired(
                        value,
                        'an outcome reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeDateFields(
              draft: draft,
              onSelectReviewDate: _selectReviewDate,
              onSelectNextReviewDate: _selectNextReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeSignalFields(
              draft: draft,
              onDecisionChanged: notifier.setDecision,
              onConfidenceChanged: notifier.setConfidenceAfter,
              onReleaseRiskChanged: notifier.setRemainingReleaseRiskCount,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeTextInput(
              controller: _evidenceController,
              label: 'Evidence summary',
              icon: Icons.description_outlined,
              minLines: 3,
              onChanged: notifier.setEvidenceSummary,
              validator:
                  IncomingTalentDevelopmentInterventionOutcomeDraft
                      .validateEvidenceSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeTextInput(
              controller: _learningController,
              label: 'Learning summary',
              icon: Icons.school_outlined,
              minLines: 3,
              onChanged: notifier.setLearningSummary,
              validator:
                  IncomingTalentDevelopmentInterventionOutcomeDraft
                      .validateLearningSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeTextInput(
              controller: _nextActionController,
              label: 'Next action',
              icon: Icons.route_outlined,
              minLines: 3,
              onChanged: notifier.setNextAction,
              validator:
                  IncomingTalentDevelopmentInterventionOutcomeDraft
                      .validateNextAction,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeReadiness(draft: draft),
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
                  key: const Key('incoming-talent-intervention-outcome-submit'),
                  onPressed: draft.isReadyToSubmit ? _submitOutcome : null,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Submit outcome'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectIntervention(String? interventionId) {
    if (interventionId == null) return;
    final interventions = ref.read(
      outcomeReadyDevelopmentInterventionsProvider,
    );
    final action = interventions.firstWhere(
      (item) => item.id == interventionId,
    );
    ref
        .read(
          incomingTalentDevelopmentInterventionOutcomeDraftProvider.notifier,
        )
        .initializeFromIntervention(action);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(
      incomingTalentDevelopmentInterventionOutcomeDraftProvider,
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
          incomingTalentDevelopmentInterventionOutcomeDraftProvider.notifier,
        )
        .setReviewDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(
      incomingTalentDevelopmentInterventionOutcomeDraftProvider,
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
          incomingTalentDevelopmentInterventionOutcomeDraftProvider.notifier,
        )
        .setNextReviewDate(picked);
  }

  void _submitOutcome() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentDevelopmentInterventionOutcomeDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final outcome = ref
          .read(incomingTalentDevelopmentInterventionOutcomesProvider.notifier)
          .submitDraft(draft);
      ref
          .read(
            incomingTalentDevelopmentInterventionOutcomeDraftProvider.notifier,
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

class _EmptyOutcomeSource extends StatelessWidget {
  const _EmptyOutcomeSource();

  @override
  Widget build(BuildContext context) {
    return const HrisListSurface(
      child: Text('No resolved development interventions need outcome review.'),
    );
  }
}
