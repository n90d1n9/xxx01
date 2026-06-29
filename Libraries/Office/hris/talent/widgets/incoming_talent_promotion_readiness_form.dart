import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_readiness_models.dart';
import '../states/incoming_talent_promotion_readiness_provider.dart';
import 'incoming_talent_development_program_form_widgets.dart';
import 'incoming_talent_promotion_readiness_fields.dart';

/// Form for assessing promotion readiness against career frameworks.
class IncomingTalentPromotionReadinessForm extends ConsumerStatefulWidget {
  const IncomingTalentPromotionReadinessForm({super.key});

  @override
  ConsumerState<IncomingTalentPromotionReadinessForm> createState() =>
      _IncomingTalentPromotionReadinessFormState();
}

class _IncomingTalentPromotionReadinessFormState
    extends ConsumerState<IncomingTalentPromotionReadinessForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _assessorController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _gapController;
  late final TextEditingController _recommendationController;
  String? _selectedSourceId;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentPromotionReadinessDraftProvider);
    _selectedSourceId =
        draft.careerPathId.isEmpty || draft.frameworkLevelId.isEmpty
            ? null
            : '${draft.careerPathId}|${draft.frameworkLevelId}';
    _assessorController = TextEditingController(text: draft.assessorName);
    _evidenceController = TextEditingController(text: draft.evidenceSummary);
    _gapController = TextEditingController(text: draft.gapSummary);
    _recommendationController = TextEditingController(
      text: draft.panelRecommendation,
    );
  }

  @override
  void dispose() {
    _assessorController.dispose();
    _evidenceController.dispose();
    _gapController.dispose();
    _recommendationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sources = ref.watch(promotionReadinessSourceProvider);
    final draft = ref.watch(incomingTalentPromotionReadinessDraftProvider);

    syncIncomingTalentDevelopmentProgramController(
      _assessorController,
      draft.assessorName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _evidenceController,
      draft.evidenceSummary,
    );
    syncIncomingTalentDevelopmentProgramController(
      _gapController,
      draft.gapSummary,
    );
    syncIncomingTalentDevelopmentProgramController(
      _recommendationController,
      draft.panelRecommendation,
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentPromotionReadinessSourcePicker(
            sources: sources,
            selectedSourceId: _selectedSourceId,
            onSourceChanged: _selectSource,
          ),
          const SizedBox(height: 12),
          if (sources.isEmpty)
            const HrisListSurface(
              child: Text(
                'Create framework coverage for career paths before promotion assessment.',
              ),
            )
          else ...[
            IncomingTalentDevelopmentProgramTextInput(
              controller: _assessorController,
              label: 'Assessor',
              icon: Icons.supervisor_account_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentPromotionReadinessDraftProvider.notifier,
                      )
                      .setAssessorName,
              validator:
                  (value) => validateIncomingTalentPromotionReadinessRequired(
                    value,
                    'an assessor',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentPromotionReadinessClassificationFields(
              draft: draft,
              onRatingChanged:
                  ref
                      .read(
                        incomingTalentPromotionReadinessDraftProvider.notifier,
                      )
                      .setRating,
              onStatusChanged:
                  ref
                      .read(
                        incomingTalentPromotionReadinessDraftProvider.notifier,
                      )
                      .setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentPromotionReadinessDateFields(
              draft: draft,
              onSelectReviewDate: _selectReviewDate,
              onSelectNextReviewDate: _selectNextReviewDate,
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
                        incomingTalentPromotionReadinessDraftProvider.notifier,
                      )
                      .setEvidenceSummary,
              validator:
                  (value) => validateIncomingTalentPromotionReadinessLongText(
                    value,
                    'evidence summary',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _gapController,
              label: 'Gap summary',
              icon: Icons.rule_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentPromotionReadinessDraftProvider.notifier,
                      )
                      .setGapSummary,
              validator:
                  (value) => validateIncomingTalentPromotionReadinessLongText(
                    value,
                    'gap summary',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _recommendationController,
              label: 'Panel recommendation',
              icon: Icons.recommend_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentPromotionReadinessDraftProvider.notifier,
                      )
                      .setPanelRecommendation,
              validator:
                  (value) => validateIncomingTalentPromotionReadinessLongText(
                    value,
                    'panel recommendation',
                  ),
            ),
            const SizedBox(height: 10),
            IncomingTalentPromotionReadinessFormActions(
              completionRatio: draft.completionRatio,
              canSubmit: draft.isReadyToSubmit,
              onClear: _clear,
              onSubmit: _submitReadiness,
            ),
          ],
        ],
      ),
    );
  }

  void _selectSource(String? value) {
    setState(() => _selectedSourceId = value);
    if (value == null) return;

    final sources = ref.read(promotionReadinessSourceProvider);
    final source = sources.firstWhere((item) => item.id == value);
    ref
        .read(incomingTalentPromotionReadinessDraftProvider.notifier)
        .initializeFromSource(source);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(incomingTalentPromotionReadinessDraftProvider);
    final picked = await _pickDate(
      initialDate: draft.reviewDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
    );
    if (picked == null) return;
    ref
        .read(incomingTalentPromotionReadinessDraftProvider.notifier)
        .setReviewDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(incomingTalentPromotionReadinessDraftProvider);
    final reviewDate = draft.reviewDate ?? draft.asOfDate;
    final picked = await _pickDate(
      initialDate:
          draft.nextReviewDate ?? reviewDate.add(const Duration(days: 45)),
      firstDate: reviewDate.add(const Duration(days: 1)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentPromotionReadinessDraftProvider.notifier)
        .setNextReviewDate(picked);
  }

  Future<DateTime?> _pickDate({
    required DateTime initialDate,
    required DateTime firstDate,
  }) {
    final draft = ref.read(incomingTalentPromotionReadinessDraftProvider);
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
  }

  void _submitReadiness() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentPromotionReadinessDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final packet = ref
          .read(incomingTalentPromotionReadinessProvider.notifier)
          .submitDraft(draft);
      _clear();
      _showMessage('${packet.id} saved for ${packet.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _clear() {
    ref.read(incomingTalentPromotionReadinessDraftProvider.notifier).clear();
    setState(() => _selectedSourceId = null);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

@Preview(name: 'Talent promotion readiness form')
Widget incomingTalentPromotionReadinessFormPreview() {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentPromotionReadinessForm(),
        ),
      ),
    ),
  );
}
