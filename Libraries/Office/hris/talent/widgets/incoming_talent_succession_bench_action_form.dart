import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_bench_action_provider.dart';
import 'incoming_talent_succession_bench_action_form_fields.dart';

class IncomingTalentSuccessionBenchActionForm extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionBenchActionForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionBenchActionForm> createState() =>
      _IncomingTalentSuccessionBenchActionFormState();
}

class _IncomingTalentSuccessionBenchActionFormState
    extends ConsumerState<IncomingTalentSuccessionBenchActionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _planController;
  late final TextEditingController _pathController;
  late final TextEditingController _evidenceController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentSuccessionBenchActionDraftProvider);
    _ownerController = TextEditingController(text: draft.ownerName);
    _planController = TextEditingController(text: draft.actionPlan);
    _pathController = TextEditingController(text: draft.escalationPath);
    _evidenceController = TextEditingController(text: draft.resolutionEvidence);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _planController.dispose();
    _pathController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentSuccessionBenchActionDraftProvider);
    final checkIns = ref.watch(actionReadySuccessionBenchCheckInsProvider);

    _sync(_ownerController, draft.ownerName);
    _sync(_planController, draft.actionPlan);
    _sync(_pathController, draft.escalationPath);
    _sync(_evidenceController, draft.resolutionEvidence);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('succession-bench-action-${draft.checkInId}'),
            initialValue:
                _checkInExists(checkIns, draft.checkInId)
                    ? draft.checkInId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Risky bench check-in',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.monitor_heart_outlined),
            ),
            items:
                checkIns
                    .map(
                      (checkIn) => DropdownMenuItem(
                        value: checkIn.id,
                        child: Text(
                          '${checkIn.role} - ${checkIn.health.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: checkIns.isEmpty ? null : _selectCheckIn,
            validator:
                (value) =>
                    IncomingTalentSuccessionBenchActionDraft.validateRequired(
                      value,
                      'an attention check-in',
                    ),
          ),
          const SizedBox(height: 12),
          if (checkIns.isEmpty)
            const HrisListSurface(
              child: Text('No risky bench check-ins are ready for action.'),
            )
          else ...[
            IncomingTalentSuccessionBenchActionTextInput(
              controller: _ownerController,
              label: 'Action owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchActionDraftProvider
                            .notifier,
                      )
                      .setOwnerName,
              validator:
                  (value) =>
                      IncomingTalentSuccessionBenchActionDraft.validateRequired(
                        value,
                        'an action owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchActionControlFields(
              draft: draft,
              onTypeChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchActionDraftProvider
                            .notifier,
                      )
                      .setActionType,
              onSelectDueDate: _selectDueDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchActionTextInput(
              controller: _planController,
              label: 'Action plan',
              icon: Icons.task_alt_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchActionDraftProvider
                            .notifier,
                      )
                      .setActionPlan,
              validator:
                  IncomingTalentSuccessionBenchActionDraft.validateActionPlan,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchActionTextInput(
              controller: _pathController,
              label: 'Escalation path',
              icon: Icons.account_tree_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchActionDraftProvider
                            .notifier,
                      )
                      .setEscalationPath,
              validator:
                  IncomingTalentSuccessionBenchActionDraft
                      .validateEscalationPath,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchActionTextInput(
              controller: _evidenceController,
              label: 'Resolution evidence',
              icon: Icons.fact_check_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchActionDraftProvider
                            .notifier,
                      )
                      .setResolutionEvidence,
              validator:
                  IncomingTalentSuccessionBenchActionDraft
                      .validateResolutionEvidence,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchActionDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentSuccessionBenchActionDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key(
                    'incoming-talent-succession-bench-action-submit',
                  ),
                  onPressed: draft.isReadyToSubmit ? _submitAction : null,
                  icon: const Icon(Icons.task_alt_outlined),
                  label: const Text('Create action'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectCheckIn(String? checkInId) {
    if (checkInId == null) return;
    final checkIns = ref.read(actionReadySuccessionBenchCheckInsProvider);
    final checkIn = checkIns.firstWhere((item) => item.id == checkInId);
    ref
        .read(incomingTalentSuccessionBenchActionDraftProvider.notifier)
        .initializeFromCheckIn(checkIn);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(incomingTalentSuccessionBenchActionDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionBenchActionDraftProvider.notifier)
        .setDueDate(picked);
  }

  void _submitAction() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentSuccessionBenchActionDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final action = ref
          .read(incomingTalentSuccessionBenchActionsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentSuccessionBenchActionDraftProvider.notifier)
          .clear();
      _showMessage('${action.id} created for ${action.role}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _checkInExists(
    List<IncomingTalentSuccessionBenchCheckIn> checkIns,
    String checkInId,
  ) {
    return checkIns.any((checkIn) => checkIn.id == checkInId);
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
