import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_portfolio_models.dart';
import '../models/incoming_talent_development_program_models.dart';
import 'incoming_talent_development_program_form_widgets.dart';

class IncomingTalentDevelopmentProgramEnrollmentPickers
    extends StatelessWidget {
  final List<IncomingTalentDevelopmentProgram> programs;
  final List<IncomingTalentDevelopmentPortfolio> portfolios;
  final String? selectedProgramId;
  final String? selectedPortfolioId;
  final ValueChanged<String?> onProgramChanged;
  final ValueChanged<String?> onPortfolioChanged;

  const IncomingTalentDevelopmentProgramEnrollmentPickers({
    super.key,
    required this.programs,
    required this.portfolios,
    required this.selectedProgramId,
    required this.selectedPortfolioId,
    required this.onProgramChanged,
    required this.onPortfolioChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        DropdownButtonFormField<String>(
          initialValue: selectedProgramId,
          decoration: const InputDecoration(
            labelText: 'Program',
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
        ),
        DropdownButtonFormField<String>(
          initialValue: selectedPortfolioId,
          decoration: const InputDecoration(
            labelText: 'IDP portfolio',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.assignment_turned_in_outlined),
          ),
          items:
              portfolios
                  .map(
                    (portfolio) => DropdownMenuItem(
                      value: portfolio.id,
                      child: Text(portfolio.candidateName),
                    ),
                  )
                  .toList(),
          onChanged: onPortfolioChanged,
        ),
      ],
    );
  }
}

class IncomingTalentDevelopmentProgramEnrollmentStatusField
    extends StatelessWidget {
  final IncomingTalentDevelopmentProgramEnrollmentDraft draft;
  final ValueChanged<IncomingTalentDevelopmentProgramEnrollmentStatus>
  onStatusChanged;

  const IncomingTalentDevelopmentProgramEnrollmentStatusField({
    super.key,
    required this.draft,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<
      IncomingTalentDevelopmentProgramEnrollmentStatus
    >(
      initialValue: draft.status,
      decoration: const InputDecoration(
        labelText: 'Enrollment status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.flag_outlined),
      ),
      items:
          IncomingTalentDevelopmentProgramEnrollmentStatus.values
              .map(
                (status) =>
                    DropdownMenuItem(value: status, child: Text(status.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onStatusChanged(value);
      },
      validator: validateIncomingTalentProgramEnrollmentStatus,
    );
  }
}

class IncomingTalentDevelopmentProgramEnrollmentFormActions
    extends StatelessWidget {
  final double completionRatio;
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentDevelopmentProgramEnrollmentFormActions({
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
          label: canSubmit ? 'Enrollment ready' : 'Enrollment draft',
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onClear, child: const Text('Clear')),
            const SizedBox(width: 10),
            FilledButton.icon(
              key: const Key('incoming-talent-program-enrollment-submit'),
              onPressed: canSubmit ? onSubmit : null,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Enroll talent'),
            ),
          ],
        ),
      ],
    );
  }
}
