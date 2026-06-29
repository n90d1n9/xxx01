import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_implementation_models.dart';
import '../states/incoming_talent_promotion_implementation_provider.dart';
import 'incoming_talent_development_program_form_widgets.dart';
import 'incoming_talent_promotion_implementation_fields.dart';

/// Form for tracking implementation work after promotion decisions.
class IncomingTalentPromotionImplementationForm extends ConsumerStatefulWidget {
  const IncomingTalentPromotionImplementationForm({super.key});

  @override
  ConsumerState<IncomingTalentPromotionImplementationForm> createState() =>
      _IncomingTalentPromotionImplementationFormState();
}

class _IncomingTalentPromotionImplementationFormState
    extends ConsumerState<IncomingTalentPromotionImplementationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _approverController;
  late final TextEditingController _systemController;
  late final TextEditingController _stepController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _blockerController;
  String? _selectedDecisionId;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentPromotionImplementationDraftProvider);
    _selectedDecisionId = draft.decisionId.isEmpty ? null : draft.decisionId;
    _ownerController = TextEditingController(text: draft.ownerName);
    _approverController = TextEditingController(text: draft.approverName);
    _systemController = TextEditingController(text: draft.systemOfRecord);
    _stepController = TextEditingController(text: draft.implementationStep);
    _evidenceController = TextEditingController(text: draft.evidenceNote);
    _blockerController = TextEditingController(text: draft.blockerNote);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _approverController.dispose();
    _systemController.dispose();
    _stepController.dispose();
    _evidenceController.dispose();
    _blockerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decisions = ref.watch(promotionImplementationReadyDecisionsProvider);
    final draft = ref.watch(incomingTalentPromotionImplementationDraftProvider);

    syncIncomingTalentDevelopmentProgramController(
      _ownerController,
      draft.ownerName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _approverController,
      draft.approverName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _systemController,
      draft.systemOfRecord,
    );
    syncIncomingTalentDevelopmentProgramController(
      _stepController,
      draft.implementationStep,
    );
    syncIncomingTalentDevelopmentProgramController(
      _evidenceController,
      draft.evidenceNote,
    );
    syncIncomingTalentDevelopmentProgramController(
      _blockerController,
      draft.blockerNote,
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentPromotionImplementationDecisionPicker(
            decisions: decisions,
            selectedDecisionId: _selectedDecisionId,
            onDecisionChanged: _selectDecision,
          ),
          const SizedBox(height: 12),
          if (decisions.isEmpty)
            const HrisListSurface(
              child: Text(
                'Approve, route, or defer promotion decisions before implementation.',
              ),
            )
          else ...[
            IncomingTalentDevelopmentProgramResponsiveRow(
              children: [
                IncomingTalentDevelopmentProgramTextInput(
                  controller: _ownerController,
                  label: 'Owner',
                  icon: Icons.supervisor_account_outlined,
                  onChanged:
                      ref
                          .read(
                            incomingTalentPromotionImplementationDraftProvider
                                .notifier,
                          )
                          .setOwnerName,
                  validator:
                      (value) =>
                          validateIncomingTalentPromotionImplementationRequired(
                            value,
                            'an owner',
                          ),
                ),
                IncomingTalentDevelopmentProgramTextInput(
                  controller: _approverController,
                  label: 'Approver',
                  icon: Icons.verified_user_outlined,
                  onChanged:
                      ref
                          .read(
                            incomingTalentPromotionImplementationDraftProvider
                                .notifier,
                          )
                          .setApproverName,
                  validator:
                      (value) =>
                          validateIncomingTalentPromotionImplementationRequired(
                            value,
                            'an approver',
                          ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            IncomingTalentPromotionImplementationClassificationFields(
              draft: draft,
              onActionChanged:
                  ref
                      .read(
                        incomingTalentPromotionImplementationDraftProvider
                            .notifier,
                      )
                      .setAction,
              onStatusChanged:
                  ref
                      .read(
                        incomingTalentPromotionImplementationDraftProvider
                            .notifier,
                      )
                      .setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentPromotionImplementationDateFields(
              draft: draft,
              onSelectDueDate: _selectDueDate,
              onSelectCompletedDate: _selectCompletedDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _systemController,
              label: 'System of record',
              icon: Icons.storage_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentPromotionImplementationDraftProvider
                            .notifier,
                      )
                      .setSystemOfRecord,
              validator:
                  (value) =>
                      validateIncomingTalentPromotionImplementationRequired(
                        value,
                        'a system of record',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _stepController,
              label: 'Implementation step',
              icon: Icons.task_alt_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentPromotionImplementationDraftProvider
                            .notifier,
                      )
                      .setImplementationStep,
              validator:
                  (value) =>
                      validateIncomingTalentPromotionImplementationLongText(
                        value,
                        'implementation step',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _evidenceController,
              label: 'Evidence note',
              icon: Icons.fact_check_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentPromotionImplementationDraftProvider
                            .notifier,
                      )
                      .setEvidenceNote,
              validator:
                  (value) =>
                      validateIncomingTalentPromotionImplementationLongText(
                        value,
                        'evidence note',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _blockerController,
              label: 'Blocker note',
              icon: Icons.shield_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentPromotionImplementationDraftProvider
                            .notifier,
                      )
                      .setBlockerNote,
              validator:
                  (value) =>
                      validateIncomingTalentPromotionImplementationLongText(
                        value,
                        'blocker note',
                      ),
            ),
            const SizedBox(height: 10),
            IncomingTalentPromotionImplementationFormActions(
              completionRatio: draft.completionRatio,
              canSubmit: draft.isReadyToSubmit,
              onClear: _clear,
              onSubmit: _submitImplementation,
            ),
          ],
        ],
      ),
    );
  }

  void _selectDecision(String? value) {
    setState(() => _selectedDecisionId = value);
    if (value == null) return;

    final decisions = ref.read(promotionImplementationReadyDecisionsProvider);
    final decision = decisions.firstWhere((item) => item.id == value);
    ref
        .read(incomingTalentPromotionImplementationDraftProvider.notifier)
        .initializeFromDecision(decision);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(incomingTalentPromotionImplementationDraftProvider);
    final picked = await _pickDate(
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
    );
    if (picked == null) return;
    ref
        .read(incomingTalentPromotionImplementationDraftProvider.notifier)
        .setDueDate(picked);
  }

  Future<void> _selectCompletedDate() async {
    final draft = ref.read(incomingTalentPromotionImplementationDraftProvider);
    final picked = await _pickDate(
      initialDate: draft.completedDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
    );
    if (picked == null) return;
    ref
        .read(incomingTalentPromotionImplementationDraftProvider.notifier)
        .setCompletedDate(picked);
  }

  Future<DateTime?> _pickDate({
    required DateTime initialDate,
    required DateTime firstDate,
  }) {
    final draft = ref.read(incomingTalentPromotionImplementationDraftProvider);
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
  }

  void _submitImplementation() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentPromotionImplementationDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final implementation = ref
          .read(incomingTalentPromotionImplementationsProvider.notifier)
          .submitDraft(draft);
      _clear();
      _showMessage(
        '${implementation.id} saved for ${implementation.candidateName}',
      );
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _clear() {
    ref
        .read(incomingTalentPromotionImplementationDraftProvider.notifier)
        .clear();
    setState(() => _selectedDecisionId = null);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

@Preview(name: 'Talent promotion implementation form')
Widget incomingTalentPromotionImplementationFormPreview() {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentPromotionImplementationForm(),
        ),
      ),
    ),
  );
}
