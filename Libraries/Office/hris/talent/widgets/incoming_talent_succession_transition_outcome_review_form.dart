import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_transition_outcome_review_provider.dart';
import 'incoming_talent_succession_transition_outcome_review_form_fields.dart';

class IncomingTalentSuccessionTransitionOutcomeReviewForm
    extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionTransitionOutcomeReviewForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionTransitionOutcomeReviewForm>
  createState() => _IncomingTalentSuccessionTransitionOutcomeReviewFormState();
}

class _IncomingTalentSuccessionTransitionOutcomeReviewFormState
    extends ConsumerState<IncomingTalentSuccessionTransitionOutcomeReviewForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _lessonsController;
  late final TextEditingController _actionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentSuccessionTransitionOutcomeReviewDraftProvider,
    );
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _evidenceController = TextEditingController(text: draft.evidenceSummary);
    _lessonsController = TextEditingController(text: draft.lessonsLearned);
    _actionController = TextEditingController(text: draft.nextTalentAction);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _evidenceController.dispose();
    _lessonsController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentSuccessionTransitionOutcomeReviewDraftProvider,
    );
    final interventions = ref.watch(
      outcomeReadySuccessionTransitionInterventionsProvider,
    );

    _sync(_reviewerController, draft.reviewerName);
    _sync(_evidenceController, draft.evidenceSummary);
    _sync(_lessonsController, draft.lessonsLearned);
    _sync(_actionController, draft.nextTalentAction);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey(
              'succession-transition-outcome-${draft.interventionId}',
            ),
            initialValue:
                _interventionExists(interventions, draft.interventionId)
                    ? draft.interventionId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Completed intervention',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.task_alt_outlined),
            ),
            items:
                interventions
                    .map(
                      (intervention) => DropdownMenuItem(
                        value: intervention.id,
                        child: Text(
                          '${intervention.candidateName} - ${intervention.interventionType.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: interventions.isEmpty ? null : _selectIntervention,
            validator:
                (value) =>
                    IncomingTalentSuccessionTransitionOutcomeReviewDraft.validateRequired(
                      value,
                      'a completed intervention',
                    ),
          ),
          const SizedBox(height: 12),
          if (interventions.isEmpty)
            const HrisListSurface(
              child: Text(
                'No completed transition interventions are ready for review.',
              ),
            )
          else ...[
            IncomingTalentSuccessionTransitionOutcomeReviewTextInput(
              controller: _reviewerController,
              label: 'Outcome reviewer',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionOutcomeReviewDraftProvider
                            .notifier,
                      )
                      .setReviewerName,
              validator:
                  (value) =>
                      IncomingTalentSuccessionTransitionOutcomeReviewDraft.validateRequired(
                        value,
                        'an outcome reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionOutcomeReviewDateFields(
              draft: draft,
              onSelectReviewDate: _selectReviewDate,
              onSelectNextReviewDate: _selectNextReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionOutcomeReviewSignalFields(
              draft: draft,
              onDecisionChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionOutcomeReviewDraftProvider
                            .notifier,
                      )
                      .setDecision,
              onRiskChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionOutcomeReviewDraftProvider
                            .notifier,
                      )
                      .setResidualRisk,
              onStabilizationChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionOutcomeReviewDraftProvider
                            .notifier,
                      )
                      .setStabilizationScore,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionOutcomeReviewTextInput(
              controller: _evidenceController,
              label: 'Evidence summary',
              icon: Icons.description_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionOutcomeReviewDraftProvider
                            .notifier,
                      )
                      .setEvidenceSummary,
              validator:
                  IncomingTalentSuccessionTransitionOutcomeReviewDraft
                      .validateEvidenceSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionOutcomeReviewTextInput(
              controller: _lessonsController,
              label: 'Lessons learned',
              icon: Icons.school_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionOutcomeReviewDraftProvider
                            .notifier,
                      )
                      .setLessonsLearned,
              validator:
                  IncomingTalentSuccessionTransitionOutcomeReviewDraft
                      .validateLessonsLearned,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionOutcomeReviewTextInput(
              controller: _actionController,
              label: 'Next talent action',
              icon: Icons.route_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionOutcomeReviewDraftProvider
                            .notifier,
                      )
                      .setNextTalentAction,
              validator:
                  IncomingTalentSuccessionTransitionOutcomeReviewDraft
                      .validateNextTalentAction,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionOutcomeReviewDraftReadiness(
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
                            incomingTalentSuccessionTransitionOutcomeReviewDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key(
                    'incoming-talent-succession-transition-outcome-submit',
                  ),
                  onPressed: draft.isReadyToSubmit ? _submitReview : null,
                  icon: const Icon(Icons.insights_outlined),
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
      outcomeReadySuccessionTransitionInterventionsProvider,
    );
    final intervention = interventions.firstWhere(
      (item) => item.id == interventionId,
    );
    ref
        .read(
          incomingTalentSuccessionTransitionOutcomeReviewDraftProvider.notifier,
        )
        .initializeFromIntervention(intervention);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(
      incomingTalentSuccessionTransitionOutcomeReviewDraftProvider,
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
          incomingTalentSuccessionTransitionOutcomeReviewDraftProvider.notifier,
        )
        .setReviewDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(
      incomingTalentSuccessionTransitionOutcomeReviewDraftProvider,
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
          incomingTalentSuccessionTransitionOutcomeReviewDraftProvider.notifier,
        )
        .setNextReviewDate(picked);
  }

  void _submitReview() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentSuccessionTransitionOutcomeReviewDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final review = ref
          .read(
            incomingTalentSuccessionTransitionOutcomeReviewsProvider.notifier,
          )
          .submitDraft(draft);
      ref
          .read(
            incomingTalentSuccessionTransitionOutcomeReviewDraftProvider
                .notifier,
          )
          .clear();
      _showMessage('${review.id} submitted for ${review.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _interventionExists(
    List<IncomingTalentSuccessionTransitionIntervention> interventions,
    String interventionId,
  ) {
    return interventions.any(
      (intervention) => intervention.id == interventionId,
    );
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
