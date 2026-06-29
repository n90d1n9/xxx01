import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import '../states/incoming_talent_promotion_stabilization_follow_up_action_provider.dart';
import 'incoming_talent_development_program_form_widgets.dart';
import 'incoming_talent_promotion_stabilization_follow_up_action_fields.dart';

/// Form for creating operational actions from risky promotion reviews.
class IncomingTalentPromotionStabilizationFollowUpActionForm
    extends ConsumerStatefulWidget {
  const IncomingTalentPromotionStabilizationFollowUpActionForm({super.key});

  @override
  ConsumerState<IncomingTalentPromotionStabilizationFollowUpActionForm>
  createState() =>
      _IncomingTalentPromotionStabilizationFollowUpActionFormState();
}

/// State backing promotion stabilization follow-up form controllers.
class _IncomingTalentPromotionStabilizationFollowUpActionFormState
    extends
        ConsumerState<IncomingTalentPromotionStabilizationFollowUpActionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _actionController;
  late final TextEditingController _criteriaController;
  late final TextEditingController _escalationController;
  late final TextEditingController _resolutionController;
  String? _selectedReviewId;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentPromotionStabilizationFollowUpActionDraftProvider,
    );
    _selectedReviewId = draft.reviewId.isEmpty ? null : draft.reviewId;
    _ownerController = TextEditingController(text: draft.ownerName);
    _actionController = TextEditingController(text: draft.actionPlan);
    _criteriaController = TextEditingController(text: draft.successCriteria);
    _escalationController = TextEditingController(text: draft.escalationNote);
    _resolutionController = TextEditingController(text: draft.resolutionNote);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _actionController.dispose();
    _criteriaController.dispose();
    _escalationController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviews = ref.watch(
      promotionStabilizationFollowUpReadyReviewsProvider,
    );
    final draft = ref.watch(
      incomingTalentPromotionStabilizationFollowUpActionDraftProvider,
    );

    syncIncomingTalentDevelopmentProgramController(
      _ownerController,
      draft.ownerName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _actionController,
      draft.actionPlan,
    );
    syncIncomingTalentDevelopmentProgramController(
      _criteriaController,
      draft.successCriteria,
    );
    syncIncomingTalentDevelopmentProgramController(
      _escalationController,
      draft.escalationNote,
    );
    syncIncomingTalentDevelopmentProgramController(
      _resolutionController,
      draft.resolutionNote,
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentPromotionStabilizationFollowUpReviewPicker(
            reviews: reviews,
            selectedReviewId: _selectedReviewId,
            onReviewChanged: _selectReview,
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            const HrisListSurface(
              child: Text(
                'No risky promotion stabilization reviews need follow-up.',
              ),
            )
          else ...[
            IncomingTalentDevelopmentProgramTextInput(
              controller: _ownerController,
              label: 'Owner',
              icon: Icons.supervisor_account_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentPromotionStabilizationFollowUpActionDraftProvider
                            .notifier,
                      )
                      .setOwnerName,
              validator:
                  (value) =>
                      validateIncomingTalentPromotionStabilizationFollowUpRequired(
                        value,
                        'an owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentPromotionStabilizationFollowUpClassificationFields(
              draft: draft,
              onActionTypeChanged:
                  ref
                      .read(
                        incomingTalentPromotionStabilizationFollowUpActionDraftProvider
                            .notifier,
                      )
                      .setActionType,
              onPriorityChanged:
                  ref
                      .read(
                        incomingTalentPromotionStabilizationFollowUpActionDraftProvider
                            .notifier,
                      )
                      .setPriority,
              onStatusChanged:
                  ref
                      .read(
                        incomingTalentPromotionStabilizationFollowUpActionDraftProvider
                            .notifier,
                      )
                      .setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentPromotionStabilizationFollowUpDueDateField(
              draft: draft,
              onTap: _selectDueDate,
            ),
            const SizedBox(height: 12),
            _FollowUpNarrativeFields(
              actionController: _actionController,
              criteriaController: _criteriaController,
              escalationController: _escalationController,
              resolutionController: _resolutionController,
            ),
            const SizedBox(height: 10),
            IncomingTalentPromotionStabilizationFollowUpFormActions(
              completionRatio: draft.completionRatio,
              canSubmit: draft.isReadyToSubmit,
              onClear: _clear,
              onSubmit: _submitAction,
            ),
          ],
        ],
      ),
    );
  }

  void _selectReview(String? value) {
    setState(() => _selectedReviewId = value);
    if (value == null) return;
    final reviews = ref.read(
      promotionStabilizationFollowUpReadyReviewsProvider,
    );
    final review = reviews.firstWhere((item) => item.id == value);
    ref
        .read(
          incomingTalentPromotionStabilizationFollowUpActionDraftProvider
              .notifier,
        )
        .initializeFromReview(review);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(
      incomingTalentPromotionStabilizationFollowUpActionDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(
          incomingTalentPromotionStabilizationFollowUpActionDraftProvider
              .notifier,
        )
        .setDueDate(picked);
  }

  void _submitAction() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentPromotionStabilizationFollowUpActionDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final action = ref
          .read(
            incomingTalentPromotionStabilizationFollowUpActionsProvider
                .notifier,
          )
          .submitDraft(draft);
      _clear();
      _showMessage('${action.id} created for ${action.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _clear() {
    ref
        .read(
          incomingTalentPromotionStabilizationFollowUpActionDraftProvider
              .notifier,
        )
        .clear();
    setState(() => _selectedReviewId = null);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Narrative fields for the promotion stabilization follow-up action form.
class _FollowUpNarrativeFields extends ConsumerWidget {
  final TextEditingController actionController;
  final TextEditingController criteriaController;
  final TextEditingController escalationController;
  final TextEditingController resolutionController;

  const _FollowUpNarrativeFields({
    required this.actionController,
    required this.criteriaController,
    required this.escalationController,
    required this.resolutionController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      incomingTalentPromotionStabilizationFollowUpActionDraftProvider.notifier,
    );
    final draft = ref.watch(
      incomingTalentPromotionStabilizationFollowUpActionDraftProvider,
    );

    return Column(
      children: [
        IncomingTalentDevelopmentProgramTextInput(
          controller: actionController,
          label: 'Action plan',
          icon: Icons.next_plan_outlined,
          minLines: 2,
          onChanged: notifier.setActionPlan,
          validator:
              (value) =>
                  validateIncomingTalentPromotionStabilizationFollowUpLongText(
                    value,
                    'action plan',
                  ),
        ),
        const SizedBox(height: 12),
        IncomingTalentDevelopmentProgramTextInput(
          controller: criteriaController,
          label: 'Success criteria',
          icon: Icons.insights_outlined,
          minLines: 2,
          onChanged: notifier.setSuccessCriteria,
          validator:
              (value) =>
                  validateIncomingTalentPromotionStabilizationFollowUpLongText(
                    value,
                    'success criteria',
                  ),
        ),
        const SizedBox(height: 12),
        IncomingTalentDevelopmentProgramTextInput(
          controller: escalationController,
          label: 'Escalation note',
          icon: Icons.report_problem_outlined,
          minLines: 2,
          onChanged: notifier.setEscalationNote,
          validator:
              (value) =>
                  validateIncomingTalentPromotionStabilizationFollowUpLongText(
                    value,
                    'escalation note',
                  ),
        ),
        const SizedBox(height: 12),
        IncomingTalentDevelopmentProgramTextInput(
          controller: resolutionController,
          label: 'Resolution note',
          icon: Icons.task_alt_outlined,
          minLines: 2,
          onChanged: notifier.setResolutionNote,
          validator:
              (value) =>
                  validateIncomingTalentPromotionStabilizationFollowUpResolutionNote(
                    status: draft.status,
                    resolutionNote: value ?? '',
                  ),
        ),
      ],
    );
  }
}

@Preview(name: 'Talent promotion stabilization follow-up form')
Widget incomingTalentPromotionStabilizationFollowUpActionFormPreview() {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentPromotionStabilizationFollowUpActionForm(),
        ),
      ),
    ),
  );
}
