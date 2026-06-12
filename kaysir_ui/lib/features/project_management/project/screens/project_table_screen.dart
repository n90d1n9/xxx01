import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../models/project_portfolio_item.dart';
import '../models/project_form_focus.dart';
import '../project_management_routes.dart';
import '../services/project_domain_gap_focus_service.dart';
import '../services/project_domain_gap_repair_service.dart';
import '../services/project_portfolio_view_service.dart';
import '../services/project_priority_service.dart';
import '../services/project_saved_view_service.dart';
import '../services/project_table_profile_recommendation_service.dart';
import '../services/project_table_custom_column_service.dart';
import '../services/project_table_view_service.dart';
import '../states/project_portfolio_provider.dart';
import '../widgets/project_portfolio_components.dart';
import '../widgets/project_portfolio_shortcuts.dart';
import '../widgets/project_portfolio_filter_bar.dart';
import '../widgets/project_domain_gap_repair_queue.dart';
import '../widgets/project_table.dart';
import '../widgets/project_table_custom_column_brief.dart';
import '../widgets/project_table_profile_summary.dart';

const double _dashboardLaneMaxWidth = 1180;
const double _recordsWorkspaceMaxWidth = 1560;

class ProjectTableScreen extends ConsumerStatefulWidget {
  const ProjectTableScreen({super.key});

  @override
  ConsumerState<ProjectTableScreen> createState() => _ProjectTableScreenState();
}

class _ProjectTableScreenState extends ConsumerState<ProjectTableScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(projectSearchQueryProvider),
    );
    _searchFocusNode = FocusNode(debugLabel: 'Project table search');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(projectPortfolioViewHydrationProvider.future));
      unawaited(ref.read(createdProjectPortfolioHydrationProvider.future));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allProjects = ref.watch(projectPortfolioProvider);
    final projects = ref.watch(filteredProjectPortfolioProvider);
    final searchQuery = ref.watch(projectSearchQueryProvider);
    final healthFilter = ref.watch(projectHealthFilterProvider);
    final domainReadinessFilter = ref.watch(
      projectDomainReadinessFilterProvider,
    );
    final domainGapFocus = ref.watch(projectDomainGapFocusProvider);
    final sortOption = ref.watch(projectSortProvider);
    final viewPreset = ref.watch(projectPortfolioViewProvider);
    final tableColumnProfile = ref.watch(projectTableColumnProfileProvider);
    final recommendedTableColumnProfile = recommendedProjectTableColumnProfile(
      viewPreset: viewPreset,
      domainReadinessFilter: domainReadinessFilter,
      sortOption: sortOption,
    );
    final tableCustomColumns =
        tableColumnProfile == ProjectTableColumnProfile.domainContext
            ? buildProjectTableCustomColumns(projects: projects)
            : const <ProjectTableCustomColumn>[];
    final createdProjectIds = ref.watch(createdProjectPortfolioIdsProvider);
    final repairPlan = buildProjectDomainGapRepairPlan(
      projects: projects,
      columns: tableCustomColumns,
      editableProjectIds: createdProjectIds,
    );
    final viewNotifier = ref.read(
      projectPortfolioViewPreferencesProvider.notifier,
    );

    ref.listen<String>(projectSearchQueryProvider, (_, query) {
      if (_searchController.text == query) return;

      _searchController.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Project Table')),
      body: ProjectPortfolioShortcuts(
        onSearchPressed: _focusTableSearch,
        onClearViewPressed: _clearPortfolioView,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
                  constraints.maxWidth >= 1280 ? 32.0 : 16.0;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  24,
                  horizontalPadding,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _WidthLane(
                      maxWidth: _dashboardLaneMaxWidth,
                      child: _TableHeader(
                        onCreate:
                            () => context.go(ProjectManagementRoutes.formUri()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _WidthLane(
                      maxWidth: _dashboardLaneMaxWidth,
                      child: ProjectPortfolioSummaryGrid(projects: allProjects),
                    ),
                    const SizedBox(height: 16),
                    _WidthLane(
                      maxWidth: _recordsWorkspaceMaxWidth,
                      child: AppContentPanel(
                        title: 'Project Records',
                        subtitle:
                            'Full-width workspace showing ${projects.length} of ${allProjects.length} projects with saved views, domain readiness, and operational sorting.',
                        leadingIcon: Icons.table_rows_outlined,
                        padding: const EdgeInsets.all(18),
                        trailing: _ProjectTableFilters(
                          healthFilter: healthFilter,
                          domainReadinessFilter: domainReadinessFilter,
                          domainGapFocus: domainGapFocus,
                          sortOption: sortOption,
                          tableColumnProfile: tableColumnProfile,
                          searchController: _searchController,
                          searchFocusNode: _searchFocusNode,
                          onHealthChanged: viewNotifier.setHealthFilter,
                          onDomainReadinessChanged: _applyDomainReadinessFilter,
                          onDomainGapFocusChanged: _applyDomainGapFocus,
                          onSearchChanged: viewNotifier.setSearchQuery,
                          onSortChanged: _applySortOption,
                          onTableColumnProfileChanged: _setTableColumnProfile,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ProjectPortfolioSavedViewsBar(
                              projects: allProjects,
                              value: viewPreset,
                              onChanged: _applyViewPreset,
                            ),
                            const SizedBox(height: 14),
                            ProjectPortfolioActiveFiltersBar(
                              query: searchQuery,
                              viewPreset: viewPreset,
                              healthFilter: healthFilter,
                              domainReadinessFilter: domainReadinessFilter,
                              domainGapFocus: domainGapFocus,
                              sortOption: sortOption,
                              visibleCount: projects.length,
                              totalCount: allProjects.length,
                              onClear: _clearPortfolioView,
                            ),
                            const SizedBox(height: 14),
                            ProjectTableProfileSummary(
                              profile: tableColumnProfile,
                              recommendedProfile: recommendedTableColumnProfile,
                              onUseRecommended:
                                  () => _setTableColumnProfile(
                                    recommendedTableColumnProfile,
                                  ),
                            ),
                            if (tableCustomColumns.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              ProjectTableCustomColumnBrief(
                                columns: tableCustomColumns,
                                domainGapFocus: domainGapFocus,
                                onDomainGapFocusChanged: _applyDomainGapFocus,
                              ),
                            ],
                            if (!repairPlan.isEmpty) ...[
                              const SizedBox(height: 14),
                              ProjectDomainGapRepairQueue.fromPlan(
                                plan: repairPlan,
                                onRepair: _repairProjectDomainGap,
                                onFocusPriority: _focusRepairPriority,
                              ),
                            ],
                            const SizedBox(height: 14),
                            ProjectPortfolioTable(
                              projects: projects,
                              visibleColumns: tableColumnProfile.columns,
                              customColumns: tableCustomColumns,
                              removableProjectIds: createdProjectIds,
                              onEditProject: _editProject,
                              onEditProjectAttributes: _editProjectAttributes,
                              onEditProjectCustomAttribute:
                                  _editProjectCustomAttribute,
                              onRemoveProject: _confirmRemoveProject,
                              onOpenProject:
                                  (project) => context.go(
                                    ProjectManagementRoutes.detailPath(
                                      project.id,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _clearPortfolioView() {
    _searchController.clear();
    ref.read(projectPortfolioViewPreferencesProvider.notifier).resetView();
  }

  void _applyViewPreset(ProjectPortfolioViewPreset viewPreset) {
    ref
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setViewPreset(viewPreset);
  }

  void _applyDomainReadinessFilter(ProjectDomainReadinessFilter filter) {
    ref
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setDomainReadinessFilter(filter);
  }

  void _applyDomainGapFocus(ProjectDomainGapFocus focus) {
    ref
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setDomainGapFocus(focus);
  }

  void _applySortOption(ProjectPortfolioSortOption sortOption) {
    ref
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setSortOption(sortOption);
  }

  void _setTableColumnProfile(ProjectTableColumnProfile profile) {
    ref
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setTableColumnProfile(profile);
  }

  void _focusTableSearch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _searchFocusNode.requestFocus();
      _searchController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _searchController.text.length,
      );
    });
  }

  void _editProject(ProjectPortfolioItem project) {
    context.go(ProjectManagementRoutes.formUri(projectId: project.id));
  }

  void _editProjectAttributes(ProjectPortfolioItem project) {
    context.go(
      ProjectManagementRoutes.formUri(
        projectId: project.id,
        focus: ProjectFormPanelFocus.domainExtensions,
      ),
    );
  }

  void _editProjectCustomAttribute(
    ProjectPortfolioItem project,
    ProjectTableCustomColumn column,
  ) {
    _openProjectAttribute(project: project, attributeKey: column.key);
  }

  void _repairProjectDomainGap(ProjectDomainGapRepairTarget target) {
    _openProjectAttribute(
      project: target.project,
      attributeKey: target.column.key,
    );
  }

  void _focusRepairPriority(ProjectDomainGapRepairPriority priority) {
    _applyDomainGapFocus(switch (priority) {
      ProjectDomainGapRepairPriority.requiredField =>
        ProjectDomainGapFocus.missingRequired,
      ProjectDomainGapRepairPriority.riskSignal =>
        ProjectDomainGapFocus.missingRiskSignals,
      ProjectDomainGapRepairPriority.recommended =>
        ProjectDomainGapFocus.missingRecommended,
      ProjectDomainGapRepairPriority.coverageGap =>
        ProjectDomainGapFocus.missingAny,
    });
  }

  void _openProjectAttribute({
    required ProjectPortfolioItem project,
    required String attributeKey,
  }) {
    context.go(
      ProjectManagementRoutes.formUri(
        projectId: project.id,
        focusedAttributeKey: attributeKey,
      ),
    );
  }

  Future<void> _confirmRemoveProject(ProjectPortfolioItem project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove project'),
            content: Text(
              'Remove ${project.name} from your local project records?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Remove'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;

    final removed = ref
        .read(createdProjectPortfolioProvider.notifier)
        .removeById(project.id);
    if (!removed || !mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Removed project: ${project.name}')));
  }
}

class _WidthLane extends StatelessWidget {
  const _WidthLane({required this.maxWidth, required this.child});

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final title = AppTextCluster(
          eyebrow: 'Project Management',
          title: 'Project Table',
          subtitle:
              'Scan, filter, and open project records from a modern operations table that still keeps dashboard context close.',
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        );
        final action = AppActionButton(
          label: 'New Project',
          icon: Icons.add_rounded,
          onPressed: onCreate,
        );

        if (constraints.maxWidth < 640) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 12), action],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: title), const SizedBox(width: 16), action],
        );
      },
    );
  }
}

class _ProjectTableFilters extends StatelessWidget {
  const _ProjectTableFilters({
    required this.healthFilter,
    required this.domainReadinessFilter,
    required this.domainGapFocus,
    required this.sortOption,
    required this.tableColumnProfile,
    required this.searchController,
    required this.searchFocusNode,
    required this.onHealthChanged,
    required this.onDomainReadinessChanged,
    required this.onDomainGapFocusChanged,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onTableColumnProfileChanged,
  });

  final ProjectHealth? healthFilter;
  final ProjectDomainReadinessFilter domainReadinessFilter;
  final ProjectDomainGapFocus domainGapFocus;
  final ProjectPortfolioSortOption sortOption;
  final ProjectTableColumnProfile tableColumnProfile;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<ProjectHealth?> onHealthChanged;
  final ValueChanged<ProjectDomainReadinessFilter> onDomainReadinessChanged;
  final ValueChanged<ProjectDomainGapFocus> onDomainGapFocusChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ProjectPortfolioSortOption> onSortChanged;
  final ValueChanged<ProjectTableColumnProfile> onTableColumnProfileChanged;

  @override
  Widget build(BuildContext context) {
    return ProjectPortfolioFilterBar(
      searchController: searchController,
      searchFocusNode: searchFocusNode,
      searchHintText: 'Search table',
      searchWidth: 240,
      healthWidth: 170,
      healthFilter: healthFilter,
      domainReadinessFilter: domainReadinessFilter,
      domainGapFocus: domainGapFocus,
      sortOption: sortOption,
      domainGapFieldKey: const ValueKey(
        'project-table-domain-gap-focus-select',
      ),
      onSearchChanged: onSearchChanged,
      onHealthChanged: onHealthChanged,
      onDomainReadinessChanged: onDomainReadinessChanged,
      onDomainGapFocusChanged: onDomainGapFocusChanged,
      onSortChanged: onSortChanged,
      leadingControls: [
        AppSelectField<ProjectTableColumnProfile>(
          label: 'Profile',
          value: tableColumnProfile,
          width: 190,
          icon: tableColumnProfile.icon,
          options: [
            for (final profile in ProjectTableColumnProfile.values)
              AppSelectOption(value: profile, label: profile.label),
          ],
          onChanged: onTableColumnProfileChanged,
        ),
      ],
    );
  }
}
