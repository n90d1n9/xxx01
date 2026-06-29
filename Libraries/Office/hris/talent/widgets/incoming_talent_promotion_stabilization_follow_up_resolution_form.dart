import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import '../models/incoming_talent_promotion_stabilization_follow_up_resolution_models.dart';
import '../models/incoming_talent_promotion_stabilization_review_models.dart';
import '../states/incoming_talent_promotion_stabilization_follow_up_resolution_provider.dart';
import 'incoming_talent_development_program_form_widgets.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution_fields.dart';

/// Form for validating outcomes after promotion follow-up actions close.
class IncomingTalentPromotionStabilizationFollowUpResolutionForm
    extends ConsumerStatefulWidget {
  const IncomingTalentPromotionStabilizationFollowUpResolutionForm({super.key});

  @override
  ConsumerState<IncomingTalentPromotionStabilizationFollowUpResolutionForm>
  createState() =>
      _IncomingTalentPromotionStabilizationFollowUpResolutionFormState();
}

/// State backing promotion follow-up resolution review controllers.
class _IncomingTalentPromotionStabilizationFollowUpResolutionFormState
    extends
        ConsumerState<
          IncomingTalentPromotionStabilizationFollowUpResolutionForm
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
      incomingTalentPromotionStabilizationFollowUpResolutionDraftProvider,
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
      incomingTalentPromotionStabilizationFollowUpResolutionDraftProvider,
    );
    final actions = ref.watch(
      resolutionReadyPromotionStabilizationFollowUpActionsProvider,
    );
    final notifier = ref.read(
      incomingTalentPromotionStabilizationFollowUpResolutionDraftProvider
          .notifier,
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
      _managerNoteController,
      draft.managerNote,
    );
    syncIncomingTalentDevelopmentProgramController(
      _nextActionController,
      draft.nextAction,
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentPromotionStabilizationFollowUpResolutionActionPicker(
            draft: draft,
            actions: actions,
            onChanged: _selectAction,
          ),
          const SizedBox(height: 12),
          if (actions.isEmpty)
            const HrisListSurface(
              child: Text(
                'No resolved or escalated promotion follow-ups are ready for review.',
              ),
            )
          else ...[
            IncomingTalentDevelopmentProgramTextInput(
              controller: _reviewerController,
              label: 'Review owner',
              icon: Icons.badge_outlined,
              onChanged: notifier.setReviewerName,
              validator:
                  (value) =>
                      validateIncomingTalentPromotionFollowUpResolutionRequired(
                        value,
                        'a reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentPromotionStabilizationFollowUpResolutionDateFields(
              draft: draft,
              onSelectReviewDate: _selectReviewDate,
              onSelectNextReviewDate: _selectNextReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentPromotionStabilizationFollowUpResolutionSignalFields(
              draft: draft,
              onOutcomeChanged: notifier.setOutcome,
              onConfidenceChanged: notifier.setConfidenceAfter,
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
                      validateIncomingTalentPromotionFollowUpResolutionLongText(
                        value,
                        'evidence summary',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _managerNoteController,
              label: 'Manager note',
              icon: Icons.handshake_outlined,
              minLines: 3,
              onChanged: notifier.setManagerNote,
              validator:
                  (value) =>
                      validateIncomingTalentPromotionFollowUpResolutionLongText(
                        value,
                        'manager note',
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
                      validateIncomingTalentPromotionFollowUpResolutionLongText(
                        value,
                        'next action',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentPromotionStabilizationFollowUpResolutionReadiness(
              draft: draft,
            ),
            const SizedBox(height: 14),
            IncomingTalentPromotionStabilizationFollowUpResolutionFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear: notifier.clear,
              onSubmit: _submitResolution,
            ),
          ],
        ],
      ),
    );
  }

  void _selectAction(String? actionId) {
    if (actionId == null) return;
    final actions = ref.read(
      resolutionReadyPromotionStabilizationFollowUpActionsProvider,
    );
    final action = actions.firstWhere((item) => item.id == actionId);
    ref
        .read(
          incomingTalentPromotionStabilizationFollowUpResolutionDraftProvider
              .notifier,
        )
        .initializeFromAction(action);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(
      incomingTalentPromotionStabilizationFollowUpResolutionDraftProvider,
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
          incomingTalentPromotionStabilizationFollowUpResolutionDraftProvider
              .notifier,
        )
        .setReviewDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(
      incomingTalentPromotionStabilizationFollowUpResolutionDraftProvider,
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
          incomingTalentPromotionStabilizationFollowUpResolutionDraftProvider
              .notifier,
        )
        .setNextReviewDate(picked);
  }

  void _submitResolution() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentPromotionStabilizationFollowUpResolutionDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final resolution = ref
          .read(
            incomingTalentPromotionStabilizationFollowUpResolutionsProvider
                .notifier,
          )
          .submitDraft(draft);
      ref
          .read(
            incomingTalentPromotionStabilizationFollowUpResolutionDraftProvider
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

@Preview(name: 'Talent promotion follow-up resolution form')
Widget incomingTalentPromotionFollowUpResolutionFormPreview() {
  final action = _previewAction;

  return ProviderScope(
    overrides: [
      resolutionReadyPromotionStabilizationFollowUpActionsProvider
          .overrideWithValue([action]),
      incomingTalentPromotionStabilizationFollowUpResolutionDraftProvider
          .overrideWith(
            (ref) =>
                IncomingTalentPromotionStabilizationFollowUpResolutionDraftNotifier(
                  DateTime(2026, 7, 28),
                )..initializeFromAction(action),
          ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentPromotionStabilizationFollowUpResolutionForm(),
        ),
      ),
    ),
  );
}

final _previewAction = IncomingTalentPromotionStabilizationFollowUpAction(
  id: 'promotion-follow-up-preview',
  reviewId: 'promotion-review-preview',
  implementationId: 'promotion-implementation-preview',
  decisionId: 'promotion-decision-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  newRole: 'Lead Backend Engineer',
  frameworkLevelCode: 'L5',
  ownerName: 'Engineering HRBP',
  actionType:
      IncomingTalentPromotionStabilizationFollowUpActionType.managerCoaching,
  priority: IncomingTalentPromotionStabilizationFollowUpPriority.critical,
  status: IncomingTalentPromotionStabilizationFollowUpStatus.resolved,
  dueDate: DateTime(2026, 7, 21),
  actionPlan:
      'Run manager coaching checkpoint and clarify promotion success measures.',
  successCriteria:
      'Manager and employee confirm clear expectations and support cadence.',
  escalationNote: 'Escalate if progress is not confirmed by the due date.',
  resolutionNote:
      'Manager and employee confirmed the promotion support cadence.',
  sourceOutcome:
      IncomingTalentPromotionStabilizationOutcome.needsManagerSupport,
  sourceReviewStatus:
      IncomingTalentPromotionStabilizationStatus.followUpRequired,
  sourceConfidenceScore: 3,
  createdAt: DateTime(2026, 7, 9),
);
