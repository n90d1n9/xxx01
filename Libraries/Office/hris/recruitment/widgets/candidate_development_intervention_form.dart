import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/candidate_development_check_in_models.dart';
import '../models/candidate_development_intervention_models.dart';
import '../states/candidate_development_intervention_provider.dart';
import 'candidate_development_intervention_form_fields.dart';

class CandidateDevelopmentInterventionForm extends ConsumerStatefulWidget {
  final List<CandidateDevelopmentCheckIn> checkIns;

  const CandidateDevelopmentInterventionForm({
    super.key,
    required this.checkIns,
  });

  @override
  ConsumerState<CandidateDevelopmentInterventionForm> createState() =>
      _CandidateDevelopmentInterventionFormState();
}

class _CandidateDevelopmentInterventionFormState
    extends ConsumerState<CandidateDevelopmentInterventionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _actionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(candidateDevelopmentInterventionDraftProvider);
    _ownerController = TextEditingController(text: draft.ownerName);
    _actionController = TextEditingController(text: draft.actionNote);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(candidateDevelopmentInterventionDraftProvider);

    _sync(_ownerController, draft.ownerName);
    _sync(_actionController, draft.actionNote);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('intervention-${draft.checkInId}'),
            initialValue:
                _checkInExists(draft.checkInId) ? draft.checkInId : null,
            decoration: const InputDecoration(
              labelText: 'Development check-in',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.insights_outlined),
            ),
            items:
                widget.checkIns
                    .map(
                      (checkIn) => DropdownMenuItem(
                        value: checkIn.id,
                        child: Text(
                          '${checkIn.candidateName} - ${checkIn.status.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: widget.checkIns.isEmpty ? null : _selectCheckIn,
            validator:
                (value) =>
                    CandidateDevelopmentInterventionDraft.validateRequired(
                      value,
                      'a check-in',
                    ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CandidateDevelopmentInterventionType>(
            initialValue: draft.type,
            decoration: const InputDecoration(
              labelText: 'Intervention type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items:
                CandidateDevelopmentInterventionType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value == null) return;
              ref
                  .read(candidateDevelopmentInterventionDraftProvider.notifier)
                  .setType(value);
            },
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentInterventionTextInput(
            controller: _ownerController,
            label: 'Owner',
            icon: Icons.badge_outlined,
            onChanged:
                ref
                    .read(
                      candidateDevelopmentInterventionDraftProvider.notifier,
                    )
                    .setOwnerName,
            validator:
                (value) =>
                    CandidateDevelopmentInterventionDraft.validateRequired(
                      value,
                      'an owner',
                    ),
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentInterventionDueField(
            draft: draft,
            onSelectDueDate: _selectDueDate,
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Escalation required'),
            value: draft.escalationRequired,
            onChanged:
                ref
                    .read(
                      candidateDevelopmentInterventionDraftProvider.notifier,
                    )
                    .setEscalationRequired,
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentInterventionTextInput(
            controller: _actionController,
            label: 'Intervention action',
            icon: Icons.handyman_outlined,
            minLines: 3,
            onChanged:
                ref
                    .read(
                      candidateDevelopmentInterventionDraftProvider.notifier,
                    )
                    .setActionNote,
            validator: CandidateDevelopmentInterventionDraft.validateActionNote,
          ),
          const SizedBox(height: 12),
          CandidateDevelopmentInterventionDraftReadiness(draft: draft),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed:
                    ref
                        .read(
                          candidateDevelopmentInterventionDraftProvider
                              .notifier,
                        )
                        .clear,
                child: const Text('Clear'),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                key: const Key('candidate-development-intervention-submit'),
                onPressed: draft.isReadyToSubmit ? _submitIntervention : null,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Submit action'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectCheckIn(String? checkInId) {
    if (checkInId == null) return;
    final checkIn = widget.checkIns.firstWhere((item) => item.id == checkInId);
    ref
        .read(candidateDevelopmentInterventionDraftProvider.notifier)
        .initializeFromCheckIn(checkIn);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(candidateDevelopmentInterventionDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate.add(const Duration(days: 7)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(candidateDevelopmentInterventionDraftProvider.notifier)
        .setDueDate(picked);
  }

  void _submitIntervention() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(candidateDevelopmentInterventionDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    final intervention = ref
        .read(candidateDevelopmentInterventionsProvider.notifier)
        .submitDraft(draft);
    ref.read(candidateDevelopmentInterventionDraftProvider.notifier).clear();
    _showMessage(
      '${intervention.id} submitted for ${intervention.candidateName}',
    );
  }

  bool _checkInExists(String checkInId) {
    return widget.checkIns.any((checkIn) => checkIn.id == checkInId);
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
