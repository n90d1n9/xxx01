import 'package:flutter/material.dart';

import 'registry_health_showcase_naming.dart';
import 'registry_health_showcase_rename_plan.dart';

Color registryHealthShowcaseRenamePlanStatusColor(
  RegistryHealthShowcaseNamingReport report,
) {
  return _renamePlanStatusColor(registryHealthShowcaseRenamePlanStatus(report));
}

Color registryHealthShowcaseRenamePlanReportColor(
  RegistryHealthShowcaseRenamePlanReport report,
) {
  return _renamePlanStatusColor(report.status);
}

Color _renamePlanStatusColor(RegistryHealthShowcaseRenamePlanStatus status) {
  switch (status) {
    case RegistryHealthShowcaseRenamePlanStatus.clean:
      return Colors.green.shade700;
    case RegistryHealthShowcaseRenamePlanStatus.ready:
      return Colors.orange.shade800;
    case RegistryHealthShowcaseRenamePlanStatus.blocked:
      return Colors.red.shade700;
  }
}
