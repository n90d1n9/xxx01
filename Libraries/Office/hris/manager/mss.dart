import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/widgets/hris_ui.dart';
import 'models/manager_models.dart';
import 'states/manager_provider.dart';
import 'widgets/manager_approval_queue_panel.dart';
import 'widgets/manager_performance_panel.dart';
import 'widgets/manager_quick_actions.dart';
import 'widgets/manager_summary_grid.dart';
import 'widgets/manager_team_panel.dart';

class ManagerSelfServiceScreen extends ConsumerWidget {
  const ManagerSelfServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamScopes = ref.watch(managerTeamScopesProvider);
    final selectedTeam = ref.watch(managerSelectedTeamProvider);
    final attentionOnly = ref.watch(managerAttentionOnlyProvider);
    final summary = ref.watch(managerSelfServiceSummaryProvider);
    final metrics = ref.watch(teamMetricsProvider);
    final teamMembers = ref.watch(filteredTeamMembersProvider);
    final pendingRequests = ref.watch(filteredPendingRequestsProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMessage(context, 'New manager action'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New action'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HrisCommandHeader(
                    title: 'Manager Self Service',
                    subtitle:
                        'Lead approvals, availability, and team health from one workspace',
                    icon: Icons.manage_accounts_outlined,
                    departments: teamScopes,
                    departmentLabel: 'Team scope',
                    selectedDepartment: selectedTeam,
                    attentionOnly: attentionOnly,
                    attentionLabel: 'Needs attention',
                    onDepartmentChanged: (value) {
                      if (value == null) return;
                      ref.read(managerSelectedTeamProvider.notifier).state =
                          value;
                    },
                    onAttentionChanged:
                        (value) =>
                            ref
                                .read(managerAttentionOnlyProvider.notifier)
                                .state = value,
                  ),
                  const SizedBox(height: 16),
                  ManagerSummaryGrid(summary: summary),
                  const SizedBox(height: 16),
                  HrisResponsivePanelGrid(
                    panels: [
                      ManagerPerformancePanel(metrics: metrics),
                      ManagerQuickActions(
                        onActionSelected:
                            (action) => _showMessage(context, '$action opened'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  HrisResponsivePanelGrid(
                    panels: [
                      ManagerApprovalQueuePanel(
                        requests: pendingRequests,
                        onApprove:
                            (request) => _showRequestMessage(
                              context,
                              request,
                              'approved',
                            ),
                        onReject:
                            (request) => _showRequestMessage(
                              context,
                              request,
                              'rejected',
                            ),
                      ),
                      ManagerTeamPanel(
                        members: teamMembers,
                        onMessage:
                            (member) =>
                                _showMemberMessage(context, member, 'message'),
                        onCall:
                            (member) =>
                                _showMemberMessage(context, member, 'call'),
                        onOpenProfile:
                            (member) =>
                                _showMemberMessage(context, member, 'profile'),
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

  void _showRequestMessage(
    BuildContext context,
    PendingRequest request,
    String action,
  ) {
    _showMessage(
      context,
      '${request.requestType} for ${request.employeeName} $action',
    );
  }

  void _showMemberMessage(
    BuildContext context,
    TeamMember member,
    String action,
  ) {
    _showMessage(context, '${member.name} $action opened');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class ManagerSelfServiceApp extends StatelessWidget {
  const ManagerSelfServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Manager Self Service',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: HrisColors.primary),
          scaffoldBackgroundColor: HrisColors.pageBackground,
        ),
        home: const ManagerSelfServiceScreen(),
      ),
    );
  }
}

void main() {
  runApp(const ManagerSelfServiceApp());
}
