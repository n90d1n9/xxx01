import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/service_center_provider.dart';
import '../widgets/case_queue_panel.dart';
import '../widgets/document_request_panel.dart';
import '../widgets/knowledge_base_panel.dart';
import '../widgets/service_announcement_panel.dart';
import '../widgets/service_center_summary_grid.dart';

class ServiceCenterScreen extends ConsumerWidget {
  const ServiceCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(serviceCenterCategoriesProvider);
    final selectedCategory = ref.watch(serviceCenterCategoryProvider);
    final urgentOnly = ref.watch(serviceCenterUrgentOnlyProvider);
    final summary = ref.watch(serviceCenterSummaryProvider);
    final cases = ref.watch(filteredServiceDeskCasesProvider);
    final documents = ref.watch(filteredDocumentRequestsProvider);
    final policies = ref.watch(filteredPolicyArticlesProvider);
    final announcements = ref.watch(filteredServiceAnnouncementsProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('HR Service Center'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(serviceDeskCasesProvider);
              ref.invalidate(documentRequestsProvider);
              ref.invalidate(policyArticlesProvider);
              ref.invalidate(serviceAnnouncementsProvider);
            },
          ),
          IconButton(
            tooltip: 'New case',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New HR case draft created')),
              );
            },
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
              HrisCommandHeader(
                icon: Icons.support_agent_outlined,
                title: 'Employee Support Hub',
                subtitle:
                    'Cases, documents, policy answers, and employee broadcasts',
                departments: categories,
                departmentLabel: 'Category',
                selectedDepartment: selectedCategory,
                attentionOnly: urgentOnly,
                attentionLabel: 'SLA risk',
                onDepartmentChanged: (value) {
                  if (value != null) {
                    ref.read(serviceCenterCategoryProvider.notifier).state =
                        value;
                  }
                },
                onAttentionChanged: (value) {
                  ref.read(serviceCenterUrgentOnlyProvider.notifier).state =
                      value;
                },
              ),
              const SizedBox(height: 16),
              ServiceCenterSummaryGrid(summary: summary),
              const SizedBox(height: 16),
              HrisResponsivePanelGrid(
                breakpoint: 920,
                panels: [
                  CaseQueuePanel(cases: cases),
                  DocumentRequestPanel(documents: documents),
                  KnowledgeBasePanel(policies: policies),
                  ServiceAnnouncementPanel(announcements: announcements),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
