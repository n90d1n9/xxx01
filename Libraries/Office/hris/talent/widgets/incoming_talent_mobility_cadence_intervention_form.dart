import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_mobility_cadence_intervention_provider.dart';
import 'incoming_talent_mobility_cadence_intervention_check_in_picker.dart';
import 'incoming_talent_mobility_cadence_intervention_form_actions.dart';
import 'incoming_talent_mobility_cadence_intervention_form_fields.dart';
import 'incoming_talent_mobility_cadence_intervention_readiness.dart';

class IncomingTalentMobilityCadenceInterventionForm
    extends ConsumerStatefulWidget {
  const IncomingTalentMobilityCadenceInterventionForm({super.key});

  @override
  ConsumerState<IncomingTalentMobilityCadenceInterventionForm> createState() =>
      _IncomingTalentMobilityCadenceInterventionFormState();
}

class _IncomingTalentMobilityCadenceInterventionFormState
    extends ConsumerState<IncomingTalentMobilityCadenceInterventionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _summaryController;
  late final TextEditingController _measureController;
  late final TextEditingController _blockerController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentMobilityCadenceInterventionDraftProvider,
    );
    _ownerController = TextEditingController(text: draft.ownerName);
    _summaryController = TextEditingController(text: draft.interventionSummary);
    _measureController = TextEditingController(text: draft.successMeasure);
    _blockerController = TextEditingController(text: draft.blockerNote);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _summaryController.dispose();
    _measureController.dispose();
    _blockerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentMobilityCadenceInterventionDraftProvider,
    );
    final checkIns = ref.watch(
      interventionReadyMobilityCadenceCheckInsProvider,
    );
    final notifier = ref.read(
      incomingTalentMobilityCadenceInterventionDraftProvider.notifier,
    );

    _sync(_ownerController, draft.ownerName);
    _sync(_summaryController, draft.interventionSummary);
    _sync(_measureController, draft.successMeasure);
    _sync(_blockerController, draft.blockerNote);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentMobilityCadenceInterventionCheckInPicker(
            draft: draft,
            checkIns: checkIns,
            onChanged: _selectCheckIn,
          ),
          const SizedBox(height: 12),
          if (checkIns.isEmpty)
            const HrisListSurface(
              child: Text('No risky mobility cadence check-ins need action.'),
            )
          else ...[
            IncomingTalentMobilityCadenceInterventionTextInput(
              controller: _ownerController,
              label: 'Intervention owner',
              icon: Icons.badge_outlined,
              onChanged: notifier.setOwnerName,
              validator:
                  (value) =>
                      IncomingTalentMobilityCadenceInterventionDraft.validateRequired(
                        value,
                        'an intervention owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceInterventionSignalFields(
              draft: draft,
              onTypeChanged: notifier.setInterventionType,
              onPriorityChanged: notifier.setPriority,
              onStatusChanged: notifier.setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceInterventionDueDateField(
              draft: draft,
              onSelectDueDate: _selectDueDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceInterventionTextInput(
              controller: _summaryController,
              label: 'Intervention summary',
              icon: Icons.medical_services_outlined,
              minLines: 3,
              onChanged: notifier.setInterventionSummary,
              validator:
                  IncomingTalentMobilityCadenceInterventionDraft
                      .validateInterventionSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceInterventionTextInput(
              controller: _measureController,
              label: 'Success measure',
              icon: Icons.flag_circle_outlined,
              minLines: 3,
              onChanged: notifier.setSuccessMeasure,
              validator:
                  IncomingTalentMobilityCadenceInterventionDraft
                      .validateSuccessMeasure,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceInterventionTextInput(
              controller: _blockerController,
              label: 'Blocker note',
              icon: Icons.warning_amber_outlined,
              minLines: 3,
              onChanged: notifier.setBlockerNote,
              validator: _validateBlockerNote,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityCadenceInterventionDraftReadiness(
              draft: draft,
            ),
            const SizedBox(height: 14),
            IncomingTalentMobilityCadenceInterventionFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear: notifier.clear,
              onSubmit: _submitIntervention,
            ),
          ],
        ],
      ),
    );
  }

  void _selectCheckIn(String? checkInId) {
    if (checkInId == null) return;
    final checkIns = ref.read(interventionReadyMobilityCadenceCheckInsProvider);
    final checkIn = checkIns.firstWhere((item) => item.id == checkInId);
    ref
        .read(incomingTalentMobilityCadenceInterventionDraftProvider.notifier)
        .initializeFromCheckIn(checkIn);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(
      incomingTalentMobilityCadenceInterventionDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentMobilityCadenceInterventionDraftProvider.notifier)
        .setDueDate(picked);
  }

  void _submitIntervention() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentMobilityCadenceInterventionDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final intervention = ref
          .read(incomingTalentMobilityCadenceInterventionsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentMobilityCadenceInterventionDraftProvider.notifier)
          .clear();
      _showMessage(
        '${intervention.id} created for ${intervention.candidateName}',
      );
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  String? _validateBlockerNote(String? value) {
    final draft = ref.read(
      incomingTalentMobilityCadenceInterventionDraftProvider,
    );
    return IncomingTalentMobilityCadenceInterventionDraft.validateBlockerNote(
      value,
      draft.status,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
