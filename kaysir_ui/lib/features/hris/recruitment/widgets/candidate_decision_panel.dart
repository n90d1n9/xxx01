import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_decision_models.dart';
import '../models/candidate_decision_review_draft.dart';
import '../models/candidate_decision_review_models.dart';
import '../states/candidate_decision_review_provider.dart';
import 'candidate_decision_form_fields.dart';
import 'candidate_decision_review_tile.dart';
import 'candidate_decision_summary_tile.dart';
import 'candidate_decision_tile.dart';

class CandidateDecisionPanel extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final List<CandidateDecisionPacket> packets;
  final CandidateDecisionSummary summary;
  final DateTime asOfDate;

  const CandidateDecisionPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.packets,
    required this.summary,
    required this.asOfDate,
  });

  @override
  ConsumerState<CandidateDecisionPanel> createState() =>
      _CandidateDecisionPanelState();
}

class _CandidateDecisionPanelState
    extends ConsumerState<CandidateDecisionPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _nextStepController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(candidateDecisionReviewDraftProvider);
    _ownerController = TextEditingController(text: draft.ownerName);
    _nextStepController = TextEditingController(text: draft.nextStep);
    _notesController = TextEditingController(text: draft.notes);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _nextStepController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(candidateDecisionReviewDraftProvider);
    final reviews = ref.watch(candidateDecisionReviewsProvider);
    final reviewSummary = ref.watch(candidateDecisionReviewSummaryProvider);

    _sync(_ownerController, draft.ownerName);
    _sync(_nextStepController, draft.nextStep);
    _sync(_notesController, draft.notes);

    return HrisSectionPanel(
      icon: Icons.assignment_turned_in_outlined,
      title: widget.title,
      subtitle: widget.subtitle,
      emptyMessage: 'No decision packets match filters',
      children: [
        CandidateDecisionSummaryTile(
          summary: widget.summary,
          reviewSummary: reviewSummary,
        ),
        Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey('candidate-decision-${draft.candidateId}'),
                initialValue:
                    _packetExists(draft.candidateId) ? draft.candidateId : null,
                decoration: const InputDecoration(
                  labelText: 'Decision packet',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_search_outlined),
                ),
                items:
                    widget.packets
                        .map(
                          (packet) => DropdownMenuItem(
                            value: packet.candidateId,
                            child: Text(
                              '${packet.candidateName} - ${packet.role}',
                            ),
                          ),
                        )
                        .toList(),
                onChanged: _selectPacket,
                validator: CandidateDecisionReviewDraft.validateCandidate,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CandidateDecisionOutcome>(
                key: ValueKey(
                  'candidate-decision-outcome-${draft.outcome?.name}',
                ),
                initialValue: draft.outcome,
                decoration: const InputDecoration(
                  labelText: 'Outcome',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.rule_folder_outlined),
                ),
                items:
                    CandidateDecisionOutcome.values
                        .map(
                          (outcome) => DropdownMenuItem(
                            value: outcome,
                            child: Text(outcome.label),
                          ),
                        )
                        .toList(),
                onChanged: _selectOutcome,
                validator: CandidateDecisionReviewDraft.validateOutcome,
              ),
              const SizedBox(height: 12),
              CandidateDecisionTextInput(
                controller: _ownerController,
                label: 'Decision owner',
                icon: Icons.badge_outlined,
                onChanged:
                    ref
                        .read(candidateDecisionReviewDraftProvider.notifier)
                        .setOwnerName,
                validator:
                    (value) => CandidateDecisionReviewDraft.validateRequired(
                      value,
                      'a decision owner',
                    ),
              ),
              const SizedBox(height: 12),
              CandidateDecisionDateField(
                draft: draft,
                onSelectDate: _selectDueDate,
              ),
              const SizedBox(height: 12),
              CandidateDecisionTextInput(
                controller: _nextStepController,
                label: 'Next step',
                icon: Icons.next_plan_outlined,
                onChanged:
                    ref
                        .read(candidateDecisionReviewDraftProvider.notifier)
                        .setNextStep,
                validator: CandidateDecisionReviewDraft.validateNextStep,
              ),
              const SizedBox(height: 12),
              CandidateDecisionTextInput(
                controller: _notesController,
                label: 'Decision notes',
                icon: Icons.notes_outlined,
                minLines: 3,
                onChanged:
                    ref
                        .read(candidateDecisionReviewDraftProvider.notifier)
                        .setNotes,
                validator: CandidateDecisionReviewDraft.validateNotes,
              ),
              const SizedBox(height: 12),
              CandidateDecisionDraftReadiness(draft: draft),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        ref
                            .read(candidateDecisionReviewDraftProvider.notifier)
                            .clear,
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    key: const Key('candidate-decision-review-submit'),
                    onPressed: draft.isReadyToSubmit ? _submitReview : null,
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Submit decision'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (reviews.isEmpty)
          const HrisListSurface(
            child: Text('No submitted decision reviews yet.'),
          )
        else
          for (final review in reviews)
            CandidateDecisionReviewTile(review: review),
        for (final packet in widget.packets)
          CandidateDecisionTile(
            packet: packet,
            asOfDate: widget.asOfDate,
            onReview: () => _selectPacket(packet.candidateId),
          ),
      ],
    );
  }

  void _selectPacket(String? candidateId) {
    if (candidateId == null) return;
    final packet = widget.packets.firstWhere(
      (item) => item.candidateId == candidateId,
    );
    ref
        .read(candidateDecisionReviewDraftProvider.notifier)
        .initializeFromPacket(packet);
  }

  void _selectOutcome(CandidateDecisionOutcome? outcome) {
    if (outcome == null) return;
    ref.read(candidateDecisionReviewDraftProvider.notifier).setOutcome(outcome);
  }

  Future<void> _selectDueDate() async {
    final draft = ref.read(candidateDecisionReviewDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref.read(candidateDecisionReviewDraftProvider.notifier).setDueDate(picked);
  }

  void _submitReview() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(candidateDecisionReviewDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    final review = ref
        .read(candidateDecisionReviewsProvider.notifier)
        .submitDraft(draft);
    ref.read(candidateDecisionReviewDraftProvider.notifier).clear();
    _showMessage('${review.id} submitted for ${review.candidateName}');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool _packetExists(String candidateId) {
    return widget.packets.any((packet) => packet.candidateId == candidateId);
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}
