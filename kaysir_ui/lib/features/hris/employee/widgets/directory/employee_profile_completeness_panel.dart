import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_profile_completeness_provider.dart';
import 'employee_profile_completeness_tiles.dart';

class EmployeeProfileCompletenessPanel extends ConsumerWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeProfileCompletenessPanel({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(
      employeeProfileCompletenessProvider(snapshot.member.id),
    );

    if (profile == null) {
      return const SizedBox.shrink();
    }

    return HrisSectionPanel(
      icon: Icons.checklist_rtl_outlined,
      title: 'Profile completeness',
      subtitle: profile.nextAction,
      children: [
        EmployeeProfileCompletenessScoreCard(profile: profile),
        EmployeeProfileCompletenessSummaryStrip(profile: profile),
        ...profile.priorityItems.map(
          (item) => EmployeeProfileCompletenessItemTile(item: item),
        ),
      ],
    );
  }
}
