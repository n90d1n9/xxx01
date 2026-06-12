import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_mobility_stabilization_action_provider.dart';
import 'incoming_talent_mobility_stabilization_form_actions.dart';
import 'incoming_talent_mobility_stabilization_form_fields.dart';
import 'incoming_talent_mobility_stabilization_review_picker.dart';

class IncomingTalentMobilityStabilizationForm extends ConsumerStatefulWidget {
  final List<IncomingTalentMobilityFirstReview> reviews;

  const IncomingTalentMobilityStabilizationForm({
    super.key,
    required this.reviews,
  });

  @override
  ConsumerState<IncomingTalentMobilityStabilizationForm> createState() =>
      _IncomingTalentMobilityStabilizationFormState();
}

class _IncomingTalentMobilityStabilizationFormState
    extends ConsumerState<IncomingTalentMobilityStabilizationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _summaryController;
  late final TextEditingController _measureController;
  late final TextEditingController _blockerController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(
      incomingTalentMobilityStabilizationActionDraftProvider,
    );
    _ownerController = TextEditingController(text: draft.ownerName);
    _summaryController = TextEditingController(text: draft.actionSummary);
    _measureController = TextEditingController(text: draft.successMeasure);
    _blockerController = TextEditingController(text: draft.blockerNote);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _summaryController.dispose();
    _measureController.dispose();
    _blockerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      incomingTalentMobilityStabilizationActionDraftProvider,
    );
    final notifier = ref.read(
      incomingTalentMobilityStabilizationActionDraftProvider.notifier,
    );

    _sync(_ownerController, draft.ownerName);
    _sync(_summaryController, draft.actionSummary);
    _sync(_measureController, draft.successMeasure);
    _sync(_blockerController, draft.blockerNote);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentMobilityStabilizationReviewPicker(
            draft: draft,
            reviews: widget.reviews,
            onChanged: _selectReview,
          ),
          const SizedBox(height: 12),
          if (widget.reviews.isEmpty)
            const HrisListSurface(
              child: Text('No risky mobility first reviews need action.'),
            )
          else ...[
            IncomingTalentMobilityStabilizationTextInput(
              controller: _ownerController,
              label: 'Action owner',
              icon: Icons.badge_outlined,
              onChanged: notifier.setOwnerName,
              validator:
                  (value) =>
                      IncomingTalentMobilityStabilizationActionDraft.validateRequired(
                        value,
                        'an action owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityStabilizationActionFields(
              draft: draft,
              onActionTypeChanged: notifier.setActionType,
              onStatusChanged: notifier.setStatus,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityStabilizationDueDateField(
              draft: draft,
              onSelectDueDate: _selectDueDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityStabilizationTextInput(
              controller: _summaryController,
              label: 'Action summary',
              icon: Icons.add_task_outlined,
              minLines: 3,
              onChanged: notifier.setActionSummary,
              validator:
                  IncomingTalentMobilityStabilizationActionDraft
                      .validateActionSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityStabilizationTextInput(
              controller: _measureController,
              label: 'Success measure',
              icon: Icons.flag_circle_outlined,
              minLines: 3,
              onChanged: notifier.setSuccessMeasure,
              validator:
                  IncomingTalentMobilityStabilizationActionDraft
                      .validateSuccessMeasure,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityStabilizationTextInput(
              controller: _blockerController,
              label: 'Blocker note',
              icon: Icons.warning_amber_outlined,
              minLines: 3,
              onChanged: notifier.setBlockerNote,
              validator: _validateBlockerNote,
            ),
            const SizedBox(height: 12),
            IncomingTalentMobilityStabilizationDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            IncomingTalentMobilityStabilizationFormActions(
              canSubmit: draft.isReadyToSubmit,
              onClear: notifier.clear,
              onSubmit: _submitAction,
            ),
          ],
        ],
      ),
    );
  }

  void _selectReview(String? reviewId) {
    if (reviewId == null) return;
    final review = widget.reviews.firstWhere((item) => item.id == reviewId);
    ref
        .read(incomingTalentMobilityStabilizationActionDraftProvider.notifier)
        .initializeFromReview(review);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(
      incomingTalentMobilityStabilizationActionDraftProvider,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentMobilityStabilizationActionDraftProvider.notifier)
        .setDueDate(picked);
  }

  void _submitAction() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(
      incomingTalentMobilityStabilizationActionDraftProvider,
    );
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final action = ref
          .read(incomingTalentMobilityStabilizationActionsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentMobilityStabilizationActionDraftProvider.notifier)
          .clear();
      _showMessage('${action.id} created for ${action.candidateName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  String? _validateBlockerNote(String? value) {
    final draft = ref.read(
      incomingTalentMobilityStabilizationActionDraftProvider,
    );
    return IncomingTalentMobilityStabilizationActionDraft.validateBlockerNote(
      value,
      draft.status,
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
