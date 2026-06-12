import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_transition_pulse_provider.dart';
import 'incoming_talent_succession_transition_pulse_form_fields.dart';

class IncomingTalentSuccessionTransitionPulseForm
    extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionTransitionPulseForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionTransitionPulseForm> createState() =>
      _IncomingTalentSuccessionTransitionPulseFormState();
}

class _IncomingTalentSuccessionTransitionPulseFormState
    extends ConsumerState<IncomingTalentSuccessionTransitionPulseForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _employeeController;
  late final TextEditingController _managerController;
  late final TextEditingController _sentimentController;
  late final TextEditingController _nextActionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentSuccessionTransitionPulseDraftProvider,
    );
    _ownerController = TextEditingController(text: draft.ownerName);
    _evidenceController = TextEditingController(text: draft.outcomeEvidence);
    _employeeController = TextEditingController(text: draft.employeeSignal);
    _managerController = TextEditingController(text: draft.managerSignal);
    _sentimentController = TextEditingController(
      text: draft.stakeholderSentiment,
    );
    _nextActionController = TextEditingController(text: draft.nextAction);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _evidenceController.dispose();
    _employeeController.dispose();
    _managerController.dispose();
    _sentimentController.dispose();
    _nextActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentSuccessionTransitionPulseDraftProvider,
    );
    final closures = ref.watch(pulseReadySuccessionActivationClosuresProvider);

    _sync(_ownerController, draft.ownerName);
    _sync(_evidenceController, draft.outcomeEvidence);
    _sync(_employeeController, draft.employeeSignal);
    _sync(_managerController, draft.managerSignal);
    _sync(_sentimentController, draft.stakeholderSentiment);
    _sync(_nextActionController, draft.nextAction);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('succession-transition-pulse-${draft.closureId}'),
            initialValue:
                _closureExists(closures, draft.closureId)
                    ? draft.closureId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Completed transition',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.verified_user_outlined),
            ),
            items:
                closures
                    .map(
                      (closure) => DropdownMenuItem(
                        value: closure.id,
                        child: Text(
                          '${closure.candidateName} - ${closure.targetRole}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: closures.isEmpty ? null : _selectClosure,
            validator:
                (value) =>
                    IncomingTalentSuccessionTransitionPulseDraft.validateRequired(
                      value,
                      'a completed closure',
                    ),
          ),
          const SizedBox(height: 12),
          if (closures.isEmpty)
            const HrisListSurface(
              child: Text('No completed transitions are ready for pulse.'),
            )
          else ...[
            IncomingTalentSuccessionTransitionPulseTextInput(
              controller: _ownerController,
              label: 'Pulse owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionPulseDraftProvider
                            .notifier,
                      )
                      .setOwnerName,
              validator:
                  (value) =>
                      IncomingTalentSuccessionTransitionPulseDraft.validateRequired(
                        value,
                        'a pulse owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionPulseScheduleFields(
              draft: draft,
              onWindowChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionPulseDraftProvider
                            .notifier,
                      )
                      .setPulseWindow,
              onSelectPulseDate: _selectPulseDate,
              onSelectNextPulseDate: _selectNextPulseDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionPulseSignalFields(
              draft: draft,
              onHealthChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionPulseDraftProvider
                            .notifier,
                      )
                      .setHealth,
              onAdoptionChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionPulseDraftProvider
                            .notifier,
                      )
                      .setAdoptionScore,
              onManagerConfidenceChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionPulseDraftProvider
                            .notifier,
                      )
                      .setManagerConfidenceScore,
              onRetentionRiskChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionPulseDraftProvider
                            .notifier,
                      )
                      .setRetentionRisk,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionPulseTextInput(
              controller: _evidenceController,
              label: 'Outcome evidence',
              icon: Icons.description_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionPulseDraftProvider
                            .notifier,
                      )
                      .setOutcomeEvidence,
              validator:
                  IncomingTalentSuccessionTransitionPulseDraft
                      .validateOutcomeEvidence,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionPulseTextInput(
              controller: _employeeController,
              label: 'Employee signal',
              icon: Icons.person_outline,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionPulseDraftProvider
                            .notifier,
                      )
                      .setEmployeeSignal,
              validator:
                  IncomingTalentSuccessionTransitionPulseDraft
                      .validateEmployeeSignal,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionPulseTextInput(
              controller: _managerController,
              label: 'Manager signal',
              icon: Icons.supervisor_account_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionPulseDraftProvider
                            .notifier,
                      )
                      .setManagerSignal,
              validator:
                  IncomingTalentSuccessionTransitionPulseDraft
                      .validateManagerSignal,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionPulseTextInput(
              controller: _sentimentController,
              label: 'Stakeholder sentiment',
              icon: Icons.groups_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionPulseDraftProvider
                            .notifier,
                      )
                      .setStakeholderSentiment,
              validator:
                  IncomingTalentSuccessionTransitionPulseDraft
                      .validateStakeholderSentiment,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionPulseTextInput(
              controller: _nextActionController,
              label: 'Next action',
              icon: Icons.route_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionPulseDraftProvider
                            .notifier,
                      )
                      .setNextAction,
              validator:
                  IncomingTalentSuccessionTransitionPulseDraft
                      .validateNextAction,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionPulseDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentSuccessionTransitionPulseDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key('incoming-talent-succession-pulse-submit'),
                  onPressed: draft.isReadyToSubmit ? _submitPulse : null,
                  icon: const Icon(Icons.monitor_heart_outlined),
                  label: const Text('Submit pulse'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectClosure(String? closureId) {
    if (closureId == null) return;
    final closures = ref.read(pulseReadySuccessionActivationClosuresProvider);
    final closure = closures.firstWhere((item) => item.id == closureId);
    ref
        .read(incomingTalentSuccessionTransitionPulseDraftProvider.notifier)
        .initializeFromClosure(closure);
  }

  Future<void> _selectPulseDate() async {
    final draft = ref.read(
      incomingTalentSuccessionTransitionPulseDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.pulseDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionTransitionPulseDraftProvider.notifier)
        .setPulseDate(picked);
  }

  Future<void> _selectNextPulseDate() async {
    final draft = ref.read(
      incomingTalentSuccessionTransitionPulseDraftProvider,
    );
    final pulseDate = draft.pulseDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.nextPulseDate ?? pulseDate.add(const Duration(days: 30)),
      firstDate: pulseDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionTransitionPulseDraftProvider.notifier)
        .setNextPulseDate(picked);
  }

  void _submitPulse() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentSuccessionTransitionPulseDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final pulse = ref
          .read(incomingTalentSuccessionTransitionPulsesProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentSuccessionTransitionPulseDraftProvider.notifier)
          .clear();
      _showMessage('${pulse.id} submitted for ${pulse.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _closureExists(
    List<IncomingTalentSuccessionActivationClosure> closures,
    String closureId,
  ) {
    return closures.any((closure) => closure.id == closureId);
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
