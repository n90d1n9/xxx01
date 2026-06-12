import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';

import '../models/project_portfolio_item.dart';
import '../project_management_routes.dart';
import '../services/project_domain_gap_focus_service.dart';
import '../services/project_portfolio_briefing_service.dart';
import '../services/project_portfolio_view_service.dart';
import '../services/project_priority_service.dart';
import '../states/project_portfolio_provider.dart';
import '../widgets/project_portfolio_briefing_panel.dart';
import '../widgets/project_portfolio_components.dart';
import '../widgets/project_portfolio_filter_bar.dart';
import '../widgets/project_portfolio_shortcuts.dart';

class ProjectScreen extends ConsumerStatefulWidget {
  const ProjectScreen({super.key});

  @override
  ConsumerState<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends ConsumerState<ProjectScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(projectSearchQueryProvider),
    );
    _searchFocusNode = FocusNode(debugLabel: 'Project portfolio search');
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
    final viewNotifier = ref.read(
      projectPortfolioViewPreferencesProvider.notifier,
    );
    final briefing = buildProjectPortfolioBriefing(
      projects: projects,
      totalProjectCount: allProjects.length,
    );

    ref.listen<String>(projectSearchQueryProvider, (_, query) {
      if (_searchController.text == query) return;

      _searchController.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: ProjectPortfolioShortcuts(
        onSearchPressed: _focusPortfolioSearch,
        onClearViewPressed: _clearPortfolioView,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextCluster(
                      eyebrow: 'Project Management',
                      title: 'Project Portfolio',
                      subtitle:
                          'Delivery health, milestones, and ownership in one workspace.',
                      titleStyle: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        AppActionButton(
                          label: 'Project Table',
                          icon: Icons.table_rows_outlined,
                          variant: AppActionButtonVariant.secondary,
                          onPressed:
                              () =>
                                  context.go(ProjectManagementRoutes.tablePath),
                        ),
                        AppActionButton(
                          label: 'New Project',
                          icon: Icons.add_rounded,
                          onPressed:
                              () =>
                                  context.go(ProjectManagementRoutes.formPath),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ProjectPortfolioSummaryGrid(projects: allProjects),
                    const SizedBox(height: 16),
                    AppContentPanel(
                      title: 'Board Briefing',
                      subtitle:
                          '${projects.length} of ${allProjects.length} projects in the current view',
                      leadingIcon: Icons.tips_and_updates_outlined,
                      child: ProjectPortfolioBriefingPanel(
                        summary: briefing,
                        onOpenProject:
                            (projectId) => context.go('/projects/$projectId'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppContentPanel(
                      title: 'Portfolio Board',
                      leadingIcon: Icons.dashboard_customize_outlined,
                      trailing: _ProjectPortfolioFilters(
                        healthFilter: healthFilter,
                        domainReadinessFilter: domainReadinessFilter,
                        domainGapFocus: domainGapFocus,
                        sortOption: sortOption,
                        searchController: _searchController,
                        searchFocusNode: _searchFocusNode,
                        onHealthChanged:
                            (value) => viewNotifier.setHealthFilter(value),
                        onDomainReadinessChanged:
                            viewNotifier.setDomainReadinessFilter,
                        onDomainGapFocusChanged: viewNotifier.setDomainGapFocus,
                        onSearchChanged: viewNotifier.setSearchQuery,
                        onSortChanged: viewNotifier.setSortOption,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProjectPortfolioSavedViewsBar(
                            projects: allProjects,
                            value: viewPreset,
                            onChanged: viewNotifier.setViewPreset,
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
                          ProjectPortfolioList(
                            projects: projects,
                            onProjectTap:
                                (project) =>
                                    context.go('/projects/${project.id}'),
                            onFocusGantt:
                                (project) => context.go(
                                  ProjectManagementRoutes.ganttChartUri(
                                    projectId: project.id,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _clearPortfolioView() {
    _searchController.clear();
    ref.read(projectPortfolioViewPreferencesProvider.notifier).resetView();
  }

  void _focusPortfolioSearch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _searchFocusNode.requestFocus();
      _searchController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _searchController.text.length,
      );
    });
  }
}

class _ProjectPortfolioFilters extends StatelessWidget {
  const _ProjectPortfolioFilters({
    required this.healthFilter,
    required this.domainReadinessFilter,
    required this.domainGapFocus,
    required this.sortOption,
    required this.searchController,
    required this.searchFocusNode,
    required this.onHealthChanged,
    required this.onDomainReadinessChanged,
    required this.onDomainGapFocusChanged,
    required this.onSearchChanged,
    required this.onSortChanged,
  });

  final ProjectHealth? healthFilter;
  final ProjectDomainReadinessFilter domainReadinessFilter;
  final ProjectDomainGapFocus domainGapFocus;
  final ProjectPortfolioSortOption sortOption;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<ProjectHealth?> onHealthChanged;
  final ValueChanged<ProjectDomainReadinessFilter> onDomainReadinessChanged;
  final ValueChanged<ProjectDomainGapFocus> onDomainGapFocusChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ProjectPortfolioSortOption> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return ProjectPortfolioFilterBar(
      searchController: searchController,
      searchFocusNode: searchFocusNode,
      searchHintText: 'Search projects',
      healthFilter: healthFilter,
      domainReadinessFilter: domainReadinessFilter,
      domainGapFocus: domainGapFocus,
      sortOption: sortOption,
      domainGapFieldKey: const ValueKey(
        'project-board-domain-gap-focus-select',
      ),
      onSearchChanged: onSearchChanged,
      onHealthChanged: onHealthChanged,
      onDomainReadinessChanged: onDomainReadinessChanged,
      onDomainGapFocusChanged: onDomainGapFocusChanged,
      onSortChanged: onSortChanged,
    );
  }
}
