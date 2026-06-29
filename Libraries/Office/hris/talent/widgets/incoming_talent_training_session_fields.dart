import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_program_models.dart';
import '../models/incoming_talent_training_session_models.dart';
import 'incoming_talent_development_program_form_widgets.dart';

/// Program picker for scheduling a training session from the catalog.
class IncomingTalentTrainingSessionProgramPicker extends StatelessWidget {
  final List<IncomingTalentDevelopmentProgram> programs;
  final String? selectedProgramId;
  final ValueChanged<String?> onProgramChanged;

  const IncomingTalentTrainingSessionProgramPicker({
    super.key,
    required this.programs,
    required this.selectedProgramId,
    required this.onProgramChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedProgramId,
      decoration: const InputDecoration(
        labelText: 'Development program',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.school_outlined),
      ),
      items:
          programs
              .map(
                (program) => DropdownMenuItem(
                  value: program.id,
                  child: Text(program.title),
                ),
              )
              .toList(),
      onChanged: onProgramChanged,
      validator:
          (value) => validateIncomingTalentTrainingSessionRequired(
            value,
            'a development program',
          ),
    );
  }
}

/// Dropdown controls for training format and session lifecycle status.
class IncomingTalentTrainingSessionClassificationFields
    extends StatelessWidget {
  final IncomingTalentTrainingSessionDraft draft;
  final ValueChanged<IncomingTalentTrainingSessionFormat> onFormatChanged;
  final ValueChanged<IncomingTalentTrainingSessionStatus> onStatusChanged;

  const IncomingTalentTrainingSessionClassificationFields({
    super.key,
    required this.draft,
    required this.onFormatChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        DropdownButtonFormField<IncomingTalentTrainingSessionFormat>(
          initialValue: draft.format,
          decoration: const InputDecoration(
            labelText: 'Format',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.connected_tv_outlined),
          ),
          items:
              IncomingTalentTrainingSessionFormat.values
                  .map(
                    (format) => DropdownMenuItem(
                      value: format,
                      child: Text(format.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onFormatChanged(value);
          },
          validator: validateIncomingTalentTrainingSessionFormat,
        ),
        DropdownButtonFormField<IncomingTalentTrainingSessionStatus>(
          initialValue: draft.status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items:
              IncomingTalentTrainingSessionStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onStatusChanged(value);
          },
          validator: validateIncomingTalentTrainingSessionStatus,
        ),
      ],
    );
  }
}

/// Date controls for the session and post-session evidence follow-up.
class IncomingTalentTrainingSessionDateFields extends StatelessWidget {
  final IncomingTalentTrainingSessionDraft draft;
  final VoidCallback onSelectSessionDate;
  final VoidCallback onSelectFollowUpDate;

  const IncomingTalentTrainingSessionDateFields({
    super.key,
    required this.draft,
    required this.onSelectSessionDate,
    required this.onSelectFollowUpDate,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        IncomingTalentDevelopmentProgramDateButton(
          label: 'Session',
          date: draft.sessionDate,
          onTap: onSelectSessionDate,
          error: validateIncomingTalentTrainingSessionDate(
            draft.sessionDate,
            draft.asOfDate,
          ),
        ),
        IncomingTalentDevelopmentProgramDateButton(
          label: 'Follow-up',
          date: draft.followUpDate,
          onTap: onSelectFollowUpDate,
          error: validateIncomingTalentTrainingSessionFollowUpDate(
            sessionDate: draft.sessionDate,
            followUpDate: draft.followUpDate,
          ),
        ),
      ],
    );
  }
}

/// Submit controls and draft-readiness indicator for session scheduling.
class IncomingTalentTrainingSessionFormActions extends StatelessWidget {
  final double completionRatio;
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentTrainingSessionFormActions({
    super.key,
    required this.completionRatio,
    required this.canSubmit,
    required this.onClear,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HrisProgressBar(
          value: completionRatio,
          color: canSubmit ? const Color(0xFF059669) : const Color(0xFFD97706),
          label: canSubmit ? 'Session ready' : 'Session draft',
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onClear, child: const Text('Clear')),
            const SizedBox(width: 10),
            FilledButton.icon(
              key: const Key('incoming-talent-training-session-submit'),
              onPressed: canSubmit ? onSubmit : null,
              icon: const Icon(Icons.event_available_outlined),
              label: const Text('Schedule session'),
            ),
          ],
        ),
      ],
    );
  }
}

@Preview(name: 'Talent training session program picker')
Widget incomingTalentTrainingSessionProgramPickerPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentTrainingSessionProgramPicker(
          programs: [_previewProgram],
          selectedProgramId: _previewProgram.id,
          onProgramChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent training session classification')
Widget incomingTalentTrainingSessionClassificationFieldsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentTrainingSessionClassificationFields(
          draft: _previewDraft,
          onFormatChanged: (_) {},
          onStatusChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent training session dates')
Widget incomingTalentTrainingSessionDateFieldsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentTrainingSessionDateFields(
          draft: _previewDraft,
          onSelectSessionDate: () {},
          onSelectFollowUpDate: () {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent training session actions')
Widget incomingTalentTrainingSessionFormActionsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentTrainingSessionFormActions(
          completionRatio: 0.82,
          canSubmit: true,
          onClear: () {},
          onSubmit: () {},
        ),
      ),
    ),
  );
}

final _previewProgram = IncomingTalentDevelopmentProgram(
  id: 'program-preview',
  title: 'Engineering growth accelerator',
  department: 'Engineering',
  ownerName: 'Engineering HRBP',
  track: IncomingTalentDevelopmentProgramTrack.leadership,
  status: IncomingTalentDevelopmentProgramStatus.active,
  intensity: IncomingTalentDevelopmentProgramIntensity.standard,
  skillFocus: 'Engineering leadership capability',
  expectedOutcome: 'Ready talent can lead a scoped operating review.',
  capacity: 12,
  durationDays: 60,
  startDate: DateTime(2026, 6, 16),
  endDate: DateTime(2026, 8, 15),
  createdAt: DateTime(2026, 6, 9),
);

final _previewDraft = IncomingTalentTrainingSessionDraft.fromProgram(
  program: _previewProgram,
  asOfDate: DateTime(2026, 6, 9),
).copyWith(reservedSeats: 8);
