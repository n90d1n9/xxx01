import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_program_models.dart';
import '../states/incoming_talent_development_program_completion_provider.dart';
import 'incoming_talent_development_program_completion_fields.dart';
import 'incoming_talent_development_program_form_widgets.dart';

class IncomingTalentDevelopmentProgramCompletionForm
    extends ConsumerStatefulWidget {
  const IncomingTalentDevelopmentProgramCompletionForm({super.key});

  @override
  ConsumerState<IncomingTalentDevelopmentProgramCompletionForm> createState() =>
      _IncomingTalentDevelopmentProgramCompletionFormState();
}

class _IncomingTalentDevelopmentProgramCompletionFormState
    extends ConsumerState<IncomingTalentDevelopmentProgramCompletionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _scoreController;
  late final TextEditingController _credentialNoteController;
  late final TextEditingController _recommendationController;
  String? _selectedMilestoneId;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentDevelopmentProgramCompletionDraftProvider,
    );
    _selectedMilestoneId = draft.milestoneId.isEmpty ? null : draft.milestoneId;
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _scoreController = TextEditingController(text: '${draft.score}');
    _credentialNoteController = TextEditingController(
      text: draft.credentialNote,
    );
    _recommendationController = TextEditingController(
      text: draft.managerRecommendation,
    );
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _scoreController.dispose();
    _credentialNoteController.dispose();
    _recommendationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final milestones = ref.watch(completionReadyProgramMilestonesProvider);
    final draft = ref.watch(
      incomingTalentDevelopmentProgramCompletionDraftProvider,
    );

    syncIncomingTalentDevelopmentProgramController(
      _reviewerController,
      draft.reviewerName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _scoreController,
      '${draft.score}',
    );
    syncIncomingTalentDevelopmentProgramController(
      _credentialNoteController,
      draft.credentialNote,
    );
    syncIncomingTalentDevelopmentProgramController(
      _recommendationController,
      draft.managerRecommendation,
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentDevelopmentProgramCompletionMilestonePicker(
            milestones: milestones,
            selectedMilestoneId: _selectedMilestoneId,
            onChanged: _selectMilestone,
          ),
          const SizedBox(height: 12),
          if (milestones.isEmpty)
            const HrisListSurface(
              child: Text(
                'Accept a program milestone before closing completion evidence.',
              ),
            )
          else ...[
            IncomingTalentDevelopmentProgramResponsiveRow(
              children: [
                IncomingTalentDevelopmentProgramTextInput(
                  controller: _reviewerController,
                  label: 'Reviewer',
                  icon: Icons.badge_outlined,
                  onChanged:
                      ref
                          .read(
                            incomingTalentDevelopmentProgramCompletionDraftProvider
                                .notifier,
                          )
                          .setReviewerName,
                  validator:
                      (value) =>
                          validateIncomingTalentProgramCompletionRequired(
                            value,
                            'a reviewer',
                          ),
                ),
                IncomingTalentDevelopmentProgramDateButton(
                  label: 'Completed',
                  date: draft.completedAt,
                  onTap: _selectCompletedAt,
                  error: validateIncomingTalentProgramCompletionDate(
                    draft.completedAt,
                    draft.asOfDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramCompletionDecisionFields(
              draft: draft,
              scoreController: _scoreController,
              onDecisionChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentProgramCompletionDraftProvider
                            .notifier,
                      )
                      .setDecision,
              onCredentialLevelChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentProgramCompletionDraftProvider
                            .notifier,
                      )
                      .setCredentialLevel,
              onScoreChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentProgramCompletionDraftProvider
                            .notifier,
                      )
                      .setScore,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramDateButton(
              label: 'Renewal',
              date: draft.renewalDate,
              onTap: _selectRenewalDate,
              error: validateIncomingTalentProgramCompletionRenewalDate(
                renewalDate: draft.renewalDate,
                completedAt: draft.completedAt,
              ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _credentialNoteController,
              label: 'Credential note',
              icon: Icons.workspace_premium_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentProgramCompletionDraftProvider
                            .notifier,
                      )
                      .setCredentialNote,
              validator:
                  (value) => validateIncomingTalentProgramCompletionLongText(
                    value,
                    'credential note',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _recommendationController,
              label: 'Manager recommendation',
              icon: Icons.recommend_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentProgramCompletionDraftProvider
                            .notifier,
                      )
                      .setManagerRecommendation,
              validator:
                  (value) => validateIncomingTalentProgramCompletionLongText(
                    value,
                    'manager recommendation',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramCompletionFormActions(
              completionRatio: draft.completionRatio,
              canSubmit: draft.isReadyToSubmit,
              onClear: _clear,
              onSubmit: _submitCompletion,
            ),
          ],
        ],
      ),
    );
  }

  void _selectMilestone(String? value) {
    setState(() => _selectedMilestoneId = value);
    if (value == null) return;

    final milestone = ref
        .read(completionReadyProgramMilestonesProvider)
        .firstWhere((item) => item.id == value);
    ref
        .read(incomingTalentDevelopmentProgramCompletionDraftProvider.notifier)
        .initializeFromMilestone(milestone);
  }

  Future<void> _selectCompletedAt() async {
    final draft = ref.read(
      incomingTalentDevelopmentProgramCompletionDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.completedAt ?? draft.asOfDate,
      firstDate: draft.asOfDate.subtract(const Duration(days: 730)),
      lastDate: draft.asOfDate,
    );
    if (picked == null) return;
    ref
        .read(incomingTalentDevelopmentProgramCompletionDraftProvider.notifier)
        .setCompletedAt(picked);
  }

  Future<void> _selectRenewalDate() async {
    final draft = ref.read(
      incomingTalentDevelopmentProgramCompletionDraftProvider,
    );
    final firstDate = draft.completedAt ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.renewalDate ?? draft.asOfDate.add(const Duration(days: 365)),
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 1825)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentDevelopmentProgramCompletionDraftProvider.notifier)
        .setRenewalDate(picked);
  }

  void _submitCompletion() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentDevelopmentProgramCompletionDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final completion = ref
          .read(incomingTalentDevelopmentProgramCompletionsProvider.notifier)
          .submitDraft(draft);
      _clear();
      _showMessage('${completion.id} created for ${completion.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _clear() {
    ref
        .read(incomingTalentDevelopmentProgramCompletionDraftProvider.notifier)
        .clear();
    setState(() => _selectedMilestoneId = null);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
