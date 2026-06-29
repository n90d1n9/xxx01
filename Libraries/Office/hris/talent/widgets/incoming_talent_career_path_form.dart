import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_path_models.dart';
import '../states/incoming_talent_career_path_provider.dart';
import 'incoming_talent_career_path_form_actions.dart';
import 'incoming_talent_career_path_narrative_fields.dart';
import 'incoming_talent_career_path_portfolio_picker.dart';
import 'incoming_talent_career_path_readiness.dart';
import 'incoming_talent_career_path_review_date_field.dart';
import 'incoming_talent_career_path_role_fields.dart';
import 'incoming_talent_career_path_status_fields.dart';

class IncomingTalentCareerPathForm extends ConsumerStatefulWidget {
  const IncomingTalentCareerPathForm({super.key});

  @override
  ConsumerState<IncomingTalentCareerPathForm> createState() =>
      _IncomingTalentCareerPathFormState();
}

class _IncomingTalentCareerPathFormState
    extends ConsumerState<IncomingTalentCareerPathForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _currentRoleController;
  late final TextEditingController _targetRoleController;
  late final TextEditingController _ownerController;
  late final TextEditingController _mentorController;
  late final TextEditingController _competencyController;
  late final TextEditingController _actionController;
  late final TextEditingController _evidenceController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentCareerPathDraftProvider);
    _currentRoleController = TextEditingController(text: draft.currentRole);
    _targetRoleController = TextEditingController(text: draft.targetRole);
    _ownerController = TextEditingController(text: draft.ownerName);
    _mentorController = TextEditingController(text: draft.mentorName);
    _competencyController = TextEditingController(text: draft.competencyName);
    _actionController = TextEditingController(text: draft.developmentAction);
    _evidenceController = TextEditingController(
      text: draft.evidenceRequirement,
    );
  }

  @override
  void dispose() {
    _currentRoleController.dispose();
    _targetRoleController.dispose();
    _ownerController.dispose();
    _mentorController.dispose();
    _competencyController.dispose();
    _actionController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentCareerPathDraftProvider);
    final portfolios = ref.watch(careerPathReadyDevelopmentPortfoliosProvider);

    _sync(_currentRoleController, draft.currentRole);
    _sync(_targetRoleController, draft.targetRole);
    _sync(_ownerController, draft.ownerName);
    _sync(_mentorController, draft.mentorName);
    _sync(_competencyController, draft.competencyName);
    _sync(_actionController, draft.developmentAction);
    _sync(_evidenceController, draft.evidenceRequirement);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentCareerPathPortfolioPicker(
            draft: draft,
            portfolios: portfolios,
            onChanged: _selectPortfolio,
          ),
          const SizedBox(height: 12),
          if (portfolios.isEmpty)
            const HrisListSurface(
              child: Text('No IDP portfolios are ready for career mapping.'),
            )
          else ...[
            IncomingTalentCareerPathRoleFields(
              currentRoleController: _currentRoleController,
              targetRoleController: _targetRoleController,
              competencyController: _competencyController,
            ),
            const SizedBox(height: 12),
            IncomingTalentCareerPathOwnerFields(
              ownerController: _ownerController,
              mentorController: _mentorController,
            ),
            const SizedBox(height: 12),
            IncomingTalentCareerPathStatusFields(
              draft: draft,
              onStatusChanged:
                  ref
                      .read(incomingTalentCareerPathDraftProvider.notifier)
                      .setStatus,
              onPriorityChanged:
                  ref
                      .read(incomingTalentCareerPathDraftProvider.notifier)
                      .setPriority,
              onCurrentLevelChanged:
                  ref
                      .read(incomingTalentCareerPathDraftProvider.notifier)
                      .setCurrentLevel,
              onTargetLevelChanged:
                  ref
                      .read(incomingTalentCareerPathDraftProvider.notifier)
                      .setTargetLevel,
            ),
            const SizedBox(height: 12),
            IncomingTalentCareerPathReviewDateField(
              draft: draft,
              onTap: _selectReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentCareerPathNarrativeFields(
              actionController: _actionController,
              evidenceController: _evidenceController,
            ),
            const SizedBox(height: 12),
            IncomingTalentCareerPathReadiness(draft: draft),
            const SizedBox(height: 14),
            IncomingTalentCareerPathFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear:
                  ref
                      .read(incomingTalentCareerPathDraftProvider.notifier)
                      .clear,
              onSubmit: _submitCareerPath,
            ),
          ],
        ],
      ),
    );
  }

  void _selectPortfolio(String? portfolioId) {
    if (portfolioId == null) return;
    final portfolios = ref.read(careerPathReadyDevelopmentPortfoliosProvider);
    final portfolio = portfolios.firstWhere((item) => item.id == portfolioId);
    ref
        .read(incomingTalentCareerPathDraftProvider.notifier)
        .initializeFromPortfolio(portfolio);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(incomingTalentCareerPathDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.reviewDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentCareerPathDraftProvider.notifier)
        .setReviewDate(picked);
  }

  void _submitCareerPath() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentCareerPathDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final careerPath = ref
          .read(incomingTalentCareerPathsProvider.notifier)
          .submitDraft(draft);
      ref.read(incomingTalentCareerPathDraftProvider.notifier).clear();
      _showMessage('${careerPath.id} created for ${careerPath.candidateName}');
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
