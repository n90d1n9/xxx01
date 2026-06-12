import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_development_calibration_models.dart';
import '../states/candidate_development_calibration_provider.dart';
import 'candidate_development_calibration_form_fields.dart';

class CandidateDevelopmentCalibrationForm extends ConsumerStatefulWidget {
  final List<CandidateDevelopmentCalibrationProfile> profiles;

  const CandidateDevelopmentCalibrationForm({
    super.key,
    required this.profiles,
  });

  @override
  ConsumerState<CandidateDevelopmentCalibrationForm> createState() =>
      _CandidateDevelopmentCalibrationFormState();
}

class _CandidateDevelopmentCalibrationFormState
    extends ConsumerState<CandidateDevelopmentCalibrationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _noteController;
  late final TextEditingController _nextActionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(candidateDevelopmentCalibrationDraftProvider);
    _ownerController = TextEditingController(text: draft.ownerName);
    _noteController = TextEditingController(text: draft.note);
    _nextActionController = TextEditingController(text: draft.nextAction);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _noteController.dispose();
    _nextActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(candidateDevelopmentCalibrationDraftProvider);
    final draftNotifier = ref.read(
      candidateDevelopmentCalibrationDraftProvider.notifier,
    );

    _sync(_ownerController, draft.ownerName);
    _sync(_noteController, draft.note);
    _sync(_nextActionController, draft.nextAction);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('calibration-${draft.objectiveId}'),
            initialValue:
                _profileExists(draft.objectiveId) ? draft.objectiveId : null,
            decoration: const InputDecoration(
              labelText: 'Calibration profile',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.fact_check_outlined),
            ),
            items:
                widget.profiles
                    .map(
                      (profile) => DropdownMenuItem(
                        value: profile.objectiveId,
                        child: Text(
                          '${profile.candidateName} - ${profile.status.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: widget.profiles.isEmpty ? null : _selectProfile,
            validator:
                (value) =>
                    CandidateDevelopmentCalibrationDraft.validateRequired(
                      value,
                      'a calibration profile',
                    ),
          ),
          const SizedBox(height: 12),
          if (draft.objectiveId.isNotEmpty) ...[
            _CalibrationReadinessPreview(draft: draft),
            const SizedBox(height: 12),
          ],
          DropdownButtonFormField<CandidateDevelopmentCalibrationOutcome>(
            key: ValueKey('calibration-outcome-${draft.outcome?.name}'),
            initialValue: draft.outcome,
            decoration: const InputDecoration(
              labelText: 'Calibration outcome',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.rule_outlined),
            ),
            items:
                CandidateDevelopmentCalibrationOutcome.values
                    .map(
                      (outcome) => DropdownMenuItem(
                        value: outcome,
                        child: Text(outcome.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value == null) return;
              draftNotifier.setOutcome(value);
            },
            validator: CandidateDevelopmentCalibrationDraft.validateOutcome,
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentCalibrationTextInput(
            controller: _ownerController,
            label: 'Owner',
            icon: Icons.badge_outlined,
            onChanged: draftNotifier.setOwnerName,
            validator:
                (value) =>
                    CandidateDevelopmentCalibrationDraft.validateRequired(
                      value,
                      'an owner',
                    ),
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentCalibrationDateField(
            draft: draft,
            onSelectReviewDate: _selectReviewDate,
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentCalibrationTextInput(
            controller: _noteController,
            label: 'Calibration notes',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: draftNotifier.setNote,
            validator: CandidateDevelopmentCalibrationDraft.validateNote,
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentCalibrationTextInput(
            controller: _nextActionController,
            label: 'Next action',
            icon: Icons.next_plan_outlined,
            minLines: 2,
            onChanged: draftNotifier.setNextAction,
            validator: CandidateDevelopmentCalibrationDraft.validateNextAction,
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentCalibrationDraftReadiness(draft: draft),
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
                key: const Key('candidate-development-calibration-submit'),
                onPressed: draft.isReadyToSubmit ? _submitReview : null,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Submit review'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectProfile(String? objectiveId) {
    if (objectiveId == null) return;
    final profile = widget.profiles.firstWhere(
      (item) => item.objectiveId == objectiveId,
    );
    ref
        .read(candidateDevelopmentCalibrationDraftProvider.notifier)
        .initializeFromProfile(profile);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(candidateDevelopmentCalibrationDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.reviewDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(candidateDevelopmentCalibrationDraftProvider.notifier)
        .setReviewDate(picked);
  }

  void _submitReview() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(candidateDevelopmentCalibrationDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    final review = ref
        .read(candidateDevelopmentCalibrationReviewsProvider.notifier)
        .submitDraft(draft);
    ref.read(candidateDevelopmentCalibrationDraftProvider.notifier).clear();
    _showMessage('${review.id} submitted for ${review.candidateName}');
  }

  bool _profileExists(String objectiveId) {
    return widget.profiles.any((profile) => profile.objectiveId == objectiveId);
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

class _CalibrationReadinessPreview extends StatelessWidget {
  final CandidateDevelopmentCalibrationDraft draft;

  const _CalibrationReadinessPreview({required this.draft});

  @override
  Widget build(BuildContext context) {
    final color = switch (draft.status) {
      CandidateDevelopmentCalibrationStatus.ready => const Color(0xFF15803D),
      CandidateDevelopmentCalibrationStatus.monitor => const Color(0xFF2563EB),
      CandidateDevelopmentCalibrationStatus.blocked => const Color(0xFFB45309),
      null => HrisColors.primary,
    };

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  draft.candidateName,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (draft.status != null)
                HrisStatusPill(label: draft.status!.label, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${draft.role} - ${draft.department}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: draft.readinessScore / 100,
            color: color,
            label: '${draft.readinessScore}% readiness score',
          ),
        ],
      ),
    );
  }
}
