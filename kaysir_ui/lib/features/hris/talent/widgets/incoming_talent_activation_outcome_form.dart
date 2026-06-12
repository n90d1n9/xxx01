import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_activation_models.dart';
import '../models/incoming_talent_activation_outcome_models.dart';
import '../states/incoming_talent_activation_outcome_provider.dart';
import 'incoming_talent_activation_outcome_form_fields.dart';

class IncomingTalentActivationOutcomeForm extends ConsumerStatefulWidget {
  const IncomingTalentActivationOutcomeForm({super.key});

  @override
  ConsumerState<IncomingTalentActivationOutcomeForm> createState() =>
      _IncomingTalentActivationOutcomeFormState();
}

class _IncomingTalentActivationOutcomeFormState
    extends ConsumerState<IncomingTalentActivationOutcomeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _trackController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _decisionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentActivationOutcomeDraftProvider);
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _trackController = TextEditingController(text: draft.nextDevelopmentTrack);
    _evidenceController = TextEditingController(text: draft.evidenceNote);
    _decisionController = TextEditingController(text: draft.decisionNote);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _trackController.dispose();
    _evidenceController.dispose();
    _decisionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentActivationOutcomeDraftProvider);
    final plans = ref.watch(outcomeReadyActivationPlansProvider);

    _sync(_reviewerController, draft.reviewerName);
    _sync(_trackController, draft.nextDevelopmentTrack);
    _sync(_evidenceController, draft.evidenceNote);
    _sync(_decisionController, draft.decisionNote);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('outcome-${draft.activationPlanId}'),
            initialValue:
                _planExists(plans, draft.activationPlanId)
                    ? draft.activationPlanId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Activation plan',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.rocket_launch_outlined),
            ),
            items:
                plans
                    .map(
                      (plan) => DropdownMenuItem(
                        value: plan.id,
                        child: Text('${plan.candidateName} - ${plan.role}'),
                      ),
                    )
                    .toList(),
            onChanged: plans.isEmpty ? null : _selectPlan,
            validator:
                (value) =>
                    IncomingTalentActivationOutcomeDraft.validateRequired(
                      value,
                      'an activation plan',
                    ),
          ),
          const SizedBox(height: 12),
          if (plans.isEmpty)
            const HrisListSurface(
              child: Text('No activation plans are ready for outcome review.'),
            )
          else ...[
            IncomingTalentActivationOutcomeTextInput(
              controller: _reviewerController,
              label: 'Reviewer',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentActivationOutcomeDraftProvider.notifier,
                      )
                      .setReviewerName,
              validator:
                  (value) =>
                      IncomingTalentActivationOutcomeDraft.validateRequired(
                        value,
                        'a reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationOutcomeReviewDateField(
              draft: draft,
              onSelectReviewDate: _selectReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationOutcomeDecisionFields(
              draft: draft,
              onDecisionChanged:
                  ref
                      .read(
                        incomingTalentActivationOutcomeDraftProvider.notifier,
                      )
                      .setDecision,
              onRiskChanged:
                  ref
                      .read(
                        incomingTalentActivationOutcomeDraftProvider.notifier,
                      )
                      .setRetentionRisk,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationOutcomeReadinessScore(
              draft: draft,
              onChanged:
                  ref
                      .read(
                        incomingTalentActivationOutcomeDraftProvider.notifier,
                      )
                      .setReadinessScore,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationOutcomeTextInput(
              controller: _trackController,
              label: 'Next development track',
              icon: Icons.route_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentActivationOutcomeDraftProvider.notifier,
                      )
                      .setNextDevelopmentTrack,
              validator:
                  IncomingTalentActivationOutcomeDraft
                      .validateNextDevelopmentTrack,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationOutcomeTextInput(
              controller: _evidenceController,
              label: 'Evidence notes',
              icon: Icons.article_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentActivationOutcomeDraftProvider.notifier,
                      )
                      .setEvidenceNote,
              validator:
                  IncomingTalentActivationOutcomeDraft.validateEvidenceNote,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationOutcomeTextInput(
              controller: _decisionController,
              label: 'Decision notes',
              icon: Icons.notes_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentActivationOutcomeDraftProvider.notifier,
                      )
                      .setDecisionNote,
              validator:
                  IncomingTalentActivationOutcomeDraft.validateDecisionNote,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationOutcomeDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentActivationOutcomeDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key('incoming-talent-outcome-submit'),
                  onPressed: draft.isReadyToSubmit ? _submitOutcome : null,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Submit outcome'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectPlan(String? planId) {
    if (planId == null) return;
    final plans = ref.read(outcomeReadyActivationPlansProvider);
    final evidence = ref.read(incomingTalentActivationOutcomeEvidenceProvider);
    final plan = plans.firstWhere((item) => item.id == planId);
    ref
        .read(incomingTalentActivationOutcomeDraftProvider.notifier)
        .initializeFromPlan(
          plan: plan,
          checkpoints: evidence.checkpoints,
          followUps: evidence.followUps,
        );
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(incomingTalentActivationOutcomeDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.reviewDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentActivationOutcomeDraftProvider.notifier)
        .setReviewDate(picked);
  }

  void _submitOutcome() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentActivationOutcomeDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final review = ref
          .read(incomingTalentActivationOutcomeReviewsProvider.notifier)
          .submitDraft(draft);
      ref.read(incomingTalentActivationOutcomeDraftProvider.notifier).clear();
      _showMessage('${review.id} submitted for ${review.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool _planExists(List<IncomingTalentActivationPlan> plans, String planId) {
    return plans.any((plan) => plan.id == planId);
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}
