import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../../models/employee_form_draft.dart';

class EmployeeFormReadinessPanel extends StatelessWidget {
  final EmployeeFormDraft draft;

  const EmployeeFormReadinessPanel({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;
    final ready = errors.isEmpty;

    return HrisSectionPanel(
      icon: ready ? Icons.verified_outlined : Icons.rule_outlined,
      title: ready ? 'Ready to save' : 'Profile readiness',
      subtitle:
          ready
              ? 'All required employee details are complete'
              : '${errors.length} item(s) need attention',
      children: [
        HrisProgressBar(
          value: draft.completionRatio,
          color: ready ? const Color(0xFF15803D) : HrisColors.primary,
          label: '${(draft.completionRatio * 100).round()}% complete',
        ),
        if (errors.isEmpty)
          const HrisListSurface(
            child: Text('This employee profile can be saved.'),
          )
        else
          ...errors.map(
            (error) => HrisListSurface(
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(error)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
