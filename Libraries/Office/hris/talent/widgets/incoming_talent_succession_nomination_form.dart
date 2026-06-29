import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_nomination_provider.dart';
import 'incoming_talent_succession_nomination_form_fields.dart';

class IncomingTalentSuccessionNominationForm extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionNominationForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionNominationForm> createState() =>
      _IncomingTalentSuccessionNominationFormState();
}

class _IncomingTalentSuccessionNominationFormState
    extends ConsumerState<IncomingTalentSuccessionNominationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _sponsorController;
  late final TextEditingController _panelController;
  late final TextEditingController _businessCaseController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _successPlanController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentSuccessionNominationDraftProvider);
    _sponsorController = TextEditingController(text: draft.sponsorName);
    _panelController = TextEditingController(text: draft.panelName);
    _businessCaseController = TextEditingController(text: draft.businessCase);
    _evidenceController = TextEditingController(text: draft.evidenceSummary);
    _successPlanController = TextEditingController(text: draft.successPlan);
  }

  @override
  void dispose() {
    _sponsorController.dispose();
    _panelController.dispose();
    _businessCaseController.dispose();
    _evidenceController.dispose();
    _successPlanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentSuccessionNominationDraftProvider);
    final candidates = ref.watch(nominationReadySuccessionCandidatesProvider);

    _sync(_sponsorController, draft.sponsorName);
    _sync(_panelController, draft.panelName);
    _sync(_businessCaseController, draft.businessCase);
    _sync(_evidenceController, draft.evidenceSummary);
    _sync(_successPlanController, draft.successPlan);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('succession-nomination-${draft.candidateId}'),
            initialValue:
                _candidateExists(candidates, draft.candidateId)
                    ? draft.candidateId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Succession candidate',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.workspace_premium_outlined),
            ),
            items:
                candidates
                    .map(
                      (candidate) => DropdownMenuItem(
                        value: candidate.candidateId,
                        child: Text(
                          '${candidate.candidateName} - ${candidate.readiness.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: candidates.isEmpty ? null : _selectCandidate,
            validator:
                (value) =>
                    IncomingTalentSuccessionNominationDraft.validateRequired(
                      value,
                      'a succession candidate',
                    ),
          ),
          const SizedBox(height: 12),
          if (candidates.isEmpty)
            const HrisListSurface(
              child: Text('No ready succession candidates available.'),
            )
          else ...[
            IncomingTalentSuccessionNominationTextInput(
              controller: _sponsorController,
              label: 'Sponsor',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionNominationDraftProvider
                            .notifier,
                      )
                      .setSponsorName,
              validator:
                  (value) =>
                      IncomingTalentSuccessionNominationDraft.validateRequired(
                        value,
                        'a sponsor',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionNominationTextInput(
              controller: _panelController,
              label: 'Panel',
              icon: Icons.groups_2_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionNominationDraftProvider
                            .notifier,
                      )
                      .setPanelName,
              validator:
                  (value) =>
                      IncomingTalentSuccessionNominationDraft.validateRequired(
                        value,
                        'a panel',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionNominationTypeFields(
              draft: draft,
              onTypeChanged:
                  ref
                      .read(
                        incomingTalentSuccessionNominationDraftProvider
                            .notifier,
                      )
                      .setNominationType,
              onStatusChanged:
                  ref
                      .read(
                        incomingTalentSuccessionNominationDraftProvider
                            .notifier,
                      )
                      .setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionNominationDateFields(
              draft: draft,
              onSelectNominationDate: _selectNominationDate,
              onSelectPanelDate: _selectPanelDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionNominationTextInput(
              controller: _businessCaseController,
              label: 'Business case',
              icon: Icons.article_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionNominationDraftProvider
                            .notifier,
                      )
                      .setBusinessCase,
              validator:
                  IncomingTalentSuccessionNominationDraft.validateBusinessCase,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionNominationTextInput(
              controller: _evidenceController,
              label: 'Evidence summary',
              icon: Icons.fact_check_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionNominationDraftProvider
                            .notifier,
                      )
                      .setEvidenceSummary,
              validator:
                  IncomingTalentSuccessionNominationDraft
                      .validateEvidenceSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionNominationTextInput(
              controller: _successPlanController,
              label: 'Success plan',
              icon: Icons.route_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionNominationDraftProvider
                            .notifier,
                      )
                      .setSuccessPlan,
              validator:
                  IncomingTalentSuccessionNominationDraft.validateSuccessPlan,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionNominationDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentSuccessionNominationDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key('incoming-talent-succession-submit'),
                  onPressed: draft.isReadyToSubmit ? _submitNomination : null,
                  icon: const Icon(Icons.workspace_premium_outlined),
                  label: const Text('Submit nomination'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectCandidate(String? candidateId) {
    if (candidateId == null) return;
    final candidates = ref.read(nominationReadySuccessionCandidatesProvider);
    final candidate = candidates.firstWhere(
      (item) => item.candidateId == candidateId,
    );
    ref
        .read(incomingTalentSuccessionNominationDraftProvider.notifier)
        .initializeFromCandidate(candidate);
  }

  Future<void> _selectNominationDate() async {
    final draft = ref.read(incomingTalentSuccessionNominationDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.nominationDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionNominationDraftProvider.notifier)
        .setNominationDate(picked);
  }

  Future<void> _selectPanelDate() async {
    final draft = ref.read(incomingTalentSuccessionNominationDraftProvider);
    final nominationDate = draft.nominationDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.panelDate ?? nominationDate.add(const Duration(days: 14)),
      firstDate: nominationDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionNominationDraftProvider.notifier)
        .setPanelDate(picked);
  }

  void _submitNomination() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentSuccessionNominationDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final nomination = ref
          .read(incomingTalentSuccessionNominationsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentSuccessionNominationDraftProvider.notifier)
          .clear();
      _showMessage(
        '${nomination.id} submitted for ${nomination.candidateName}',
      );
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _candidateExists(
    List<IncomingTalentSuccessionCandidate> candidates,
    String candidateId,
  ) {
    return candidates.any((candidate) => candidate.candidateId == candidateId);
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
