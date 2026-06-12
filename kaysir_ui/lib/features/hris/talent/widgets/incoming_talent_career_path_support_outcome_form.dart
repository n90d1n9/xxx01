import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_path_support_outcome_models.dart';
import '../states/incoming_talent_career_path_support_outcome_provider.dart';
import 'incoming_talent_career_path_support_outcome_action_picker.dart';
import 'incoming_talent_career_path_support_outcome_form_actions.dart';
import 'incoming_talent_career_path_support_outcome_form_fields.dart';
import 'incoming_talent_career_path_support_outcome_readiness.dart';

class IncomingTalentCareerPathSupportOutcomeForm
    extends ConsumerStatefulWidget {
  const IncomingTalentCareerPathSupportOutcomeForm({super.key});

  @override
  ConsumerState<IncomingTalentCareerPathSupportOutcomeForm> createState() =>
      _IncomingTalentCareerPathSupportOutcomeFormState();
}

class _IncomingTalentCareerPathSupportOutcomeFormState
    extends ConsumerState<IncomingTalentCareerPathSupportOutcomeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _managerController;
  late final TextEditingController _nextActionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentCareerPathSupportOutcomeDraftProvider);
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _evidenceController = TextEditingController(text: draft.evidenceSummary);
    _managerController = TextEditingController(text: draft.managerNote);
    _nextActionController = TextEditingController(text: draft.nextReviewAction);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _evidenceController.dispose();
    _managerController.dispose();
    _nextActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentCareerPathSupportOutcomeDraftProvider,
    );
    final actions = ref.watch(careerPathSupportOutcomeReadyActionsProvider);
    final notifier = ref.read(
      incomingTalentCareerPathSupportOutcomeDraftProvider.notifier,
    );

    _sync(_reviewerController, draft.reviewerName);
    _sync(_evidenceController, draft.evidenceSummary);
    _sync(_managerController, draft.managerNote);
    _sync(_nextActionController, draft.nextReviewAction);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentCareerPathSupportOutcomeActionPicker(
            draft: draft,
            actions: actions,
            onChanged: _selectAction,
          ),
          const SizedBox(height: 12),
          if (actions.isEmpty)
            const HrisListSurface(
              child: Text('No resolved career support actions are ready.'),
            )
          else ...[
            IncomingTalentCareerPathSupportOutcomeTextInput(
              controller: _reviewerController,
              label: 'Outcome reviewer',
              icon: Icons.badge_outlined,
              onChanged: notifier.setReviewerName,
              validator:
                  (value) =>
                      validateIncomingTalentCareerPathSupportOutcomeRequired(
                        value,
                        'an outcome reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentCareerPathSupportOutcomeDateFields(
              draft: draft,
              onSelectOutcomeDate: _selectOutcomeDate,
              onSelectNextReviewDate: _selectNextReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentCareerPathSupportOutcomeSignalFields(
              draft: draft,
              onDecisionChanged: notifier.setDecision,
              onResidualRiskChanged: notifier.setResidualRisk,
              onVerifiedLevelChanged: notifier.setVerifiedLevel,
            ),
            const SizedBox(height: 12),
            _SupportOutcomeNarrativeFields(
              evidenceController: _evidenceController,
              managerController: _managerController,
              nextActionController: _nextActionController,
            ),
            const SizedBox(height: 12),
            IncomingTalentCareerPathSupportOutcomeReadiness(draft: draft),
            const SizedBox(height: 14),
            IncomingTalentCareerPathSupportOutcomeFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear: notifier.clear,
              onSubmit: _submitOutcome,
            ),
          ],
        ],
      ),
    );
  }

  void _selectAction(String? actionId) {
    if (actionId == null) return;
    final actions = ref.read(careerPathSupportOutcomeReadyActionsProvider);
    final action = actions.firstWhere((item) => item.id == actionId);
    ref
        .read(incomingTalentCareerPathSupportOutcomeDraftProvider.notifier)
        .initializeFromAction(action);
  }

  Future<void> _selectOutcomeDate() async {
    final draft = ref.read(incomingTalentCareerPathSupportOutcomeDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.outcomeDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentCareerPathSupportOutcomeDraftProvider.notifier)
        .setOutcomeDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(incomingTalentCareerPathSupportOutcomeDraftProvider);
    final outcomeDate = draft.outcomeDate ?? draft.asOfDate;
    final firstDate = outcomeDate.add(const Duration(days: 1));
    final initialDate =
        draft.nextReviewDate != null &&
                draft.nextReviewDate!.isAfter(outcomeDate)
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
        .read(incomingTalentCareerPathSupportOutcomeDraftProvider.notifier)
        .setNextReviewDate(picked);
  }

  void _submitOutcome() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentCareerPathSupportOutcomeDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final outcome = ref
          .read(incomingTalentCareerPathSupportOutcomesProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentCareerPathSupportOutcomeDraftProvider.notifier)
          .clear();
      _showMessage('${outcome.id} recorded for ${outcome.candidateName}');
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

class _SupportOutcomeNarrativeFields extends ConsumerWidget {
  final TextEditingController evidenceController;
  final TextEditingController managerController;
  final TextEditingController nextActionController;

  const _SupportOutcomeNarrativeFields({
    required this.evidenceController,
    required this.managerController,
    required this.nextActionController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      incomingTalentCareerPathSupportOutcomeDraftProvider.notifier,
    );

    return Column(
      children: [
        IncomingTalentCareerPathSupportOutcomeTextInput(
          controller: evidenceController,
          label: 'Evidence summary',
          icon: Icons.description_outlined,
          minLines: 3,
          onChanged: notifier.setEvidenceSummary,
          validator:
              (value) => validateIncomingTalentCareerPathSupportOutcomeLongText(
                value,
                'evidence summary',
              ),
        ),
        const SizedBox(height: 12),
        IncomingTalentCareerPathSupportOutcomeTextInput(
          controller: managerController,
          label: 'Manager note',
          icon: Icons.supervisor_account_outlined,
          minLines: 3,
          onChanged: notifier.setManagerNote,
          validator:
              (value) => validateIncomingTalentCareerPathSupportOutcomeLongText(
                value,
                'manager note',
              ),
        ),
        const SizedBox(height: 12),
        IncomingTalentCareerPathSupportOutcomeTextInput(
          controller: nextActionController,
          label: 'Next review action',
          icon: Icons.route_outlined,
          minLines: 3,
          onChanged: notifier.setNextReviewAction,
          validator:
              (value) => validateIncomingTalentCareerPathSupportOutcomeLongText(
                value,
                'next review action',
              ),
        ),
      ],
    );
  }
}
