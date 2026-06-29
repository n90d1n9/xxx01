import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_workforce_impact_models.dart';
import 'holiday_workforce_impact_scope_tile.dart';
import 'holiday_workforce_impact_summary.dart';

class HolidayWorkforceImpactPanel extends StatelessWidget {
  final HolidayWorkforceImpact impact;

  const HolidayWorkforceImpactPanel({super.key, required this.impact});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.groups_outlined,
      title: 'Workforce impact',
      subtitle: '${impact.horizonDays}-day scope pressure',
      emptyMessage:
          'No workforce impact in the next ${impact.horizonDays} days',
      children:
          impact.scopes.isEmpty
              ? const []
              : [
                HolidayWorkforceImpactSummary(impact: impact),
                for (final scope in impact.scopes)
                  HolidayWorkforceScopeTile(scopeImpact: scope),
              ],
    );
  }
}
