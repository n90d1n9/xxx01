import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_mobility_match_provider.dart';
import 'incoming_talent_mobility_decision_picker.dart';
import 'incoming_talent_mobility_form_actions.dart';
import 'incoming_talent_mobility_form_fields.dart';
import 'incoming_talent_mobility_owner_fields.dart';

class IncomingTalentMobilityForm extends ConsumerStatefulWidget {
  final List<IncomingTalentSuccessionPanelDecision> decisions;

  const IncomingTalentMobilityForm({super.key, required this.decisions});

  @override
  ConsumerState<IncomingTalentMobilityForm> createState() =>
      _IncomingTalentMobilityFormState();
}

class _IncomingTalentMobilityFormState
    extends ConsumerState<IncomingTalentMobilityForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _opportunityController;
  late final TextEditingController _hostDepartmentController;
  late final TextEditingController _sponsorController;
  late final TextEditingController _ownerController;
  late final TextEditingController _rationaleController;
  late final TextEditingController _successController;
  late final TextEditingController _supportController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentMobilityMatchDraftProvider);
    _opportunityController = TextEditingController(
      text: draft.opportunityTitle,
    );
    _hostDepartmentController = TextEditingController(
      text: draft.hostDepartment,
    );
    _sponsorController = TextEditingController(text: draft.sponsorName);
    _ownerController = TextEditingController(text: draft.mobilityOwnerName);
    _rationaleController = TextEditingController(text: draft.businessRationale);
    _successController = TextEditingController(text: draft.successMeasure);
    _supportController = TextEditingController(text: draft.supportPlan);
  }

  @override
  void dispose() {
    _opportunityController.dispose();
    _hostDepartmentController.dispose();
    _sponsorController.dispose();
    _ownerController.dispose();
    _rationaleController.dispose();
    _successController.dispose();
    _supportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentMobilityMatchDraftProvider);
    final notifier = ref.read(
      incomingTalentMobilityMatchDraftProvider.notifier,
    );

    _sync(_opportunityController, draft.opportunityTitle);
    _sync(_hostDepartmentController, draft.hostDepartment);
    _sync(_sponsorController, draft.sponsorName);
    _sync(_ownerController, draft.mobilityOwnerName);
    _sync(_rationaleController, draft.businessRationale);
    _sync(_successController, draft.successMeasure);
    _sync(_supportController, draft.supportPlan);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentMobilityDecisionPicker(
            draft: draft,
            decisions: widget.decisions,
            onChanged: _selectDecision,
          ),
          const SizedBox(height: 12),
          if (widget.decisions.isEmpty)
            const HrisListSurface(
              child: Text(
                'No approved panel decisions need mobility matching.',
              ),
            )
          else ...[
            IncomingTalentMobilityTextInput(
              controller: _opportunityController,
              label: 'Opportunity title',
              icon: Icons.work_outline,
              onChanged: notifier.setOpportunityTitle,
              validator:
                  (value) => validateIncomingTalentMobilityRequired(
                    value,
                    'an opportunity title',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityTextInput(
              controller: _hostDepartmentController,
              label: 'Host department',
              icon: Icons.apartment_outlined,
              onChanged: notifier.setHostDepartment,
              validator:
                  (value) => validateIncomingTalentMobilityRequired(
                    value,
                    'a host department',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityOwnerFields(
              sponsorController: _sponsorController,
              ownerController: _ownerController,
              onSponsorChanged: notifier.setSponsorName,
              onOwnerChanged: notifier.setMobilityOwnerName,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityTypeAndStatusFields(
              draft: draft,
              onMoveTypeChanged: notifier.setMoveType,
              onStatusChanged: notifier.setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityDateFields(
              draft: draft,
              onSelectStartDate: _selectStartDate,
              onSelectReviewDate: _selectReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityFitField(
              draft: draft,
              onChanged: (value) => notifier.setFitScore(value.round()),
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityTextInput(
              controller: _rationaleController,
              label: 'Business rationale',
              icon: Icons.psychology_alt_outlined,
              minLines: 3,
              onChanged: notifier.setBusinessRationale,
              validator:
                  (value) => incomingTalentMobilityLongTextError(
                    value,
                    'business rationale',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityTextInput(
              controller: _successController,
              label: 'Success measure',
              icon: Icons.flag_circle_outlined,
              minLines: 2,
              onChanged: notifier.setSuccessMeasure,
              validator:
                  (value) => incomingTalentMobilityLongTextError(
                    value,
                    'success measure',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityTextInput(
              controller: _supportController,
              label: 'Support plan',
              icon: Icons.handshake_outlined,
              minLines: 2,
              onChanged: notifier.setSupportPlan,
              validator:
                  (value) => incomingTalentMobilityLongTextError(
                    value,
                    'support plan',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            IncomingTalentMobilityFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear: notifier.clear,
              onSubmit: _submitMatch,
            ),
          ],
        ],
      ),
    );
  }

  void _selectDecision(String? decisionId) {
    if (decisionId == null) return;
    final decision = widget.decisions.firstWhere(
      (item) => item.id == decisionId,
    );
    ref
        .read(incomingTalentMobilityMatchDraftProvider.notifier)
        .initializeFromDecision(decision);
  }

  Future<void> _selectStartDate() async {
    final draft = ref.read(incomingTalentMobilityMatchDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.startDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentMobilityMatchDraftProvider.notifier)
        .setStartDate(picked);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(incomingTalentMobilityMatchDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.reviewDate ?? draft.asOfDate,
      firstDate: draft.startDate ?? draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentMobilityMatchDraftProvider.notifier)
        .setReviewDate(picked);
  }

  void _submitMatch() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentMobilityMatchDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final match = ref
          .read(incomingTalentMobilityMatchesProvider.notifier)
          .submitDraft(draft);
      ref.read(incomingTalentMobilityMatchDraftProvider.notifier).clear();
      _showMessage('${match.id} created for ${match.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
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
