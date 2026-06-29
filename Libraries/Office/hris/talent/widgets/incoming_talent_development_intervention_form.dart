import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_intervention_models.dart';
import '../states/incoming_talent_development_intervention_provider.dart';
import 'incoming_talent_development_intervention_form_fields.dart';
import 'incoming_talent_development_intervention_source_field.dart';

class IncomingTalentDevelopmentInterventionForm extends ConsumerStatefulWidget {
  const IncomingTalentDevelopmentInterventionForm({super.key});

  @override
  ConsumerState<IncomingTalentDevelopmentInterventionForm> createState() =>
      _IncomingTalentDevelopmentInterventionFormState();
}

class _IncomingTalentDevelopmentInterventionFormState
    extends ConsumerState<IncomingTalentDevelopmentInterventionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _actionController;
  late final TextEditingController _successController;
  late final TextEditingController _resolutionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentDevelopmentInterventionDraftProvider);
    _ownerController = TextEditingController(text: draft.ownerName);
    _actionController = TextEditingController(text: draft.action);
    _successController = TextEditingController(text: draft.successCriteria);
    _resolutionController = TextEditingController(text: draft.resolutionNote);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _actionController.dispose();
    _successController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentDevelopmentInterventionDraftProvider);
    final sources = ref.watch(interventionReadyDevelopmentSourcesProvider);

    _sync(_ownerController, draft.ownerName);
    _sync(_actionController, draft.action);
    _sync(_successController, draft.successCriteria);
    _sync(_resolutionController, draft.resolutionNote);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentDevelopmentInterventionSourceField(
            selectedKey: draft.sourceKey,
            sources: sources,
            onChanged: _selectSource,
          ),
          const SizedBox(height: 12),
          if (sources.isEmpty)
            const HrisListSurface(
              child: Text('No risky talent sources need intervention actions.'),
            )
          else ...[
            IncomingTalentDevelopmentInterventionTextInput(
              controller: _ownerController,
              label: 'Action owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentInterventionDraftProvider
                            .notifier,
                      )
                      .setOwnerName,
              validator:
                  (value) =>
                      IncomingTalentDevelopmentInterventionDraft.validateRequired(
                        value,
                        'an owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionStatusFields(
              draft: draft,
              onTypeChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentInterventionDraftProvider
                            .notifier,
                      )
                      .setActionType,
              onPriorityChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentInterventionDraftProvider
                            .notifier,
                      )
                      .setPriority,
              onStatusChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentInterventionDraftProvider
                            .notifier,
                      )
                      .setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionDueDateField(
              draft: draft,
              onSelectDueDate: _selectDueDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionTextInput(
              controller: _actionController,
              label: 'Action',
              icon: Icons.task_alt_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentInterventionDraftProvider
                            .notifier,
                      )
                      .setAction,
              validator:
                  IncomingTalentDevelopmentInterventionDraft.validateAction,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionTextInput(
              controller: _successController,
              label: 'Success criteria',
              icon: Icons.insights_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentInterventionDraftProvider
                            .notifier,
                      )
                      .setSuccessCriteria,
              validator:
                  IncomingTalentDevelopmentInterventionDraft
                      .validateSuccessCriteria,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionTextInput(
              controller: _resolutionController,
              label: 'Resolution note',
              icon: Icons.verified_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentDevelopmentInterventionDraftProvider
                            .notifier,
                      )
                      .setResolutionNote,
              validator:
                  (value) =>
                      IncomingTalentDevelopmentInterventionDraft.validateResolutionNote(
                        value,
                        draft.status,
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentInterventionDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentDevelopmentInterventionDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key('incoming-talent-intervention-submit'),
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

  void _selectSource(String? sourceKey) {
    if (sourceKey == null) return;
    final sources = ref.read(interventionReadyDevelopmentSourcesProvider);
    final source = sources.firstWhere((item) => item.key == sourceKey);
    final notifier = ref.read(
      incomingTalentDevelopmentInterventionDraftProvider.notifier,
    );

    switch (source.source) {
      case IncomingTalentDevelopmentInterventionSource.checkIn:
        final checkIn = ref
            .read(interventionReadyDevelopmentCheckInsProvider)
            .firstWhere((item) => item.id == source.id);
        notifier.initializeFromCheckIn(checkIn);
      case IncomingTalentDevelopmentInterventionSource.activationFollowUp:
        final action = ref
            .read(interventionReadyActivationFollowUpsProvider)
            .firstWhere((item) => item.id == source.id);
        notifier.initializeFromFollowUp(action);
    }
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(incomingTalentDevelopmentInterventionDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentDevelopmentInterventionDraftProvider.notifier)
        .setDueDate(picked);
  }

  void _submitAction() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentDevelopmentInterventionDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final action = ref
          .read(incomingTalentDevelopmentInterventionsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentDevelopmentInterventionDraftProvider.notifier)
          .clear();
      _showMessage('${action.id} created for ${action.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
