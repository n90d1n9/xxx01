import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_program_models.dart';
import '../states/incoming_talent_development_program_milestone_provider.dart';
import 'incoming_talent_development_program_form_widgets.dart';
import 'incoming_talent_development_program_milestone_fields.dart';

class IncomingTalentDevelopmentProgramMilestoneForm
    extends ConsumerStatefulWidget {
  const IncomingTalentDevelopmentProgramMilestoneForm({super.key});

  @override
  ConsumerState<IncomingTalentDevelopmentProgramMilestoneForm> createState() =>
      _IncomingTalentDevelopmentProgramMilestoneFormState();
}

class _IncomingTalentDevelopmentProgramMilestoneFormState
    extends ConsumerState<IncomingTalentDevelopmentProgramMilestoneForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _titleController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _notesController;
  late final TextEditingController _scoreController;
  String? _selectedEnrollmentId;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentDevelopmentProgramMilestoneDraftProvider,
    );
    _selectedEnrollmentId =
        draft.enrollmentId.isEmpty ? null : draft.enrollmentId;
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _titleController = TextEditingController(text: draft.title);
    _evidenceController = TextEditingController(text: draft.evidenceSummary);
    _notesController = TextEditingController(text: draft.reviewNotes);
    _scoreController = TextEditingController(text: '${draft.score}');
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _titleController.dispose();
    _evidenceController.dispose();
    _notesController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enrollments = ref.watch(milestoneReadyProgramEnrollmentsProvider);
    final draft = ref.watch(
      incomingTalentDevelopmentProgramMilestoneDraftProvider,
    );

    syncIncomingTalentDevelopmentProgramController(
      _reviewerController,
      draft.reviewerName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _titleController,
      draft.title,
    );
    syncIncomingTalentDevelopmentProgramController(
      _evidenceController,
      draft.evidenceSummary,
    );
    syncIncomingTalentDevelopmentProgramController(
      _notesController,
      draft.reviewNotes,
    );
    syncIncomingTalentDevelopmentProgramController(
      _scoreController,
      '${draft.score}',
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentDevelopmentProgramMilestoneEnrollmentPicker(
            enrollments: enrollments,
            selectedEnrollmentId: _selectedEnrollmentId,
            onChanged: _selectEnrollment,
          ),
          const SizedBox(height: 12),
          if (enrollments.isEmpty)
            const HrisListSurface(
              child: Text(
                'Enroll talent into a program before milestone review.',
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
                            incomingTalentDevelopmentProgramMilestoneDraftProvider
                                .notifier,
                          )
                          .setReviewerName,
                  validator:
                      (value) => validateIncomingTalentProgramMilestoneRequired(
                        value,
                        'a reviewer',
                      ),
                ),
                IncomingTalentDevelopmentProgramDateButton(
                  label: 'Due',
                  date: draft.dueDate,
                  onTap: _selectDueDate,
                  error: validateIncomingTalentProgramMilestoneDueDate(
                    draft.dueDate,
                    draft.asOfDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramMilestoneReviewFields(
              draft: draft,
              scoreController: _scoreController,
              onTypeChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentProgramMilestoneDraftProvider
                            .notifier,
                      )
                      .setType,
              onStatusChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentProgramMilestoneDraftProvider
                            .notifier,
                      )
                      .setStatus,
              onScoreChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentProgramMilestoneDraftProvider
                            .notifier,
                      )
                      .setScore,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _titleController,
              label: 'Milestone title',
              icon: Icons.task_alt_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentProgramMilestoneDraftProvider
                            .notifier,
                      )
                      .setTitle,
              validator:
                  (value) => validateIncomingTalentProgramMilestoneLongText(
                    value,
                    'title',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _evidenceController,
              label: 'Evidence summary',
              icon: Icons.fact_check_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentProgramMilestoneDraftProvider
                            .notifier,
                      )
                      .setEvidenceSummary,
              validator:
                  (value) => validateIncomingTalentProgramMilestoneLongText(
                    value,
                    'evidence summary',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _notesController,
              label: 'Review notes',
              icon: Icons.rate_review_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentProgramMilestoneDraftProvider
                            .notifier,
                      )
                      .setReviewNotes,
              validator:
                  (value) => validateIncomingTalentProgramMilestoneLongText(
                    value,
                    'review notes',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramMilestoneFormActions(
              completionRatio: draft.completionRatio,
              canSubmit: draft.isReadyToSubmit,
              onClear: _clear,
              onSubmit: _submitMilestone,
            ),
          ],
        ],
      ),
    );
  }

  void _selectEnrollment(String? value) {
    setState(() => _selectedEnrollmentId = value);
    if (value == null) return;

    final enrollment = ref
        .read(milestoneReadyProgramEnrollmentsProvider)
        .firstWhere((item) => item.id == value);
    ref
        .read(incomingTalentDevelopmentProgramMilestoneDraftProvider.notifier)
        .initializeFromEnrollment(enrollment);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(
      incomingTalentDevelopmentProgramMilestoneDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentDevelopmentProgramMilestoneDraftProvider.notifier)
        .setDueDate(picked);
  }

  void _submitMilestone() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentDevelopmentProgramMilestoneDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final milestone = ref
          .read(incomingTalentDevelopmentProgramMilestonesProvider.notifier)
          .submitDraft(draft);
      _clear();
      _showMessage('${milestone.id} created for ${milestone.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _clear() {
    ref
        .read(incomingTalentDevelopmentProgramMilestoneDraftProvider.notifier)
        .clear();
    setState(() => _selectedEnrollmentId = null);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
