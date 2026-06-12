import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/time_off_request.dart';
import '../../states/ess_provider.dart';
import '../../widgets/history/time_off_history_panel.dart';
import '../../widgets/history/time_off_history_summary_grid.dart';
import 'request_time_off_screen.dart';

class TimeOffRequestsScreen extends ConsumerWidget {
  const TimeOffRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(timeOffHistorySummaryProvider);
    final requests = ref.watch(filteredTimeOffRequestsProvider);
    final selectedFilter = ref.watch(selectedTimeOffHistoryFilterProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Time Off Requests'),
        backgroundColor: HrisColors.surface,
        foregroundColor: HrisColors.ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                children: [
                  TimeOffHistorySummaryGrid(summary: summary),
                  const SizedBox(height: 16),
                  TimeOffHistoryPanel(
                    requests: requests,
                    selectedFilter: selectedFilter,
                    onFilterChanged:
                        (filter) =>
                            ref
                                .read(
                                  selectedTimeOffHistoryFilterProvider.notifier,
                                )
                                .state = filter,
                    onCancel:
                        (request) => _cancelRequest(context, ref, request),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RequestTimeOffScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New request'),
      ),
    );
  }

  void _cancelRequest(
    BuildContext context,
    WidgetRef ref,
    TimeOffRequest request,
  ) {
    ref.read(timeOffRequestsProvider.notifier).state =
        ref.read(timeOffRequestsProvider).map((item) {
          if (item.id != request.id) return item;
          return TimeOffRequest(
            id: item.id,
            startDate: item.startDate,
            endDate: item.endDate,
            reason: item.reason,
            status: 'Rejected',
          );
        }).toList();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Request cancelled')));
  }
}
