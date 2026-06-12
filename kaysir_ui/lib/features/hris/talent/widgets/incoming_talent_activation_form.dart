import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_activation_models.dart';
import '../models/incoming_talent_readiness.dart';
import '../states/incoming_talent_activation_provider.dart';
import 'incoming_talent_activation_form_fields.dart';

class IncomingTalentActivationForm extends ConsumerStatefulWidget {
  final List<IncomingTalentReadiness> readiness;

  const IncomingTalentActivationForm({super.key, required this.readiness});

  @override
  ConsumerState<IncomingTalentActivationForm> createState() =>
      _IncomingTalentActivationFormState();
}

class _IncomingTalentActivationFormState
    extends ConsumerState<IncomingTalentActivationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _mentorController;
  late final TextEditingController _learningController;
  late final TextEditingController _ownerController;
  late final TextEditingController _successController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentActivationDraftProvider);
    _mentorController = TextEditingController(text: draft.mentorName);
    _learningController = TextEditingController(text: draft.learningPlanTitle);
    _ownerController = TextEditingController(text: draft.activationOwner);
    _successController = TextEditingController(text: draft.successMeasure);
    _notesController = TextEditingController(text: draft.notes);
  }

  @override
  void dispose() {
    _mentorController.dispose();
    _learningController.dispose();
    _ownerController.dispose();
    _successController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentActivationDraftProvider);
    final readyHandoffs =
        widget.readiness
            .where((item) => item.status == IncomingTalentReadinessStatus.ready)
            .toList();

    _sync(_mentorController, draft.mentorName);
    _sync(_learningController, draft.learningPlanTitle);
    _sync(_ownerController, draft.activationOwner);
    _sync(_successController, draft.successMeasure);
    _sync(_notesController, draft.notes);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('activation-${draft.handoffId}'),
            initialValue:
                _readinessExists(readyHandoffs, draft.handoffId)
                    ? draft.handoffId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Ready handoff',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_search_outlined),
            ),
            items:
                readyHandoffs
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.handoffId,
                        child: Text('${item.candidateName} - ${item.role}'),
                      ),
                    )
                    .toList(),
            onChanged: readyHandoffs.isEmpty ? null : _selectReadiness,
            validator:
                (value) => IncomingTalentActivationDraft.validateRequired(
                  value,
                  'an incoming handoff',
                ),
          ),
          const SizedBox(height: 12),
          if (readyHandoffs.isEmpty)
            const HrisListSurface(
              child: Text(
                'Complete incoming readiness gates before activation.',
              ),
            )
          else ...[
            IncomingTalentActivationTextInput(
              controller: _mentorController,
              label: 'Mentor',
              icon: Icons.supervisor_account_outlined,
              onChanged:
                  ref
                      .read(incomingTalentActivationDraftProvider.notifier)
                      .setMentorName,
              validator:
                  (value) => IncomingTalentActivationDraft.validateRequired(
                    value,
                    'a mentor',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationTextInput(
              controller: _learningController,
              label: 'Learning plan',
              icon: Icons.school_outlined,
              onChanged:
                  ref
                      .read(incomingTalentActivationDraftProvider.notifier)
                      .setLearningPlanTitle,
              validator:
                  (value) => IncomingTalentActivationDraft.validateRequired(
                    value,
                    'a learning plan',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationTextInput(
              controller: _ownerController,
              label: 'Activation owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(incomingTalentActivationDraftProvider.notifier)
                      .setActivationOwner,
              validator:
                  (value) => IncomingTalentActivationDraft.validateRequired(
                    value,
                    'an activation owner',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationDateFields(
              draft: draft,
              onSelectKickoff: _selectKickoffDate,
              onSelectCheckpoint: _selectCheckpointDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationTextInput(
              controller: _successController,
              label: 'Success measure',
              icon: Icons.flag_circle_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(incomingTalentActivationDraftProvider.notifier)
                      .setSuccessMeasure,
              validator: IncomingTalentActivationDraft.validateSuccessMeasure,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationTextInput(
              controller: _notesController,
              label: 'Activation notes',
              icon: Icons.notes_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(incomingTalentActivationDraftProvider.notifier)
                      .setNotes,
              validator: IncomingTalentActivationDraft.validateNotes,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(incomingTalentActivationDraftProvider.notifier)
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key('incoming-talent-activation-submit'),
                  onPressed: draft.isReadyToSubmit ? _submitActivation : null,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Create activation'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectReadiness(String? handoffId) {
    if (handoffId == null) return;
    final readiness = widget.readiness.firstWhere(
      (item) => item.handoffId == handoffId,
    );
    ref
        .read(incomingTalentActivationDraftProvider.notifier)
        .initializeFromReadiness(readiness);
  }

  Future<void> _selectKickoffDate() async {
    final draft = ref.read(incomingTalentActivationDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.kickoffDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentActivationDraftProvider.notifier)
        .setKickoffDate(picked);
  }

  Future<void> _selectCheckpointDate() async {
    final draft = ref.read(incomingTalentActivationDraftProvider);
    final firstDate = draft.kickoffDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.firstCheckpointDate ?? firstDate.add(const Duration(days: 14)),
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentActivationDraftProvider.notifier)
        .setFirstCheckpointDate(picked);
  }

  void _submitActivation() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentActivationDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final plan = ref
          .read(incomingTalentActivationPlansProvider.notifier)
          .submitDraft(draft);
      ref.read(incomingTalentActivationDraftProvider.notifier).clear();
      _showMessage('${plan.id} created for ${plan.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool _readinessExists(List<IncomingTalentReadiness> items, String handoffId) {
    return items.any((item) => item.handoffId == handoffId);
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}
