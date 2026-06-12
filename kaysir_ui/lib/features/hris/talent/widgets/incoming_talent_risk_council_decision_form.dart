import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_decision_models.dart';
import '../states/incoming_talent_risk_council_decision_provider.dart';
import 'incoming_talent_risk_council_decision_controls.dart';
import 'incoming_talent_risk_council_decision_date_fields.dart';
import 'incoming_talent_risk_council_decision_form_actions.dart';
import 'incoming_talent_risk_council_decision_form_fields.dart';
import 'incoming_talent_risk_council_decision_queue_picker.dart';
import 'incoming_talent_risk_council_decision_readiness.dart';

class IncomingTalentRiskCouncilDecisionForm extends ConsumerStatefulWidget {
  const IncomingTalentRiskCouncilDecisionForm({super.key});

  @override
  ConsumerState<IncomingTalentRiskCouncilDecisionForm> createState() =>
      _IncomingTalentRiskCouncilDecisionFormState();
}

class _IncomingTalentRiskCouncilDecisionFormState
    extends ConsumerState<IncomingTalentRiskCouncilDecisionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _decisionMakerController;
  late final TextEditingController _ownerController;
  late final TextEditingController _commitmentController;
  late final TextEditingController _minutesController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentRiskCouncilDecisionDraftProvider);
    _decisionMakerController = TextEditingController(
      text: draft.decisionMakerName,
    );
    _ownerController = TextEditingController(text: draft.ownerName);
    _commitmentController = TextEditingController(
      text: draft.commitmentSummary,
    );
    _minutesController = TextEditingController(text: draft.minutesNote);
  }

  @override
  void dispose() {
    _decisionMakerController.dispose();
    _ownerController.dispose();
    _commitmentController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentRiskCouncilDecisionDraftProvider);
    final queueItems = ref.watch(
      decisionReadyTalentRiskCouncilQueueItemsProvider,
    );

    _sync(_decisionMakerController, draft.decisionMakerName);
    _sync(_ownerController, draft.ownerName);
    _sync(_commitmentController, draft.commitmentSummary);
    _sync(_minutesController, draft.minutesNote);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentRiskCouncilDecisionQueuePicker(
            draft: draft,
            items: queueItems,
            onChanged: _selectQueueItem,
          ),
          const SizedBox(height: 12),
          if (queueItems.isEmpty)
            const HrisListSurface(
              child: Text('No talent risk council queue items need decisions.'),
            )
          else ...[
            IncomingTalentRiskCouncilDecisionTextInput(
              controller: _decisionMakerController,
              label: 'Decision maker',
              icon: Icons.groups_2_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilDecisionDraftProvider.notifier,
                      )
                      .setDecisionMakerName,
              validator:
                  (value) => validateRiskCouncilDecisionRequired(
                    value,
                    'a decision maker',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilDecisionTextInput(
              controller: _ownerController,
              label: 'Accountable owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilDecisionDraftProvider.notifier,
                      )
                      .setOwnerName,
              validator:
                  (value) =>
                      validateRiskCouncilDecisionRequired(value, 'an owner'),
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilDecisionOutcomeField(
              draft: draft,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilDecisionDraftProvider.notifier,
                      )
                      .setOutcome,
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilDecisionDateFields(
              draft: draft,
              onSelectDecisionDate: _selectDecisionDate,
              onSelectFollowUpDate: _selectFollowUpDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilDecisionTextInput(
              controller: _commitmentController,
              label: 'Commitment summary',
              icon: Icons.handshake_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilDecisionDraftProvider.notifier,
                      )
                      .setCommitmentSummary,
              validator:
                  (value) => riskCouncilDecisionLongTextError(
                    value,
                    'commitment summary',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilDecisionTextInput(
              controller: _minutesController,
              label: 'Minutes note',
              icon: Icons.article_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentRiskCouncilDecisionDraftProvider.notifier,
                      )
                      .setMinutesNote,
              validator:
                  (value) =>
                      riskCouncilDecisionLongTextError(value, 'minutes note'),
            ),
            const SizedBox(height: 12),
            IncomingTalentRiskCouncilDecisionDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            IncomingTalentRiskCouncilDecisionFormActions(
              draft: draft,
              onClear:
                  ref
                      .read(
                        incomingTalentRiskCouncilDecisionDraftProvider.notifier,
                      )
                      .clear,
              onSubmit: _submitDecision,
            ),
          ],
        ],
      ),
    );
  }

  void _selectQueueItem(String? queueItemId) {
    if (queueItemId == null) return;
    final items = ref.read(decisionReadyTalentRiskCouncilQueueItemsProvider);
    final item = items.firstWhere((entry) => entry.id == queueItemId);
    ref
        .read(incomingTalentRiskCouncilDecisionDraftProvider.notifier)
        .initializeFromQueueItem(item);
  }

  Future<void> _selectDecisionDate() async {
    final draft = ref.read(incomingTalentRiskCouncilDecisionDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.decisionDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentRiskCouncilDecisionDraftProvider.notifier)
        .setDecisionDate(picked);
  }

  Future<void> _selectFollowUpDate() async {
    final draft = ref.read(incomingTalentRiskCouncilDecisionDraftProvider);
    final decisionDate = draft.decisionDate ?? draft.asOfDate;
    final firstDate = decisionDate.add(const Duration(days: 1));
    final initialDate =
        draft.followUpDate != null && draft.followUpDate!.isAfter(decisionDate)
            ? draft.followUpDate!
            : firstDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentRiskCouncilDecisionDraftProvider.notifier)
        .setFollowUpDate(picked);
  }

  void _submitDecision() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentRiskCouncilDecisionDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final decision = ref
          .read(incomingTalentRiskCouncilDecisionsProvider.notifier)
          .submitDraft(draft);
      ref.read(incomingTalentRiskCouncilDecisionDraftProvider.notifier).clear();
      _showMessage('${decision.id} recorded for ${decision.candidateName}');
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
