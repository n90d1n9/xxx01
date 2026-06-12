import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../../states/ess_provider.dart';
import '../../widgets/empl_profile_screen.dart';
import '../../widgets/ess/ess_pay_stub_panel.dart';
import '../../widgets/ess/ess_profile_panel.dart';
import '../../widgets/ess/ess_quick_actions.dart';
import '../../widgets/ess/ess_summary_grid.dart';
import '../../widgets/ess/ess_time_off_panel.dart';
import 'pay_stub_screen.dart';
import 'request_time_off_screen.dart';
import 'time_off_request_screen.dart';

class EmployeeSelfServiceScreen extends ConsumerWidget {
  const EmployeeSelfServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = ref.watch(employeeProvider);
    final payStubs = ref.watch(payStubsProvider);
    final timeOffRequests = ref.watch(timeOffRequestsProvider);
    final summary = ref.watch(employeeSelfServiceSummaryProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Employee Self-Service'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No ESS alerts right now')),
              );
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EssProfilePanel(
                employee: employee,
                onEditProfile:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    ),
              ),
              const SizedBox(height: 16),
              EssSummaryGrid(summary: summary),
              const SizedBox(height: 16),
              EssQuickActions(
                onUpdateProfile:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    ),
                onViewPayStubs:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PayStubsScreen(),
                      ),
                    ),
                onRequestTimeOff:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RequestTimeOffScreen(),
                      ),
                    ),
                onSubmitFeedback: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feedback form opened')),
                  );
                },
              ),
              const SizedBox(height: 16),
              EssPayStubPanel(
                payStubs: payStubs,
                onViewAll:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PayStubsScreen(),
                      ),
                    ),
              ),
              const SizedBox(height: 16),
              EssTimeOffPanel(
                requests: timeOffRequests,
                onViewAll:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TimeOffRequestsScreen(),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
