import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_program_models.dart';
import '../states/incoming_talent_development_program_enrollment_provider.dart';
import 'incoming_talent_development_program_enrollment_fields.dart';
import 'incoming_talent_development_program_form_widgets.dart';

class IncomingTalentDevelopmentProgramEnrollmentForm
    extends ConsumerStatefulWidget {
  const IncomingTalentDevelopmentProgramEnrollmentForm({super.key});

  @override
  ConsumerState<IncomingTalentDevelopmentProgramEnrollmentForm> createState() =>
      _IncomingTalentDevelopmentProgramEnrollmentFormState();
}

class _IncomingTalentDevelopmentProgramEnrollmentFormState
    extends ConsumerState<IncomingTalentDevelopmentProgramEnrollmentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _mentorController;
  late final TextEditingController _milestoneController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _progressController;
  String? _selectedProgramId;
  String? _selectedPortfolioId;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentDevelopmentProgramEnrollmentDraftProvider,
    );
    _selectedProgramId = draft.programId.isEmpty ? null : draft.programId;
    _selectedPortfolioId = draft.portfolioId.isEmpty ? null : draft.portfolioId;
    _mentorController = TextEditingController(text: draft.mentorName);
    _milestoneController = TextEditingController(text: draft.milestone);
    _evidenceController = TextEditingController(text: draft.evidencePlan);
    _progressController = TextEditingController(text: '${draft.progressScore}');
  }

  @override
  void dispose() {
    _mentorController.dispose();
    _milestoneController.dispose();
    _evidenceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final programs = ref.watch(enrollmentReadyDevelopmentProgramsProvider);
    final portfolios = ref.watch(programReadyDevelopmentPortfoliosProvider);
    final draft = ref.watch(
      incomingTalentDevelopmentProgramEnrollmentDraftProvider,
    );

    syncIncomingTalentDevelopmentProgramController(
      _mentorController,
      draft.mentorName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _milestoneController,
      draft.milestone,
    );
    syncIncomingTalentDevelopmentProgramController(
      _evidenceController,
      draft.evidencePlan,
    );
    syncIncomingTalentDevelopmentProgramController(
      _progressController,
      '${draft.progressScore}',
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentDevelopmentProgramEnrollmentPickers(
            programs: programs,
            portfolios: portfolios,
            selectedProgramId: _selectedProgramId,
            selectedPortfolioId: _selectedPortfolioId,
            onProgramChanged: _selectProgram,
            onPortfolioChanged: _selectPortfolio,
          ),
          const SizedBox(height: 12),
          if (programs.isEmpty || portfolios.isEmpty)
            const HrisListSurface(
              child: Text(
                'Create an active development program and IDP portfolio before enrollment.',
              ),
            )
          else ...[
            IncomingTalentDevelopmentProgramResponsiveRow(
              children: [
                IncomingTalentDevelopmentProgramTextInput(
                  controller: _mentorController,
                  label: 'Mentor',
                  icon: Icons.supervisor_account_outlined,
                  onChanged:
                      ref
                          .read(
                            incomingTalentDevelopmentProgramEnrollmentDraftProvider
                                .notifier,
                          )
                          .setMentorName,
                  validator:
                      (value) =>
                          validateIncomingTalentProgramEnrollmentRequired(
                            value,
                            'a mentor',
                          ),
                ),
                IncomingTalentDevelopmentProgramNumberInput(
                  controller: _progressController,
                  label: 'Progress score',
                  icon: Icons.percent_outlined,
                  onChanged:
                      ref
                          .read(
                            incomingTalentDevelopmentProgramEnrollmentDraftProvider
                                .notifier,
                          )
                          .setProgressScore,
                  validator: validateIncomingTalentProgramEnrollmentProgress,
                ),
              ],
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramEnrollmentStatusField(
              draft: draft,
              onStatusChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentProgramEnrollmentDraftProvider
                            .notifier,
                      )
                      .setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _milestoneController,
              label: 'First milestone',
              icon: Icons.task_alt_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentProgramEnrollmentDraftProvider
                            .notifier,
                      )
                      .setMilestone,
              validator:
                  (value) => validateIncomingTalentProgramEnrollmentLongText(
                    value,
                    'milestone',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _evidenceController,
              label: 'Evidence plan',
              icon: Icons.fact_check_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentProgramEnrollmentDraftProvider
                            .notifier,
                      )
                      .setEvidencePlan,
              validator:
                  (value) => validateIncomingTalentProgramEnrollmentLongText(
                    value,
                    'evidence plan',
                  ),
            ),
            const SizedBox(height: 10),
            IncomingTalentDevelopmentProgramEnrollmentFormActions(
              completionRatio: draft.completionRatio,
              canSubmit: draft.isReadyToSubmit,
              onClear: _clear,
              onSubmit: _submitEnrollment,
            ),
          ],
        ],
      ),
    );
  }

  void _selectProgram(String? value) {
    setState(() => _selectedProgramId = value);
    _tryInitializeDraft();
  }

  void _selectPortfolio(String? value) {
    setState(() => _selectedPortfolioId = value);
    _tryInitializeDraft();
  }

  void _tryInitializeDraft() {
    final programId = _selectedProgramId;
    final portfolioId = _selectedPortfolioId;
    if (programId == null || portfolioId == null) return;

    final programs = ref.read(enrollmentReadyDevelopmentProgramsProvider);
    final portfolios = ref.read(programReadyDevelopmentPortfoliosProvider);
    final program = programs.firstWhere((item) => item.id == programId);
    final portfolio = portfolios.firstWhere((item) => item.id == portfolioId);

    ref
        .read(incomingTalentDevelopmentProgramEnrollmentDraftProvider.notifier)
        .initializeFromProgramPortfolio(program: program, portfolio: portfolio);
  }

  void _submitEnrollment() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentDevelopmentProgramEnrollmentDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final enrollment = ref
          .read(incomingTalentDevelopmentProgramEnrollmentsProvider.notifier)
          .submitDraft(draft);
      _clear();
      _showMessage('${enrollment.id} created for ${enrollment.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _clear() {
    ref
        .read(incomingTalentDevelopmentProgramEnrollmentDraftProvider.notifier)
        .clear();
    setState(() {
      _selectedProgramId = null;
      _selectedPortfolioId = null;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
