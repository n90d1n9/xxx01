import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_stabilization_review_models.dart';
import '../states/incoming_talent_promotion_stabilization_review_provider.dart';
import 'incoming_talent_development_program_form_widgets.dart';
import 'incoming_talent_promotion_stabilization_review_fields.dart';

/// Form for validating post-promotion adoption, feedback, and support plans.
class IncomingTalentPromotionStabilizationReviewForm
    extends ConsumerStatefulWidget {
  const IncomingTalentPromotionStabilizationReviewForm({super.key});

  @override
  ConsumerState<IncomingTalentPromotionStabilizationReviewForm> createState() =>
      _IncomingTalentPromotionStabilizationReviewFormState();
}

/// State backing the promotion stabilization review form controllers.
class _IncomingTalentPromotionStabilizationReviewFormState
    extends ConsumerState<IncomingTalentPromotionStabilizationReviewForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _reviewerController;
  late final TextEditingController _confidenceController;
  late final TextEditingController _managerFeedbackController;
  late final TextEditingController _employeeFeedbackController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _supportPlanController;
  String? _selectedImplementationId;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentPromotionStabilizationReviewDraftProvider,
    );
    _selectedImplementationId =
        draft.implementationId.isEmpty ? null : draft.implementationId;
    _ownerController = TextEditingController(text: draft.ownerName);
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _confidenceController = TextEditingController(
      text: '${draft.confidenceScore}',
    );
    _managerFeedbackController = TextEditingController(
      text: draft.managerFeedback,
    );
    _employeeFeedbackController = TextEditingController(
      text: draft.employeeFeedback,
    );
    _evidenceController = TextEditingController(text: draft.evidenceSummary);
    _supportPlanController = TextEditingController(text: draft.supportPlan);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _reviewerController.dispose();
    _confidenceController.dispose();
    _managerFeedbackController.dispose();
    _employeeFeedbackController.dispose();
    _evidenceController.dispose();
    _supportPlanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final implementations = ref.watch(
      promotionStabilizationReviewReadyImplementationsProvider,
    );
    final draft = ref.watch(
      incomingTalentPromotionStabilizationReviewDraftProvider,
    );

    syncIncomingTalentDevelopmentProgramController(
      _ownerController,
      draft.ownerName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _reviewerController,
      draft.reviewerName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _confidenceController,
      '${draft.confidenceScore}',
    );
    syncIncomingTalentDevelopmentProgramController(
      _managerFeedbackController,
      draft.managerFeedback,
    );
    syncIncomingTalentDevelopmentProgramController(
      _employeeFeedbackController,
      draft.employeeFeedback,
    );
    syncIncomingTalentDevelopmentProgramController(
      _evidenceController,
      draft.evidenceSummary,
    );
    syncIncomingTalentDevelopmentProgramController(
      _supportPlanController,
      draft.supportPlan,
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentPromotionStabilizationImplementationPicker(
            implementations: implementations,
            selectedImplementationId: _selectedImplementationId,
            onImplementationChanged: _selectImplementation,
          ),
          const SizedBox(height: 12),
          if (implementations.isEmpty)
            const HrisListSurface(
              child: Text(
                'Complete promotion implementations before stabilization review.',
              ),
            )
          else ...[
            IncomingTalentDevelopmentProgramResponsiveRow(
              children: [
                IncomingTalentDevelopmentProgramTextInput(
                  controller: _ownerController,
                  label: 'Owner',
                  icon: Icons.supervisor_account_outlined,
                  onChanged:
                      ref
                          .read(
                            incomingTalentPromotionStabilizationReviewDraftProvider
                                .notifier,
                          )
                          .setOwnerName,
                  validator:
                      (value) =>
                          validateIncomingTalentPromotionStabilizationRequired(
                            value,
                            'an owner',
                          ),
                ),
                IncomingTalentDevelopmentProgramTextInput(
                  controller: _reviewerController,
                  label: 'Reviewer',
                  icon: Icons.verified_user_outlined,
                  onChanged:
                      ref
                          .read(
                            incomingTalentPromotionStabilizationReviewDraftProvider
                                .notifier,
                          )
                          .setReviewerName,
                  validator:
                      (value) =>
                          validateIncomingTalentPromotionStabilizationRequired(
                            value,
                            'a reviewer',
                          ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            IncomingTalentPromotionStabilizationClassificationFields(
              draft: draft,
              onOutcomeChanged:
                  ref
                      .read(
                        incomingTalentPromotionStabilizationReviewDraftProvider
                            .notifier,
                      )
                      .setOutcome,
              onStatusChanged:
                  ref
                      .read(
                        incomingTalentPromotionStabilizationReviewDraftProvider
                            .notifier,
                      )
                      .setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentPromotionStabilizationSignalFields(
              draft: draft,
              confidenceController: _confidenceController,
              onSelectReviewDate: _selectReviewDate,
              onSelectFollowUpDate: _selectFollowUpDate,
              onConfidenceChanged:
                  ref
                      .read(
                        incomingTalentPromotionStabilizationReviewDraftProvider
                            .notifier,
                      )
                      .setConfidenceScore,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _managerFeedbackController,
              label: 'Manager feedback',
              icon: Icons.record_voice_over_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentPromotionStabilizationReviewDraftProvider
                            .notifier,
                      )
                      .setManagerFeedback,
              validator:
                  (value) =>
                      validateIncomingTalentPromotionStabilizationLongText(
                        value,
                        'manager feedback',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _employeeFeedbackController,
              label: 'Employee feedback',
              icon: Icons.person_outline,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentPromotionStabilizationReviewDraftProvider
                            .notifier,
                      )
                      .setEmployeeFeedback,
              validator:
                  (value) =>
                      validateIncomingTalentPromotionStabilizationLongText(
                        value,
                        'employee feedback',
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
                        incomingTalentPromotionStabilizationReviewDraftProvider
                            .notifier,
                      )
                      .setEvidenceSummary,
              validator:
                  (value) =>
                      validateIncomingTalentPromotionStabilizationLongText(
                        value,
                        'evidence summary',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _supportPlanController,
              label: 'Support plan',
              icon: Icons.handshake_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentPromotionStabilizationReviewDraftProvider
                            .notifier,
                      )
                      .setSupportPlan,
              validator:
                  (value) =>
                      validateIncomingTalentPromotionStabilizationLongText(
                        value,
                        'support plan',
                      ),
            ),
            const SizedBox(height: 10),
            IncomingTalentPromotionStabilizationFormActions(
              completionRatio: draft.completionRatio,
              canSubmit: draft.isReadyToSubmit,
              onClear: _clear,
              onSubmit: _submitReview,
            ),
          ],
        ],
      ),
    );
  }

  void _selectImplementation(String? value) {
    setState(() => _selectedImplementationId = value);
    if (value == null) return;

    final implementations = ref.read(
      promotionStabilizationReviewReadyImplementationsProvider,
    );
    final implementation = implementations.firstWhere(
      (item) => item.id == value,
    );
    ref
        .read(incomingTalentPromotionStabilizationReviewDraftProvider.notifier)
        .initializeFromImplementation(implementation);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(
      incomingTalentPromotionStabilizationReviewDraftProvider,
    );
    final picked = await _pickDate(
      initialDate: draft.reviewDate ?? draft.asOfDate,
      firstDate: draft.asOfDate.subtract(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentPromotionStabilizationReviewDraftProvider.notifier)
        .setReviewDate(picked);
  }

  Future<void> _selectFollowUpDate() async {
    final draft = ref.read(
      incomingTalentPromotionStabilizationReviewDraftProvider,
    );
    final picked = await _pickDate(
      initialDate:
          draft.followUpDate ?? draft.asOfDate.add(const Duration(days: 14)),
      firstDate: draft.reviewDate ?? draft.asOfDate,
    );
    if (picked == null) return;
    ref
        .read(incomingTalentPromotionStabilizationReviewDraftProvider.notifier)
        .setFollowUpDate(picked);
  }

  Future<DateTime?> _pickDate({
    required DateTime initialDate,
    required DateTime firstDate,
  }) {
    final draft = ref.read(
      incomingTalentPromotionStabilizationReviewDraftProvider,
    );
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
  }

  void _submitReview() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentPromotionStabilizationReviewDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final review = ref
          .read(incomingTalentPromotionStabilizationReviewsProvider.notifier)
          .submitDraft(draft);
      _clear();
      _showMessage('${review.id} saved for ${review.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _clear() {
    ref
        .read(incomingTalentPromotionStabilizationReviewDraftProvider.notifier)
        .clear();
    setState(() => _selectedImplementationId = null);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

@Preview(name: 'Talent promotion stabilization form')
Widget incomingTalentPromotionStabilizationReviewFormPreview() {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentPromotionStabilizationReviewForm(),
        ),
      ),
    ),
  );
}
