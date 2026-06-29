import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/candidate_development_calibration_models.dart';
import '../models/candidate_talent_handoff_models.dart';
import '../states/candidate_talent_handoff_provider.dart';
import 'candidate_talent_handoff_form_fields.dart';
import 'candidate_talent_handoff_readiness_preview.dart';

class CandidateTalentHandoffForm extends ConsumerStatefulWidget {
  final List<CandidateDevelopmentCalibrationReview> reviews;

  const CandidateTalentHandoffForm({super.key, required this.reviews});

  @override
  ConsumerState<CandidateTalentHandoffForm> createState() =>
      _CandidateTalentHandoffFormState();
}

class _CandidateTalentHandoffFormState
    extends ConsumerState<CandidateTalentHandoffForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _managerController;
  late final TextEditingController _focusController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(candidateTalentHandoffDraftProvider);
    _ownerController = TextEditingController(text: draft.ownerName);
    _managerController = TextEditingController(
      text: draft.receivingManagerName,
    );
    _focusController = TextEditingController(text: draft.talentFocus);
    _noteController = TextEditingController(text: draft.handoffNote);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _managerController.dispose();
    _focusController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(candidateTalentHandoffDraftProvider);
    final draftNotifier = ref.read(
      candidateTalentHandoffDraftProvider.notifier,
    );

    _sync(_ownerController, draft.ownerName);
    _sync(_managerController, draft.receivingManagerName);
    _sync(_focusController, draft.talentFocus);
    _sync(_noteController, draft.handoffNote);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('handoff-${draft.calibrationReviewId}'),
            initialValue:
                _reviewExists(draft.calibrationReviewId)
                    ? draft.calibrationReviewId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Calibration review',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.fact_check_outlined),
            ),
            items:
                widget.reviews
                    .map(
                      (review) => DropdownMenuItem(
                        value: review.id,
                        child: Text(
                          '${review.candidateName} - ${review.outcome.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: widget.reviews.isEmpty ? null : _selectReview,
            validator:
                (value) => CandidateTalentHandoffDraft.validateRequired(
                  value,
                  'a calibration review',
                ),
          ),
          const SizedBox(height: 12),
          if (draft.calibrationReviewId.isNotEmpty) ...[
            CandidateTalentHandoffReadinessPreview(draft: draft),
            const SizedBox(height: 12),
          ],
          DropdownButtonFormField<CandidateTalentHandoffType>(
            initialValue: draft.type,
            decoration: const InputDecoration(
              labelText: 'Handoff type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.hub_outlined),
            ),
            items:
                CandidateTalentHandoffType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value == null) return;
              draftNotifier.setType(value);
            },
            validator: CandidateTalentHandoffDraft.validateType,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CandidateTalentHandoffStatus>(
            initialValue: draft.status,
            decoration: const InputDecoration(
              labelText: 'Handoff status',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.verified_user_outlined),
            ),
            items:
                CandidateTalentHandoffStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value == null) return;
              draftNotifier.setStatus(value);
            },
            validator: CandidateTalentHandoffDraft.validateStatus,
          ),
          const SizedBox(height: 12),
          CandidateTalentHandoffTextInput(
            controller: _ownerController,
            label: 'Handoff owner',
            icon: Icons.badge_outlined,
            onChanged: draftNotifier.setOwnerName,
            validator:
                (value) => CandidateTalentHandoffDraft.validateRequired(
                  value,
                  'a handoff owner',
                ),
          ),
          const SizedBox(height: 12),
          CandidateTalentHandoffTextInput(
            controller: _managerController,
            label: 'Receiving manager',
            icon: Icons.supervisor_account_outlined,
            onChanged: draftNotifier.setReceivingManagerName,
            validator:
                (value) => CandidateTalentHandoffDraft.validateRequired(
                  value,
                  'a receiving manager',
                ),
          ),
          const SizedBox(height: 12),
          CandidateTalentHandoffDateFields(
            draft: draft,
            onSelectTargetStart: _selectTargetStartDate,
            onSelectFirstCheckpoint: _selectFirstCheckpointDate,
          ),
          const SizedBox(height: 12),
          CandidateTalentHandoffTextInput(
            controller: _focusController,
            label: 'Talent focus',
            icon: Icons.track_changes_outlined,
            minLines: 2,
            onChanged: draftNotifier.setTalentFocus,
            validator: CandidateTalentHandoffDraft.validateTalentFocus,
          ),
          const SizedBox(height: 12),
          CandidateTalentHandoffTextInput(
            controller: _noteController,
            label: 'Handoff notes',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: draftNotifier.setHandoffNote,
            validator: CandidateTalentHandoffDraft.validateHandoffNote,
          ),
          const SizedBox(height: 12),
          CandidateTalentHandoffDraftReadiness(draft: draft),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: draftNotifier.clear,
                child: const Text('Clear'),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                key: const Key('candidate-talent-handoff-submit'),
                onPressed: draft.isReadyToSubmit ? _submitHandoff : null,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Submit handoff'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectReview(String? reviewId) {
    if (reviewId == null) return;
    final review = widget.reviews.firstWhere((item) => item.id == reviewId);
    ref
        .read(candidateTalentHandoffDraftProvider.notifier)
        .initializeFromCalibrationReview(review);
  }

  Future<void> _selectTargetStartDate() async {
    final draft = ref.read(candidateTalentHandoffDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.targetStartDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(candidateTalentHandoffDraftProvider.notifier)
        .setTargetStartDate(picked);
  }

  Future<void> _selectFirstCheckpointDate() async {
    final draft = ref.read(candidateTalentHandoffDraftProvider);
    final firstDate = draft.targetStartDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.firstCheckpointDate ?? firstDate.add(const Duration(days: 14)),
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(candidateTalentHandoffDraftProvider.notifier)
        .setFirstCheckpointDate(picked);
  }

  void _submitHandoff() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(candidateTalentHandoffDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    final handoff = ref
        .read(candidateTalentHandoffsProvider.notifier)
        .submitDraft(draft);
    ref.read(candidateTalentHandoffDraftProvider.notifier).clear();
    _showMessage('${handoff.id} submitted for ${handoff.candidateName}');
  }

  bool _reviewExists(String reviewId) {
    return widget.reviews.any((review) => review.id == reviewId);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}
