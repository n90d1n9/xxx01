import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_development_program_models.dart';
import '../states/incoming_talent_development_program_provider.dart';
import 'incoming_talent_development_program_catalog_fields.dart';
import 'incoming_talent_development_program_form_widgets.dart';

class IncomingTalentDevelopmentProgramForm extends ConsumerStatefulWidget {
  const IncomingTalentDevelopmentProgramForm({super.key});

  @override
  ConsumerState<IncomingTalentDevelopmentProgramForm> createState() =>
      _IncomingTalentDevelopmentProgramFormState();
}

class _IncomingTalentDevelopmentProgramFormState
    extends ConsumerState<IncomingTalentDevelopmentProgramForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _departmentController;
  late final TextEditingController _ownerController;
  late final TextEditingController _focusController;
  late final TextEditingController _outcomeController;
  late final TextEditingController _capacityController;
  late final TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentDevelopmentProgramDraftProvider);
    _titleController = TextEditingController(text: draft.title);
    _departmentController = TextEditingController(text: draft.department);
    _ownerController = TextEditingController(text: draft.ownerName);
    _focusController = TextEditingController(text: draft.skillFocus);
    _outcomeController = TextEditingController(text: draft.expectedOutcome);
    _capacityController = TextEditingController(text: '${draft.capacity}');
    _durationController = TextEditingController(text: '${draft.durationDays}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _departmentController.dispose();
    _ownerController.dispose();
    _focusController.dispose();
    _outcomeController.dispose();
    _capacityController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentDevelopmentProgramDraftProvider);

    syncIncomingTalentDevelopmentProgramController(
      _titleController,
      draft.title,
    );
    syncIncomingTalentDevelopmentProgramController(
      _departmentController,
      draft.department,
    );
    syncIncomingTalentDevelopmentProgramController(
      _ownerController,
      draft.ownerName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _focusController,
      draft.skillFocus,
    );
    syncIncomingTalentDevelopmentProgramController(
      _outcomeController,
      draft.expectedOutcome,
    );
    syncIncomingTalentDevelopmentProgramController(
      _capacityController,
      '${draft.capacity}',
    );
    syncIncomingTalentDevelopmentProgramController(
      _durationController,
      '${draft.durationDays}',
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentDevelopmentProgramResponsiveRow(
            children: [
              IncomingTalentDevelopmentProgramTextInput(
                controller: _titleController,
                label: 'Program title',
                icon: Icons.school_outlined,
                onChanged:
                    ref
                        .read(
                          incomingTalentDevelopmentProgramDraftProvider
                              .notifier,
                        )
                        .setTitle,
                validator:
                    (value) => validateIncomingTalentDevelopmentProgramRequired(
                      value,
                      'a title',
                    ),
              ),
              IncomingTalentDevelopmentProgramTextInput(
                controller: _departmentController,
                label: 'Department',
                icon: Icons.apartment_outlined,
                onChanged:
                    ref
                        .read(
                          incomingTalentDevelopmentProgramDraftProvider
                              .notifier,
                        )
                        .setDepartment,
                validator:
                    (value) => validateIncomingTalentDevelopmentProgramRequired(
                      value,
                      'a department',
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          IncomingTalentDevelopmentProgramResponsiveRow(
            children: [
              IncomingTalentDevelopmentProgramTextInput(
                controller: _ownerController,
                label: 'Program owner',
                icon: Icons.badge_outlined,
                onChanged:
                    ref
                        .read(
                          incomingTalentDevelopmentProgramDraftProvider
                              .notifier,
                        )
                        .setOwnerName,
                validator:
                    (value) => validateIncomingTalentDevelopmentProgramRequired(
                      value,
                      'a program owner',
                    ),
              ),
              IncomingTalentDevelopmentProgramNumberInput(
                controller: _capacityController,
                label: 'Capacity',
                icon: Icons.groups_outlined,
                onChanged:
                    ref
                        .read(
                          incomingTalentDevelopmentProgramDraftProvider
                              .notifier,
                        )
                        .setCapacity,
                validator: validateIncomingTalentDevelopmentProgramCapacity,
              ),
              IncomingTalentDevelopmentProgramNumberInput(
                controller: _durationController,
                label: 'Duration days',
                icon: Icons.timelapse_outlined,
                onChanged:
                    ref
                        .read(
                          incomingTalentDevelopmentProgramDraftProvider
                              .notifier,
                        )
                        .setDurationDays,
                validator: validateIncomingTalentDevelopmentProgramDuration,
              ),
            ],
          ),
          const SizedBox(height: 12),
          IncomingTalentDevelopmentProgramClassificationFields(
            draft: draft,
            onTrackChanged:
                ref
                    .read(
                      incomingTalentDevelopmentProgramDraftProvider.notifier,
                    )
                    .setTrack,
            onStatusChanged:
                ref
                    .read(
                      incomingTalentDevelopmentProgramDraftProvider.notifier,
                    )
                    .setStatus,
            onIntensityChanged:
                ref
                    .read(
                      incomingTalentDevelopmentProgramDraftProvider.notifier,
                    )
                    .setIntensity,
          ),
          const SizedBox(height: 12),
          IncomingTalentDevelopmentProgramCatalogDateFields(
            draft: draft,
            onSelectStartDate: _selectStartDate,
            onSelectEndDate: _selectEndDate,
          ),
          const SizedBox(height: 12),
          IncomingTalentDevelopmentProgramTextInput(
            controller: _focusController,
            label: 'Skill focus',
            icon: Icons.psychology_alt_outlined,
            minLines: 2,
            onChanged:
                ref
                    .read(
                      incomingTalentDevelopmentProgramDraftProvider.notifier,
                    )
                    .setSkillFocus,
            validator:
                (value) => validateIncomingTalentDevelopmentProgramLongText(
                  value,
                  'skill focus',
                ),
          ),
          const SizedBox(height: 12),
          IncomingTalentDevelopmentProgramTextInput(
            controller: _outcomeController,
            label: 'Expected outcome',
            icon: Icons.emoji_events_outlined,
            minLines: 2,
            onChanged:
                ref
                    .read(
                      incomingTalentDevelopmentProgramDraftProvider.notifier,
                    )
                    .setExpectedOutcome,
            validator:
                (value) => validateIncomingTalentDevelopmentProgramLongText(
                  value,
                  'expected outcome',
                ),
          ),
          const SizedBox(height: 10),
          IncomingTalentDevelopmentProgramFormActions(
            completionRatio: draft.completionRatio,
            canSubmit: draft.isReadyToSubmit,
            onClear: _clear,
            onSubmit: _submitProgram,
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final draft = ref.read(incomingTalentDevelopmentProgramDraftProvider);
    final picked = await _pickDate(
      initialDate: draft.startDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
    );
    if (picked == null) return;
    ref
        .read(incomingTalentDevelopmentProgramDraftProvider.notifier)
        .setStartDate(picked);
  }

  Future<void> _selectEndDate() async {
    final draft = ref.read(incomingTalentDevelopmentProgramDraftProvider);
    final startDate = draft.startDate ?? draft.asOfDate;
    final picked = await _pickDate(
      initialDate: draft.endDate ?? startDate.add(const Duration(days: 60)),
      firstDate: startDate,
    );
    if (picked == null) return;
    ref
        .read(incomingTalentDevelopmentProgramDraftProvider.notifier)
        .setEndDate(picked);
  }

  Future<DateTime?> _pickDate({
    required DateTime initialDate,
    required DateTime firstDate,
  }) {
    final draft = ref.read(incomingTalentDevelopmentProgramDraftProvider);
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
  }

  void _submitProgram() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentDevelopmentProgramDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final program = ref
          .read(incomingTalentDevelopmentProgramsProvider.notifier)
          .submitDraft(draft);
      _clear();
      _showMessage('${program.id} created');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _clear() {
    ref.read(incomingTalentDevelopmentProgramDraftProvider.notifier).clear();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
