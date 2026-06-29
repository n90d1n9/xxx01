import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/hris_ui.dart';
import '../../employee/models/ess_history_models.dart';
import '../../employee/states/ess_provider.dart';
import '../../employee/widgets/history/pay_history_summary_grid.dart';
import '../../employee/widgets/history/pay_stub_history_panel.dart';

class PayStubsScreen extends ConsumerWidget {
  const PayStubsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(payHistorySummaryProvider);
    final payStubs = ref.watch(payStubBreakdownsProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Pay Stubs'),
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
                  PayHistorySummaryGrid(summary: summary),
                  const SizedBox(height: 16),
                  PayStubHistoryPanel(
                    stubs: payStubs,
                    onDownload: (stub) => _showDownloadMessage(context, stub),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDownloadMessage(BuildContext context, PayStubBreakdown stub) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${stub.stub.id} PDF download prepared')),
      );
  }
}
