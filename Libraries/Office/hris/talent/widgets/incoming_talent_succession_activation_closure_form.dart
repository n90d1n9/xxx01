import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_activation_closure_provider.dart';
import 'incoming_talent_succession_activation_closure_form_fields.dart';

class IncomingTalentSuccessionActivationClosureForm
    extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionActivationClosureForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionActivationClosureForm> createState() =>
      _IncomingTalentSuccessionActivationClosureFormState();
}

class _IncomingTalentSuccessionActivationClosureFormState
    extends ConsumerState<IncomingTalentSuccessionActivationClosureForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _handoverController;
  late final TextEditingController _hrPartnerController;
  late final TextEditingController _communicationController;
  late final TextEditingController _accessController;
  late final TextEditingController _compensationController;
  late final TextEditingController _governanceController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentSuccessionActivationClosureDraftProvider,
    );
    _ownerController = TextEditingController(text: draft.ownerName);
    _handoverController = TextEditingController(text: draft.handoverOwner);
    _hrPartnerController = TextEditingController(text: draft.hrPartnerName);
    _communicationController = TextEditingController(
      text: draft.communicationPlan,
    );
    _accessController = TextEditingController(text: draft.accessReadiness);
    _compensationController = TextEditingController(
      text: draft.compensationNote,
    );
    _governanceController = TextEditingController(text: draft.governanceNote);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _handoverController.dispose();
    _hrPartnerController.dispose();
    _communicationController.dispose();
    _accessController.dispose();
    _compensationController.dispose();
    _governanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentSuccessionActivationClosureDraftProvider,
    );
    final reviews = ref.watch(
      closureReadySuccessionActivationResolutionReviewsProvider,
    );

    _sync(_ownerController, draft.ownerName);
    _sync(_handoverController, draft.handoverOwner);
    _sync(_hrPartnerController, draft.hrPartnerName);
    _sync(_communicationController, draft.communicationPlan);
    _sync(_accessController, draft.accessReadiness);
    _sync(_compensationController, draft.compensationNote);
    _sync(_governanceController, draft.governanceNote);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('succession-closure-${draft.resolutionReviewId}'),
            initialValue:
                _reviewExists(reviews, draft.resolutionReviewId)
                    ? draft.resolutionReviewId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Cleared resolution review',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.verified_outlined),
            ),
            items:
                reviews
                    .map(
                      (review) => DropdownMenuItem(
                        value: review.id,
                        child: Text(
                          '${review.candidateName} - ${review.outcome.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: reviews.isEmpty ? null : _selectReview,
            validator:
                (value) =>
                    IncomingTalentSuccessionActivationClosureDraft.validateRequired(
                      value,
                      'a cleared resolution review',
                    ),
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            const HrisListSurface(
              child: Text('No cleared resolution reviews are ready to close.'),
            )
          else ...[
            IncomingTalentSuccessionActivationClosureTextInput(
              controller: _ownerController,
              label: 'Closure owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationClosureDraftProvider
                            .notifier,
                      )
                      .setOwnerName,
              validator:
                  (value) =>
                      IncomingTalentSuccessionActivationClosureDraft.validateRequired(
                        value,
                        'a closure owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationClosureControlFields(
              draft: draft,
              onTypeChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationClosureDraftProvider
                            .notifier,
                      )
                      .setClosureType,
              onStatusChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationClosureDraftProvider
                            .notifier,
                      )
                      .setStatus,
              onSelectEffectiveDate: _selectEffectiveDate,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final handover = IncomingTalentSuccessionActivationClosureTextInput(
                  controller: _handoverController,
                  label: 'Handover owner',
                  icon: Icons.switch_account_outlined,
                  onChanged:
                      ref
                          .read(
                            incomingTalentSuccessionActivationClosureDraftProvider
                                .notifier,
                          )
                          .setHandoverOwner,
                  validator:
                      (value) =>
                          IncomingTalentSuccessionActivationClosureDraft.validateRequired(
                            value,
                            'a handover owner',
                          ),
                );
                final hrPartner = IncomingTalentSuccessionActivationClosureTextInput(
                  controller: _hrPartnerController,
                  label: 'HR partner',
                  icon: Icons.support_agent_outlined,
                  onChanged:
                      ref
                          .read(
                            incomingTalentSuccessionActivationClosureDraftProvider
                                .notifier,
                          )
                          .setHrPartnerName,
                  validator:
                      (value) =>
                          IncomingTalentSuccessionActivationClosureDraft.validateRequired(
                            value,
                            'an HR partner',
                          ),
                );
                if (constraints.maxWidth < 620) {
                  return Column(
                    children: [handover, const SizedBox(height: 12), hrPartner],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: handover),
                    const SizedBox(width: 12),
                    Expanded(child: hrPartner),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationClosureTextInput(
              controller: _communicationController,
              label: 'Communication plan',
              icon: Icons.campaign_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationClosureDraftProvider
                            .notifier,
                      )
                      .setCommunicationPlan,
              validator:
                  IncomingTalentSuccessionActivationClosureDraft
                      .validateCommunicationPlan,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationClosureTextInput(
              controller: _accessController,
              label: 'Access readiness',
              icon: Icons.vpn_key_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationClosureDraftProvider
                            .notifier,
                      )
                      .setAccessReadiness,
              validator:
                  IncomingTalentSuccessionActivationClosureDraft
                      .validateAccessReadiness,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationClosureTextInput(
              controller: _compensationController,
              label: 'Compensation note',
              icon: Icons.payments_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationClosureDraftProvider
                            .notifier,
                      )
                      .setCompensationNote,
              validator:
                  IncomingTalentSuccessionActivationClosureDraft
                      .validateCompensationNote,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationClosureTextInput(
              controller: _governanceController,
              label: 'Governance note',
              icon: Icons.rule_folder_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionActivationClosureDraftProvider
                            .notifier,
                      )
                      .setGovernanceNote,
              validator:
                  IncomingTalentSuccessionActivationClosureDraft
                      .validateGovernanceNote,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionActivationClosureDraftReadiness(
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
                            incomingTalentSuccessionActivationClosureDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key('incoming-talent-succession-closure-submit'),
                  onPressed: draft.isReadyToSubmit ? _submitClosure : null,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Create closure'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectReview(String? reviewId) {
    if (reviewId == null) return;
    final reviews = ref.read(
      closureReadySuccessionActivationResolutionReviewsProvider,
    );
    final review = reviews.firstWhere((item) => item.id == reviewId);
    ref
        .read(incomingTalentSuccessionActivationClosureDraftProvider.notifier)
        .initializeFromReview(review);
  }

  Future<void> _selectEffectiveDate() async {
    final draft = ref.read(
      incomingTalentSuccessionActivationClosureDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.effectiveDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionActivationClosureDraftProvider.notifier)
        .setEffectiveDate(picked);
  }

  void _submitClosure() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentSuccessionActivationClosureDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final closure = ref
          .read(incomingTalentSuccessionActivationClosuresProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentSuccessionActivationClosureDraftProvider.notifier)
          .clear();
      _showMessage('${closure.id} created for ${closure.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _reviewExists(
    List<IncomingTalentSuccessionActivationResolutionReview> reviews,
    String reviewId,
  ) {
    return reviews.any((review) => review.id == reviewId);
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
