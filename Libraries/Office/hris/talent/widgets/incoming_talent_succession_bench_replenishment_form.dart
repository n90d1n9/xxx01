import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_bench_replenishment_provider.dart';
import 'incoming_talent_succession_bench_replenishment_form_fields.dart';

class IncomingTalentSuccessionBenchReplenishmentForm
    extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionBenchReplenishmentForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionBenchReplenishmentForm> createState() =>
      _IncomingTalentSuccessionBenchReplenishmentFormState();
}

class _IncomingTalentSuccessionBenchReplenishmentFormState
    extends ConsumerState<IncomingTalentSuccessionBenchReplenishmentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _gapController;
  late final TextEditingController _strategyController;
  late final TextEditingController _trackController;
  late final TextEditingController _cadenceController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentSuccessionBenchReplenishmentDraftProvider,
    );
    _ownerController = TextEditingController(text: draft.ownerName);
    _gapController = TextEditingController(text: draft.benchGap);
    _strategyController = TextEditingController(text: draft.sourcingStrategy);
    _trackController = TextEditingController(text: draft.developmentTrack);
    _cadenceController = TextEditingController(text: draft.reviewCadence);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _gapController.dispose();
    _strategyController.dispose();
    _trackController.dispose();
    _cadenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentSuccessionBenchReplenishmentDraftProvider,
    );
    final reviews = ref.watch(
      benchReadySuccessionTransitionOutcomeReviewsProvider,
    );

    _sync(_ownerController, draft.ownerName);
    _sync(_gapController, draft.benchGap);
    _sync(_strategyController, draft.sourcingStrategy);
    _sync(_trackController, draft.developmentTrack);
    _sync(_cadenceController, draft.reviewCadence);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('succession-bench-${draft.outcomeReviewId}'),
            initialValue:
                _reviewExists(reviews, draft.outcomeReviewId)
                    ? draft.outcomeReviewId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Transition outcome',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.insights_outlined),
            ),
            items:
                reviews
                    .map(
                      (review) => DropdownMenuItem(
                        value: review.id,
                        child: Text(
                          '${review.candidateName} - ${review.decision.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: reviews.isEmpty ? null : _selectReview,
            validator:
                (value) =>
                    IncomingTalentSuccessionBenchReplenishmentDraft.validateRequired(
                      value,
                      'a transition outcome',
                    ),
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            const HrisListSurface(
              child: Text(
                'No transition outcomes are ready for bench replenishment.',
              ),
            )
          else ...[
            IncomingTalentSuccessionBenchReplenishmentTextInput(
              controller: _ownerController,
              label: 'Replenishment owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchReplenishmentDraftProvider
                            .notifier,
                      )
                      .setOwnerName,
              validator:
                  (value) =>
                      IncomingTalentSuccessionBenchReplenishmentDraft.validateRequired(
                        value,
                        'a replenishment owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchReplenishmentControlFields(
              draft: draft,
              onPriorityChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchReplenishmentDraftProvider
                            .notifier,
                      )
                      .setPriority,
              onSelectTargetReadyDate: _selectTargetReadyDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchReplenishmentTextInput(
              controller: _gapController,
              label: 'Bench gap',
              icon: Icons.account_tree_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchReplenishmentDraftProvider
                            .notifier,
                      )
                      .setBenchGap,
              validator:
                  IncomingTalentSuccessionBenchReplenishmentDraft
                      .validateBenchGap,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchReplenishmentTextInput(
              controller: _strategyController,
              label: 'Sourcing strategy',
              icon: Icons.manage_search_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchReplenishmentDraftProvider
                            .notifier,
                      )
                      .setSourcingStrategy,
              validator:
                  IncomingTalentSuccessionBenchReplenishmentDraft
                      .validateSourcingStrategy,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchReplenishmentTextInput(
              controller: _trackController,
              label: 'Development track',
              icon: Icons.school_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchReplenishmentDraftProvider
                            .notifier,
                      )
                      .setDevelopmentTrack,
              validator:
                  IncomingTalentSuccessionBenchReplenishmentDraft
                      .validateDevelopmentTrack,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchReplenishmentTextInput(
              controller: _cadenceController,
              label: 'Review cadence',
              icon: Icons.update_outlined,
              minLines: 2,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchReplenishmentDraftProvider
                            .notifier,
                      )
                      .setReviewCadence,
              validator:
                  IncomingTalentSuccessionBenchReplenishmentDraft
                      .validateReviewCadence,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchReplenishmentDraftReadiness(
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
                            incomingTalentSuccessionBenchReplenishmentDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key(
                    'incoming-talent-succession-bench-replenishment-submit',
                  ),
                  onPressed: draft.isReadyToSubmit ? _submitPlan : null,
                  icon: const Icon(Icons.account_tree_outlined),
                  label: const Text('Create plan'),
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
      benchReadySuccessionTransitionOutcomeReviewsProvider,
    );
    final review = reviews.firstWhere((item) => item.id == reviewId);
    ref
        .read(incomingTalentSuccessionBenchReplenishmentDraftProvider.notifier)
        .initializeFromOutcomeReview(review);
  }

  Future<void> _selectTargetReadyDate() async {
    final draft = ref.read(
      incomingTalentSuccessionBenchReplenishmentDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.targetReadyDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionBenchReplenishmentDraftProvider.notifier)
        .setTargetReadyDate(picked);
  }

  void _submitPlan() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentSuccessionBenchReplenishmentDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final plan = ref
          .read(incomingTalentSuccessionBenchReplenishmentsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(
            incomingTalentSuccessionBenchReplenishmentDraftProvider.notifier,
          )
          .clear();
      _showMessage('${plan.id} created for ${plan.department}');
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
    List<IncomingTalentSuccessionTransitionOutcomeReview> reviews,
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
