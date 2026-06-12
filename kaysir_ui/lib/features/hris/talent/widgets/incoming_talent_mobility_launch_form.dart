import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_mobility_launch_checklist_provider.dart';
import 'incoming_talent_mobility_launch_form_actions.dart';
import 'incoming_talent_mobility_launch_form_fields.dart';
import 'incoming_talent_mobility_launch_gate_checklist.dart';
import 'incoming_talent_mobility_launch_match_picker.dart';

class IncomingTalentMobilityLaunchForm extends ConsumerStatefulWidget {
  final List<IncomingTalentMobilityMatch> matches;

  const IncomingTalentMobilityLaunchForm({super.key, required this.matches});

  @override
  ConsumerState<IncomingTalentMobilityLaunchForm> createState() =>
      _IncomingTalentMobilityLaunchFormState();
}

class _IncomingTalentMobilityLaunchFormState
    extends ConsumerState<IncomingTalentMobilityLaunchForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _riskController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentMobilityLaunchChecklistDraftProvider);
    _ownerController = TextEditingController(text: draft.ownerName);
    _riskController = TextEditingController(text: draft.riskNote);
    _notesController = TextEditingController(text: draft.launchNotes);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _riskController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentMobilityLaunchChecklistDraftProvider);
    final notifier = ref.read(
      incomingTalentMobilityLaunchChecklistDraftProvider.notifier,
    );

    _sync(_ownerController, draft.ownerName);
    _sync(_riskController, draft.riskNote);
    _sync(_notesController, draft.launchNotes);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentMobilityLaunchMatchPicker(
            draft: draft,
            matches: widget.matches,
            onChanged: _selectMatch,
          ),
          const SizedBox(height: 12),
          if (widget.matches.isEmpty)
            const HrisListSurface(
              child: Text('No accepted mobility matches need launch checks.'),
            )
          else ...[
            IncomingTalentMobilityLaunchTextInput(
              controller: _ownerController,
              label: 'Launch owner',
              icon: Icons.badge_outlined,
              onChanged: notifier.setOwnerName,
              validator:
                  (value) =>
                      IncomingTalentMobilityLaunchChecklistDraft.validateRequired(
                        value,
                        'a launch owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityLaunchStatusField(
              draft: draft,
              onChanged: notifier.setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityLaunchDateFields(
              draft: draft,
              onSelectLaunchDate: _selectLaunchDate,
              onSelectFirstReviewDate: _selectFirstReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityLaunchGateChecklist(
              draft: draft,
              onSponsorSignedOff: notifier.setSponsorSignedOff,
              onHostManagerReady: notifier.setHostManagerReady,
              onAccessReady: notifier.setAccessReady,
              onCommunicationReady: notifier.setCommunicationReady,
              onBackfillReady: notifier.setBackfillReady,
              onFirstReviewScheduled: notifier.setFirstReviewScheduled,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityLaunchTextInput(
              controller: _notesController,
              label: 'Launch notes',
              icon: Icons.notes_outlined,
              minLines: 3,
              onChanged: notifier.setLaunchNotes,
              validator:
                  IncomingTalentMobilityLaunchChecklistDraft
                      .validateLaunchNotes,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityLaunchTextInput(
              controller: _riskController,
              label: 'Risk note',
              icon: Icons.report_problem_outlined,
              minLines: 2,
              onChanged: notifier.setRiskNote,
              validator: _validateRiskNote,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityLaunchDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            IncomingTalentMobilityLaunchFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear: notifier.clear,
              onSubmit: _submitChecklist,
            ),
          ],
        ],
      ),
    );
  }

  void _selectMatch(String? matchId) {
    if (matchId == null) return;
    final match = widget.matches.firstWhere((item) => item.id == matchId);
    ref
        .read(incomingTalentMobilityLaunchChecklistDraftProvider.notifier)
        .initializeFromMatch(match);
  }

  Future<void> _selectLaunchDate() async {
    final draft = ref.read(incomingTalentMobilityLaunchChecklistDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.launchDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentMobilityLaunchChecklistDraftProvider.notifier)
        .setLaunchDate(picked);
  }

  Future<void> _selectFirstReviewDate() async {
    final draft = ref.read(incomingTalentMobilityLaunchChecklistDraftProvider);
    final launchDate = draft.launchDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.firstReviewDate ?? launchDate.add(const Duration(days: 45)),
      firstDate: launchDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentMobilityLaunchChecklistDraftProvider.notifier)
        .setFirstReviewDate(picked);
  }

  void _submitChecklist() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentMobilityLaunchChecklistDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final checklist = ref
          .read(incomingTalentMobilityLaunchChecklistsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentMobilityLaunchChecklistDraftProvider.notifier)
          .clear();
      _showMessage('${checklist.id} created for ${checklist.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  String? _validateRiskNote(String? value) {
    final draft = ref.read(incomingTalentMobilityLaunchChecklistDraftProvider);
    if (draft.status != IncomingTalentMobilityLaunchStatus.blocked) {
      return null;
    }
    return IncomingTalentMobilityLaunchChecklistDraft.validateRiskNote(value);
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
