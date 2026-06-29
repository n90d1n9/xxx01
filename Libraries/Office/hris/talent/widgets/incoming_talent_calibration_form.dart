import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_calibration_models.dart';
import '../states/incoming_talent_calibration_provider.dart';
import 'incoming_talent_calibration_form_fields.dart';

class IncomingTalentCalibrationForm extends ConsumerStatefulWidget {
  const IncomingTalentCalibrationForm({super.key});

  @override
  ConsumerState<IncomingTalentCalibrationForm> createState() =>
      _IncomingTalentCalibrationFormState();
}

class _IncomingTalentCalibrationFormState
    extends ConsumerState<IncomingTalentCalibrationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _trackController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _decisionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentCalibrationReviewDraftProvider);
    _reviewerController = TextEditingController(text: draft.reviewerName);
    _trackController = TextEditingController(text: draft.talentTrack);
    _evidenceController = TextEditingController(text: draft.evidenceSummary);
    _decisionController = TextEditingController(text: draft.decisionNote);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _trackController.dispose();
    _evidenceController.dispose();
    _decisionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentCalibrationReviewDraftProvider);
    final packets = ref.watch(calibrationReadyPacketsProvider);

    _sync(_reviewerController, draft.reviewerName);
    _sync(_trackController, draft.talentTrack);
    _sync(_evidenceController, draft.evidenceSummary);
    _sync(_decisionController, draft.decisionNote);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('calibration-${draft.packetId}'),
            initialValue:
                _packetExists(packets, draft.packetId) ? draft.packetId : null,
            decoration: const InputDecoration(
              labelText: 'Calibration packet',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.rule_outlined),
            ),
            items:
                packets
                    .map(
                      (packet) => DropdownMenuItem(
                        value: packet.id,
                        child: Text(
                          '${packet.candidateName} - ${packet.recommendation.label}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: packets.isEmpty ? null : _selectPacket,
            validator:
                (value) =>
                    IncomingTalentCalibrationReviewDraft.validateRequired(
                      value,
                      'a calibration packet',
                    ),
          ),
          const SizedBox(height: 12),
          if (packets.isEmpty)
            const HrisListSurface(
              child: Text('No calibration packets are ready for review.'),
            )
          else ...[
            IncomingTalentCalibrationTextInput(
              controller: _reviewerController,
              label: 'Reviewer',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentCalibrationReviewDraftProvider.notifier,
                      )
                      .setReviewerName,
              validator:
                  (value) =>
                      IncomingTalentCalibrationReviewDraft.validateRequired(
                        value,
                        'a reviewer',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentCalibrationDateFields(
              draft: draft,
              onSelectReviewDate: _selectReviewDate,
              onSelectNextReviewDate: _selectNextReviewDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentCalibrationDecisionFields(
              draft: draft,
              onDecisionChanged:
                  ref
                      .read(
                        incomingTalentCalibrationReviewDraftProvider.notifier,
                      )
                      .setDecision,
              onPotentialChanged:
                  ref
                      .read(
                        incomingTalentCalibrationReviewDraftProvider.notifier,
                      )
                      .setPotential,
            ),
            const SizedBox(height: 12),
            IncomingTalentCalibrationTextInput(
              controller: _trackController,
              label: 'Talent track',
              icon: Icons.route_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentCalibrationReviewDraftProvider.notifier,
                      )
                      .setTalentTrack,
              validator:
                  IncomingTalentCalibrationReviewDraft.validateTalentTrack,
            ),
            const SizedBox(height: 12),
            IncomingTalentCalibrationTextInput(
              controller: _evidenceController,
              label: 'Evidence summary',
              icon: Icons.article_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentCalibrationReviewDraftProvider.notifier,
                      )
                      .setEvidenceSummary,
              validator:
                  IncomingTalentCalibrationReviewDraft.validateEvidenceSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentCalibrationTextInput(
              controller: _decisionController,
              label: 'Decision note',
              icon: Icons.notes_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentCalibrationReviewDraftProvider.notifier,
                      )
                      .setDecisionNote,
              validator:
                  IncomingTalentCalibrationReviewDraft.validateDecisionNote,
            ),
            const SizedBox(height: 12),
            IncomingTalentCalibrationDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentCalibrationReviewDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key('incoming-talent-calibration-submit'),
                  onPressed: draft.isReadyToSubmit ? _submitReview : null,
                  icon: const Icon(Icons.rule_outlined),
                  label: const Text('Submit review'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectPacket(String? packetId) {
    if (packetId == null) return;
    final packets = ref.read(calibrationReadyPacketsProvider);
    final packet = packets.firstWhere((item) => item.id == packetId);
    ref
        .read(incomingTalentCalibrationReviewDraftProvider.notifier)
        .initializeFromPacket(packet);
  }

  Future<void> _selectReviewDate() async {
    final draft = ref.read(incomingTalentCalibrationReviewDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.reviewDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentCalibrationReviewDraftProvider.notifier)
        .setReviewDate(picked);
  }

  Future<void> _selectNextReviewDate() async {
    final draft = ref.read(incomingTalentCalibrationReviewDraftProvider);
    final reviewDate = draft.reviewDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.nextReviewDate ?? reviewDate.add(const Duration(days: 30)),
      firstDate: reviewDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentCalibrationReviewDraftProvider.notifier)
        .setNextReviewDate(picked);
  }

  void _submitReview() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentCalibrationReviewDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final review = ref
          .read(incomingTalentCalibrationReviewsProvider.notifier)
          .submitDraft(draft);
      ref.read(incomingTalentCalibrationReviewDraftProvider.notifier).clear();
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

  bool _packetExists(
    List<IncomingTalentCalibrationPacket> packets,
    String packetId,
  ) {
    return packets.any((packet) => packet.id == packetId);
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
