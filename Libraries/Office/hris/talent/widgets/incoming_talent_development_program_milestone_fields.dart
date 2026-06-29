import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_program_models.dart';
import 'incoming_talent_development_program_form_widgets.dart';

class IncomingTalentDevelopmentProgramMilestoneEnrollmentPicker
    extends StatelessWidget {
  final List<IncomingTalentDevelopmentProgramEnrollment> enrollments;
  final String? selectedEnrollmentId;
  final ValueChanged<String?> onChanged;

  const IncomingTalentDevelopmentProgramMilestoneEnrollmentPicker({
    super.key,
    required this.enrollments,
    required this.selectedEnrollmentId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedEnrollmentId,
      decoration: const InputDecoration(
        labelText: 'Program enrollment',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_add_alt_1_outlined),
      ),
      items:
          enrollments
              .map(
                (enrollment) => DropdownMenuItem(
                  value: enrollment.id,
                  child: Text(enrollment.candidateName),
                ),
              )
              .toList(),
      onChanged: onChanged,
    );
  }
}

class IncomingTalentDevelopmentProgramMilestoneReviewFields
    extends StatelessWidget {
  final IncomingTalentDevelopmentProgramMilestoneDraft draft;
  final ValueChanged<IncomingTalentDevelopmentProgramMilestoneType>
  onTypeChanged;
  final ValueChanged<IncomingTalentDevelopmentProgramMilestoneStatus>
  onStatusChanged;
  final ValueChanged<int> onScoreChanged;
  final TextEditingController scoreController;

  const IncomingTalentDevelopmentProgramMilestoneReviewFields({
    super.key,
    required this.draft,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onScoreChanged,
    required this.scoreController,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        DropdownButtonFormField<IncomingTalentDevelopmentProgramMilestoneType>(
          initialValue: draft.type,
          decoration: const InputDecoration(
            labelText: 'Milestone type',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items:
              IncomingTalentDevelopmentProgramMilestoneType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onTypeChanged(value);
          },
          validator: validateIncomingTalentProgramMilestoneType,
        ),
        DropdownButtonFormField<
          IncomingTalentDevelopmentProgramMilestoneStatus
        >(
          initialValue: draft.status,
          decoration: const InputDecoration(
            labelText: 'Review status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items:
              IncomingTalentDevelopmentProgramMilestoneStatus.values
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
          validator: validateIncomingTalentProgramMilestoneStatus,
        ),
        IncomingTalentDevelopmentProgramNumberInput(
          controller: scoreController,
          label: 'Score',
          icon: Icons.percent_outlined,
          onChanged: onScoreChanged,
          validator: validateIncomingTalentProgramMilestoneScore,
        ),
      ],
    );
  }
}

class IncomingTalentDevelopmentProgramMilestoneFormActions
    extends StatelessWidget {
  final double completionRatio;
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentDevelopmentProgramMilestoneFormActions({
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
          label: canSubmit ? 'Milestone ready' : 'Milestone draft',
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onClear, child: const Text('Clear')),
            const SizedBox(width: 10),
            FilledButton.icon(
              key: const Key('incoming-talent-program-milestone-submit'),
              onPressed: canSubmit ? onSubmit : null,
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Create review'),
            ),
          ],
        ),
      ],
    );
  }
}
