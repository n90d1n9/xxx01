import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_coverage_action_provider.dart';
import 'incoming_talent_succession_coverage_action_form_fields.dart';
import 'incoming_talent_succession_coverage_action_review_picker.dart';

class IncomingTalentSuccessionCoverageActionForm
    extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionCoverageActionForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionCoverageActionForm> createState() =>
      _IncomingTalentSuccessionCoverageActionFormState();
}

class _IncomingTalentSuccessionCoverageActionFormState
    extends ConsumerState<IncomingTalentSuccessionCoverageActionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _planController;
  late final TextEditingController _pathController;
  late final TextEditingController _evidenceController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentSuccessionCoverageActionDraftProvider);
    _ownerController = TextEditingController(text: draft.ownerName);
    _planController = TextEditingController(text: draft.actionPlan);
    _pathController = TextEditingController(text: draft.escalationPath);
    _evidenceController = TextEditingController(text: draft.resolutionEvidence);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _planController.dispose();
    _pathController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentSuccessionCoverageActionDraftProvider,
    );
    final reviews = ref.watch(actionReadySuccessionCoverageReviewsProvider);

    _sync(_ownerController, draft.ownerName);
    _sync(_planController, draft.actionPlan);
    _sync(_pathController, draft.escalationPath);
    _sync(_evidenceController, draft.resolutionEvidence);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentSuccessionCoverageActionReviewPicker(
            draft: draft,
            reviews: reviews,
            onChanged: _selectReview,
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            const HrisListSurface(
              child: Text('No coverage reviews are ready for action.'),
            )
          else ...[
            IncomingTalentSuccessionCoverageActionTextInput(
              controller: _ownerController,
              label: 'Action owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageActionDraftProvider
                            .notifier,
                      )
                      .setOwnerName,
              validator:
                  (value) =>
                      IncomingTalentSuccessionCoverageActionDraft.validateRequired(
                        value,
                        'an action owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageActionControlFields(
              draft: draft,
              onTypeChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageActionDraftProvider
                            .notifier,
                      )
                      .setActionType,
              onSelectDueDate: _selectDueDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageActionTextInput(
              controller: _planController,
              label: 'Action plan',
              icon: Icons.task_alt_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageActionDraftProvider
                            .notifier,
                      )
                      .setActionPlan,
              validator:
                  IncomingTalentSuccessionCoverageActionDraft
                      .validateActionPlan,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageActionTextInput(
              controller: _pathController,
              label: 'Escalation path',
              icon: Icons.account_tree_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageActionDraftProvider
                            .notifier,
                      )
                      .setEscalationPath,
              validator:
                  IncomingTalentSuccessionCoverageActionDraft
                      .validateEscalationPath,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageActionTextInput(
              controller: _evidenceController,
              label: 'Resolution evidence',
              icon: Icons.verified_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageActionDraftProvider
                            .notifier,
                      )
                      .setResolutionEvidence,
              validator:
                  IncomingTalentSuccessionCoverageActionDraft
                      .validateResolutionEvidence,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageActionDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentSuccessionCoverageActionDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key(
                    'incoming-talent-succession-coverage-action-submit',
                  ),
                  onPressed: draft.isReadyToSubmit ? _submitAction : null,
                  icon: const Icon(Icons.task_alt_outlined),
                  label: const Text('Create action'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectReview(String? reviewId) {
    if (reviewId == null) return;
    final reviews = ref.read(actionReadySuccessionCoverageReviewsProvider);
    final review = reviews.firstWhere((item) => item.id == reviewId);
    ref
        .read(incomingTalentSuccessionCoverageActionDraftProvider.notifier)
        .initializeFromReview(review);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(incomingTalentSuccessionCoverageActionDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionCoverageActionDraftProvider.notifier)
        .setDueDate(picked);
  }

  void _submitAction() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentSuccessionCoverageActionDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final action = ref
          .read(incomingTalentSuccessionCoverageActionsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentSuccessionCoverageActionDraftProvider.notifier)
          .clear();
      _showMessage('${action.id} created for ${action.scopeLabel}');
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
