import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/time_off_request.dart';
import '../../states/ess_provider.dart';
import '../../widgets/time_off_request/request_time_off_form_panel.dart';
import '../../widgets/time_off_request/request_time_off_review_panel.dart';
import '../../widgets/time_off_request/time_off_balance_panel.dart';

class RequestTimeOffScreen extends ConsumerWidget {
  const RequestTimeOffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balances = ref.watch(timeOffBalancesProvider);
    final draft = ref.watch(requestTimeOffDraftProvider);
    final review = ref.watch(requestTimeOffReviewProvider);
    final today = ref.watch(requestTimeOffTodayProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Request Time Off'),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TimeOffBalancePanel(
                    balances: balances,
                    selectedType: draft.type,
                  ),
                  const SizedBox(height: 16),
                  HrisResponsivePanelGrid(
                    panels: [
                      RequestTimeOffFormPanel(
                        draft: draft,
                        balances: balances,
                        onTypeChanged:
                            ref
                                .read(requestTimeOffDraftProvider.notifier)
                                .setType,
                        onStartDateTap:
                            () => _pickStartDate(context, ref, today),
                        onEndDateTap: () => _pickEndDate(context, ref, today),
                        onReasonChanged:
                            ref
                                .read(requestTimeOffDraftProvider.notifier)
                                .setReason,
                      ),
                      RequestTimeOffReviewPanel(
                        review: review,
                        onSubmit: () => _confirmSubmit(context, ref),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickStartDate(
    BuildContext context,
    WidgetRef ref,
    DateTime today,
  ) async {
    final draft = ref.read(requestTimeOffDraftProvider);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: draft.startDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (selectedDate == null) return;
    ref.read(requestTimeOffDraftProvider.notifier).setStartDate(selectedDate);
  }

  Future<void> _pickEndDate(
    BuildContext context,
    WidgetRef ref,
    DateTime today,
  ) async {
    final draft = ref.read(requestTimeOffDraftProvider);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: draft.endDate,
      firstDate: draft.startDate,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (selectedDate == null) return;
    ref.read(requestTimeOffDraftProvider.notifier).setEndDate(selectedDate);
  }

  Future<void> _confirmSubmit(BuildContext context, WidgetRef ref) async {
    final review = ref.read(requestTimeOffReviewProvider);
    if (!review.canSubmit) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm request'),
            content: Text(
              'Submit ${review.durationDays} day(s) of ${review.draft.type} from '
              '${DateFormat('MMM d, yyyy').format(review.draft.startDate)} to '
              '${DateFormat('MMM d, yyyy').format(review.draft.endDate)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.send_outlined),
                label: const Text('Submit'),
              ),
            ],
          ),
    );

    if (confirmed != true || !context.mounted) return;

    final request = TimeOffRequest(
      id: 'TOR${DateTime.now().millisecondsSinceEpoch}',
      startDate: review.draft.startDate,
      endDate: review.draft.endDate,
      reason: '${review.draft.type}: ${review.draft.reason.trim()}',
      status: 'Pending',
    );

    ref.read(timeOffRequestsProvider.notifier).state = [
      ...ref.read(timeOffRequestsProvider),
      request,
    ];
    ref.read(requestTimeOffDraftProvider.notifier).reset();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Time off request submitted')),
      );

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
