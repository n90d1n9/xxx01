import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/candidate_development_check_in_models.dart';
import '../models/candidate_development_models.dart';
import '../states/candidate_development_check_in_provider.dart';
import 'candidate_development_check_in_form_fields.dart';

class CandidateDevelopmentCheckInForm extends ConsumerStatefulWidget {
  final List<CandidateDevelopmentObjective> objectives;

  const CandidateDevelopmentCheckInForm({super.key, required this.objectives});

  @override
  ConsumerState<CandidateDevelopmentCheckInForm> createState() =>
      _CandidateDevelopmentCheckInFormState();
}

class _CandidateDevelopmentCheckInFormState
    extends ConsumerState<CandidateDevelopmentCheckInForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _mentorController;
  late final TextEditingController _progressController;
  late final TextEditingController _blockerController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(candidateDevelopmentCheckInDraftProvider);
    _ownerController = TextEditingController(text: draft.ownerName);
    _mentorController = TextEditingController(text: draft.mentorName);
    _progressController = TextEditingController(text: draft.progressNote);
    _blockerController = TextEditingController(text: draft.blockerNote);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _mentorController.dispose();
    _progressController.dispose();
    _blockerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(candidateDevelopmentCheckInDraftProvider);

    _sync(_ownerController, draft.ownerName);
    _sync(_mentorController, draft.mentorName);
    _sync(_progressController, draft.progressNote);
    _sync(_blockerController, draft.blockerNote);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('check-in-${draft.objectiveId}'),
            initialValue:
                _objectiveExists(draft.objectiveId) ? draft.objectiveId : null,
            decoration: const InputDecoration(
              labelText: 'Development objective',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items:
                widget.objectives
                    .map(
                      (objective) => DropdownMenuItem(
                        value: objective.id,
                        child: Text(
                          '${objective.candidateName} - ${objective.status.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: widget.objectives.isEmpty ? null : _selectObjective,
            validator:
                (value) => CandidateDevelopmentCheckInDraft.validateRequired(
                  value,
                  'an objective',
                ),
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentCheckInTextInput(
            controller: _ownerController,
            label: 'Owner',
            icon: Icons.badge_outlined,
            onChanged:
                ref
                    .read(candidateDevelopmentCheckInDraftProvider.notifier)
                    .setOwnerName,
            validator:
                (value) => CandidateDevelopmentCheckInDraft.validateRequired(
                  value,
                  'an owner',
                ),
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentCheckInTextInput(
            controller: _mentorController,
            label: 'Mentor',
            icon: Icons.supervisor_account_outlined,
            onChanged:
                ref
                    .read(candidateDevelopmentCheckInDraftProvider.notifier)
                    .setMentorName,
            validator:
                (value) => CandidateDevelopmentCheckInDraft.validateRequired(
                  value,
                  'a mentor',
                ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: draft.confidenceText,
            decoration: const InputDecoration(
              labelText: 'Confidence',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.speed_outlined),
            ),
            items:
                const ['1', '2', '3', '4', '5']
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text('$value / 5'),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value == null) return;
              ref
                  .read(candidateDevelopmentCheckInDraftProvider.notifier)
                  .setConfidence(value);
            },
            validator: CandidateDevelopmentCheckInDraft.validateConfidence,
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentCheckInReviewField(
            draft: draft,
            onSelectReviewDate: _selectReviewDate,
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentCheckInTextInput(
            controller: _progressController,
            label: 'Progress note',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged:
                ref
                    .read(candidateDevelopmentCheckInDraftProvider.notifier)
                    .setProgressNote,
            validator: CandidateDevelopmentCheckInDraft.validateProgressNote,
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentCheckInTextInput(
            controller: _blockerController,
            label: 'Blocker note',
            icon: Icons.report_problem_outlined,
            minLines: 2,
            onChanged:
                ref
                    .read(candidateDevelopmentCheckInDraftProvider.notifier)
                    .setBlockerNote,
            validator: (_) => null,
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentCheckInDraftReadiness(draft: draft),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed:
                    ref
                        .read(candidateDevelopmentCheckInDraftProvider.notifier)
                        .clear,
                child: const Text('Clear'),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                key: const Key('candidate-development-check-in-submit'),
                onPressed: draft.isReadyToSubmit ? _submitCheckIn : null,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Submit check-in'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectObjective(String? objectiveId) {
    if (objectiveId == null) return;
    final objective = widget.objectives.firstWhere(
      (item) => item.id == objectiveId,
    );
    ref
        .read(candidateDevelopmentCheckInDraftProvider.notifier)
        .initializeFromObjective(objective);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(candidateDevelopmentCheckInDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.nextReviewDate ?? draft.asOfDate.add(const Duration(days: 14)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(candidateDevelopmentCheckInDraftProvider.notifier)
        .setNextReviewDate(picked);
  }

  void _submitCheckIn() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(candidateDevelopmentCheckInDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    final checkIn = ref
        .read(candidateDevelopmentCheckInsProvider.notifier)
        .submitDraft(draft);
    ref.read(candidateDevelopmentCheckInDraftProvider.notifier).clear();
    _showMessage('${checkIn.id} submitted for ${checkIn.candidateName}');
  }

  bool _objectiveExists(String objectiveId) {
    return widget.objectives.any((objective) => objective.id == objectiveId);
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
