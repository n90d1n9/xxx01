import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../../models/employee_detail_summary.dart';
import '../../models/shift.dart';
import '../shift_list_view.dart';

class EmployeeDetailTabs extends StatelessWidget {
  final AsyncValue<List<Shift>> shifts;
  final EmployeeDetailSummary? summary;

  const EmployeeDetailTabs({
    super.key,
    required this.shifts,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: hrisPanelDecoration(),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.event_note_outlined), text: 'Shifts'),
                Tab(icon: Icon(Icons.insights_outlined), text: 'Performance'),
                Tab(icon: Icon(Icons.description_outlined), text: 'Documents'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  shifts.when(
                    data: (items) => ShiftsListView(shifts: items),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (error, stackTrace) =>
                            Center(child: Text('Error loading shifts: $error')),
                  ),
                  _PerformanceSnapshot(summary: summary),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: HrisEmptyState(
                        message:
                            'Documents workspace is ready for contract and policy records.',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceSnapshot extends StatelessWidget {
  final EmployeeDetailSummary? summary;

  const _PerformanceSnapshot({required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary == null) {
      return const Center(
        child: HrisEmptyState(message: 'No performance summary available.'),
      );
    }

    final completionRatio =
        summary!.totalShifts == 0
            ? 0.0
            : summary!.completedShifts / summary!.totalShifts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Completed',
                value: '${summary!.completedShifts}',
              ),
              HrisMetricStripItem(
                label: 'Missed',
                value: '${summary!.missedShifts}',
              ),
              HrisMetricStripItem(
                label: 'In progress',
                value: '${summary!.inProgressShifts}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          HrisListSurface(
            child: HrisProgressBar(
              value: completionRatio,
              color: const Color(0xFF15803D),
              label:
                  '${(completionRatio * 100).round()}% of assigned shifts completed',
            ),
          ),
          const SizedBox(height: 16),
          HrisListSurface(
            child: Row(
              children: [
                const Icon(Icons.recommend_outlined, color: HrisColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    summary!.missedShifts == 0
                        ? 'No attendance exceptions in this view.'
                        : 'Review missed shifts before the next performance conversation.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
