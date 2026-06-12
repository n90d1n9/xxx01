import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_next_action_provider.dart';
import 'employee_next_action_tiles.dart';

class EmployeeNextActionPanel extends ConsumerWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeNextActionPanel({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(
      employeeNextActionProfileProvider(snapshot.member.id),
    );

    if (profile == null) {
      return const SizedBox.shrink();
    }

    final topActions = profile.topActions;

    return HrisSectionPanel(
      icon: Icons.playlist_add_check_circle_outlined,
      title: 'Next best actions',
      subtitle: profile.nextAction,
      children: [
        EmployeeNextActionSummaryStrip(profile: profile),
        if (topActions.isEmpty)
          const HrisEmptyState(message: 'No open employee next actions')
        else
          ...topActions.map((action) => EmployeeNextActionTile(action: action)),
      ],
    );
  }
}
