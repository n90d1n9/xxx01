import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_path_review_models.dart';
import '../states/incoming_talent_career_path_review_provider.dart';
import 'incoming_talent_career_path_review_form_actions.dart';
import 'incoming_talent_career_path_review_form_fields.dart';
import 'incoming_talent_career_path_review_path_picker.dart';
import 'incoming_talent_career_path_review_readiness.dart';

class IncomingTalentCareerPathReviewForm extends ConsumerStatefulWidget {
  const IncomingTalentCareerPathReviewForm({super.key});

  @override
  ConsumerState<IncomingTalentCareerPathReviewForm> createState() =>
      _IncomingTalentCareerPathReviewFormState();
}

class _IncomingTalentCareerPathReviewFormState
    extends ConsumerState<IncomingTalentCareerPathReviewForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _blockerController;
  late final TextEditingController _nextActionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentCareerPathReviewDraftProvider);
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _evidenceController = TextEditingController(text: draft.evidenceNote);
    _blockerController = TextEditingController(text: draft.blockerNote);
    _nextActionController = TextEditingController(text: draft.nextAction);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _evidenceController.dispose();
    _blockerController.dispose();
    _nextActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentCareerPathReviewDraftProvider);
    final careerPaths = ref.watch(careerPathReviewReadyProvider);

    _sync(_reviewerController, draft.reviewerName);
    _sync(_evidenceController, draft.evidenceNote);
    _sync(_blockerController, draft.blockerNote);
    _sync(_nextActionController, draft.nextAction);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentCareerPathReviewPathPicker(
            draft: draft,
            careerPaths: careerPaths,
            onChanged: _selectCareerPath,
          ),
          const SizedBox(height: 12),
          if (careerPaths.isEmpty)
            const HrisListSurface(
              child: Text('No career paths are ready for review.'),
            )
          else ...[
            IncomingTalentCareerPathReviewTextInput(
              controller: _reviewerController,
              label: 'Reviewer',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentCareerPathReviewDraftProvider.notifier,
                      )
                      .setReviewerName,
              validator:
                  (value) => validateIncomingTalentCareerPathReviewRequired(
                    value,
                    'a reviewer',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentCareerPathReviewDecisionFields(
              draft: draft,
              onDecisionChanged:
                  ref
                      .read(
                        incomingTalentCareerPathReviewDraftProvider.notifier,
                      )
                      .setDecision,
              onReviewedLevelChanged:
                  ref
                      .read(
                        incomingTalentCareerPathReviewDraftProvider.notifier,
                      )
                      .setReviewedLevel,
            ),
            const SizedBox(height: 12),
            IncomingTalentCareerPathReviewDateFields(
              draft: draft,
              onSelectReviewDate: _selectReviewDate,
              onSelectNextReviewDate: _selectNextReviewDate,
            ),
            const SizedBox(height: 12),
            _ReviewNarrativeFields(
              evidenceController: _evidenceController,
              blockerController: _blockerController,
              nextActionController: _nextActionController,
            ),
            const SizedBox(height: 12),
            IncomingTalentCareerPathReviewReadiness(draft: draft),
            const SizedBox(height: 14),
            IncomingTalentCareerPathReviewFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear:
                  ref
                      .read(
                        incomingTalentCareerPathReviewDraftProvider.notifier,
                      )
                      .clear,
              onSubmit: _submitReview,
            ),
          ],
        ],
      ),
    );
  }

  void _selectCareerPath(String? careerPathId) {
    if (careerPathId == null) return;
    final careerPaths = ref.read(careerPathReviewReadyProvider);
    final careerPath = careerPaths.firstWhere(
      (item) => item.id == careerPathId,
    );
    ref
        .read(incomingTalentCareerPathReviewDraftProvider.notifier)
        .initializeFromCareerPath(careerPath);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(incomingTalentCareerPathReviewDraftProvider);
    final picked = await _pickDate(draft.reviewDate ?? draft.asOfDate);
    if (picked == null) return;
    ref
        .read(incomingTalentCareerPathReviewDraftProvider.notifier)
        .setReviewDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(incomingTalentCareerPathReviewDraftProvider);
    final picked = await _pickDate(
      draft.nextReviewDate ?? draft.asOfDate.add(const Duration(days: 30)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentCareerPathReviewDraftProvider.notifier)
        .setNextReviewDate(picked);
  }

  Future<DateTime?> _pickDate(DateTime initialDate) {
    final draft = ref.read(incomingTalentCareerPathReviewDraftProvider);
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
  }

  void _submitReview() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentCareerPathReviewDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final review = ref
          .read(incomingTalentCareerPathReviewsProvider.notifier)
          .submitDraft(draft);
      ref.read(incomingTalentCareerPathReviewDraftProvider.notifier).clear();
      _showMessage('${review.id} recorded for ${review.candidateName}');
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

class _ReviewNarrativeFields extends ConsumerWidget {
  final TextEditingController evidenceController;
  final TextEditingController blockerController;
  final TextEditingController nextActionController;

  const _ReviewNarrativeFields({
    required this.evidenceController,
    required this.blockerController,
    required this.nextActionController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      incomingTalentCareerPathReviewDraftProvider.notifier,
    );

    return Column(
      children: [
        IncomingTalentCareerPathReviewTextInput(
          controller: evidenceController,
          label: 'Evidence note',
          icon: Icons.fact_check_outlined,
          minLines: 3,
          onChanged: notifier.setEvidenceNote,
          validator:
              (value) => validateIncomingTalentCareerPathReviewLongText(
                value,
                'evidence note',
              ),
        ),
        const SizedBox(height: 12),
        IncomingTalentCareerPathReviewTextInput(
          controller: blockerController,
          label: 'Blocker note',
          icon: Icons.report_problem_outlined,
          minLines: 3,
          onChanged: notifier.setBlockerNote,
          validator:
              (value) => validateIncomingTalentCareerPathReviewLongText(
                value,
                'blocker note',
              ),
        ),
        const SizedBox(height: 12),
        IncomingTalentCareerPathReviewTextInput(
          controller: nextActionController,
          label: 'Next action',
          icon: Icons.next_plan_outlined,
          minLines: 3,
          onChanged: notifier.setNextAction,
          validator:
              (value) => validateIncomingTalentCareerPathReviewLongText(
                value,
                'next action',
              ),
        ),
      ],
    );
  }
}
