import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_action_sla_provider.dart';
import 'employee_action_sla_tiles.dart';

class EmployeeActionSlaPanel extends ConsumerWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeActionSlaPanel({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(
      employeeActionSlaProfileProvider(snapshot.member.id),
    );

    if (profile == null) {
      return const SizedBox.shrink();
    }

    final signals = profile.topSignals;

    return HrisSectionPanel(
      icon: Icons.notification_important_outlined,
      title: 'Action SLA monitor',
      subtitle: profile.nextAction,
      children: [
        EmployeeActionSlaSummaryStrip(profile: profile),
        EmployeeActionOwnerLoadBoard(loads: profile.ownerLoads),
        if (signals.isEmpty)
          const HrisEmptyState(message: 'No employee action SLA signals')
        else
          ...signals.map(
            (signal) => EmployeeActionSlaSignalTile(signal: signal),
          ),
      ],
    );
  }
}
