import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/candidate_decision_models.dart';
import '../models/candidate_development_models.dart';
import '../states/candidate_development_provider.dart';
import 'candidate_development_form_fields.dart';

class CandidateDevelopmentForm extends ConsumerStatefulWidget {
  final List<CandidateDecisionPacket> packets;

  const CandidateDevelopmentForm({super.key, required this.packets});

  @override
  ConsumerState<CandidateDevelopmentForm> createState() =>
      _CandidateDevelopmentFormState();
}

class _CandidateDevelopmentFormState
    extends ConsumerState<CandidateDevelopmentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _skillController;
  late final TextEditingController _ownerController;
  late final TextEditingController _mentorController;
  late final TextEditingController _measureController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(candidateDevelopmentObjectiveDraftProvider);
    _titleController = TextEditingController(text: draft.objectiveTitle);
    _skillController = TextEditingController(text: draft.skillFocus);
    _ownerController = TextEditingController(text: draft.ownerName);
    _mentorController = TextEditingController(text: draft.mentorName);
    _measureController = TextEditingController(text: draft.successMeasure);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _skillController.dispose();
    _ownerController.dispose();
    _mentorController.dispose();
    _measureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(candidateDevelopmentObjectiveDraftProvider);

    _sync(_titleController, draft.objectiveTitle);
    _sync(_skillController, draft.skillFocus);
    _sync(_ownerController, draft.ownerName);
    _sync(_mentorController, draft.mentorName);
    _sync(_measureController, draft.successMeasure);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('development-${draft.candidateId}'),
            initialValue:
                _packetExists(draft.candidateId) ? draft.candidateId : null,
            decoration: const InputDecoration(
              labelText: 'Decision packet',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.assignment_ind_outlined),
            ),
            items:
                widget.packets
                    .map(
                      (packet) => DropdownMenuItem(
                        value: packet.candidateId,
                        child: Text(
                          '${packet.candidateName} - ${packet.recommendation.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: widget.packets.isEmpty ? null : _selectPacket,
            validator:
                (value) => CandidateDevelopmentObjectiveDraft.validateRequired(
                  value,
                  'a candidate',
                ),
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentTextInput(
            controller: _titleController,
            label: 'Objective',
            icon: Icons.flag_outlined,
            onChanged:
                ref
                    .read(candidateDevelopmentObjectiveDraftProvider.notifier)
                    .setObjectiveTitle,
            validator: CandidateDevelopmentObjectiveDraft.validateTitle,
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentTextInput(
            controller: _skillController,
            label: 'Skill focus',
            icon: Icons.psychology_alt_outlined,
            onChanged:
                ref
                    .read(candidateDevelopmentObjectiveDraftProvider.notifier)
                    .setSkillFocus,
            validator:
                (value) => CandidateDevelopmentObjectiveDraft.validateRequired(
                  value,
                  'a skill focus',
                ),
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentTextInput(
            controller: _ownerController,
            label: 'Owner',
            icon: Icons.badge_outlined,
            onChanged:
                ref
                    .read(candidateDevelopmentObjectiveDraftProvider.notifier)
                    .setOwnerName,
            validator:
                (value) => CandidateDevelopmentObjectiveDraft.validateRequired(
                  value,
                  'an owner',
                ),
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentTextInput(
            controller: _mentorController,
            label: 'Mentor',
            icon: Icons.supervisor_account_outlined,
            onChanged:
                ref
                    .read(candidateDevelopmentObjectiveDraftProvider.notifier)
                    .setMentorName,
            validator:
                (value) => CandidateDevelopmentObjectiveDraft.validateRequired(
                  value,
                  'a mentor',
                ),
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentDateFields(
            draft: draft,
            onSelectStart: _selectStartDate,
            onSelectDue: _selectDueDate,
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentTextInput(
            controller: _measureController,
            label: 'Success measure',
            icon: Icons.checklist_outlined,
            minLines: 3,
            onChanged:
                ref
                    .read(candidateDevelopmentObjectiveDraftProvider.notifier)
                    .setSuccessMeasure,
            validator:
                CandidateDevelopmentObjectiveDraft.validateSuccessMeasure,
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentDraftReadiness(draft: draft),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed:
                    ref
                        .read(
                          candidateDevelopmentObjectiveDraftProvider.notifier,
                        )
                        .clear,
                child: const Text('Clear'),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                key: const Key('candidate-development-submit'),
                onPressed: draft.isReadyToSubmit ? _submitObjective : null,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Submit objective'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectPacket(String? candidateId) {
    if (candidateId == null) return;
    final packet = widget.packets.firstWhere(
      (item) => item.candidateId == candidateId,
    );
    ref
        .read(candidateDevelopmentObjectiveDraftProvider.notifier)
        .initializeFromPacket(packet);
  }

  Future<void> _selectStartDate() async {
    final draft = ref.read(candidateDevelopmentObjectiveDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.startDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(candidateDevelopmentObjectiveDraftProvider.notifier)
        .setStartDate(picked);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(candidateDevelopmentObjectiveDraftProvider);
    final firstDate = draft.startDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? firstDate.add(const Duration(days: 30)),
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(candidateDevelopmentObjectiveDraftProvider.notifier)
        .setDueDate(picked);
  }

  void _submitObjective() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(candidateDevelopmentObjectiveDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    final objective = ref
        .read(candidateDevelopmentObjectivesProvider.notifier)
        .submitDraft(draft);
    ref.read(candidateDevelopmentObjectiveDraftProvider.notifier).clear();
    _showMessage('${objective.id} submitted for ${objective.candidateName}');
  }

  bool _packetExists(String candidateId) {
    return widget.packets.any((packet) => packet.candidateId == candidateId);
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
