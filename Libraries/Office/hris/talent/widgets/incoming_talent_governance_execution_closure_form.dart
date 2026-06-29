import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import '../states/incoming_talent_governance_execution_closure_provider.dart';
import 'incoming_talent_development_program_form_widgets.dart';
import 'incoming_talent_governance_execution_closure_fields.dart';

/// Form for closing governance execution actions with evidence.
class IncomingTalentGovernanceExecutionClosureForm
    extends ConsumerStatefulWidget {
  const IncomingTalentGovernanceExecutionClosureForm({super.key});

  @override
  ConsumerState<IncomingTalentGovernanceExecutionClosureForm> createState() =>
      _IncomingTalentGovernanceExecutionClosureFormState();
}

/// State backing governance execution closure form controllers.
class _IncomingTalentGovernanceExecutionClosureFormState
    extends ConsumerState<IncomingTalentGovernanceExecutionClosureForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _ownerNoteController;
  late final TextEditingController _nextActionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentGovernanceExecutionClosureDraftProvider,
    );
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _evidenceController = TextEditingController(text: draft.evidenceSummary);
    _ownerNoteController = TextEditingController(
      text: draft.ownerConfirmationNote,
    );
    _nextActionController = TextEditingController(text: draft.nextAction);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _evidenceController.dispose();
    _ownerNoteController.dispose();
    _nextActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentGovernanceExecutionClosureDraftProvider,
    );
    final actions = ref.watch(
      closureReadyTalentGovernanceExecutionActionsProvider,
    );
    final notifier = ref.read(
      incomingTalentGovernanceExecutionClosureDraftProvider.notifier,
    );

    syncIncomingTalentDevelopmentProgramController(
      _reviewerController,
      draft.reviewerName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _evidenceController,
      draft.evidenceSummary,
    );
    syncIncomingTalentDevelopmentProgramController(
      _ownerNoteController,
      draft.ownerConfirmationNote,
    );
    syncIncomingTalentDevelopmentProgramController(
      _nextActionController,
      draft.nextAction,
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentGovernanceExecutionClosureActionPicker(
            draft: draft,
            actions: actions,
            onChanged: _selectAction,
          ),
          const SizedBox(height: 12),
          if (actions.isEmpty)
            const HrisListSurface(
              child: Text(
                'No governance execution actions are ready for closure.',
              ),
            )
          else ...[
            IncomingTalentDevelopmentProgramTextInput(
              controller: _reviewerController,
              label: 'Closure reviewer',
              icon: Icons.badge_outlined,
              onChanged: notifier.setReviewerName,
              validator:
                  (value) =>
                      validateIncomingTalentGovernanceExecutionClosureRequired(
                        value,
                        'a closure reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentGovernanceExecutionClosureDateFields(
              draft: draft,
              onSelectClosureDate: _selectClosureDate,
              onSelectNextReviewDate: _selectNextReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentGovernanceExecutionClosureSignalFields(
              draft: draft,
              onOutcomeChanged: notifier.setOutcome,
              onResidualRiskChanged: notifier.setResidualRiskCount,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _evidenceController,
              label: 'Evidence summary',
              icon: Icons.description_outlined,
              minLines: 3,
              onChanged: notifier.setEvidenceSummary,
              validator:
                  (value) =>
                      validateIncomingTalentGovernanceExecutionClosureLongText(
                        value,
                        'evidence summary',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _ownerNoteController,
              label: 'Owner confirmation',
              icon: Icons.assignment_ind_outlined,
              minLines: 3,
              onChanged: notifier.setOwnerConfirmationNote,
              validator:
                  (value) =>
                      validateIncomingTalentGovernanceExecutionClosureLongText(
                        value,
                        'owner confirmation note',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _nextActionController,
              label: 'Next action',
              icon: Icons.route_outlined,
              minLines: 3,
              onChanged: notifier.setNextAction,
              validator:
                  (value) =>
                      validateIncomingTalentGovernanceExecutionClosureLongText(
                        value,
                        'next action',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentGovernanceExecutionClosureReadiness(draft: draft),
            const SizedBox(height: 14),
            IncomingTalentGovernanceExecutionClosureFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear: notifier.clear,
              onSubmit: _submitClosure,
            ),
          ],
        ],
      ),
    );
  }

  void _selectAction(String? actionId) {
    if (actionId == null) return;
    final actions = ref.read(
      closureReadyTalentGovernanceExecutionActionsProvider,
    );
    final action = actions.firstWhere((item) => item.id == actionId);
    ref
        .read(incomingTalentGovernanceExecutionClosureDraftProvider.notifier)
        .initializeFromAction(action);
  }

  Future<void> _selectClosureDate() async {
    final draft = ref.read(
      incomingTalentGovernanceExecutionClosureDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.closureDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentGovernanceExecutionClosureDraftProvider.notifier)
        .setClosureDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(
      incomingTalentGovernanceExecutionClosureDraftProvider,
    );
    final closureDate = draft.closureDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.nextReviewDate ?? closureDate.add(const Duration(days: 14)),
      firstDate: closureDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentGovernanceExecutionClosureDraftProvider.notifier)
        .setNextReviewDate(picked);
  }

  void _submitClosure() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentGovernanceExecutionClosureDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final closure = ref
          .read(incomingTalentGovernanceExecutionClosuresProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentGovernanceExecutionClosureDraftProvider.notifier)
          .clear();
      _showMessage('${closure.id} submitted for ${closure.ownerName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

@Preview(name: 'Talent governance execution closure form')
Widget incomingTalentGovernanceExecutionClosureFormPreview() {
  final action = _previewAction;
  final draft = IncomingTalentGovernanceExecutionClosureDraft.fromAction(
    action: action,
    asOfDate: DateTime(2026, 6, 12),
  );

  return ProviderScope(
    overrides: [
      closureReadyTalentGovernanceExecutionActionsProvider.overrideWithValue([
        action,
      ]),
      incomingTalentGovernanceExecutionClosureDraftProvider.overrideWith(
        (_) => _PreviewClosureDraftNotifier(draft),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentGovernanceExecutionClosureForm(),
        ),
      ),
    ),
  );
}

class _PreviewClosureDraftNotifier
    extends IncomingTalentGovernanceExecutionClosureDraftNotifier {
  _PreviewClosureDraftNotifier(
    IncomingTalentGovernanceExecutionClosureDraft draft,
  ) : super(draft.asOfDate) {
    state = draft;
  }
}

final _previewAction = IncomingTalentGovernanceExecutionAction(
  id: 'talent-governance-execution-action-preview',
  trackId: 'talent-governance-execution-preview',
  type: IncomingTalentGovernanceExecutionActionType.recoverOverdue,
  priority: IncomingTalentGovernanceExecutionActionPriority.critical,
  title: 'People Risk and Assurance - recover overdue',
  detail: 'Execute assurance approval decision',
  nextAction:
      'Ask People Risk and Assurance to recover overdue follow-through for execute assurance approval decision.',
  playbook:
      'Reconfirm due date, capture recovery evidence, and mark owner acceptance.',
  evidenceExpectation:
      'Attach assurance approval evidence, owner confirmation, and recovery note.',
  ownerName: 'People Risk and Assurance',
  dueDate: DateTime(2026, 6, 11),
  progressRatio: 0.1,
  signalCount: 5,
  decisionCount: 3,
  readinessTaskCount: 1,
  overdue: true,
);
