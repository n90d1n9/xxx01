import 'package:flutter/material.dart';

import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_overview.dart';
import 'registry_health_api_consistency_panel_options.dart';
import 'registry_health_api_consistency_sections.dart';

class RegistryHealthApiConsistencyPanel extends StatelessWidget {
  const RegistryHealthApiConsistencyPanel({
    super.key,
    required this.report,
    this.options = const RegistryHealthApiConsistencyPanelOptions(),
  });

  final RegistryHealthApiConsistencyReport report;
  final RegistryHealthApiConsistencyPanelOptions options;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegistryHealthApiConsistencyOverview(report: report),
        const SizedBox(height: 12),
        RegistryHealthApiConsistencySections(report: report, options: options),
      ],
    );
  }
}
