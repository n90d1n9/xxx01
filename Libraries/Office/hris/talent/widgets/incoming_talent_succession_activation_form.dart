import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_activation_provider.dart';
import 'incoming_talent_succession_activation_form_fields.dart';

class IncomingTalentSuccessionActivationForm extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionActivationForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionActivationForm> createState() =>
      _IncomingTalentSuccessionActivationFormState();
}

class _IncomingTalentSuccessionActivationFormState
    extends ConsumerState<IncomingTalentSuccessionActivationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _mentorController;
  late final TextEditingController _goalController;
  late final TextEditingController _milestoneController;
  late final TextEditingController _metricController;
  late final TextEditingController _supportController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentSuccessionActivationDraftProvider);
    _ownerController = TextEditingController(text: draft.activationOwner);
    _mentorController = TextEditingController(text: draft.mentorName);
    _goalController = TextEditingController(text: draft.transitionGoal);
    _milestoneController = TextEditingController(text: draft.milestone);
    _metricController = TextEditingController(text: draft.successMetric);
    _supportController = TextEditingController(text: draft.supportPlan);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _mentorController.dispose();
    _goalController.dispose();
    _milestoneController.dispose();
    _metricController.dispose();
    _supportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentSuccessionActivationDraftProvider);
    final decisions = ref.watch(
      activationReadySuccessionPanelDecisionsProvider,
    );

    _sync(_ownerController, draft.activationOwner);
    _sync(_mentorController, draft.mentorName);
    _sync(_goalController, draft.transitionGoal);
    _sync(_milestoneController, draft.milestone);
    _sync(_metricController, draft.successMetric);
    _sync(_supportController, draft.supportPlan);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('succession-activation-${draft.decisionId}'),
            initialValue:
                _decisionExists(decisions, draft.decisionId)
                    ? draft.decisionId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Approved panel decision',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.fact_check_outlined),
            ),
            items:
                decisions
                    .map(
                      (decision) => DropdownMenuItem(
                        value: decision.id,
                        child: Text(
                          '${decision.candidateName} - ${decision.outcome.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: decisions.isEmpty ? null : _selectDecision,
            validator:
                (value) =>
                    IncomingTalentSuccessionActivationPlanDraft.validateRequired(
                      value,
                      'an approved panel decision',
                    ),
          ),
          const SizedBox(height: 12),
          if (decisions.isEmpty)
            const HrisListSurface(
              child: Text('No approved panel decisions are ready to activate.'),
            )
          else ...[
            IncomingTalentSuccessionActivationTextInput(
              controller: _ownerController,
              label: 'Activation owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationDraftProvider
                            .notifier,
                      )
                      .setActivationOwner,
              validator:
                  (value) =>
                      IncomingTalentSuccessionActivationPlanDraft.validateRequired(
                        value,
                        'an activation owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationTextInput(
              controller: _mentorController,
              label: 'Transition mentor',
              icon: Icons.groups_2_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationDraftProvider
                            .notifier,
                      )
                      .setMentorName,
              validator:
                  (value) =>
                      IncomingTalentSuccessionActivationPlanDraft.validateRequired(
                        value,
                        'a transition mentor',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationStatusField(
              draft: draft,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationDraftProvider
                            .notifier,
                      )
                      .setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationDateFields(
              draft: draft,
              onSelectStartDate: _selectStartDate,
              onSelectMilestoneDate: _selectMilestoneDate,
              onSelectFirstReviewDate: _selectFirstReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationTextInput(
              controller: _goalController,
              label: 'Transition goal',
              icon: Icons.rocket_launch_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationDraftProvider
                            .notifier,
                      )
                      .setTransitionGoal,
              validator:
                  IncomingTalentSuccessionActivationPlanDraft
                      .validateTransitionGoal,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationTextInput(
              controller: _milestoneController,
              label: 'Milestone',
              icon: Icons.flag_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationDraftProvider
                            .notifier,
                      )
                      .setMilestone,
              validator:
                  IncomingTalentSuccessionActivationPlanDraft.validateMilestone,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationTextInput(
              controller: _metricController,
              label: 'Success metric',
              icon: Icons.insights_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationDraftProvider
                            .notifier,
                      )
                      .setSuccessMetric,
              validator:
                  IncomingTalentSuccessionActivationPlanDraft
                      .validateSuccessMetric,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationTextInput(
              controller: _supportController,
              label: 'Support plan',
              icon: Icons.handshake_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationDraftProvider
                            .notifier,
                      )
                      .setSupportPlan,
              validator:
                  IncomingTalentSuccessionActivationPlanDraft
                      .validateSupportPlan,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentSuccessionActivationDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key('incoming-talent-activation-submit'),
                  onPressed: draft.isReadyToSubmit ? _submitPlan : null,
                  icon: const Icon(Icons.rocket_launch_outlined),
                  label: const Text('Submit plan'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectDecision(String? decisionId) {
    if (decisionId == null) return;
    final decisions = ref.read(activationReadySuccessionPanelDecisionsProvider);
    final decision = decisions.firstWhere((item) => item.id == decisionId);
    ref
        .read(incomingTalentSuccessionActivationDraftProvider.notifier)
        .initializeFromDecision(decision);
  }

  Future<void> _selectStartDate() async {
    final draft = ref.read(incomingTalentSuccessionActivationDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.startDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionActivationDraftProvider.notifier)
        .setStartDate(picked);
  }

  Future<void> _selectMilestoneDate() async {
    final draft = ref.read(incomingTalentSuccessionActivationDraftProvider);
    final startDate = draft.startDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.milestoneDate ?? startDate.add(const Duration(days: 30)),
      firstDate: startDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionActivationDraftProvider.notifier)
        .setMilestoneDate(picked);
  }

  Future<void> _selectFirstReviewDate() async {
    final draft = ref.read(incomingTalentSuccessionActivationDraftProvider);
    final startDate = draft.startDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.firstReviewDate ?? startDate.add(const Duration(days: 90)),
      firstDate: startDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionActivationDraftProvider.notifier)
        .setFirstReviewDate(picked);
  }

  void _submitPlan() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentSuccessionActivationDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final plan = ref
          .read(incomingTalentSuccessionActivationPlansProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentSuccessionActivationDraftProvider.notifier)
          .clear();
      _showMessage('${plan.id} submitted for ${plan.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _decisionExists(
    List<IncomingTalentSuccessionPanelDecision> decisions,
    String decisionId,
  ) {
    return decisions.any((decision) => decision.id == decisionId);
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
