import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_progress.dart';

class DashboardActionProgressStrip extends StatelessWidget {
  final DashboardActionProgress progress;

  const DashboardActionProgressStrip({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Open', value: '${progress.openCount}'),
        HrisMetricStripItem(
          label: 'In progress',
          value: '${progress.inProgressCount}',
        ),
        HrisMetricStripItem(label: 'Done', value: '${progress.doneCount}'),
      ],
    );
  }
}
