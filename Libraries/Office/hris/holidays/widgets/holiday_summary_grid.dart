import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_models.dart';
import 'holiday_formatters.dart';

class HolidaySummaryGrid extends StatelessWidget {
  final HolidaySummary summary;

  const HolidaySummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final nextHoliday = summary.nextHoliday;

    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Holiday rules',
          value: '${summary.totalCount}',
          detail:
              '${summary.nationalCount} national, ${summary.customCount} custom',
          icon: Icons.event_available_outlined,
          color: HrisColors.primary,
        ),
        HrisSummaryMetric(
          title: 'Upcoming',
          value: '${summary.upcomingCount}',
          detail: 'Within 60 days',
          icon: Icons.upcoming_outlined,
          color: Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Paid holidays',
          value: '${summary.paidCount}',
          detail: '${summary.recurringCount} recurring rules',
          icon: Icons.payments_outlined,
          color: Colors.green,
        ),
        HrisSummaryMetric(
          title: 'Next holiday',
          value: nextHoliday == null ? '-' : nextHoliday.name,
          detail:
              nextHoliday == null
                  ? 'No upcoming rules'
                  : formatHolidayDate(nextHoliday.effectiveDate),
          icon: Icons.today_outlined,
          color: Colors.purple,
        ),
      ],
    );
  }
}
