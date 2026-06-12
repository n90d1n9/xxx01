import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_transition_intervention_provider.dart';
import 'incoming_talent_succession_transition_intervention_form_fields.dart';

class IncomingTalentSuccessionTransitionInterventionForm
    extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionTransitionInterventionForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionTransitionInterventionForm>
  createState() => _IncomingTalentSuccessionTransitionInterventionFormState();
}

class _IncomingTalentSuccessionTransitionInterventionFormState
    extends ConsumerState<IncomingTalentSuccessionTransitionInterventionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _planController;
  late final TextEditingController _supportController;
  late final TextEditingController _metricController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentSuccessionTransitionInterventionDraftProvider,
    );
    _ownerController = TextEditingController(text: draft.ownerName);
    _planController = TextEditingController(text: draft.interventionPlan);
    _supportController = TextEditingController(text: draft.sponsorSupport);
    _metricController = TextEditingController(text: draft.successMetric);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _planController.dispose();
    _supportController.dispose();
    _metricController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentSuccessionTransitionInterventionDraftProvider,
    );
    final pulses = ref.watch(
      interventionReadySuccessionTransitionPulsesProvider,
    );

    _sync(_ownerController, draft.ownerName);
    _sync(_planController, draft.interventionPlan);
    _sync(_supportController, draft.sponsorSupport);
    _sync(_metricController, draft.successMetric);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey(
              'succession-transition-intervention-${draft.pulseId}',
            ),
            initialValue:
                _pulseExists(pulses, draft.pulseId) ? draft.pulseId : null,
            decoration: const InputDecoration(
              labelText: 'Attention pulse',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.monitor_heart_outlined),
            ),
            items:
                pulses
                    .map(
                      (pulse) => DropdownMenuItem(
                        value: pulse.id,
                        child: Text(
                          '${pulse.candidateName} - ${pulse.health.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: pulses.isEmpty ? null : _selectPulse,
            validator:
                (value) =>
                    IncomingTalentSuccessionTransitionInterventionDraft.validateRequired(
                      value,
                      'an attention pulse',
                    ),
          ),
          const SizedBox(height: 12),
          if (pulses.isEmpty)
            const HrisListSurface(
              child: Text('No transition pulses need intervention.'),
            )
          else ...[
            IncomingTalentSuccessionTransitionInterventionTextInput(
              controller: _ownerController,
              label: 'Intervention owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionInterventionDraftProvider
                            .notifier,
                      )
                      .setOwnerName,
              validator:
                  (value) =>
                      IncomingTalentSuccessionTransitionInterventionDraft.validateRequired(
                        value,
                        'an intervention owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionInterventionControlFields(
              draft: draft,
              onTypeChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionInterventionDraftProvider
                            .notifier,
                      )
                      .setInterventionType,
              onSelectDueDate: _selectDueDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionInterventionTextInput(
              controller: _planController,
              label: 'Intervention plan',
              icon: Icons.task_alt_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionInterventionDraftProvider
                            .notifier,
                      )
                      .setInterventionPlan,
              validator:
                  IncomingTalentSuccessionTransitionInterventionDraft
                      .validateInterventionPlan,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionInterventionTextInput(
              controller: _supportController,
              label: 'Sponsor support',
              icon: Icons.handshake_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionInterventionDraftProvider
                            .notifier,
                      )
                      .setSponsorSupport,
              validator:
                  IncomingTalentSuccessionTransitionInterventionDraft
                      .validateSponsorSupport,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionInterventionTextInput(
              controller: _metricController,
              label: 'Success metric',
              icon: Icons.flag_circle_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionTransitionInterventionDraftProvider
                            .notifier,
                      )
                      .setSuccessMetric,
              validator:
                  IncomingTalentSuccessionTransitionInterventionDraft
                      .validateSuccessMetric,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionTransitionInterventionDraftReadiness(
              draft: draft,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentSuccessionTransitionInterventionDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key(
                    'incoming-talent-succession-transition-intervention-submit',
                  ),
                  onPressed: draft.isReadyToSubmit ? _submitIntervention : null,
                  icon: const Icon(Icons.healing_outlined),
                  label: const Text('Create intervention'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectPulse(String? pulseId) {
    if (pulseId == null) return;
    final pulses = ref.read(
      interventionReadySuccessionTransitionPulsesProvider,
    );
    final pulse = pulses.firstWhere((item) => item.id == pulseId);
    ref
        .read(
          incomingTalentSuccessionTransitionInterventionDraftProvider.notifier,
        )
        .initializeFromPulse(pulse);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(
      incomingTalentSuccessionTransitionInterventionDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(
          incomingTalentSuccessionTransitionInterventionDraftProvider.notifier,
        )
        .setDueDate(picked);
  }

  void _submitIntervention() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentSuccessionTransitionInterventionDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final intervention = ref
          .read(
            incomingTalentSuccessionTransitionInterventionsProvider.notifier,
          )
          .submitDraft(draft);
      ref
          .read(
            incomingTalentSuccessionTransitionInterventionDraftProvider
                .notifier,
          )
          .clear();
      _showMessage(
        '${intervention.id} created for ${intervention.candidateName}',
      );
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _pulseExists(
    List<IncomingTalentSuccessionTransitionPulse> pulses,
    String pulseId,
  ) {
    return pulses.any((pulse) => pulse.id == pulseId);
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
