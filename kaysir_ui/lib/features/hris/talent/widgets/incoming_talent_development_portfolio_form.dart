import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_portfolio_models.dart';
import '../states/incoming_talent_development_portfolio_provider.dart';
import 'incoming_talent_development_portfolio_form_actions.dart';
import 'incoming_talent_development_portfolio_form_fields.dart';
import 'incoming_talent_development_portfolio_narrative_fields.dart';
import 'incoming_talent_development_portfolio_owner_fields.dart';
import 'incoming_talent_development_portfolio_readiness.dart';
import 'incoming_talent_development_portfolio_roadmap_picker.dart';

class IncomingTalentDevelopmentPortfolioForm extends ConsumerStatefulWidget {
  const IncomingTalentDevelopmentPortfolioForm({super.key});

  @override
  ConsumerState<IncomingTalentDevelopmentPortfolioForm> createState() =>
      _IncomingTalentDevelopmentPortfolioFormState();
}

class _IncomingTalentDevelopmentPortfolioFormState
    extends ConsumerState<IncomingTalentDevelopmentPortfolioForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _mentorController;
  late final TextEditingController _competencyController;
  late final TextEditingController _goalController;
  late final TextEditingController _learningController;
  late final TextEditingController _evidenceController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentDevelopmentPortfolioDraftProvider);
    _ownerController = TextEditingController(text: draft.portfolioOwnerName);
    _mentorController = TextEditingController(text: draft.mentorName);
    _competencyController = TextEditingController(text: draft.competencyFocus);
    _goalController = TextEditingController(text: draft.growthGoal);
    _learningController = TextEditingController(text: draft.learningPath);
    _evidenceController = TextEditingController(text: draft.evidencePlan);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _mentorController.dispose();
    _competencyController.dispose();
    _goalController.dispose();
    _learningController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentDevelopmentPortfolioDraftProvider);
    final roadmaps = ref.watch(portfolioReadyDevelopmentRoadmapsProvider);

    _sync(_ownerController, draft.portfolioOwnerName);
    _sync(_mentorController, draft.mentorName);
    _sync(_competencyController, draft.competencyFocus);
    _sync(_goalController, draft.growthGoal);
    _sync(_learningController, draft.learningPath);
    _sync(_evidenceController, draft.evidencePlan);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentDevelopmentPortfolioRoadmapPicker(
            draft: draft,
            roadmaps: roadmaps,
            onChanged: _selectRoadmap,
          ),
          const SizedBox(height: 12),
          if (roadmaps.isEmpty)
            const HrisListSurface(
              child: Text('No development roadmaps are ready for IDP setup.'),
            )
          else ...[
            IncomingTalentDevelopmentPortfolioOwnerFields(
              ownerController: _ownerController,
              mentorController: _mentorController,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentPortfolioStatusFields(
              draft: draft,
              onStageChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentPortfolioDraftProvider
                            .notifier,
                      )
                      .setStage,
              onPriorityChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentPortfolioDraftProvider
                            .notifier,
                      )
                      .setPriority,
              onCadenceChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentPortfolioDraftProvider
                            .notifier,
                      )
                      .setReviewCadence,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentPortfolioDateFields(
              draft: draft,
              onSelectStartDate: _selectStartDate,
              onSelectNextReviewDate: _selectNextReviewDate,
              onSelectTargetDate: _selectTargetDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentPortfolioNarrativeFields(
              competencyController: _competencyController,
              goalController: _goalController,
              learningController: _learningController,
              evidenceController: _evidenceController,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentPortfolioReadiness(draft: draft),
            const SizedBox(height: 14),
            IncomingTalentDevelopmentPortfolioFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear:
                  ref
                      .read(
                        incomingTalentDevelopmentPortfolioDraftProvider
                            .notifier,
                      )
                      .clear,
              onSubmit: _submitPortfolio,
            ),
          ],
        ],
      ),
    );
  }

  void _selectRoadmap(String? roadmapId) {
    if (roadmapId == null) return;
    final roadmaps = ref.read(portfolioReadyDevelopmentRoadmapsProvider);
    final roadmap = roadmaps.firstWhere((item) => item.id == roadmapId);
    ref
        .read(incomingTalentDevelopmentPortfolioDraftProvider.notifier)
        .initializeFromRoadmap(roadmap);
  }

  Future<void> _selectStartDate() async {
    final draft = ref.read(incomingTalentDevelopmentPortfolioDraftProvider);
    final picked = await _pickDate(
      initialDate: draft.startDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
    );
    if (picked == null) return;
    ref
        .read(incomingTalentDevelopmentPortfolioDraftProvider.notifier)
        .setStartDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(incomingTalentDevelopmentPortfolioDraftProvider);
    final startDate = draft.startDate ?? draft.asOfDate;
    final picked = await _pickDate(
      initialDate:
          draft.nextReviewDate ?? startDate.add(const Duration(days: 14)),
      firstDate: startDate,
    );
    if (picked == null) return;
    ref
        .read(incomingTalentDevelopmentPortfolioDraftProvider.notifier)
        .setNextReviewDate(picked);
  }

  Future<void> _selectTargetDate() async {
    final draft = ref.read(incomingTalentDevelopmentPortfolioDraftProvider);
    final startDate = draft.startDate ?? draft.asOfDate;
    final picked = await _pickDate(
      initialDate:
          draft.targetCompletionDate ?? startDate.add(const Duration(days: 60)),
      firstDate: startDate,
    );
    if (picked == null) return;
    ref
        .read(incomingTalentDevelopmentPortfolioDraftProvider.notifier)
        .setTargetCompletionDate(picked);
  }

  Future<DateTime?> _pickDate({
    required DateTime initialDate,
    required DateTime firstDate,
  }) {
    final draft = ref.read(incomingTalentDevelopmentPortfolioDraftProvider);
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
  }

  void _submitPortfolio() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentDevelopmentPortfolioDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final portfolio = ref
          .read(incomingTalentDevelopmentPortfoliosProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentDevelopmentPortfolioDraftProvider.notifier)
          .clear();
      _showMessage('${portfolio.id} created for ${portfolio.candidateName}');
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
