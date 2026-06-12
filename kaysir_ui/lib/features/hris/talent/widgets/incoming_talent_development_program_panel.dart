import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_program_models.dart';
import '../states/incoming_talent_development_program_enrollment_provider.dart';
import '../states/incoming_talent_development_program_provider.dart';
import 'incoming_talent_development_program_enrollment_form.dart';
import 'incoming_talent_development_program_enrollment_tile.dart';
import 'incoming_talent_development_program_form.dart';
import 'incoming_talent_development_program_tile.dart';

class IncomingTalentDevelopmentProgramPanel extends ConsumerWidget {
  const IncomingTalentDevelopmentProgramPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programs = ref.watch(
      filteredIncomingTalentDevelopmentProgramsProvider,
    );
    final enrollments = ref.watch(
      filteredIncomingTalentDevelopmentProgramEnrollmentsProvider,
    );
    final programSummary = ref.watch(
      incomingTalentDevelopmentProgramSummaryProvider,
    );
    final enrollmentSummary = ref.watch(
      incomingTalentDevelopmentProgramEnrollmentSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.school_outlined,
      title: 'Development programs',
      subtitle:
          enrollmentSummary.totalCount == 0
              ? programSummary.nextAction
              : enrollmentSummary.nextAction,
      emptyMessage: 'No development program data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Programs',
              value: '${programSummary.activeCount}',
            ),
            HrisMetricStripItem(
              label: 'Enrolled',
              value: '${enrollmentSummary.totalCount}',
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value: '${enrollmentSummary.watchCount}',
            ),
          ],
        ),
        const IncomingTalentDevelopmentProgramForm(),
        const SizedBox(height: 12),
        const IncomingTalentDevelopmentProgramEnrollmentForm(),
        const SizedBox(height: 12),
        if (programs.isEmpty)
          const HrisListSurface(
            child: Text('No development programs created yet.'),
          )
        else
          for (final program in programs)
            IncomingTalentDevelopmentProgramTile(
              program: program,
              enrolledCount: _openEnrollmentCount(enrollments, program.id),
            ),
        if (enrollments.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final enrollment in enrollments)
            IncomingTalentDevelopmentProgramEnrollmentTile(
              enrollment: enrollment,
            ),
        ],
      ],
    );
  }
}

int _openEnrollmentCount(
  List<IncomingTalentDevelopmentProgramEnrollment> enrollments,
  String programId,
) {
  return enrollments
      .where(
        (enrollment) =>
            enrollment.programId == programId && !enrollment.isClosed,
      )
      .length;
}
