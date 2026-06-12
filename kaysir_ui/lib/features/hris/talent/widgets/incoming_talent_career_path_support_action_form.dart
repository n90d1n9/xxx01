import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_path_support_action_models.dart';
import '../states/incoming_talent_career_path_support_action_provider.dart';
import 'incoming_talent_career_path_support_action_form_actions.dart';
import 'incoming_talent_career_path_support_action_form_fields.dart';
import 'incoming_talent_career_path_support_action_readiness.dart';
import 'incoming_talent_career_path_support_action_review_picker.dart';

class IncomingTalentCareerPathSupportActionForm extends ConsumerStatefulWidget {
  const IncomingTalentCareerPathSupportActionForm({super.key});

  @override
  ConsumerState<IncomingTalentCareerPathSupportActionForm> createState() =>
      _IncomingTalentCareerPathSupportActionFormState();
}

class _IncomingTalentCareerPathSupportActionFormState
    extends ConsumerState<IncomingTalentCareerPathSupportActionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _actionController;
  late final TextEditingController _criteriaController;
  late final TextEditingController _escalationController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentCareerPathSupportActionDraftProvider);
    _ownerController = TextEditingController(text: draft.ownerName);
    _actionController = TextEditingController(text: draft.actionPlan);
    _criteriaController = TextEditingController(text: draft.successCriteria);
    _escalationController = TextEditingController(text: draft.escalationNote);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _actionController.dispose();
    _criteriaController.dispose();
    _escalationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentCareerPathSupportActionDraftProvider);
    final reviews = ref.watch(careerPathSupportActionReadyReviewsProvider);

    _sync(_ownerController, draft.ownerName);
    _sync(_actionController, draft.actionPlan);
    _sync(_criteriaController, draft.successCriteria);
    _sync(_escalationController, draft.escalationNote);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentCareerPathSupportActionReviewPicker(
            draft: draft,
            reviews: reviews,
            onChanged: _selectReview,
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            const HrisListSurface(
              child: Text('No blocked career reviews need support actions.'),
            )
          else ...[
            IncomingTalentCareerPathSupportActionTextInput(
              controller: _ownerController,
              label: 'Action owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentCareerPathSupportActionDraftProvider
                            .notifier,
                      )
                      .setOwnerName,
              validator:
                  (value) =>
                      validateIncomingTalentCareerPathSupportActionRequired(
                        value,
                        'an owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentCareerPathSupportActionStatusFields(
              draft: draft,
              onTypeChanged:
                  ref
                      .read(
                        incomingTalentCareerPathSupportActionDraftProvider
                            .notifier,
                      )
                      .setActionType,
              onPriorityChanged:
                  ref
                      .read(
                        incomingTalentCareerPathSupportActionDraftProvider
                            .notifier,
                      )
                      .setPriority,
              onStatusChanged:
                  ref
                      .read(
                        incomingTalentCareerPathSupportActionDraftProvider
                            .notifier,
                      )
                      .setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentCareerPathSupportActionDueDateField(
              draft: draft,
              onTap: _selectDueDate,
            ),
            const SizedBox(height: 12),
            _SupportNarrativeFields(
              actionController: _actionController,
              criteriaController: _criteriaController,
              escalationController: _escalationController,
            ),
            const SizedBox(height: 12),
            IncomingTalentCareerPathSupportActionReadiness(draft: draft),
            const SizedBox(height: 14),
            IncomingTalentCareerPathSupportActionFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear:
                  ref
                      .read(
                        incomingTalentCareerPathSupportActionDraftProvider
                            .notifier,
                      )
                      .clear,
              onSubmit: _submitAction,
            ),
          ],
        ],
      ),
    );
  }

  void _selectReview(String? reviewId) {
    if (reviewId == null) return;
    final reviews = ref.read(careerPathSupportActionReadyReviewsProvider);
    final review = reviews.firstWhere((item) => item.id == reviewId);
    ref
        .read(incomingTalentCareerPathSupportActionDraftProvider.notifier)
        .initializeFromReview(review);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(incomingTalentCareerPathSupportActionDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentCareerPathSupportActionDraftProvider.notifier)
        .setDueDate(picked);
  }

  void _submitAction() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentCareerPathSupportActionDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final action = ref
          .read(incomingTalentCareerPathSupportActionsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentCareerPathSupportActionDraftProvider.notifier)
          .clear();
      _showMessage('${action.id} created for ${action.candidateName}');
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

class _SupportNarrativeFields extends ConsumerWidget {
  final TextEditingController actionController;
  final TextEditingController criteriaController;
  final TextEditingController escalationController;

  const _SupportNarrativeFields({
    required this.actionController,
    required this.criteriaController,
    required this.escalationController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      incomingTalentCareerPathSupportActionDraftProvider.notifier,
    );

    return Column(
      children: [
        IncomingTalentCareerPathSupportActionTextInput(
          controller: actionController,
          label: 'Action plan',
          icon: Icons.next_plan_outlined,
          minLines: 3,
          onChanged: notifier.setActionPlan,
          validator:
              (value) => validateIncomingTalentCareerPathSupportActionLongText(
                value,
                'action plan',
              ),
        ),
        const SizedBox(height: 12),
        IncomingTalentCareerPathSupportActionTextInput(
          controller: criteriaController,
          label: 'Success criteria',
          icon: Icons.insights_outlined,
          minLines: 3,
          onChanged: notifier.setSuccessCriteria,
          validator:
              (value) => validateIncomingTalentCareerPathSupportActionLongText(
                value,
                'success criteria',
              ),
        ),
        const SizedBox(height: 12),
        IncomingTalentCareerPathSupportActionTextInput(
          controller: escalationController,
          label: 'Escalation note',
          icon: Icons.report_problem_outlined,
          minLines: 3,
          onChanged: notifier.setEscalationNote,
          validator:
              (value) => validateIncomingTalentCareerPathSupportActionLongText(
                value,
                'escalation note',
              ),
        ),
      ],
    );
  }
}
