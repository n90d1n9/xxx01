import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_coverage_council_decision_provider.dart';
import 'incoming_talent_succession_coverage_council_decision_agenda_picker.dart';
import 'incoming_talent_succession_coverage_council_decision_controls.dart';
import 'incoming_talent_succession_coverage_council_decision_date_fields.dart';
import 'incoming_talent_succession_coverage_council_decision_form_actions.dart';
import 'incoming_talent_succession_coverage_council_decision_form_fields.dart';
import 'incoming_talent_succession_coverage_council_decision_readiness.dart';

class IncomingTalentSuccessionCoverageCouncilDecisionForm
    extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionCoverageCouncilDecisionForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionCoverageCouncilDecisionForm>
  createState() => _IncomingTalentSuccessionCoverageCouncilDecisionFormState();
}

class _IncomingTalentSuccessionCoverageCouncilDecisionFormState
    extends ConsumerState<IncomingTalentSuccessionCoverageCouncilDecisionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _decisionMakerController;
  late final TextEditingController _sponsorController;
  late final TextEditingController _commitmentController;
  late final TextEditingController _minutesController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentSuccessionCoverageCouncilDecisionDraftProvider,
    );
    _decisionMakerController = TextEditingController(
      text: draft.decisionMakerName,
    );
    _sponsorController = TextEditingController(
      text: draft.executiveSponsorName,
    );
    _commitmentController = TextEditingController(
      text: draft.commitmentSummary,
    );
    _minutesController = TextEditingController(text: draft.minutesNote);
  }

  @override
  void dispose() {
    _decisionMakerController.dispose();
    _sponsorController.dispose();
    _commitmentController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentSuccessionCoverageCouncilDecisionDraftProvider,
    );
    final agendaItems = ref.watch(
      decisionReadyCoverageCouncilAgendaItemsProvider,
    );

    _sync(_decisionMakerController, draft.decisionMakerName);
    _sync(_sponsorController, draft.executiveSponsorName);
    _sync(_commitmentController, draft.commitmentSummary);
    _sync(_minutesController, draft.minutesNote);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentSuccessionCoverageCouncilDecisionAgendaPicker(
            draft: draft,
            items: agendaItems,
            onChanged: _selectAgendaItem,
          ),
          const SizedBox(height: 12),
          if (agendaItems.isEmpty)
            const HrisListSurface(
              child: Text('No coverage council agenda items need decisions.'),
            )
          else ...[
            IncomingTalentSuccessionCoverageCouncilDecisionTextInput(
              controller: _decisionMakerController,
              label: 'Decision maker',
              icon: Icons.groups_2_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageCouncilDecisionDraftProvider
                            .notifier,
                      )
                      .setDecisionMakerName,
              validator:
                  (value) => validateCoverageCouncilDecisionRequired(
                    value,
                    'a decision maker',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageCouncilDecisionTextInput(
              controller: _sponsorController,
              label: 'Executive sponsor',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageCouncilDecisionDraftProvider
                            .notifier,
                      )
                      .setExecutiveSponsorName,
              validator:
                  (value) => validateCoverageCouncilDecisionRequired(
                    value,
                    'an executive sponsor',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageCouncilDecisionOutcomeField(
              draft: draft,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageCouncilDecisionDraftProvider
                            .notifier,
                      )
                      .setOutcome,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageCouncilDecisionDateFields(
              draft: draft,
              onSelectDecisionDate: _selectDecisionDate,
              onSelectFollowUpDate: _selectFollowUpDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageCouncilDecisionTextInput(
              controller: _commitmentController,
              label: 'Commitment summary',
              icon: Icons.handshake_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageCouncilDecisionDraftProvider
                            .notifier,
                      )
                      .setCommitmentSummary,
              validator:
                  (value) => coverageCouncilDecisionLongTextError(
                    value,
                    'commitment summary',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageCouncilDecisionTextInput(
              controller: _minutesController,
              label: 'Minutes note',
              icon: Icons.article_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageCouncilDecisionDraftProvider
                            .notifier,
                      )
                      .setMinutesNote,
              validator:
                  (value) => coverageCouncilDecisionLongTextError(
                    value,
                    'minutes note',
                  ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionCoverageCouncilDecisionDraftReadiness(
              draft: draft,
            ),
            const SizedBox(height: 14),
            IncomingTalentSuccessionCoverageCouncilDecisionFormActions(
              draft: draft,
              onClear:
                  ref
                      .read(
                        incomingTalentSuccessionCoverageCouncilDecisionDraftProvider
                            .notifier,
                      )
                      .clear,
              onSubmit: _submitDecision,
            ),
          ],
        ],
      ),
    );
  }

  void _selectAgendaItem(String? agendaItemId) {
    if (agendaItemId == null) return;
    final items = ref.read(decisionReadyCoverageCouncilAgendaItemsProvider);
    final item = items.firstWhere((entry) => entry.id == agendaItemId);
    ref
        .read(
          incomingTalentSuccessionCoverageCouncilDecisionDraftProvider.notifier,
        )
        .initializeFromAgendaItem(item);
  }

  Future<void> _selectDecisionDate() async {
    final draft = ref.read(
      incomingTalentSuccessionCoverageCouncilDecisionDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.decisionDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(
          incomingTalentSuccessionCoverageCouncilDecisionDraftProvider.notifier,
        )
        .setDecisionDate(picked);
  }

  Future<void> _selectFollowUpDate() async {
    final draft = ref.read(
      incomingTalentSuccessionCoverageCouncilDecisionDraftProvider,
    );
    final decisionDate = draft.decisionDate ?? draft.asOfDate;
    final firstDate = decisionDate.add(const Duration(days: 1));
    final initialDate =
        draft.followUpDate != null && draft.followUpDate!.isAfter(decisionDate)
            ? draft.followUpDate!
            : firstDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(
          incomingTalentSuccessionCoverageCouncilDecisionDraftProvider.notifier,
        )
        .setFollowUpDate(picked);
  }

  void _submitDecision() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentSuccessionCoverageCouncilDecisionDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final decision = ref
          .read(
            incomingTalentSuccessionCoverageCouncilDecisionsProvider.notifier,
          )
          .submitDraft(draft);
      ref
          .read(
            incomingTalentSuccessionCoverageCouncilDecisionDraftProvider
                .notifier,
          )
          .clear();
      _showMessage('${decision.id} recorded for ${decision.scopeLabel}');
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
