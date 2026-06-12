import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_mobility_first_review_provider.dart';
import 'incoming_talent_mobility_first_review_form_actions.dart';
import 'incoming_talent_mobility_first_review_form_fields.dart';
import 'incoming_talent_mobility_first_review_picker.dart';

class IncomingTalentMobilityFirstReviewForm extends ConsumerStatefulWidget {
  final List<IncomingTalentMobilityLaunchChecklist> checklists;

  const IncomingTalentMobilityFirstReviewForm({
    super.key,
    required this.checklists,
  });

  @override
  ConsumerState<IncomingTalentMobilityFirstReviewForm> createState() =>
      _IncomingTalentMobilityFirstReviewFormState();
}

class _IncomingTalentMobilityFirstReviewFormState
    extends ConsumerState<IncomingTalentMobilityFirstReviewForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _deliveryController;
  late final TextEditingController _blockerController;
  late final TextEditingController _nextActionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentMobilityFirstReviewDraftProvider);
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _deliveryController = TextEditingController(text: draft.deliverySignal);
    _blockerController = TextEditingController(text: draft.blockerNote);
    _nextActionController = TextEditingController(text: draft.nextAction);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _deliveryController.dispose();
    _blockerController.dispose();
    _nextActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentMobilityFirstReviewDraftProvider);
    final notifier = ref.read(
      incomingTalentMobilityFirstReviewDraftProvider.notifier,
    );

    _sync(_reviewerController, draft.reviewerName);
    _sync(_deliveryController, draft.deliverySignal);
    _sync(_blockerController, draft.blockerNote);
    _sync(_nextActionController, draft.nextAction);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentMobilityFirstReviewPicker(
            draft: draft,
            checklists: widget.checklists,
            onChanged: _selectChecklist,
          ),
          const SizedBox(height: 12),
          if (widget.checklists.isEmpty)
            const HrisListSurface(
              child: Text('No launched mobility moves need first review.'),
            )
          else ...[
            IncomingTalentMobilityFirstReviewTextInput(
              controller: _reviewerController,
              label: 'Reviewer',
              icon: Icons.badge_outlined,
              onChanged: notifier.setReviewerName,
              validator:
                  (value) =>
                      IncomingTalentMobilityFirstReviewDraft.validateRequired(
                        value,
                        'a reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityFirstReviewDateFields(
              draft: draft,
              onSelectReviewDate: _selectReviewDate,
              onSelectFollowUpDate: _selectFollowUpDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityFirstReviewSignalFields(
              draft: draft,
              onOutcomeChanged: notifier.setOutcome,
              onConfidenceChanged: notifier.setHostConfidenceScore,
              onRetentionRiskChanged: notifier.setRetentionRisk,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityFirstReviewTextInput(
              controller: _deliveryController,
              label: 'Delivery signal',
              icon: Icons.insights_outlined,
              minLines: 3,
              onChanged: notifier.setDeliverySignal,
              validator:
                  IncomingTalentMobilityFirstReviewDraft.validateDeliverySignal,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityFirstReviewTextInput(
              controller: _blockerController,
              label: 'Blocker note',
              icon: Icons.warning_amber_outlined,
              minLines: 3,
              onChanged: notifier.setBlockerNote,
              validator: _validateBlockerNote,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityFirstReviewTextInput(
              controller: _nextActionController,
              label: 'Next action',
              icon: Icons.route_outlined,
              minLines: 3,
              onChanged: notifier.setNextAction,
              validator:
                  IncomingTalentMobilityFirstReviewDraft.validateNextAction,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityFirstReviewDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            IncomingTalentMobilityFirstReviewFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear: notifier.clear,
              onSubmit: _submitReview,
            ),
          ],
        ],
      ),
    );
  }

  void _selectChecklist(String? checklistId) {
    if (checklistId == null) return;
    final checklist = widget.checklists.firstWhere(
      (item) => item.id == checklistId,
    );
    ref
        .read(incomingTalentMobilityFirstReviewDraftProvider.notifier)
        .initializeFromChecklist(checklist);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(incomingTalentMobilityFirstReviewDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.reviewDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentMobilityFirstReviewDraftProvider.notifier)
        .setReviewDate(picked);
  }

  Future<void> _selectFollowUpDate() async {
    final draft = ref.read(incomingTalentMobilityFirstReviewDraftProvider);
    final reviewDate = draft.reviewDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.followUpDate ?? reviewDate.add(const Duration(days: 30)),
      firstDate: reviewDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentMobilityFirstReviewDraftProvider.notifier)
        .setFollowUpDate(picked);
  }

  void _submitReview() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentMobilityFirstReviewDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final review = ref
          .read(incomingTalentMobilityFirstReviewsProvider.notifier)
          .submitDraft(draft);
      ref.read(incomingTalentMobilityFirstReviewDraftProvider.notifier).clear();
      _showMessage('${review.id} submitted for ${review.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  String? _validateBlockerNote(String? value) {
    final draft = ref.read(incomingTalentMobilityFirstReviewDraftProvider);
    return IncomingTalentMobilityFirstReviewDraft.validateBlockerNote(
      value,
      draft.outcome,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
