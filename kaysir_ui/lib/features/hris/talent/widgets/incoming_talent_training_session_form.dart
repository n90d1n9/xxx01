import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_training_session_models.dart';
import '../states/incoming_talent_training_session_provider.dart';
import 'incoming_talent_development_program_form_widgets.dart';
import 'incoming_talent_training_session_fields.dart';

/// Form for scheduling a concrete session from a development program.
class IncomingTalentTrainingSessionForm extends ConsumerStatefulWidget {
  const IncomingTalentTrainingSessionForm({super.key});

  @override
  ConsumerState<IncomingTalentTrainingSessionForm> createState() =>
      _IncomingTalentTrainingSessionFormState();
}

class _IncomingTalentTrainingSessionFormState
    extends ConsumerState<IncomingTalentTrainingSessionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _trainerController;
  late final TextEditingController _locationController;
  late final TextEditingController _capacityController;
  late final TextEditingController _reservedSeatsController;
  late final TextEditingController _prerequisiteController;
  late final TextEditingController _outcomeController;
  String? _selectedProgramId;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentTrainingSessionDraftProvider);
    _selectedProgramId = draft.programId.isEmpty ? null : draft.programId;
    _trainerController = TextEditingController(text: draft.trainerName);
    _locationController = TextEditingController(text: draft.location);
    _capacityController = TextEditingController(text: '${draft.capacity}');
    _reservedSeatsController = TextEditingController(
      text: '${draft.reservedSeats}',
    );
    _prerequisiteController = TextEditingController(text: draft.prerequisite);
    _outcomeController = TextEditingController(text: draft.outcomeCheckpoint);
  }

  @override
  void dispose() {
    _trainerController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _reservedSeatsController.dispose();
    _prerequisiteController.dispose();
    _outcomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final programs = ref.watch(trainingSessionReadyDevelopmentProgramsProvider);
    final draft = ref.watch(incomingTalentTrainingSessionDraftProvider);

    syncIncomingTalentDevelopmentProgramController(
      _trainerController,
      draft.trainerName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _locationController,
      draft.location,
    );
    syncIncomingTalentDevelopmentProgramController(
      _capacityController,
      '${draft.capacity}',
    );
    syncIncomingTalentDevelopmentProgramController(
      _reservedSeatsController,
      '${draft.reservedSeats}',
    );
    syncIncomingTalentDevelopmentProgramController(
      _prerequisiteController,
      draft.prerequisite,
    );
    syncIncomingTalentDevelopmentProgramController(
      _outcomeController,
      draft.outcomeCheckpoint,
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentTrainingSessionProgramPicker(
            programs: programs,
            selectedProgramId: _selectedProgramId,
            onProgramChanged: _selectProgram,
          ),
          const SizedBox(height: 12),
          if (programs.isEmpty)
            const HrisListSurface(
              child: Text(
                'Create an active development program before scheduling sessions.',
              ),
            )
          else ...[
            IncomingTalentDevelopmentProgramResponsiveRow(
              children: [
                IncomingTalentDevelopmentProgramTextInput(
                  controller: _trainerController,
                  label: 'Trainer',
                  icon: Icons.co_present_outlined,
                  onChanged:
                      ref
                          .read(
                            incomingTalentTrainingSessionDraftProvider.notifier,
                          )
                          .setTrainerName,
                  validator:
                      (value) => validateIncomingTalentTrainingSessionRequired(
                        value,
                        'a trainer',
                      ),
                ),
                IncomingTalentDevelopmentProgramTextInput(
                  controller: _locationController,
                  label: 'Location',
                  icon: Icons.location_on_outlined,
                  onChanged:
                      ref
                          .read(
                            incomingTalentTrainingSessionDraftProvider.notifier,
                          )
                          .setLocation,
                  validator:
                      (value) => validateIncomingTalentTrainingSessionRequired(
                        value,
                        'a location',
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramResponsiveRow(
              children: [
                IncomingTalentDevelopmentProgramNumberInput(
                  controller: _capacityController,
                  label: 'Capacity',
                  icon: Icons.groups_outlined,
                  onChanged:
                      ref
                          .read(
                            incomingTalentTrainingSessionDraftProvider.notifier,
                          )
                          .setCapacity,
                  validator: validateIncomingTalentTrainingSessionCapacity,
                ),
                IncomingTalentDevelopmentProgramNumberInput(
                  controller: _reservedSeatsController,
                  label: 'Reserved seats',
                  icon: Icons.event_seat_outlined,
                  onChanged:
                      ref
                          .read(
                            incomingTalentTrainingSessionDraftProvider.notifier,
                          )
                          .setReservedSeats,
                  validator:
                      (value) =>
                          validateIncomingTalentTrainingSessionReservedSeats(
                            reservedSeats: value,
                            capacity: draft.capacity,
                          ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            IncomingTalentTrainingSessionClassificationFields(
              draft: draft,
              onFormatChanged:
                  ref
                      .read(incomingTalentTrainingSessionDraftProvider.notifier)
                      .setFormat,
              onStatusChanged:
                  ref
                      .read(incomingTalentTrainingSessionDraftProvider.notifier)
                      .setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentTrainingSessionDateFields(
              draft: draft,
              onSelectSessionDate: _selectSessionDate,
              onSelectFollowUpDate: _selectFollowUpDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _prerequisiteController,
              label: 'Prerequisite',
              icon: Icons.rule_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(incomingTalentTrainingSessionDraftProvider.notifier)
                      .setPrerequisite,
              validator:
                  (value) => validateIncomingTalentTrainingSessionLongText(
                    value,
                    'prerequisite',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _outcomeController,
              label: 'Outcome checkpoint',
              icon: Icons.fact_check_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(incomingTalentTrainingSessionDraftProvider.notifier)
                      .setOutcomeCheckpoint,
              validator:
                  (value) => validateIncomingTalentTrainingSessionLongText(
                    value,
                    'outcome checkpoint',
                  ),
            ),
            const SizedBox(height: 10),
            IncomingTalentTrainingSessionFormActions(
              completionRatio: draft.completionRatio,
              canSubmit: draft.isReadyToSubmit,
              onClear: _clear,
              onSubmit: _submitSession,
            ),
          ],
        ],
      ),
    );
  }

  void _selectProgram(String? value) {
    setState(() => _selectedProgramId = value);
    if (value == null) return;

    final programs = ref.read(trainingSessionReadyDevelopmentProgramsProvider);
    final program = programs.firstWhere((item) => item.id == value);
    ref
        .read(incomingTalentTrainingSessionDraftProvider.notifier)
        .initializeFromProgram(program);
  }

  Future<void> _selectSessionDate() async {
    final draft = ref.read(incomingTalentTrainingSessionDraftProvider);
    final picked = await _pickDate(
      initialDate: draft.sessionDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
    );
    if (picked == null) return;
    ref
        .read(incomingTalentTrainingSessionDraftProvider.notifier)
        .setSessionDate(picked);
  }

  Future<void> _selectFollowUpDate() async {
    final draft = ref.read(incomingTalentTrainingSessionDraftProvider);
    final sessionDate = draft.sessionDate ?? draft.asOfDate;
    final picked = await _pickDate(
      initialDate:
          draft.followUpDate ?? sessionDate.add(const Duration(days: 14)),
      firstDate: sessionDate.add(const Duration(days: 1)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentTrainingSessionDraftProvider.notifier)
        .setFollowUpDate(picked);
  }

  Future<DateTime?> _pickDate({
    required DateTime initialDate,
    required DateTime firstDate,
  }) {
    final draft = ref.read(incomingTalentTrainingSessionDraftProvider);
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
  }

  void _submitSession() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentTrainingSessionDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final session = ref
          .read(incomingTalentTrainingSessionsProvider.notifier)
          .submitDraft(draft);
      _clear();
      _showMessage('${session.id} scheduled for ${session.programTitle}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _clear() {
    ref.read(incomingTalentTrainingSessionDraftProvider.notifier).clear();
    setState(() => _selectedProgramId = null);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

@Preview(name: 'Talent training session form')
Widget incomingTalentTrainingSessionFormPreview() {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentTrainingSessionForm(),
        ),
      ),
    ),
  );
}
