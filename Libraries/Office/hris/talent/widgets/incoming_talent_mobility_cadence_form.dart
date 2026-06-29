import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_mobility_cadence_check_in_provider.dart';
import 'incoming_talent_mobility_cadence_form_actions.dart';
import 'incoming_talent_mobility_cadence_form_fields.dart';
import 'incoming_talent_mobility_cadence_outcome_picker.dart';
import 'incoming_talent_mobility_cadence_readiness.dart';

class IncomingTalentMobilityCadenceForm extends ConsumerStatefulWidget {
  const IncomingTalentMobilityCadenceForm({super.key});

  @override
  ConsumerState<IncomingTalentMobilityCadenceForm> createState() =>
      _IncomingTalentMobilityCadenceFormState();
}

class _IncomingTalentMobilityCadenceFormState
    extends ConsumerState<IncomingTalentMobilityCadenceForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _pulseController;
  late final TextEditingController _supportController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentMobilityCadenceCheckInDraftProvider);
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _pulseController = TextEditingController(text: draft.pulseSummary);
    _supportController = TextEditingController(text: draft.supportPlan);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _pulseController.dispose();
    _supportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentMobilityCadenceCheckInDraftProvider);
    final outcomes = ref.watch(
      cadenceReadyMobilityStabilizationOutcomesProvider,
    );
    final notifier = ref.read(
      incomingTalentMobilityCadenceCheckInDraftProvider.notifier,
    );

    _sync(_reviewerController, draft.reviewerName);
    _sync(_pulseController, draft.pulseSummary);
    _sync(_supportController, draft.supportPlan);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentMobilityCadenceOutcomePicker(
            draft: draft,
            outcomes: outcomes,
            onChanged: _selectOutcome,
          ),
          const SizedBox(height: 12),
          if (outcomes.isEmpty)
            const HrisListSurface(
              child: Text('No mobility outcomes are due for cadence review.'),
            )
          else ...[
            IncomingTalentMobilityCadenceTextInput(
              controller: _reviewerController,
              label: 'Cadence reviewer',
              icon: Icons.badge_outlined,
              onChanged: notifier.setReviewerName,
              validator:
                  (value) =>
                      IncomingTalentMobilityCadenceCheckInDraft.validateRequired(
                        value,
                        'a cadence reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceDateFields(
              draft: draft,
              onSelectCheckInDate: _selectCheckInDate,
              onSelectNextReviewDate: _selectNextReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceSignalFields(
              draft: draft,
              onStatusChanged: notifier.setStatus,
              onResidualRiskChanged: notifier.setResidualRisk,
              onConfidenceChanged: notifier.setHostConfidenceScore,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceTextInput(
              controller: _pulseController,
              label: 'Pulse summary',
              icon: Icons.monitor_heart_outlined,
              minLines: 3,
              onChanged: notifier.setPulseSummary,
              validator:
                  IncomingTalentMobilityCadenceCheckInDraft
                      .validatePulseSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceTextInput(
              controller: _supportController,
              label: 'Support plan',
              icon: Icons.route_outlined,
              minLines: 3,
              onChanged: notifier.setSupportPlan,
              validator:
                  IncomingTalentMobilityCadenceCheckInDraft.validateSupportPlan,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            IncomingTalentMobilityCadenceFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear: notifier.clear,
              onSubmit: _submitCheckIn,
            ),
          ],
        ],
      ),
    );
  }

  void _selectOutcome(String? outcomeId) {
    if (outcomeId == null) return;
    final outcomes = ref.read(
      cadenceReadyMobilityStabilizationOutcomesProvider,
    );
    final outcome = outcomes.firstWhere((item) => item.id == outcomeId);
    ref
        .read(incomingTalentMobilityCadenceCheckInDraftProvider.notifier)
        .initializeFromOutcome(outcome);
  }

  Future<void> _selectCheckInDate() async {
    final draft = ref.read(incomingTalentMobilityCadenceCheckInDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.checkInDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentMobilityCadenceCheckInDraftProvider.notifier)
        .setCheckInDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(incomingTalentMobilityCadenceCheckInDraftProvider);
    final checkInDate = draft.checkInDate ?? draft.asOfDate;
    final firstDate = checkInDate.add(const Duration(days: 1));
    final initialDate =
        draft.nextReviewDate != null &&
                draft.nextReviewDate!.isAfter(checkInDate)
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
        .read(incomingTalentMobilityCadenceCheckInDraftProvider.notifier)
        .setNextReviewDate(picked);
  }

  void _submitCheckIn() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentMobilityCadenceCheckInDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final checkIn = ref
          .read(incomingTalentMobilityCadenceCheckInsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentMobilityCadenceCheckInDraftProvider.notifier)
          .clear();
      _showMessage('${checkIn.id} submitted for ${checkIn.candidateName}');
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
