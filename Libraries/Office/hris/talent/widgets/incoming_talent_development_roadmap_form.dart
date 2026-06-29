import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_activation_outcome_models.dart';
import '../models/incoming_talent_development_roadmap_models.dart';
import '../states/incoming_talent_development_roadmap_provider.dart';
import 'incoming_talent_development_roadmap_form_fields.dart';

class IncomingTalentDevelopmentRoadmapForm extends ConsumerStatefulWidget {
  const IncomingTalentDevelopmentRoadmapForm({super.key});

  @override
  ConsumerState<IncomingTalentDevelopmentRoadmapForm> createState() =>
      _IncomingTalentDevelopmentRoadmapFormState();
}

class _IncomingTalentDevelopmentRoadmapFormState
    extends ConsumerState<IncomingTalentDevelopmentRoadmapForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _mentorController;
  late final TextEditingController _focusController;
  late final TextEditingController _objectiveController;
  late final TextEditingController _milestoneController;
  late final TextEditingController _metricController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentDevelopmentRoadmapDraftProvider);
    _ownerController = TextEditingController(text: draft.ownerName);
    _mentorController = TextEditingController(text: draft.mentorName);
    _focusController = TextEditingController(text: draft.focusArea);
    _objectiveController = TextEditingController(text: draft.learningObjective);
    _milestoneController = TextEditingController(text: draft.firstMilestone);
    _metricController = TextEditingController(text: draft.successMetric);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _mentorController.dispose();
    _focusController.dispose();
    _objectiveController.dispose();
    _milestoneController.dispose();
    _metricController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentDevelopmentRoadmapDraftProvider);
    final reviews = ref.watch(roadmapReadyActivationOutcomeReviewsProvider);

    _sync(_ownerController, draft.ownerName);
    _sync(_mentorController, draft.mentorName);
    _sync(_focusController, draft.focusArea);
    _sync(_objectiveController, draft.learningObjective);
    _sync(_milestoneController, draft.firstMilestone);
    _sync(_metricController, draft.successMetric);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('roadmap-${draft.outcomeReviewId}'),
            initialValue:
                _reviewExists(reviews, draft.outcomeReviewId)
                    ? draft.outcomeReviewId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Outcome review',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.verified_outlined),
            ),
            items:
                reviews
                    .map(
                      (review) => DropdownMenuItem(
                        value: review.id,
                        child: Text(
                          '${review.candidateName} - ${review.decision.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: reviews.isEmpty ? null : _selectReview,
            validator:
                (value) =>
                    IncomingTalentDevelopmentRoadmapDraft.validateRequired(
                      value,
                      'an outcome review',
                    ),
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            const HrisListSurface(
              child: Text('No outcome reviews are ready for roadmapping.'),
            )
          else ...[
            IncomingTalentDevelopmentRoadmapTextInput(
              controller: _ownerController,
              label: 'Roadmap owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentRoadmapDraftProvider.notifier,
                      )
                      .setOwnerName,
              validator:
                  (value) =>
                      IncomingTalentDevelopmentRoadmapDraft.validateRequired(
                        value,
                        'an owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentRoadmapTextInput(
              controller: _mentorController,
              label: 'Mentor',
              icon: Icons.supervisor_account_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentRoadmapDraftProvider.notifier,
                      )
                      .setMentorName,
              validator:
                  (value) =>
                      IncomingTalentDevelopmentRoadmapDraft.validateRequired(
                        value,
                        'a mentor',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentRoadmapStatusFields(
              draft: draft,
              onCadenceChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentRoadmapDraftProvider.notifier,
                      )
                      .setCadence,
              onStatusChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentRoadmapDraftProvider.notifier,
                      )
                      .setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentRoadmapDateFields(
              draft: draft,
              onSelectStartDate: _selectStartDate,
              onSelectTargetDate: _selectTargetDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentRoadmapTextInput(
              controller: _focusController,
              label: 'Focus area',
              icon: Icons.center_focus_strong_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentRoadmapDraftProvider.notifier,
                      )
                      .setFocusArea,
              validator:
                  IncomingTalentDevelopmentRoadmapDraft.validateFocusArea,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentRoadmapTextInput(
              controller: _objectiveController,
              label: 'Learning objective',
              icon: Icons.psychology_alt_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentRoadmapDraftProvider.notifier,
                      )
                      .setLearningObjective,
              validator:
                  IncomingTalentDevelopmentRoadmapDraft
                      .validateLearningObjective,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentRoadmapTextInput(
              controller: _milestoneController,
              label: 'First milestone',
              icon: Icons.flag_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentRoadmapDraftProvider.notifier,
                      )
                      .setFirstMilestone,
              validator:
                  IncomingTalentDevelopmentRoadmapDraft.validateFirstMilestone,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentRoadmapTextInput(
              controller: _metricController,
              label: 'Success metric',
              icon: Icons.insights_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentRoadmapDraftProvider.notifier,
                      )
                      .setSuccessMetric,
              validator:
                  IncomingTalentDevelopmentRoadmapDraft.validateSuccessMetric,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentRoadmapDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentDevelopmentRoadmapDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key('incoming-talent-roadmap-submit'),
                  onPressed: draft.isReadyToSubmit ? _submitRoadmap : null,
                  icon: const Icon(Icons.add_road_outlined),
                  label: const Text('Create roadmap'),
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
    final reviews = ref.read(roadmapReadyActivationOutcomeReviewsProvider);
    final review = reviews.firstWhere((item) => item.id == reviewId);
    ref
        .read(incomingTalentDevelopmentRoadmapDraftProvider.notifier)
        .initializeFromOutcome(review);
  }

  Future<void> _selectStartDate() async {
    final draft = ref.read(incomingTalentDevelopmentRoadmapDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.startDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentDevelopmentRoadmapDraftProvider.notifier)
        .setStartDate(picked);
  }

  Future<void> _selectTargetDate() async {
    final draft = ref.read(incomingTalentDevelopmentRoadmapDraftProvider);
    final startDate = draft.startDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.targetCompletionDate ?? startDate.add(const Duration(days: 60)),
      firstDate: startDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentDevelopmentRoadmapDraftProvider.notifier)
        .setTargetCompletionDate(picked);
  }

  void _submitRoadmap() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentDevelopmentRoadmapDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final roadmap = ref
          .read(incomingTalentDevelopmentRoadmapsProvider.notifier)
          .submitDraft(draft);
      ref.read(incomingTalentDevelopmentRoadmapDraftProvider.notifier).clear();
      _showMessage('${roadmap.id} created for ${roadmap.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _reviewExists(
    List<IncomingTalentActivationOutcomeReview> reviews,
    String reviewId,
  ) {
    return reviews.any((review) => review.id == reviewId);
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
