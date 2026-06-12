import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_intervention_outcome_follow_up_resolution_models.dart';
import '../states/incoming_talent_development_intervention_outcome_follow_up_resolution_provider.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_resolution_form_fields.dart';

class IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionForm
    extends ConsumerStatefulWidget {
  const IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionForm({
    super.key,
  });

  @override
  ConsumerState<
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionForm
  >
  createState() =>
      _IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionFormState();
}

class _IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionFormState
    extends
        ConsumerState<
          IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionForm
        > {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _managerNoteController;
  late final TextEditingController _nextActionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider,
    );
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _evidenceController = TextEditingController(text: draft.evidenceSummary);
    _managerNoteController = TextEditingController(text: draft.managerNote);
    _nextActionController = TextEditingController(text: draft.nextAction);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _evidenceController.dispose();
    _managerNoteController.dispose();
    _nextActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider,
    );
    final followUps = ref.watch(
      resolutionReadyDevelopmentInterventionOutcomeFollowUpsProvider,
    );
    final notifier = ref.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider
          .notifier,
    );

    _sync(_reviewerController, draft.reviewerName);
    _sync(_evidenceController, draft.evidenceSummary);
    _sync(_managerNoteController, draft.managerNote);
    _sync(_nextActionController, draft.nextAction);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionPicker(
            draft: draft,
            followUps: followUps,
            onChanged: _selectFollowUp,
          ),
          const SizedBox(height: 12),
          if (followUps.isEmpty)
            const HrisListSurface(
              child: Text(
                'No completed or escalated follow-ups are ready for review.',
              ),
            )
          else ...[
            IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionTextInput(
              controller: _reviewerController,
              label: 'Review owner',
              icon: Icons.badge_outlined,
              onChanged: notifier.setReviewerName,
              validator:
                  (value) =>
                      IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft.validateRequired(
                        value,
                        'a reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDateFields(
              draft: draft,
              onSelectReviewDate: _selectReviewDate,
              onSelectNextReviewDate: _selectNextReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSignalFields(
              draft: draft,
              onDecisionChanged: notifier.setDecision,
              onConfidenceChanged: notifier.setConfidenceAfter,
              onRiskChanged: notifier.setRemainingReleaseRiskCount,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionTextInput(
              controller: _evidenceController,
              label: 'Evidence summary',
              icon: Icons.description_outlined,
              minLines: 3,
              onChanged: notifier.setEvidenceSummary,
              validator:
                  IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft
                      .validateEvidenceSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionTextInput(
              controller: _managerNoteController,
              label: 'Manager note',
              icon: Icons.handshake_outlined,
              minLines: 3,
              onChanged: notifier.setManagerNote,
              validator:
                  IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft
                      .validateManagerNote,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionTextInput(
              controller: _nextActionController,
              label: 'Next action',
              icon: Icons.route_outlined,
              minLines: 3,
              onChanged: notifier.setNextAction,
              validator:
                  IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft
                      .validateNextAction,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionReadiness(
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
                    'incoming-talent-intervention-follow-up-resolution-submit',
                  ),
                  onPressed: draft.isReadyToSubmit ? _submitResolution : null,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Submit review'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectFollowUp(String? followUpId) {
    if (followUpId == null) return;
    final followUps = ref.read(
      resolutionReadyDevelopmentInterventionOutcomeFollowUpsProvider,
    );
    final followUp = followUps.firstWhere((item) => item.id == followUpId);
    ref
        .read(
          incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider
              .notifier,
        )
        .initializeFromFollowUp(followUp);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider,
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
          incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider
              .notifier,
        )
        .setReviewDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider,
    );
    final reviewDate = draft.reviewDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.nextReviewDate ?? reviewDate.add(const Duration(days: 30)),
      firstDate: reviewDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(
          incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider
              .notifier,
        )
        .setNextReviewDate(picked);
  }

  void _submitResolution() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final resolution = ref
          .read(
            incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsProvider
                .notifier,
          )
          .submitDraft(draft);
      ref
          .read(
            incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider
                .notifier,
          )
          .clear();
      _showMessage(
        '${resolution.id} submitted for ${resolution.candidateName}',
      );
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
