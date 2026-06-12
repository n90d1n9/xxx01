import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_panel_decision_provider.dart';
import 'incoming_talent_succession_panel_decision_form_fields.dart';

class IncomingTalentSuccessionPanelDecisionForm extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionPanelDecisionForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionPanelDecisionForm> createState() =>
      _IncomingTalentSuccessionPanelDecisionFormState();
}

class _IncomingTalentSuccessionPanelDecisionFormState
    extends ConsumerState<IncomingTalentSuccessionPanelDecisionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _panelLeadController;
  late final TextEditingController _ownerController;
  late final TextEditingController _summaryController;
  late final TextEditingController _conditionsController;
  late final TextEditingController _commitmentController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentSuccessionPanelDecisionDraftProvider);
    _panelLeadController = TextEditingController(text: draft.panelLeadName);
    _ownerController = TextEditingController(text: draft.followUpOwner);
    _summaryController = TextEditingController(text: draft.decisionSummary);
    _conditionsController = TextEditingController(text: draft.conditions);
    _commitmentController = TextEditingController(
      text: draft.sponsorCommitment,
    );
  }

  @override
  void dispose() {
    _panelLeadController.dispose();
    _ownerController.dispose();
    _summaryController.dispose();
    _conditionsController.dispose();
    _commitmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentSuccessionPanelDecisionDraftProvider);
    final nominations = ref.watch(panelReadySuccessionNominationsProvider);

    _sync(_panelLeadController, draft.panelLeadName);
    _sync(_ownerController, draft.followUpOwner);
    _sync(_summaryController, draft.decisionSummary);
    _sync(_conditionsController, draft.conditions);
    _sync(_commitmentController, draft.sponsorCommitment);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('succession-panel-${draft.nominationId}'),
            initialValue:
                _nominationExists(nominations, draft.nominationId)
                    ? draft.nominationId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Nomination',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.how_to_reg_outlined),
            ),
            items:
                nominations
                    .map(
                      (nomination) => DropdownMenuItem(
                        value: nomination.id,
                        child: Text(
                          '${nomination.candidateName} - ${nomination.nominationType.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: nominations.isEmpty ? null : _selectNomination,
            validator:
                (value) =>
                    IncomingTalentSuccessionPanelDecisionDraft.validateRequired(
                      value,
                      'a succession nomination',
                    ),
          ),
          const SizedBox(height: 12),
          if (nominations.isEmpty)
            const HrisListSurface(
              child: Text('No succession nominations are ready for panel.'),
            )
          else ...[
            IncomingTalentSuccessionPanelDecisionTextInput(
              controller: _panelLeadController,
              label: 'Panel lead',
              icon: Icons.groups_2_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionPanelDecisionDraftProvider
                            .notifier,
                      )
                      .setPanelLeadName,
              validator:
                  (value) =>
                      IncomingTalentSuccessionPanelDecisionDraft.validateRequired(
                        value,
                        'a panel lead',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionPanelDecisionTextInput(
              controller: _ownerController,
              label: 'Follow-up owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionPanelDecisionDraftProvider
                            .notifier,
                      )
                      .setFollowUpOwner,
              validator:
                  (value) =>
                      IncomingTalentSuccessionPanelDecisionDraft.validateRequired(
                        value,
                        'a follow-up owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionPanelOutcomeField(
              draft: draft,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionPanelDecisionDraftProvider
                            .notifier,
                      )
                      .setOutcome,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionPanelDecisionDateFields(
              draft: draft,
              onSelectDecisionDate: _selectDecisionDate,
              onSelectActivationDate: _selectActivationDate,
              onSelectNextReviewDate: _selectNextReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionPanelDecisionTextInput(
              controller: _summaryController,
              label: 'Decision summary',
              icon: Icons.article_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionPanelDecisionDraftProvider
                            .notifier,
                      )
                      .setDecisionSummary,
              validator:
                  IncomingTalentSuccessionPanelDecisionDraft
                      .validateDecisionSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionPanelDecisionTextInput(
              controller: _conditionsController,
              label: 'Conditions',
              icon: Icons.rule_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionPanelDecisionDraftProvider
                            .notifier,
                      )
                      .setConditions,
              validator:
                  (value) =>
                      IncomingTalentSuccessionPanelDecisionDraft.validateConditions(
                        value,
                        draft.outcome,
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionPanelDecisionTextInput(
              controller: _commitmentController,
              label: 'Sponsor commitment',
              icon: Icons.handshake_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionPanelDecisionDraftProvider
                            .notifier,
                      )
                      .setSponsorCommitment,
              validator:
                  IncomingTalentSuccessionPanelDecisionDraft
                      .validateSponsorCommitment,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionPanelDecisionDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentSuccessionPanelDecisionDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key('incoming-talent-panel-decision-submit'),
                  onPressed: draft.isReadyToSubmit ? _submitDecision : null,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Submit decision'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectNomination(String? nominationId) {
    if (nominationId == null) return;
    final nominations = ref.read(panelReadySuccessionNominationsProvider);
    final nomination = nominations.firstWhere(
      (item) => item.id == nominationId,
    );
    ref
        .read(incomingTalentSuccessionPanelDecisionDraftProvider.notifier)
        .initializeFromNomination(nomination);
  }

  Future<void> _selectDecisionDate() async {
    final draft = ref.read(incomingTalentSuccessionPanelDecisionDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.decisionDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionPanelDecisionDraftProvider.notifier)
        .setDecisionDate(picked);
  }

  Future<void> _selectActivationDate() async {
    final draft = ref.read(incomingTalentSuccessionPanelDecisionDraftProvider);
    final decisionDate = draft.decisionDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.activationDate ?? decisionDate.add(const Duration(days: 30)),
      firstDate: decisionDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionPanelDecisionDraftProvider.notifier)
        .setActivationDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(incomingTalentSuccessionPanelDecisionDraftProvider);
    final decisionDate = draft.decisionDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.nextReviewDate ?? decisionDate.add(const Duration(days: 90)),
      firstDate: decisionDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionPanelDecisionDraftProvider.notifier)
        .setNextReviewDate(picked);
  }

  void _submitDecision() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentSuccessionPanelDecisionDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final decision = ref
          .read(incomingTalentSuccessionPanelDecisionsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentSuccessionPanelDecisionDraftProvider.notifier)
          .clear();
      _showMessage('${decision.id} submitted for ${decision.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _nominationExists(
    List<IncomingTalentSuccessionNomination> nominations,
    String nominationId,
  ) {
    return nominations.any((nomination) => nomination.id == nominationId);
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
