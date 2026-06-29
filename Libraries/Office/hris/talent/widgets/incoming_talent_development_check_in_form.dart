import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_check_in_models.dart';
import '../models/incoming_talent_development_roadmap_models.dart';
import '../states/incoming_talent_development_check_in_provider.dart';
import 'incoming_talent_development_check_in_form_fields.dart';

class IncomingTalentDevelopmentCheckInForm extends ConsumerStatefulWidget {
  const IncomingTalentDevelopmentCheckInForm({super.key});

  @override
  ConsumerState<IncomingTalentDevelopmentCheckInForm> createState() =>
      _IncomingTalentDevelopmentCheckInFormState();
}

class _IncomingTalentDevelopmentCheckInFormState
    extends ConsumerState<IncomingTalentDevelopmentCheckInForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _blockerController;
  late final TextEditingController _actionController;
  late final TextEditingController _commitmentController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentDevelopmentCheckInDraftProvider);
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _blockerController = TextEditingController(text: draft.blockerNote);
    _actionController = TextEditingController(text: draft.nextAction);
    _commitmentController = TextEditingController(
      text: draft.managerCommitment,
    );
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _blockerController.dispose();
    _actionController.dispose();
    _commitmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentDevelopmentCheckInDraftProvider);
    final roadmaps = ref.watch(checkInReadyDevelopmentRoadmapsProvider);

    _sync(_reviewerController, draft.reviewerName);
    _sync(_blockerController, draft.blockerNote);
    _sync(_actionController, draft.nextAction);
    _sync(_commitmentController, draft.managerCommitment);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('check-in-${draft.roadmapId}'),
            initialValue:
                _roadmapExists(roadmaps, draft.roadmapId)
                    ? draft.roadmapId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Development roadmap',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.add_road_outlined),
            ),
            items:
                roadmaps
                    .map(
                      (roadmap) => DropdownMenuItem(
                        value: roadmap.id,
                        child: Text(
                          '${roadmap.candidateName} - ${roadmap.focusArea}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: roadmaps.isEmpty ? null : _selectRoadmap,
            validator:
                (value) =>
                    IncomingTalentDevelopmentCheckInDraft.validateRequired(
                      value,
                      'a development roadmap',
                    ),
          ),
          const SizedBox(height: 12),
          if (roadmaps.isEmpty)
            const HrisListSurface(
              child: Text('No active development roadmaps need check-ins.'),
            )
          else ...[
            IncomingTalentDevelopmentCheckInTextInput(
              controller: _reviewerController,
              label: 'Reviewer',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentCheckInDraftProvider.notifier,
                      )
                      .setReviewerName,
              validator:
                  (value) =>
                      IncomingTalentDevelopmentCheckInDraft.validateRequired(
                        value,
                        'a reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentCheckInDateFields(
              draft: draft,
              onSelectCheckInDate: _selectCheckInDate,
              onSelectNextReviewDate: _selectNextReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentCheckInTrendFields(
              draft: draft,
              onTrendChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentCheckInDraftProvider.notifier,
                      )
                      .setTrend,
              onConfidenceChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentCheckInDraftProvider.notifier,
                      )
                      .setConfidenceScore,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentCheckInTextInput(
              controller: _blockerController,
              label: 'Blocker note',
              icon: Icons.report_problem_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentCheckInDraftProvider.notifier,
                      )
                      .setBlockerNote,
              validator:
                  (value) =>
                      IncomingTalentDevelopmentCheckInDraft.validateBlockerNote(
                        value,
                        draft.trend,
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentCheckInTextInput(
              controller: _actionController,
              label: 'Next action',
              icon: Icons.task_alt_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentCheckInDraftProvider.notifier,
                      )
                      .setNextAction,
              validator:
                  IncomingTalentDevelopmentCheckInDraft.validateNextAction,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentCheckInTextInput(
              controller: _commitmentController,
              label: 'Manager commitment',
              icon: Icons.handshake_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentCheckInDraftProvider.notifier,
                      )
                      .setManagerCommitment,
              validator:
                  IncomingTalentDevelopmentCheckInDraft
                      .validateManagerCommitment,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentCheckInDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentDevelopmentCheckInDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key('incoming-talent-check-in-submit'),
                  onPressed: draft.isReadyToSubmit ? _submitCheckIn : null,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Submit check-in'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectRoadmap(String? roadmapId) {
    if (roadmapId == null) return;
    final roadmaps = ref.read(checkInReadyDevelopmentRoadmapsProvider);
    final roadmap = roadmaps.firstWhere((item) => item.id == roadmapId);
    ref
        .read(incomingTalentDevelopmentCheckInDraftProvider.notifier)
        .initializeFromRoadmap(roadmap);
  }

  Future<void> _selectCheckInDate() async {
    final draft = ref.read(incomingTalentDevelopmentCheckInDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.checkInDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentDevelopmentCheckInDraftProvider.notifier)
        .setCheckInDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(incomingTalentDevelopmentCheckInDraftProvider);
    final checkInDate = draft.checkInDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.nextReviewDate ?? checkInDate.add(const Duration(days: 14)),
      firstDate: checkInDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentDevelopmentCheckInDraftProvider.notifier)
        .setNextReviewDate(picked);
  }

  void _submitCheckIn() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentDevelopmentCheckInDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final checkIn = ref
          .read(incomingTalentDevelopmentCheckInsProvider.notifier)
          .submitDraft(draft);
      ref.read(incomingTalentDevelopmentCheckInDraftProvider.notifier).clear();
      _showMessage('${checkIn.id} submitted for ${checkIn.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _roadmapExists(
    List<IncomingTalentDevelopmentRoadmap> roadmaps,
    String roadmapId,
  ) {
    return roadmaps.any((roadmap) => roadmap.id == roadmapId);
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
