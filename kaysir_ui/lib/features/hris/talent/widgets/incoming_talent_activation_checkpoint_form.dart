import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_activation_checkpoint_models.dart';
import '../models/incoming_talent_activation_models.dart';
import '../states/incoming_talent_activation_checkpoint_provider.dart';
import 'incoming_talent_activation_checkpoint_form_fields.dart';

class IncomingTalentActivationCheckpointForm extends ConsumerStatefulWidget {
  final List<IncomingTalentActivationPlan> plans;

  const IncomingTalentActivationCheckpointForm({
    super.key,
    required this.plans,
  });

  @override
  ConsumerState<IncomingTalentActivationCheckpointForm> createState() =>
      _IncomingTalentActivationCheckpointFormState();
}

class _IncomingTalentActivationCheckpointFormState
    extends ConsumerState<IncomingTalentActivationCheckpointForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _feedbackController;
  late final TextEditingController _blockerController;
  late final TextEditingController _nextStepController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentActivationCheckpointDraftProvider);
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _feedbackController = TextEditingController(text: draft.managerFeedback);
    _blockerController = TextEditingController(text: draft.blockerNote);
    _nextStepController = TextEditingController(text: draft.nextStep);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _feedbackController.dispose();
    _blockerController.dispose();
    _nextStepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentActivationCheckpointDraftProvider);
    final openPlans = widget.plans.where((plan) => plan.isOpen).toList();

    _sync(_reviewerController, draft.reviewerName);
    _sync(_feedbackController, draft.managerFeedback);
    _sync(_blockerController, draft.blockerNote);
    _sync(_nextStepController, draft.nextStep);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('checkpoint-${draft.activationPlanId}'),
            initialValue:
                _planExists(openPlans, draft.activationPlanId)
                    ? draft.activationPlanId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Activation plan',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.rocket_launch_outlined),
            ),
            items:
                openPlans
                    .map(
                      (plan) => DropdownMenuItem(
                        value: plan.id,
                        child: Text('${plan.candidateName} - ${plan.role}'),
                      ),
                    )
                    .toList(),
            onChanged: openPlans.isEmpty ? null : _selectPlan,
            validator:
                (value) =>
                    IncomingTalentActivationCheckpointDraft.validateRequired(
                      value,
                      'an activation plan',
                    ),
          ),
          const SizedBox(height: 12),
          if (openPlans.isEmpty)
            const HrisListSurface(
              child: Text('Create an open activation plan before checkpoint.'),
            )
          else ...[
            IncomingTalentActivationCheckpointTextInput(
              controller: _reviewerController,
              label: 'Reviewer',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentActivationCheckpointDraftProvider
                            .notifier,
                      )
                      .setReviewerName,
              validator:
                  (value) =>
                      IncomingTalentActivationCheckpointDraft.validateRequired(
                        value,
                        'a reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationCheckpointDateField(
              draft: draft,
              onSelectReviewDate: _selectReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationCheckpointSignalFields(
              draft: draft,
              onHealthChanged:
                  ref
                      .read(
                        incomingTalentActivationCheckpointDraftProvider
                            .notifier,
                      )
                      .setHealth,
              onConfidenceChanged:
                  ref
                      .read(
                        incomingTalentActivationCheckpointDraftProvider
                            .notifier,
                      )
                      .setConfidenceScore,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationCheckpointTextInput(
              controller: _feedbackController,
              label: 'Manager feedback',
              icon: Icons.rate_review_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentActivationCheckpointDraftProvider
                            .notifier,
                      )
                      .setManagerFeedback,
              validator:
                  IncomingTalentActivationCheckpointDraft
                      .validateManagerFeedback,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationCheckpointTextInput(
              controller: _blockerController,
              label: 'Blocker note',
              icon: Icons.report_problem_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentActivationCheckpointDraftProvider
                            .notifier,
                      )
                      .setBlockerNote,
              validator:
                  (value) =>
                      IncomingTalentActivationCheckpointDraft.validateBlockerNote(
                        value,
                        draft.requiresBlockerNote,
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationCheckpointTextInput(
              controller: _nextStepController,
              label: 'Next step',
              icon: Icons.next_plan_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentActivationCheckpointDraftProvider
                            .notifier,
                      )
                      .setNextStep,
              validator:
                  IncomingTalentActivationCheckpointDraft.validateNextStep,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationCheckpointDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentActivationCheckpointDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key('incoming-talent-checkpoint-submit'),
                  onPressed: draft.isReadyToSubmit ? _submitCheckpoint : null,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Submit checkpoint'),
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
    final plan = widget.plans.firstWhere((item) => item.id == planId);
    ref
        .read(incomingTalentActivationCheckpointDraftProvider.notifier)
        .initializeFromPlan(plan);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(incomingTalentActivationCheckpointDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.reviewDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentActivationCheckpointDraftProvider.notifier)
        .setReviewDate(picked);
  }

  void _submitCheckpoint() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentActivationCheckpointDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    final checkpoint = ref
        .read(incomingTalentActivationCheckpointsProvider.notifier)
        .submitDraft(draft);
    ref.read(incomingTalentActivationCheckpointDraftProvider.notifier).clear();
    _showMessage('${checkpoint.id} submitted for ${checkpoint.candidateName}');
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
