import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/candidate_talent_handoff_checklist_models.dart';
import '../models/candidate_talent_handoff_models.dart';
import '../states/candidate_talent_handoff_checklist_provider.dart';
import 'candidate_talent_handoff_checklist_form_fields.dart';

class CandidateTalentHandoffChecklistForm extends ConsumerStatefulWidget {
  final List<CandidateTalentHandoff> handoffs;

  const CandidateTalentHandoffChecklistForm({
    super.key,
    required this.handoffs,
  });

  @override
  ConsumerState<CandidateTalentHandoffChecklistForm> createState() =>
      _CandidateTalentHandoffChecklistFormState();
}

class _CandidateTalentHandoffChecklistFormState
    extends ConsumerState<CandidateTalentHandoffChecklistForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _ownerController;
  late final TextEditingController _detailController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(candidateTalentHandoffChecklistDraftProvider);
    _titleController = TextEditingController(text: draft.title);
    _ownerController = TextEditingController(text: draft.ownerName);
    _detailController = TextEditingController(text: draft.detail);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(candidateTalentHandoffChecklistDraftProvider);
    final draftNotifier = ref.read(
      candidateTalentHandoffChecklistDraftProvider.notifier,
    );

    _sync(_titleController, draft.title);
    _sync(_ownerController, draft.ownerName);
    _sync(_detailController, draft.detail);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('checklist-${draft.handoffId}'),
            initialValue:
                _handoffExists(draft.handoffId) ? draft.handoffId : null,
            decoration: const InputDecoration(
              labelText: 'Talent handoff',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.hub_outlined),
            ),
            items:
                widget.handoffs
                    .map(
                      (handoff) => DropdownMenuItem(
                        value: handoff.id,
                        child: Text(
                          '${handoff.candidateName} - ${handoff.status.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: widget.handoffs.isEmpty ? null : _selectHandoff,
            validator:
                (value) =>
                    CandidateTalentHandoffChecklistDraft.validateRequired(
                      value,
                      'a talent handoff',
                    ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CandidateTalentHandoffChecklistCategory>(
            initialValue: draft.category,
            decoration: const InputDecoration(
              labelText: 'Checklist category',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items:
                CandidateTalentHandoffChecklistCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value == null) return;
              draftNotifier.setCategory(value);
            },
            validator: CandidateTalentHandoffChecklistDraft.validateCategory,
          ),
          const SizedBox(height: 12),
          CandidateTalentHandoffChecklistTextInput(
            controller: _titleController,
            label: 'Checklist title',
            icon: Icons.task_alt_outlined,
            onChanged: draftNotifier.setTitle,
            validator: CandidateTalentHandoffChecklistDraft.validateTitle,
          ),
          const SizedBox(height: 12),
          CandidateTalentHandoffChecklistTextInput(
            controller: _ownerController,
            label: 'Owner',
            icon: Icons.badge_outlined,
            onChanged: draftNotifier.setOwnerName,
            validator:
                (value) =>
                    CandidateTalentHandoffChecklistDraft.validateRequired(
                      value,
                      'an owner',
                    ),
          ),
          const SizedBox(height: 12),
          CandidateTalentHandoffChecklistDueField(
            draft: draft,
            onSelectDueDate: _selectDueDate,
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Required before start'),
            value: draft.requiredBeforeStart,
            onChanged: draftNotifier.setRequiredBeforeStart,
          ),
          const SizedBox(height: 12),
          CandidateTalentHandoffChecklistTextInput(
            controller: _detailController,
            label: 'Checklist detail',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: draftNotifier.setDetail,
            validator: CandidateTalentHandoffChecklistDraft.validateDetail,
          ),
          const SizedBox(height: 12),
          CandidateTalentHandoffChecklistDraftReadiness(draft: draft),
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
                key: const Key('candidate-handoff-checklist-submit'),
                onPressed: draft.isReadyToSubmit ? _submitChecklistItem : null,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Submit task'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectHandoff(String? handoffId) {
    if (handoffId == null) return;
    final handoff = widget.handoffs.firstWhere((item) => item.id == handoffId);
    ref
        .read(candidateTalentHandoffChecklistDraftProvider.notifier)
        .initializeFromHandoff(handoff);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(candidateTalentHandoffChecklistDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(candidateTalentHandoffChecklistDraftProvider.notifier)
        .setDueDate(picked);
  }

  void _submitChecklistItem() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(candidateTalentHandoffChecklistDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    final item = ref
        .read(candidateTalentHandoffChecklistItemsProvider.notifier)
        .submitDraft(draft);
    ref.read(candidateTalentHandoffChecklistDraftProvider.notifier).clear();
    _showMessage('${item.id} submitted for ${item.candidateName}');
  }

  bool _handoffExists(String handoffId) {
    return widget.handoffs.any((handoff) => handoff.id == handoffId);
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
