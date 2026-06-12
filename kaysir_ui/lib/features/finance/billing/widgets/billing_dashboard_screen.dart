import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/billing_cash_forecast.dart';
import '../models/billing_invoice.dart';
import '../models/billing_invoice_action.dart';
import '../models/billing_invoice_aging_bucket.dart';
import '../models/billing_invoice_attention.dart';
import '../models/billing_invoice_filter.dart';
import '../models/billing_invoice_status.dart';
import '../models/billing_tenant_account.dart';
import '../models/billing_tenant_preferences.dart';
import '../states/billing_business_domain_profile_provider.dart';
import '../states/billing_dashboard_provider.dart';
import '../states/billing_invoice_action_provider.dart';
import '../states/billing_management_navigation_context_provider.dart';
import '../states/billing_product_catalog_provider.dart';
import '../utils/billing_dashboard_section_tracker.dart';
import '../utils/billing_route_context.dart';
import '../utils/billing_route_locations.dart';
import '../utils/billing_tenant_context_bridge.dart';
import 'billing_dashboard_header_section.dart';
import 'billing_dashboard_insight_stack.dart';
import 'billing_dashboard_invoice_section.dart';
import 'billing_dashboard_stats_strip.dart';
import 'billing_diagnostics_screen.dart';
import 'billing_invoice_action_result_sheet.dart';
import 'billing_invoice_create_sheet.dart';
import 'billing_invoice_detail_sheet.dart';
import 'billing_invoice_issue_outbox_inspector_sheet.dart';
import 'billing_management_initial_local_navigation_controller.dart';
import 'billing_management_local_target_action_set.dart';
import 'billing_management_navigation_coordinator.dart';
import 'billing_management_navigation_session.dart';
import 'billing_navigation_dispatch_snapshot.dart';
import 'billing_navigation_drawer.dart';
import 'billing_navigation_local_target.dart';
import 'billing_management_navigation_scaffold.dart';
import 'billing_management_quick_action_menu.dart';
import 'billing_product_workspace_screen.dart';
import 'billing_tenant_selection_screen.dart';

class BillingDashboardScreen extends ConsumerStatefulWidget {
  final BillingNavigationDestinationId initialDestination;
  final String? initialTenantId;
  final String? initialBusinessDomain;

  const BillingDashboardScreen({
    super.key,
    this.initialDestination = BillingNavigationDestinationId.dashboard,
    this.initialTenantId,
    this.initialBusinessDomain,
  });

  @override
  ConsumerState<BillingDashboardScreen> createState() =>
      _BillingDashboardScreenState();
}

class _BillingDashboardScreenState
    extends ConsumerState<BillingDashboardScreen> {
  final _dashboardSectionKey = GlobalKey();
  final _insightsSectionKey = GlobalKey();
  final _invoicesSectionKey = GlobalKey();
  late BillingNavigationDestinationId _activeDestination;
  var _hasPendingSectionSync = false;
  var _hasHandledInitialDestination = false;
  var _hasUserScrollInteraction = false;
  var _isProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();
    _activeDestination = billingDashboardActiveDestinationFor(
      widget.initialDestination,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTenantId = ref.watch(selectedBillingTenantIdProvider);
    final tenantsAsync = ref.watch(billingTenantsProvider);
    final drawerTenant = tenantsAsync.maybeWhen(
      data:
          (tenants) => _selectedTenant(
            tenants: tenants,
            currentTenantId: currentTenantId,
          ),
      orElse: () => null,
    );
    final navigationContext = ref.watch(
      billingManagementNavigationContextProvider(
        BillingManagementNavigationContextRequest.dashboard(
          preferences: drawerTenant?.preferences,
          tenantId: drawerTenant?.id,
          noTenantBusinessDomain: widget.initialBusinessDomain,
          selectedDestinationId: _activeDestination,
        ),
      ),
    );
    final domainReadinessReport = ref.watch(
      billingTenantDomainModuleReadinessProvider(
        navigationContext.launchPlannerRequest,
      ),
    );
    return BillingManagementNavigationScaffold(
      navigationContext: navigationContext,
      backgroundColor: const Color(0xFFF7F9FC),
      selectedDestination: _activeDestination,
      tenantName: drawerTenant?.name,
      tenantSubtitle:
          drawerTenant?.planName.isNotEmpty == true
              ? '${drawerTenant!.planName} plan'
              : null,
      onDestinationSelected:
          (destination) => _handleNavigationDestination(
            context,
            ref,
            destination,
            navigationContext.destinationDispatchSnapshot,
          ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Billing Dashboard',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          BillingManagementQuickActionMenu(
            navigationContext: navigationContext,
            onDestinationSelected:
                (destination) => _handleNavigationDestination(
                  context,
                  ref,
                  destination,
                  navigationContext.quickActionDispatchSnapshot,
                ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: tenantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => const Center(child: Text('Error loading tenants')),
        data: (tenants) {
          if (currentTenantId.isEmpty && tenants.isNotEmpty) {
            final initialTenant = _tenantForId(
              tenants: tenants,
              tenantId: widget.initialTenantId,
            );
            Future.microtask(
              () =>
                  ref.read(selectedBillingTenantIdProvider.notifier).state =
                      (initialTenant ?? tenants.first).id,
            );
          }

          final selectedTenant = _selectedTenant(
            tenants: tenants,
            currentTenantId: currentTenantId,
          );

          _handleInitialDestination(
            ref,
            selectedTenant,
            navigationContext.destinationDispatchSnapshot,
          );

          return NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: KeyedSubtree(
                    key: _dashboardSectionKey,
                    child: BillingDashboardHeaderSection(
                      tenants: tenants,
                      selectedTenant: selectedTenant,
                      onTenantChanged:
                          (tenantId) =>
                              ref
                                  .read(
                                    selectedBillingTenantIdProvider.notifier,
                                  )
                                  .state = tenantId,
                      onPayNow: () {},
                      onViewInvoices:
                          () => _activateInvoices(ref, selectedTenant.id),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: BillingDashboardStatsStrip(
                    tenantId: selectedTenant.id,
                    preferences: selectedTenant.preferences,
                  ),
                ),
                SliverToBoxAdapter(
                  child: KeyedSubtree(
                    key: _insightsSectionKey,
                    child: BillingDashboardInsightStack(
                      tenantId: selectedTenant.id,
                      preferences: selectedTenant.preferences,
                      readinessReport: domainReadinessReport,
                      onCashForecastBucketSelected:
                          (bucket) => _applyCashForecastFilter(
                            ref,
                            tenantId: selectedTenant.id,
                            bucket: bucket,
                          ),
                      onAttentionItemSelected:
                          (item) => _applyAttentionFilter(
                            ref,
                            tenantId: selectedTenant.id,
                            item: item,
                          ),
                      onAgingBucketSelected:
                          (bucket) => _applyAgingBucketFilter(
                            ref,
                            tenantId: selectedTenant.id,
                            bucket: bucket,
                          ),
                      onCollectionTaskSelected:
                          (task) => _openInvoiceDetail(
                            context,
                            ref,
                            selectedTenant: selectedTenant,
                            invoice: task.invoice,
                          ),
                      onIssueOutboxInspect:
                          () => showBillingInvoiceIssueOutboxInspectorSheet(
                            context,
                            tenantId: selectedTenant.id,
                          ),
                    ),
                  ),
                ),
                BillingDashboardInvoiceSection(
                  sectionKey: _invoicesSectionKey,
                  tenantId: selectedTenant.id,
                  preferences: selectedTenant.preferences,
                  onInvoiceTap:
                      (invoice) => _openInvoiceDetail(
                        context,
                        ref,
                        selectedTenant: selectedTenant,
                        invoice: invoice,
                      ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: tenantsAsync.maybeWhen(
        data: (tenants) {
          final selectedTenant = _selectedTenant(
            tenants: tenants,
            currentTenantId: currentTenantId,
          );
          if (selectedTenant.id.isEmpty) return null;

          return FloatingActionButton(
            tooltip: 'Create invoice',
            onPressed:
                () => _openInvoiceCreate(
                  context,
                  ref,
                  selectedTenant: selectedTenant,
                ),
            backgroundColor: const Color(0xFF6366F1),
            child: const Icon(Icons.add),
          );
        },
        orElse: () => null,
      ),
    );
  }

  BillingTenantAccount _selectedTenant({
    required List<BillingTenantAccount> tenants,
    required String currentTenantId,
  }) {
    final selectedTenant = tenants.firstWhere(
      (tenant) => tenant.id == currentTenantId,
      orElse:
          () =>
              tenants.isNotEmpty
                  ? tenants.first
                  : const BillingTenantAccount(
                    id: '',
                    name: 'No Tenant',
                    logoUrl: '',
                    planName: '',
                    currentBalance: 0,
                  ),
    );
    return billingTenantAccountWithRouteContext(
      selectedTenant,
      businessDomain: widget.initialBusinessDomain,
    );
  }

  BillingTenantAccount? _tenantForId({
    required List<BillingTenantAccount> tenants,
    required String? tenantId,
  }) {
    final normalizedTenantId = tenantId?.trim();
    if (normalizedTenantId == null || normalizedTenantId.isEmpty) return null;

    for (final tenant in tenants) {
      if (tenant.id == normalizedTenantId) return tenant;
    }

    return null;
  }

  void _handleNavigationDestination(
    BuildContext context,
    WidgetRef ref,
    BillingNavigationDestinationId destination,
    BillingNavigationDispatchSnapshot dispatchSnapshot,
  ) {
    final tenantsAsync = ref.read(billingTenantsProvider);
    final currentTenantId = ref.read(selectedBillingTenantIdProvider);
    final selectedTenant = tenantsAsync.maybeWhen(
      data:
          (tenants) => _selectedTenant(
            tenants: tenants,
            currentTenantId: currentTenantId,
          ),
      orElse:
          () => const BillingTenantAccount(
            id: '',
            name: '',
            logoUrl: '',
            planName: '',
            currentBalance: 0,
          ),
    );

    final session = BillingManagementNavigationSession.dashboard(
      dispatchSnapshot: dispatchSnapshot,
      tenant: selectedTenant,
    );

    BillingManagementNavigationCoordinator.fromSession(
      context: context,
      session: session,
      onLocalNavigation: (localTarget) {
        return _handleLocalNavigationTarget(
          context,
          ref,
          selectedTenant,
          localTarget,
        );
      },
      onProductWorkspaceRouteOpening: (_) {
        if (selectedTenant.id.isEmpty) return;

        ref
            .read(currentTenantProvider.notifier)
            .state = billingTenantFromAccount(selectedTenant);
      },
      onProductWorkspaceRouteDestination: (destinationId, _) {
        _openProductWorkspace(context, ref, selectedTenant, destinationId);
        return true;
      },
      onTenantSelectionRoute: (_) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder:
                (_) => TenantSelectionScreen(
                  popOnSelect: true,
                  initialBusinessDomain:
                      selectedTenant.preferences.businessDomain,
                ),
          ),
        );
        return true;
      },
    ).handleDestination(destination);
  }

  bool _handleLocalNavigationTarget(
    BuildContext context,
    WidgetRef ref,
    BillingTenantAccount selectedTenant,
    BillingNavigationLocalTarget localTarget,
  ) {
    return BillingManagementLocalTargetActionSet.dashboard(
      onDashboardOverview: (_) {
        _activateDashboardSection(BillingNavigationDestinationId.dashboard);
        _scrollToSection(_dashboardSectionKey);
        return true;
      },
      onDashboardWorkCenter: (_) {
        _activateDashboardSection(BillingNavigationDestinationId.workCenter);
        context.go(
          billingRouteLocationForDestination(
            BillingNavigationDestinationId.workCenter,
            tenantId: selectedTenant.id,
            businessDomain: selectedTenant.preferences.businessDomain,
          ),
        );
        return true;
      },
      onDashboardInvoices: (_) {
        _activateInvoices(ref, selectedTenant.id);
        return true;
      },
      onDashboardCreateInvoice: (_) {
        _activateDashboardSection(BillingNavigationDestinationId.createInvoice);
        _openInvoiceCreate(context, ref, selectedTenant: selectedTenant);
        return true;
      },
      onDashboardReports: (_) {
        _activateDashboardSection(BillingNavigationDestinationId.reports);
        _scrollToSection(_insightsSectionKey);
        return true;
      },
      onDashboardIssueOutbox: (_) {
        _activateDashboardSection(BillingNavigationDestinationId.issueOutbox);
        showBillingInvoiceIssueOutboxInspectorSheet(
          context,
          tenantId: selectedTenant.id,
        );
        return true;
      },
      onDashboardPolicyCenter: (_) {
        _activateDashboardSection(BillingNavigationDestinationId.policyCenter);
        context.go(
          billingRouteLocationForDestination(
            BillingNavigationDestinationId.policyCenter,
            tenantId: selectedTenant.id,
            businessDomain: selectedTenant.preferences.businessDomain,
          ),
        );
        return true;
      },
      onDashboardDiagnostics: (_) {
        _activateDashboardSection(BillingNavigationDestinationId.diagnostics);
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const BillingDiagnosticsScreen(),
          ),
        );
        return true;
      },
    ).handleTarget(localTarget);
  }

  void _handleInitialDestination(
    WidgetRef ref,
    BillingTenantAccount selectedTenant,
    BillingNavigationDispatchSnapshot dispatchSnapshot,
  ) {
    final session = BillingManagementNavigationSession.dashboard(
      dispatchSnapshot: dispatchSnapshot,
      tenant: selectedTenant,
    );

    BillingManagementNavigationCoordinator.fromSession(
      context: context,
      session: session,
      onLocalNavigation:
          (localTarget) => _handleLocalNavigationTarget(
            context,
            ref,
            selectedTenant,
            localTarget,
          ),
    ).scheduleInitialDestination(
      destinationId: widget.initialDestination,
      hasHandledInitialDestination: _hasHandledInitialDestination,
      markInitialDestinationHandled: () => _hasHandledInitialDestination = true,
      resolveLocalTarget: billingInitialDashboardLocalTargetFor,
      canHandleLocalNavigation: () => mounted && selectedTenant.id.isNotEmpty,
    );
  }

  void _openProductWorkspace(
    BuildContext context,
    WidgetRef ref,
    BillingTenantAccount selectedTenant,
    BillingNavigationDestinationId destination,
  ) {
    ref.read(currentTenantProvider.notifier).state = billingTenantFromAccount(
      selectedTenant,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => BillingScreen(
              initialDestination: destination,
              initialBusinessDomain: selectedTenant.preferences.businessDomain,
            ),
      ),
    );
  }

  void _resetInvoiceFilters(WidgetRef ref, String tenantId) {
    ref.read(billingInvoiceFilterProvider(tenantId).notifier).state =
        const BillingInvoiceFilter();
  }

  void _activateInvoices(WidgetRef ref, String tenantId) {
    _activateDashboardSection(BillingNavigationDestinationId.invoices);
    _resetInvoiceFilters(ref, tenantId);
    _scrollToSection(_invoicesSectionKey);
  }

  void _activateDashboardSection(BillingNavigationDestinationId destination) {
    if (_activeDestination == destination) return;

    setState(() {
      _activeDestination = destination;
    });
  }

  void _scrollToSection(GlobalKey sectionKey) {
    _isProgrammaticScroll = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final sectionContext = sectionKey.currentContext;
      if (sectionContext == null) {
        _isProgrammaticScroll = false;
        return;
      }

      Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        alignment: 0.04,
      );
      Future<void>.delayed(const Duration(milliseconds: 380), () {
        if (!mounted) return;
        _isProgrammaticScroll = false;
      });
    });
  }

  void _queueActiveSectionSync() {
    if (_isProgrammaticScroll || _hasPendingSectionSync) return;

    _hasPendingSectionSync = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hasPendingSectionSync = false;
      if (!mounted || _isProgrammaticScroll) return;

      final activeSection = activeBillingDashboardSection(
        _sectionPositions(),
        activationOffset: _sectionActivationOffset(),
      );
      if (activeSection == null) return;

      _activateDashboardSection(activeSection);
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isProgrammaticScroll) return false;
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _hasUserScrollInteraction = true;
      _queueActiveSectionSync();
      return false;
    }

    if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null) {
      _hasUserScrollInteraction = true;
      _queueActiveSectionSync();
      return false;
    }

    if (notification is UserScrollNotification &&
        notification.direction != ScrollDirection.idle) {
      _hasUserScrollInteraction = true;
      _queueActiveSectionSync();
      return false;
    }

    if (notification is ScrollEndNotification && _hasUserScrollInteraction) {
      _hasUserScrollInteraction = false;
      _queueActiveSectionSync();
    }

    return false;
  }

  double _sectionActivationOffset() {
    final sectionContext =
        _dashboardSectionKey.currentContext ??
        _insightsSectionKey.currentContext ??
        _invoicesSectionKey.currentContext;
    if (sectionContext == null) return 96;

    final height = Scrollable.maybeOf(sectionContext)?.context.size?.height;
    if (height == null || !height.isFinite || height <= 0) return 96;

    return height * 0.72;
  }

  List<BillingDashboardSectionPosition<BillingNavigationDestinationId>>
  _sectionPositions() {
    return [
      if (_sectionPosition(
            key: _dashboardSectionKey,
            section: BillingNavigationDestinationId.dashboard,
          )
          case final position?)
        position,
      if (_sectionPosition(
            key: _insightsSectionKey,
            section: BillingNavigationDestinationId.reports,
          )
          case final position?)
        position,
      if (_sectionPosition(
            key: _invoicesSectionKey,
            section: BillingNavigationDestinationId.invoices,
          )
          case final position?)
        position,
    ];
  }

  BillingDashboardSectionPosition<BillingNavigationDestinationId>?
  _sectionPosition({
    required GlobalKey key,
    required BillingNavigationDestinationId section,
  }) {
    final sectionContext = key.currentContext;
    if (sectionContext == null) return null;

    final scrollable = Scrollable.maybeOf(sectionContext);
    final viewport = scrollable?.context.findRenderObject();
    final sectionRenderObject = sectionContext.findRenderObject();
    if (viewport == null || sectionRenderObject is! RenderBox) return null;
    if (!viewport.attached || !sectionRenderObject.attached) return null;

    final transform = sectionRenderObject.getTransformTo(viewport);
    return BillingDashboardSectionPosition(
      section: section,
      leadingOffset: MatrixUtils.transformPoint(transform, Offset.zero).dy,
    );
  }

  void _openInvoiceDetail(
    BuildContext context,
    WidgetRef ref, {
    required BillingTenantAccount selectedTenant,
    required BillingInvoice invoice,
  }) {
    showBillingInvoiceDetailSheet(
      context,
      invoice: invoice,
      preferences: selectedTenant.preferences,
      tenantName: selectedTenant.name,
      onActionSelected:
          (action) => _performInvoiceAction(
            context,
            ref,
            invoice: invoice,
            action: action,
            tenantName: selectedTenant.name,
            preferences: selectedTenant.preferences,
          ),
    );
  }

  Future<void> _openInvoiceCreate(
    BuildContext context,
    WidgetRef ref, {
    required BillingTenantAccount selectedTenant,
  }) async {
    final invoice = await showBillingInvoiceCreateSheet(
      context,
      tenant: selectedTenant,
    );
    if (invoice == null || !context.mounted) return;

    _openInvoiceDetail(
      context,
      ref,
      selectedTenant: selectedTenant,
      invoice: invoice,
    );
  }

  Future<void> _performInvoiceAction(
    BuildContext context,
    WidgetRef ref, {
    required BillingInvoice invoice,
    required BillingInvoiceAction action,
    required String tenantName,
    required BillingTenantPreferences preferences,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await ref
          .read(billingInvoiceActionControllerProvider.notifier)
          .performAction(
            invoice: invoice,
            action: action,
            tenantName: tenantName,
          );
      if (!context.mounted) return;

      await showBillingInvoiceActionResultSheet(
        context,
        result: result,
        preferences: preferences,
        tenantName: tenantName,
      );
    } catch (error) {
      if (!context.mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _applyAttentionFilter(
    WidgetRef ref, {
    required String tenantId,
    required BillingInvoiceAttentionItem item,
  }) {
    final status = switch (item.kind) {
      BillingInvoiceAttentionKind.overdue => BillingInvoiceStatus.overdue,
      BillingInvoiceAttentionKind.dueSoon => BillingInvoiceStatus.pending,
      BillingInvoiceAttentionKind.openBalance => null,
    };

    _applyInvoiceStatusFilter(ref, tenantId: tenantId, status: status);
  }

  void _applyAgingBucketFilter(
    WidgetRef ref, {
    required String tenantId,
    required BillingInvoiceAgingBucket bucket,
  }) {
    final status = switch (bucket.kind) {
      BillingInvoiceAgingBucketKind.overdue31Plus ||
      BillingInvoiceAgingBucketKind
          .overdue1To30 => BillingInvoiceStatus.overdue,
      BillingInvoiceAgingBucketKind.dueSoon ||
      BillingInvoiceAgingBucketKind.futureDue => BillingInvoiceStatus.pending,
    };

    _applyInvoiceStatusFilter(ref, tenantId: tenantId, status: status);
  }

  void _applyCashForecastFilter(
    WidgetRef ref, {
    required String tenantId,
    required BillingCashForecastBucket bucket,
  }) {
    final status = switch (bucket.kind) {
      BillingCashForecastBucketKind.overdueRecovery =>
        BillingInvoiceStatus.overdue,
      BillingCashForecastBucketKind.next7Days ||
      BillingCashForecastBucketKind.next30Days ||
      BillingCashForecastBucketKind.later => BillingInvoiceStatus.pending,
    };

    _applyInvoiceStatusFilter(ref, tenantId: tenantId, status: status);
  }

  void _applyInvoiceStatusFilter(
    WidgetRef ref, {
    required String tenantId,
    required BillingInvoiceStatus? status,
  }) {
    final currentFilter = ref.read(billingInvoiceFilterProvider(tenantId));

    ref
        .read(billingInvoiceFilterProvider(tenantId).notifier)
        .state = currentFilter
        .withStatus(status)
        .withSort(BillingInvoiceSortOption.amountHighToLow);
  }
}
