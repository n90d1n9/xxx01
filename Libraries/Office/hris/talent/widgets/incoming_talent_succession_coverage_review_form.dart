import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_coverage_review_provider.dart';
import 'incoming_talent_succession_coverage_review_form_fields.dart';
import 'incoming_talent_succession_coverage_review_snapshot.dart';

class IncomingTalentSuccessionCoverageReviewForm
    extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionCoverageReviewForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionCoverageReviewForm> createState() =>
      _IncomingTalentSuccessionCoverageReviewFormState();
}

class _IncomingTalentSuccessionCoverageReviewFormState
    extends ConsumerState<IncomingTalentSuccessionCoverageReviewForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _summaryController;
  late final TextEditingController _commitmentController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentSuccessionCoverageReviewDraftProvider);
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _summaryController = TextEditingController(text: draft.reviewSummary);
    _commitmentController = TextEditingController(
      text: draft.executiveCommitment,
    );
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _summaryController.dispose();
    _commitmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentSuccessionCoverageReviewDraftProvider,
    );

    _sync(_reviewerController, draft.reviewerName);
    _sync(_summaryController, draft.reviewSummary);
    _sync(_commitmentController, draft.executiveCommitment);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          HrisListSurface(
            child: IncomingTalentSuccessionCoverageReviewSnapshot(draft: draft),
          ),
          const SizedBox(height: 12),
          IncomingTalentSuccessionCoverageReviewTextInput(
            controller: _reviewerController,
            label: 'Executive reviewer',
            icon: Icons.badge_outlined,
            onChanged:
                ref
                    .read(
                      incomingTalentSuccessionCoverageReviewDraftProvider
                          .notifier,
                    )
                    .setReviewerName,
            validator:
                (value) =>
                    IncomingTalentSuccessionCoverageReviewDraft.validateRequired(
                      value,
                      'a reviewer',
                    ),
          ),
          const SizedBox(height: 12),
          IncomingTalentSuccessionCoverageReviewDateFields(
            draft: draft,
            onSelectReviewDate: _selectReviewDate,
            onSelectNextReviewDate: _selectNextReviewDate,
          ),
          const SizedBox(height: 12),
          IncomingTalentSuccessionCoverageReviewDecisionField(
            draft: draft,
            onChanged:
                ref
                    .read(
                      incomingTalentSuccessionCoverageReviewDraftProvider
                          .notifier,
                    )
                    .setDecision,
          ),
          const SizedBox(height: 12),
          IncomingTalentSuccessionCoverageReviewTextInput(
            controller: _summaryController,
            label: 'Review summary',
            icon: Icons.summarize_outlined,
            minLines: 3,
            onChanged:
                ref
                    .read(
                      incomingTalentSuccessionCoverageReviewDraftProvider
                          .notifier,
                    )
                    .setReviewSummary,
            validator:
                IncomingTalentSuccessionCoverageReviewDraft
                    .validateReviewSummary,
          ),
          const SizedBox(height: 12),
          IncomingTalentSuccessionCoverageReviewTextInput(
            controller: _commitmentController,
            label: 'Executive commitment',
            icon: Icons.handshake_outlined,
            minLines: 3,
            onChanged:
                ref
                    .read(
                      incomingTalentSuccessionCoverageReviewDraftProvider
                          .notifier,
                    )
                    .setExecutiveCommitment,
            validator:
                IncomingTalentSuccessionCoverageReviewDraft
                    .validateExecutiveCommitment,
          ),
          const SizedBox(height: 12),
          IncomingTalentSuccessionCoverageReviewDraftReadiness(draft: draft),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed:
                    ref
                        .read(
                          incomingTalentSuccessionCoverageReviewDraftProvider
                              .notifier,
                        )
                        .refreshSnapshot,
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Refresh'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed:
                    ref
                        .read(
                          incomingTalentSuccessionCoverageReviewDraftProvider
                              .notifier,
                        )
                        .clear,
                child: const Text('Clear'),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                key: const Key('incoming-talent-succession-coverage-submit'),
                onPressed: draft.isReadyToSubmit ? _submitReview : null,
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Submit review'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(incomingTalentSuccessionCoverageReviewDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.reviewDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionCoverageReviewDraftProvider.notifier)
        .setReviewDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(incomingTalentSuccessionCoverageReviewDraftProvider);
    final reviewDate = draft.reviewDate ?? draft.asOfDate;
    final firstDate = reviewDate.add(const Duration(days: 1));
    final initialDate =
        draft.nextReviewDate != null &&
                draft.nextReviewDate!.isAfter(reviewDate)
            ? draft.nextReviewDate!
            : firstDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionCoverageReviewDraftProvider.notifier)
        .setNextReviewDate(picked);
  }

  void _submitReview() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentSuccessionCoverageReviewDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final review = ref
          .read(incomingTalentSuccessionCoverageReviewsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentSuccessionCoverageReviewDraftProvider.notifier)
          .refreshSnapshot();
      _showMessage('${review.id} submitted for ${review.scopeLabel}');
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
