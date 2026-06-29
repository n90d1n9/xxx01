import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_activation_resolution_review_provider.dart';
import 'incoming_talent_succession_activation_resolution_review_form_fields.dart';

class IncomingTalentSuccessionActivationResolutionReviewForm
    extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionActivationResolutionReviewForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionActivationResolutionReviewForm>
  createState() =>
      _IncomingTalentSuccessionActivationResolutionReviewFormState();
}

class _IncomingTalentSuccessionActivationResolutionReviewFormState
    extends
        ConsumerState<IncomingTalentSuccessionActivationResolutionReviewForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _sponsorController;
  late final TextEditingController _nextStepController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentSuccessionActivationResolutionReviewDraftProvider,
    );
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _evidenceController = TextEditingController(text: draft.evidenceSummary);
    _sponsorController = TextEditingController(text: draft.sponsorConfirmation);
    _nextStepController = TextEditingController(text: draft.nextGovernanceStep);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _evidenceController.dispose();
    _sponsorController.dispose();
    _nextStepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentSuccessionActivationResolutionReviewDraftProvider,
    );
    final escalations = ref.watch(
      resolutionReadySuccessionActivationEscalationsProvider,
    );

    _sync(_reviewerController, draft.reviewerName);
    _sync(_evidenceController, draft.evidenceSummary);
    _sync(_sponsorController, draft.sponsorConfirmation);
    _sync(_nextStepController, draft.nextGovernanceStep);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('succession-resolution-${draft.escalationId}'),
            initialValue:
                _escalationExists(escalations, draft.escalationId)
                    ? draft.escalationId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Resolved escalation',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.fact_check_outlined),
            ),
            items:
                escalations
                    .map(
                      (escalation) => DropdownMenuItem(
                        value: escalation.id,
                        child: Text(
                          '${escalation.candidateName} - ${escalation.priority.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: escalations.isEmpty ? null : _selectEscalation,
            validator:
                (value) =>
                    IncomingTalentSuccessionActivationResolutionReviewDraft.validateRequired(
                      value,
                      'a resolved escalation',
                    ),
          ),
          const SizedBox(height: 12),
          if (escalations.isEmpty)
            const HrisListSurface(
              child: Text('No resolved escalations are ready for review.'),
            )
          else ...[
            IncomingTalentSuccessionActivationResolutionReviewTextInput(
              controller: _reviewerController,
              label: 'Review owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationResolutionReviewDraftProvider
                            .notifier,
                      )
                      .setReviewerName,
              validator:
                  (value) =>
                      IncomingTalentSuccessionActivationResolutionReviewDraft.validateRequired(
                        value,
                        'a reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationResolutionReviewDateFields(
              draft: draft,
              onSelectResolutionDate: _selectResolutionDate,
              onSelectNextReviewDate: _selectNextReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationResolutionReviewSignalFields(
              draft: draft,
              onOutcomeChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationResolutionReviewDraftProvider
                            .notifier,
                      )
                      .setOutcome,
              onRiskChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationResolutionReviewDraftProvider
                            .notifier,
                      )
                      .setResidualRisk,
              onConfidenceChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationResolutionReviewDraftProvider
                            .notifier,
                      )
                      .setFinalConfidenceScore,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationResolutionReviewTextInput(
              controller: _evidenceController,
              label: 'Evidence summary',
              icon: Icons.description_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationResolutionReviewDraftProvider
                            .notifier,
                      )
                      .setEvidenceSummary,
              validator:
                  IncomingTalentSuccessionActivationResolutionReviewDraft
                      .validateEvidenceSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationResolutionReviewTextInput(
              controller: _sponsorController,
              label: 'Sponsor confirmation',
              icon: Icons.handshake_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationResolutionReviewDraftProvider
                            .notifier,
                      )
                      .setSponsorConfirmation,
              validator:
                  IncomingTalentSuccessionActivationResolutionReviewDraft
                      .validateSponsorConfirmation,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationResolutionReviewTextInput(
              controller: _nextStepController,
              label: 'Next governance step',
              icon: Icons.route_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationResolutionReviewDraftProvider
                            .notifier,
                      )
                      .setNextGovernanceStep,
              validator:
                  IncomingTalentSuccessionActivationResolutionReviewDraft
                      .validateNextGovernanceStep,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationResolutionReviewDraftReadiness(
              draft: draft,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentSuccessionActivationResolutionReviewDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key(
                    'incoming-talent-succession-resolution-submit',
                  ),
                  onPressed: draft.isReadyToSubmit ? _submitReview : null,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Submit review'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectEscalation(String? escalationId) {
    if (escalationId == null) return;
    final escalations = ref.read(
      resolutionReadySuccessionActivationEscalationsProvider,
    );
    final escalation = escalations.firstWhere(
      (item) => item.id == escalationId,
    );
    ref
        .read(
          incomingTalentSuccessionActivationResolutionReviewDraftProvider
              .notifier,
        )
        .initializeFromEscalation(escalation);
  }

  Future<void> _selectResolutionDate() async {
    final draft = ref.read(
      incomingTalentSuccessionActivationResolutionReviewDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.resolutionDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(
          incomingTalentSuccessionActivationResolutionReviewDraftProvider
              .notifier,
        )
        .setResolutionDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(
      incomingTalentSuccessionActivationResolutionReviewDraftProvider,
    );
    final resolutionDate = draft.resolutionDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.nextReviewDate ?? resolutionDate.add(const Duration(days: 30)),
      firstDate: resolutionDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(
          incomingTalentSuccessionActivationResolutionReviewDraftProvider
              .notifier,
        )
        .setNextReviewDate(picked);
  }

  void _submitReview() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentSuccessionActivationResolutionReviewDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final review = ref
          .read(
            incomingTalentSuccessionActivationResolutionReviewsProvider
                .notifier,
          )
          .submitDraft(draft);
      ref
          .read(
            incomingTalentSuccessionActivationResolutionReviewDraftProvider
                .notifier,
          )
          .clear();
      _showMessage('${review.id} submitted for ${review.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _escalationExists(
    List<IncomingTalentSuccessionActivationEscalation> escalations,
    String escalationId,
  ) {
    return escalations.any((escalation) => escalation.id == escalationId);
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
