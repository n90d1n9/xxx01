import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_activation_checkpoint_models.dart';
import '../models/incoming_talent_activation_follow_up_models.dart';
import '../states/incoming_talent_activation_follow_up_provider.dart';
import 'incoming_talent_activation_follow_up_form_fields.dart';

class IncomingTalentActivationFollowUpForm extends ConsumerStatefulWidget {
  final List<IncomingTalentActivationCheckpoint> checkpoints;

  const IncomingTalentActivationFollowUpForm({
    super.key,
    required this.checkpoints,
  });

  @override
  ConsumerState<IncomingTalentActivationFollowUpForm> createState() =>
      _IncomingTalentActivationFollowUpFormState();
}

class _IncomingTalentActivationFollowUpFormState
    extends ConsumerState<IncomingTalentActivationFollowUpForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _actionController;
  late final TextEditingController _successController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentActivationFollowUpDraftProvider);
    _ownerController = TextEditingController(text: draft.ownerName);
    _actionController = TextEditingController(text: draft.action);
    _successController = TextEditingController(text: draft.successCriteria);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _actionController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentActivationFollowUpDraftProvider);
    final attentionCheckpoints =
        widget.checkpoints
            .where((checkpoint) => checkpoint.needsAttention)
            .toList();

    _sync(_ownerController, draft.ownerName);
    _sync(_actionController, draft.action);
    _sync(_successController, draft.successCriteria);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('follow-up-${draft.checkpointId}'),
            initialValue:
                _checkpointExists(attentionCheckpoints, draft.checkpointId)
                    ? draft.checkpointId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Attention checkpoint',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.monitor_heart_outlined),
            ),
            items:
                attentionCheckpoints
                    .map(
                      (checkpoint) => DropdownMenuItem(
                        value: checkpoint.id,
                        child: Text(
                          '${checkpoint.candidateName} - ${checkpoint.health.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: attentionCheckpoints.isEmpty ? null : _selectCheckpoint,
            validator:
                (value) =>
                    IncomingTalentActivationFollowUpDraft.validateRequired(
                      value,
                      'a checkpoint',
                    ),
          ),
          const SizedBox(height: 12),
          if (attentionCheckpoints.isEmpty)
            const HrisListSurface(
              child: Text('No attention checkpoints need follow-up.'),
            )
          else ...[
            IncomingTalentActivationFollowUpTextInput(
              controller: _ownerController,
              label: 'Follow-up owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentActivationFollowUpDraftProvider.notifier,
                      )
                      .setOwnerName,
              validator:
                  (value) =>
                      IncomingTalentActivationFollowUpDraft.validateRequired(
                        value,
                        'an owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationFollowUpTypeAndDateFields(
              draft: draft,
              onTypeChanged:
                  ref
                      .read(
                        incomingTalentActivationFollowUpDraftProvider.notifier,
                      )
                      .setActionType,
              onSelectDueDate: _selectDueDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationFollowUpTextInput(
              controller: _actionController,
              label: 'Follow-up action',
              icon: Icons.task_alt_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentActivationFollowUpDraftProvider.notifier,
                      )
                      .setAction,
              validator: IncomingTalentActivationFollowUpDraft.validateAction,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationFollowUpTextInput(
              controller: _successController,
              label: 'Success criteria',
              icon: Icons.flag_circle_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentActivationFollowUpDraftProvider.notifier,
                      )
                      .setSuccessCriteria,
              validator:
                  IncomingTalentActivationFollowUpDraft.validateSuccessCriteria,
            ),
            const SizedBox(height: 12),
            IncomingTalentActivationFollowUpDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentActivationFollowUpDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key('incoming-talent-follow-up-submit'),
                  onPressed: draft.isReadyToSubmit ? _submitFollowUp : null,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Create follow-up'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectCheckpoint(String? checkpointId) {
    if (checkpointId == null) return;
    final checkpoint = widget.checkpoints.firstWhere(
      (item) => item.id == checkpointId,
    );
    ref
        .read(incomingTalentActivationFollowUpDraftProvider.notifier)
        .initializeFromCheckpoint(checkpoint);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(incomingTalentActivationFollowUpDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentActivationFollowUpDraftProvider.notifier)
        .setDueDate(picked);
  }

  void _submitFollowUp() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentActivationFollowUpDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final action = ref
          .read(incomingTalentActivationFollowUpActionsProvider.notifier)
          .submitDraft(draft);
      ref.read(incomingTalentActivationFollowUpDraftProvider.notifier).clear();
      _showMessage('${action.id} created for ${action.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool _checkpointExists(
    List<IncomingTalentActivationCheckpoint> checkpoints,
    String checkpointId,
  ) {
    return checkpoints.any((checkpoint) => checkpoint.id == checkpointId);
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}
