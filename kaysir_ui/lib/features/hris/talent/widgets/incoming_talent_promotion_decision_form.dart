import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_decision_models.dart';
import '../states/incoming_talent_promotion_decision_provider.dart';
import 'incoming_talent_development_program_form_widgets.dart';
import 'incoming_talent_promotion_decision_fields.dart';

/// Form for capturing final promotion panel decisions.
class IncomingTalentPromotionDecisionForm extends ConsumerStatefulWidget {
  const IncomingTalentPromotionDecisionForm({super.key});

  @override
  ConsumerState<IncomingTalentPromotionDecisionForm> createState() =>
      _IncomingTalentPromotionDecisionFormState();
}

class _IncomingTalentPromotionDecisionFormState
    extends ConsumerState<IncomingTalentPromotionDecisionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _approverController;
  late final TextEditingController _newRoleController;
  late final TextEditingController _compensationController;
  late final TextEditingController _implementationController;
  late final TextEditingController _riskController;
  String? _selectedReadinessId;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentPromotionDecisionDraftProvider);
    _selectedReadinessId = draft.readinessId.isEmpty ? null : draft.readinessId;
    _ownerController = TextEditingController(text: draft.ownerName);
    _approverController = TextEditingController(text: draft.approverName);
    _newRoleController = TextEditingController(text: draft.newRole);
    _compensationController = TextEditingController(
      text: draft.compensationBandNote,
    );
    _implementationController = TextEditingController(
      text: draft.implementationNote,
    );
    _riskController = TextEditingController(text: draft.riskControlNote);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _approverController.dispose();
    _newRoleController.dispose();
    _compensationController.dispose();
    _implementationController.dispose();
    _riskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packets = ref.watch(promotionDecisionReadyReadinessProvider);
    final draft = ref.watch(incomingTalentPromotionDecisionDraftProvider);

    syncIncomingTalentDevelopmentProgramController(
      _ownerController,
      draft.ownerName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _approverController,
      draft.approverName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _newRoleController,
      draft.newRole,
    );
    syncIncomingTalentDevelopmentProgramController(
      _compensationController,
      draft.compensationBandNote,
    );
    syncIncomingTalentDevelopmentProgramController(
      _implementationController,
      draft.implementationNote,
    );
    syncIncomingTalentDevelopmentProgramController(
      _riskController,
      draft.riskControlNote,
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentPromotionDecisionReadinessPicker(
            packets: packets,
            selectedReadinessId: _selectedReadinessId,
            onReadinessChanged: _selectReadiness,
          ),
          const SizedBox(height: 12),
          if (packets.isEmpty)
            const HrisListSurface(
              child: Text(
                'Endorse or calibrate promotion readiness before decisions.',
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
                            incomingTalentPromotionDecisionDraftProvider
                                .notifier,
                          )
                          .setOwnerName,
                  validator:
                      (value) =>
                          validateIncomingTalentPromotionDecisionRequired(
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
                            incomingTalentPromotionDecisionDraftProvider
                                .notifier,
                          )
                          .setApproverName,
                  validator:
                      (value) =>
                          validateIncomingTalentPromotionDecisionRequired(
                            value,
                            'an approver',
                          ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _newRoleController,
              label: 'New role',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentPromotionDecisionDraftProvider.notifier,
                      )
                      .setNewRole,
              validator:
                  (value) => validateIncomingTalentPromotionDecisionRequired(
                    value,
                    'a new role',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentPromotionDecisionClassificationFields(
              draft: draft,
              onOutcomeChanged:
                  ref
                      .read(
                        incomingTalentPromotionDecisionDraftProvider.notifier,
                      )
                      .setOutcome,
              onStatusChanged:
                  ref
                      .read(
                        incomingTalentPromotionDecisionDraftProvider.notifier,
                      )
                      .setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentPromotionDecisionDateFields(
              draft: draft,
              onSelectEffectiveDate: _selectEffectiveDate,
              onSelectFollowUpDate: _selectFollowUpDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _compensationController,
              label: 'Compensation note',
              icon: Icons.payments_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentPromotionDecisionDraftProvider.notifier,
                      )
                      .setCompensationBandNote,
              validator:
                  (value) => validateIncomingTalentPromotionDecisionLongText(
                    value,
                    'compensation note',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _implementationController,
              label: 'Implementation note',
              icon: Icons.task_alt_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentPromotionDecisionDraftProvider.notifier,
                      )
                      .setImplementationNote,
              validator:
                  (value) => validateIncomingTalentPromotionDecisionLongText(
                    value,
                    'implementation note',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentDevelopmentProgramTextInput(
              controller: _riskController,
              label: 'Risk control note',
              icon: Icons.shield_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentPromotionDecisionDraftProvider.notifier,
                      )
                      .setRiskControlNote,
              validator:
                  (value) => validateIncomingTalentPromotionDecisionLongText(
                    value,
                    'risk control note',
                  ),
            ),
            const SizedBox(height: 10),
            IncomingTalentPromotionDecisionFormActions(
              completionRatio: draft.completionRatio,
              canSubmit: draft.isReadyToSubmit,
              onClear: _clear,
              onSubmit: _submitDecision,
            ),
          ],
        ],
      ),
    );
  }

  void _selectReadiness(String? value) {
    setState(() => _selectedReadinessId = value);
    if (value == null) return;

    final packets = ref.read(promotionDecisionReadyReadinessProvider);
    final readiness = packets.firstWhere((item) => item.id == value);
    ref
        .read(incomingTalentPromotionDecisionDraftProvider.notifier)
        .initializeFromReadiness(readiness);
  }

  Future<void> _selectEffectiveDate() async {
    final draft = ref.read(incomingTalentPromotionDecisionDraftProvider);
    final picked = await _pickDate(
      initialDate: draft.effectiveDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
    );
    if (picked == null) return;
    ref
        .read(incomingTalentPromotionDecisionDraftProvider.notifier)
        .setEffectiveDate(picked);
  }

  Future<void> _selectFollowUpDate() async {
    final draft = ref.read(incomingTalentPromotionDecisionDraftProvider);
    final effectiveDate = draft.effectiveDate ?? draft.asOfDate;
    final picked = await _pickDate(
      initialDate:
          draft.followUpDate ?? effectiveDate.add(const Duration(days: 30)),
      firstDate: effectiveDate.add(const Duration(days: 1)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentPromotionDecisionDraftProvider.notifier)
        .setFollowUpDate(picked);
  }

  Future<DateTime?> _pickDate({
    required DateTime initialDate,
    required DateTime firstDate,
  }) {
    final draft = ref.read(incomingTalentPromotionDecisionDraftProvider);
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
  }

  void _submitDecision() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentPromotionDecisionDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final decision = ref
          .read(incomingTalentPromotionDecisionsProvider.notifier)
          .submitDraft(draft);
      _clear();
      _showMessage('${decision.id} saved for ${decision.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _clear() {
    ref.read(incomingTalentPromotionDecisionDraftProvider.notifier).clear();
    setState(() => _selectedReadinessId = null);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

@Preview(name: 'Talent promotion decision form')
Widget incomingTalentPromotionDecisionFormPreview() {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentPromotionDecisionForm(),
        ),
      ),
    ),
  );
}
