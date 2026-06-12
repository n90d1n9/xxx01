import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_ramp_action_models.dart';
import '../models/candidate_ramp_models.dart';
import '../states/candidate_ramp_action_provider.dart';
import 'candidate_ramp_action_form_fields.dart';
import 'candidate_ramp_action_summary_tile.dart';
import 'candidate_ramp_action_tile.dart';

class CandidateRampActionPanel extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final List<CandidateRampPlan> plans;

  const CandidateRampActionPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.plans,
  });

  @override
  ConsumerState<CandidateRampActionPanel> createState() =>
      _CandidateRampActionPanelState();
}

class _CandidateRampActionPanelState
    extends ConsumerState<CandidateRampActionPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _mentorController;
  late final TextEditingController _learningController;
  late final TextEditingController _ownerController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(candidateRampActionDraftProvider);
    _mentorController = TextEditingController(text: draft.mentorName);
    _learningController = TextEditingController(text: draft.learningPlanTitle);
    _ownerController = TextEditingController(text: draft.ownerName);
    _notesController = TextEditingController(text: draft.notes);
  }

  @override
  void dispose() {
    _mentorController.dispose();
    _learningController.dispose();
    _ownerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(candidateRampActionDraftProvider);
    final actions = ref.watch(candidateRampActionsProvider);
    final summary = ref.watch(candidateRampActionSummaryProvider);

    _sync(_mentorController, draft.mentorName);
    _sync(_learningController, draft.learningPlanTitle);
    _sync(_ownerController, draft.ownerName);
    _sync(_notesController, draft.notes);

    return HrisSectionPanel(
      icon: Icons.assignment_turned_in_outlined,
      title: widget.title,
      subtitle: widget.subtitle,
      children: [
        CandidateRampActionSummaryTile(summary: summary),
        Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey('candidate-${draft.candidateId}'),
                initialValue:
                    _planExists(draft.candidateId) ? draft.candidateId : null,
                decoration: const InputDecoration(
                  labelText: 'Candidate plan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_search_outlined),
                ),
                items:
                    widget.plans
                        .map(
                          (plan) => DropdownMenuItem(
                            value: plan.id,
                            child: Text('${plan.candidateName} - ${plan.role}'),
                          ),
                        )
                        .toList(),
                onChanged: _selectPlan,
                validator:
                    (value) => CandidateRampActionDraft.validateRequired(
                      value,
                      'a candidate',
                    ),
              ),
              const SizedBox(height: 12),
              CandidateRampActionTextInput(
                controller: _mentorController,
                label: 'Mentor',
                icon: Icons.supervisor_account_outlined,
                onChanged:
                    ref
                        .read(candidateRampActionDraftProvider.notifier)
                        .setMentorName,
                validator:
                    (value) => CandidateRampActionDraft.validateRequired(
                      value,
                      'a mentor',
                    ),
              ),
              const SizedBox(height: 12),
              CandidateRampActionTextInput(
                controller: _learningController,
                label: 'Learning plan',
                icon: Icons.school_outlined,
                onChanged:
                    ref
                        .read(candidateRampActionDraftProvider.notifier)
                        .setLearningPlanTitle,
                validator:
                    (value) => CandidateRampActionDraft.validateRequired(
                      value,
                      'a learning plan',
                    ),
              ),
              const SizedBox(height: 12),
              CandidateRampActionTextInput(
                controller: _ownerController,
                label: 'Plan owner',
                icon: Icons.badge_outlined,
                onChanged:
                    ref
                        .read(candidateRampActionDraftProvider.notifier)
                        .setOwnerName,
                validator:
                    (value) => CandidateRampActionDraft.validateRequired(
                      value,
                      'an owner',
                    ),
              ),
              const SizedBox(height: 12),
              CandidateRampActionDateFields(
                draft: draft,
                onSelectKickoff: _selectKickoffDate,
                onSelectReadiness: _selectReadinessDate,
              ),
              const SizedBox(height: 12),
              CandidateRampActionTextInput(
                controller: _notesController,
                label: 'Ramp notes',
                icon: Icons.notes_outlined,
                minLines: 3,
                onChanged:
                    ref
                        .read(candidateRampActionDraftProvider.notifier)
                        .setNotes,
                validator: CandidateRampActionDraft.validateNotes,
              ),
              const SizedBox(height: 12),
              CandidateRampActionDraftReadiness(draft: draft),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        ref
                            .read(candidateRampActionDraftProvider.notifier)
                            .clear,
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    key: const Key('candidate-ramp-action-submit'),
                    onPressed: draft.isReadyToSubmit ? _submitAction : null,
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Submit ramp plan'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (actions.isEmpty)
          const HrisListSurface(child: Text('No submitted ramp actions yet.'))
        else
          for (final action in actions)
            CandidateRampSubmittedActionTile(action: action),
      ],
    );
  }

  void _selectPlan(String? planId) {
    if (planId == null) return;
    final plan = widget.plans.firstWhere((item) => item.id == planId);
    ref
        .read(candidateRampActionDraftProvider.notifier)
        .initializeFromPlan(plan);
  }

  Future<void> _selectKickoffDate() async {
    final draft = ref.read(candidateRampActionDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.kickoffDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref.read(candidateRampActionDraftProvider.notifier).setKickoffDate(picked);
  }

  Future<void> _selectReadinessDate() async {
    final draft = ref.read(candidateRampActionDraftProvider);
    final firstDate = draft.kickoffDate ?? draft.asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.readinessDate ?? firstDate.add(const Duration(days: 30)),
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(candidateRampActionDraftProvider.notifier)
        .setReadinessDate(picked);
  }

  void _submitAction() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(candidateRampActionDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    final action = ref
        .read(candidateRampActionsProvider.notifier)
        .submitDraft(draft);
    ref.read(candidateRampActionDraftProvider.notifier).clear();
    _showMessage('${action.id} submitted for ${action.candidateName}');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool _planExists(String planId) {
    return widget.plans.any((plan) => plan.id == planId);
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}
