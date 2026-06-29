import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_activation_check_in_provider.dart';
import 'incoming_talent_succession_activation_check_in_form_fields.dart';

class IncomingTalentSuccessionActivationCheckInForm
    extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionActivationCheckInForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionActivationCheckInForm> createState() =>
      _IncomingTalentSuccessionActivationCheckInFormState();
}

class _IncomingTalentSuccessionActivationCheckInFormState
    extends ConsumerState<IncomingTalentSuccessionActivationCheckInForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _milestoneController;
  late final TextEditingController _blockerController;
  late final TextEditingController _sponsorController;
  late final TextEditingController _nextStepController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentSuccessionActivationCheckInDraftProvider,
    );
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _milestoneController = TextEditingController(text: draft.milestoneHealth);
    _blockerController = TextEditingController(text: draft.blockerNote);
    _sponsorController = TextEditingController(text: draft.sponsorAction);
    _nextStepController = TextEditingController(text: draft.nextStep);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _milestoneController.dispose();
    _blockerController.dispose();
    _sponsorController.dispose();
    _nextStepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentSuccessionActivationCheckInDraftProvider,
    );
    final plans = ref.watch(checkInReadySuccessionActivationPlansProvider);

    _sync(_reviewerController, draft.reviewerName);
    _sync(_milestoneController, draft.milestoneHealth);
    _sync(_blockerController, draft.blockerNote);
    _sync(_sponsorController, draft.sponsorAction);
    _sync(_nextStepController, draft.nextStep);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey(
              'succession-activation-check-in-${draft.activationPlanId}',
            ),
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
                        child: Text(
                          '${plan.candidateName} - ${plan.status.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: plans.isEmpty ? null : _selectPlan,
            validator:
                (value) =>
                    IncomingTalentSuccessionActivationCheckInDraft.validateRequired(
                      value,
                      'an activation plan',
                    ),
          ),
          const SizedBox(height: 12),
          if (plans.isEmpty)
            const HrisListSurface(
              child: Text('No active succession plans are ready for check-in.'),
            )
          else ...[
            IncomingTalentSuccessionActivationCheckInTextInput(
              controller: _reviewerController,
              label: 'Reviewer',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationCheckInDraftProvider
                            .notifier,
                      )
                      .setReviewerName,
              validator:
                  (value) =>
                      IncomingTalentSuccessionActivationCheckInDraft.validateRequired(
                        value,
                        'a reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationCheckInDateFields(
              draft: draft,
              onSelectCheckInDate: _selectCheckInDate,
              onSelectNextCheckInDate: _selectNextCheckInDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationCheckInSignalFields(
              draft: draft,
              onTrendChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationCheckInDraftProvider
                            .notifier,
                      )
                      .setTrend,
              onConfidenceChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationCheckInDraftProvider
                            .notifier,
                      )
                      .setConfidenceScore,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationCheckInTextInput(
              controller: _milestoneController,
              label: 'Milestone health',
              icon: Icons.flag_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationCheckInDraftProvider
                            .notifier,
                      )
                      .setMilestoneHealth,
              validator:
                  IncomingTalentSuccessionActivationCheckInDraft
                      .validateMilestoneHealth,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationCheckInTextInput(
              controller: _blockerController,
              label: 'Blocker note',
              icon: Icons.warning_amber_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationCheckInDraftProvider
                            .notifier,
                      )
                      .setBlockerNote,
              validator:
                  (value) =>
                      IncomingTalentSuccessionActivationCheckInDraft.validateBlockerNote(
                        value,
                        draft.trend,
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationCheckInTextInput(
              controller: _sponsorController,
              label: 'Sponsor action',
              icon: Icons.handshake_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationCheckInDraftProvider
                            .notifier,
                      )
                      .setSponsorAction,
              validator:
                  IncomingTalentSuccessionActivationCheckInDraft
                      .validateSponsorAction,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationCheckInTextInput(
              controller: _nextStepController,
              label: 'Next step',
              icon: Icons.route_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationCheckInDraftProvider
                            .notifier,
                      )
                      .setNextStep,
              validator:
                  IncomingTalentSuccessionActivationCheckInDraft
                      .validateNextStep,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationCheckInDraftReadiness(
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
                            incomingTalentSuccessionActivationCheckInDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key('incoming-talent-activation-check-in-submit'),
                  onPressed: draft.isReadyToSubmit ? _submitCheckIn : null,
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Submit check-in'),
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
    final plans = ref.read(checkInReadySuccessionActivationPlansProvider);
    final plan = plans.firstWhere((item) => item.id == planId);
    ref
        .read(incomingTalentSuccessionActivationCheckInDraftProvider.notifier)
        .initializeFromPlan(plan);
  }

  Future<void> _selectCheckInDate() async {
    final draft = ref.read(
      incomingTalentSuccessionActivationCheckInDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.checkInDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionActivationCheckInDraftProvider.notifier)
        .setCheckInDate(picked);
  }

  Future<void> _selectNextCheckInDate() async {
    final draft = ref.read(
      incomingTalentSuccessionActivationCheckInDraftProvider,
    );
    final checkInDate = draft.checkInDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.nextCheckInDate ?? checkInDate.add(const Duration(days: 30)),
      firstDate: checkInDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionActivationCheckInDraftProvider.notifier)
        .setNextCheckInDate(picked);
  }

  void _submitCheckIn() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentSuccessionActivationCheckInDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final checkIn = ref
          .read(incomingTalentSuccessionActivationCheckInsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentSuccessionActivationCheckInDraftProvider.notifier)
          .clear();
      _showMessage('${checkIn.id} submitted for ${checkIn.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _planExists(
    List<IncomingTalentSuccessionActivationPlan> plans,
    String planId,
  ) {
    return plans.any((plan) => plan.id == planId);
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
