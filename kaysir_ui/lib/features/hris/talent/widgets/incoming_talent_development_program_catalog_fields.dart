import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_program_models.dart';
import 'incoming_talent_development_program_form_widgets.dart';

class IncomingTalentDevelopmentProgramClassificationFields
    extends StatelessWidget {
  final IncomingTalentDevelopmentProgramDraft draft;
  final ValueChanged<IncomingTalentDevelopmentProgramTrack> onTrackChanged;
  final ValueChanged<IncomingTalentDevelopmentProgramStatus> onStatusChanged;
  final ValueChanged<IncomingTalentDevelopmentProgramIntensity>
  onIntensityChanged;

  const IncomingTalentDevelopmentProgramClassificationFields({
    super.key,
    required this.draft,
    required this.onTrackChanged,
    required this.onStatusChanged,
    required this.onIntensityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        DropdownButtonFormField<IncomingTalentDevelopmentProgramTrack>(
          initialValue: draft.track,
          decoration: const InputDecoration(
            labelText: 'Track',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items:
              IncomingTalentDevelopmentProgramTrack.values
                  .map(
                    (track) => DropdownMenuItem(
                      value: track,
                      child: Text(track.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onTrackChanged(value);
          },
          validator: validateIncomingTalentDevelopmentProgramTrack,
        ),
        DropdownButtonFormField<IncomingTalentDevelopmentProgramStatus>(
          initialValue: draft.status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items:
              IncomingTalentDevelopmentProgramStatus.values
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
          validator: validateIncomingTalentDevelopmentProgramStatus,
        ),
        DropdownButtonFormField<IncomingTalentDevelopmentProgramIntensity>(
          initialValue: draft.intensity,
          decoration: const InputDecoration(
            labelText: 'Intensity',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.speed_outlined),
          ),
          items:
              IncomingTalentDevelopmentProgramIntensity.values
                  .map(
                    (intensity) => DropdownMenuItem(
                      value: intensity,
                      child: Text(intensity.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onIntensityChanged(value);
          },
          validator: validateIncomingTalentDevelopmentProgramIntensity,
        ),
      ],
    );
  }
}

class IncomingTalentDevelopmentProgramCatalogDateFields
    extends StatelessWidget {
  final IncomingTalentDevelopmentProgramDraft draft;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;

  const IncomingTalentDevelopmentProgramCatalogDateFields({
    super.key,
    required this.draft,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        IncomingTalentDevelopmentProgramDateButton(
          label: 'Start',
          date: draft.startDate,
          onTap: onSelectStartDate,
          error: validateIncomingTalentDevelopmentProgramStartDate(
            draft.startDate,
            draft.asOfDate,
          ),
        ),
        IncomingTalentDevelopmentProgramDateButton(
          label: 'End',
          date: draft.endDate,
          onTap: onSelectEndDate,
          error: validateIncomingTalentDevelopmentProgramEndDate(
            draft.startDate,
            draft.endDate,
          ),
        ),
      ],
    );
  }
}

class IncomingTalentDevelopmentProgramFormActions extends StatelessWidget {
  final double completionRatio;
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentDevelopmentProgramFormActions({
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
          label: canSubmit ? 'Program ready' : 'Program draft',
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onClear, child: const Text('Clear')),
            const SizedBox(width: 10),
            FilledButton.icon(
              key: const Key('incoming-talent-program-submit'),
              onPressed: canSubmit ? onSubmit : null,
              icon: const Icon(Icons.school_outlined),
              label: const Text('Create program'),
            ),
          ],
        ),
      ],
    );
  }
}
