import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_skill_evidence_models.dart';
import '../models/candidate_skill_fit_models.dart';
import '../states/candidate_skill_fit_provider.dart';
import 'candidate_skill_evidence_readiness.dart';

class CandidateSkillEvidencePanel extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final List<CandidateSkillFitProfile> profiles;

  const CandidateSkillEvidencePanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.profiles,
  });

  @override
  ConsumerState<CandidateSkillEvidencePanel> createState() =>
      _CandidateSkillEvidencePanelState();
}

class _CandidateSkillEvidencePanelState
    extends ConsumerState<CandidateSkillEvidencePanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _evidenceController;

  @override
  void initState() {
    super.initState();
    _evidenceController = TextEditingController(
      text: ref.read(candidateSkillEvidenceDraftProvider).evidence,
    );
  }

  @override
  void dispose() {
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(candidateSkillEvidenceDraftProvider);
    final profile = _selectedProfile(draft.candidateId);
    final signals = profile?.signals ?? const <CandidateSkillFitSignal>[];
    final canSubmit =
        draft.isReady && profile != null && _signalExists(signals, draft.skill);

    _syncEvidence(draft.evidence);

    return HrisSectionPanel(
      icon: Icons.rate_review_outlined,
      title: widget.title,
      subtitle: widget.subtitle,
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey('candidate-evidence-${draft.candidateId}'),
                initialValue: profile == null ? null : draft.candidateId,
                decoration: const InputDecoration(
                  labelText: 'Candidate',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_search_outlined),
                ),
                items:
                    widget.profiles
                        .map(
                          (profile) => DropdownMenuItem(
                            value: profile.candidateId,
                            child: Text(
                              '${profile.candidateName} - ${profile.role}',
                            ),
                          ),
                        )
                        .toList(),
                onChanged: _selectCandidate,
                validator: CandidateSkillEvidenceDraft.validateCandidate,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(
                  'skill-evidence-${draft.candidateId}-${draft.skill}',
                ),
                initialValue:
                    _signalExists(signals, draft.skill) ? draft.skill : null,
                decoration: const InputDecoration(
                  labelText: 'Skill',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.psychology_alt_outlined),
                ),
                items:
                    signals
                        .map(
                          (signal) => DropdownMenuItem(
                            value: signal.skill,
                            child: Text(signal.skill),
                          ),
                        )
                        .toList(),
                onChanged:
                    profile == null
                        ? null
                        : (value) {
                          if (value != null) _selectSkill(profile, value);
                        },
                validator: CandidateSkillEvidenceDraft.validateSkill,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey('level-evidence-${draft.currentLevelText}'),
                initialValue:
                    CandidateSkillEvidenceDraft.validateLevel(
                              draft.currentLevelText,
                            ) ==
                            null
                        ? draft.currentLevelText
                        : null,
                decoration: const InputDecoration(
                  labelText: 'Current level',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.stacked_line_chart_outlined),
                ),
                items:
                    List.generate(6, (index) => '$index')
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text('Level $level'),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) => ref
                        .read(candidateSkillEvidenceDraftProvider.notifier)
                        .setCurrentLevel(value ?? ''),
                validator: CandidateSkillEvidenceDraft.validateLevel,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _evidenceController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Evidence notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                onChanged:
                    ref
                        .read(candidateSkillEvidenceDraftProvider.notifier)
                        .setEvidence,
                validator: CandidateSkillEvidenceDraft.validateEvidence,
              ),
              const SizedBox(height: 12),
              CandidateSkillEvidenceReadiness(draft: draft),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _clearDraft,
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    key: const Key('candidate-skill-evidence-submit'),
                    onPressed: canSubmit ? _submitEvidence : null,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save evidence'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  CandidateSkillFitProfile? _selectedProfile(String candidateId) {
    for (final profile in widget.profiles) {
      if (profile.candidateId == candidateId) return profile;
    }
    return null;
  }

  void _selectCandidate(String? candidateId) {
    if (candidateId == null) return;
    final profile = widget.profiles.firstWhere(
      (item) => item.candidateId == candidateId,
    );
    ref
        .read(candidateSkillEvidenceDraftProvider.notifier)
        .setCandidate(profile: profile);
  }

  void _selectSkill(CandidateSkillFitProfile profile, String skill) {
    ref
        .read(candidateSkillEvidenceDraftProvider.notifier)
        .setSkill(profile, skill);
  }

  void _submitEvidence() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(candidateSkillEvidenceDraftProvider);
    if (!isValid || !draft.isReady) return;

    final evidence = ref
        .read(candidateSkillEvidenceProvider.notifier)
        .upsertDraft(draft);
    ref.read(candidateSkillEvidenceDraftProvider.notifier).clear();
    _showMessage('${evidence.skill} evidence saved for ${draft.candidateName}');
  }

  void _clearDraft() {
    ref.read(candidateSkillEvidenceDraftProvider.notifier).clear();
  }

  bool _signalExists(List<CandidateSkillFitSignal> signals, String skill) {
    return signals.any((signal) => signal.skill == skill);
  }

  void _syncEvidence(String value) {
    if (_evidenceController.text == value) return;
    _evidenceController.text = value;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
