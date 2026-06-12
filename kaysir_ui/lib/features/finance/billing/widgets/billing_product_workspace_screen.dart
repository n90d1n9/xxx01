import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_tenant.dart';
import '../states/billing_cart_provider.dart';
import '../states/billing_dashboard_provider.dart';
import '../states/billing_management_navigation_context_provider.dart';
import '../states/billing_product_catalog_provider.dart';
import '../utils/billing_tenant_context_bridge.dart';
import 'billing_dashboard_screen.dart';
import 'billing_cart_bottom_sheet.dart';
import 'billing_cart_panel.dart';
import 'billing_checkout_bar.dart';
import 'billing_checkout_dialog.dart';
import 'billing_invoice_create_sheet.dart';
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
import 'billing_product_catalog_toolbar.dart';
import 'billing_product_category_filter.dart';
import 'billing_product_grid.dart';
import 'billing_tenant_avatar.dart';
import 'billing_tenant_selection_screen.dart';

class BillingScreen extends ConsumerStatefulWidget {
  static const double _persistentCartBreakpoint = 1100;

  final BillingNavigationDestinationId initialDestination;
  final String? initialBusinessDomain;

  const BillingScreen({
    super.key,
    this.initialDestination = BillingNavigationDestinationId.productWorkspace,
    this.initialBusinessDomain,
  });

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  late BillingNavigationDestinationId _activeDestination;
  var _hasHandledInitialDestination = false;
  String? _tenantSelectionBusinessDomain;

  @override
  void initState() {
    super.initState();
    _activeDestination = billingProductWorkspaceActiveDestinationFor(
      widget.initialDestination,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTenant = ref.watch(currentTenantProvider);

    if (currentTenant == null) {
      return TenantSelectionScreen(
        initialBusinessDomain:
            _tenantSelectionBusinessDomain ?? widget.initialBusinessDomain,
      );
    }

    final itemCount =
        ref.watch(cartSummaryForTenantProvider(currentTenant.id)).itemCount;
    final navigationContext = ref.watch(
      billingManagementNavigationContextProvider(
        BillingManagementNavigationContextRequest.productWorkspace(
          preferences: currentTenant.preferences,
          tenantId: currentTenant.id,
          selectedDestinationId: _activeDestination,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final showPersistentCart =
            constraints.maxWidth >= BillingScreen._persistentCartBreakpoint;

        _handleInitialDestination(
          context,
          currentTenant,
          dispatchSnapshot: navigationContext.destinationDispatchSnapshot,
          showPersistentCart: showPersistentCart,
        );

        return BillingManagementNavigationScaffold(
          navigationContext: navigationContext,
          backgroundColor: const Color(0xFFF8F9FC),
          selectedDestination: _activeDestination,
          tenantName: currentTenant.name,
          tenantSubtitle: 'Product checkout workspace',
          onDestinationSelected:
              (destination) => _handleNavigationDestination(
                context,
                currentTenant,
                destination,
                navigationContext.destinationDispatchSnapshot,
                showPersistentCart: showPersistentCart,
              ),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Row(
              children: [
                BillingTenantAvatar(
                  name: currentTenant.name,
                  logoUrl: currentTenant.logoUrl,
                  radius: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    currentTenant.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              BillingManagementQuickActionMenu(
                navigationContext: navigationContext,
                onDestinationSelected:
                    (destination) => _handleNavigationDestination(
                      context,
                      currentTenant,
                      destination,
                      navigationContext.quickActionDispatchSnapshot,
                      showPersistentCart: showPersistentCart,
                    ),
              ),
              IconButton(
                tooltip: 'Category filters',
                icon: const Icon(Icons.tune, color: Color(0xFF4A5568)),
                onPressed: () {
                  _showFilterBottomSheet(context, currentTenant.id);
                },
              ),
              if (!showPersistentCart)
                _CartButton(
                  itemCount: itemCount,
                  onPressed: () {
                    _showCartBottomSheet(context, currentTenant);
                  },
                ),
              IconButton(
                tooltip: 'Switch tenant',
                icon: const Icon(Icons.logout, color: Color(0xFF4A5568)),
                onPressed: () {
                  _tenantSelectionBusinessDomain =
                      currentTenant.preferences.businessDomain;
                  ref.read(currentTenantProvider.notifier).state = null;
                },
              ),
            ],
          ),
          body: _BillingProductWorkspaceBody(
            tenant: currentTenant,
            showPersistentCart: showPersistentCart,
            onCheckout:
                () => showBillingCheckoutDialog(
                  context,
                  preferences: currentTenant.preferences,
                ),
          ),
          bottomNavigationBar:
              showPersistentCart
                  ? null
                  : BillingCheckoutBar(
                    tenantId: currentTenant.id,
                    preferences: currentTenant.preferences,
                    onCheckout:
                        () => showBillingCheckoutDialog(
                          context,
                          preferences: currentTenant.preferences,
                        ),
                  ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context, String tenantId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 20, 4, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Category',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                BillingProductCategoryFilter(tenantId: tenantId),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCartBottomSheet(BuildContext context, Tenant tenant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return CartBottomSheet(
              tenantId: tenant.id,
              scrollController: scrollController,
              preferences: tenant.preferences,
              onCheckout:
                  () => showBillingCheckoutDialog(
                    context,
                    preferences: tenant.preferences,
                  ),
            );
          },
        );
      },
    );
  }

  void _handleNavigationDestination(
    BuildContext context,
    Tenant tenant,
    BillingNavigationDestinationId destination,
    BillingNavigationDispatchSnapshot dispatchSnapshot, {
    required bool showPersistentCart,
  }) {
    final session = BillingManagementNavigationSession.productWorkspace(
      dispatchSnapshot: dispatchSnapshot,
      tenant: tenant,
    );

    BillingManagementNavigationCoordinator.fromSession(
      context: context,
      session: session,
      onLocalNavigation: (localTarget) {
        return _handleLocalNavigationTarget(
          context,
          tenant,
          localTarget,
          showPersistentCart: showPersistentCart,
        );
      },
      onDashboardRouteOpening: (_) {
        ref.read(selectedBillingTenantIdProvider.notifier).state = tenant.id;
      },
      onTenantSelectionRouteOpening: (_) {
        _tenantSelectionBusinessDomain = tenant.preferences.businessDomain;
        ref.read(currentTenantProvider.notifier).state = null;
      },
      onDashboardRouteDestination: (destinationId, _) {
        ref.read(selectedBillingTenantIdProvider.notifier).state = tenant.id;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder:
                (_) => BillingDashboardScreen(
                  initialDestination: destinationId,
                  initialTenantId: tenant.id,
                  initialBusinessDomain: tenant.preferences.businessDomain,
                ),
          ),
        );
        return true;
      },
      onTenantSelectionRoute: (_) {
        _tenantSelectionBusinessDomain = tenant.preferences.businessDomain;
        ref.read(currentTenantProvider.notifier).state = null;
        return true;
      },
    ).handleDestination(destination);
  }

  bool _handleLocalNavigationTarget(
    BuildContext context,
    Tenant tenant,
    BillingNavigationLocalTarget localTarget, {
    required bool showPersistentCart,
  }) {
    return BillingManagementLocalTargetActionSet.productWorkspace(
      onDashboardCreateInvoice: (_) {
        _activateDestination(BillingNavigationDestinationId.createInvoice);
        _openInvoiceCreate(context, tenant);
        return true;
      },
      onDashboardIssueOutbox: (_) {
        _activateDestination(BillingNavigationDestinationId.issueOutbox);
        showBillingInvoiceIssueOutboxInspectorSheet(
          context,
          tenantId: tenant.id,
        );
        return true;
      },
      onCartCheckout: (_) {
        _activateCartCheckout(
          context,
          tenant,
          showPersistentCart: showPersistentCart,
        );
        return true;
      },
      onProductCatalog: (_) {
        _activateDestination(BillingNavigationDestinationId.productWorkspace);
        return true;
      },
    ).handleTarget(localTarget);
  }

  void _handleInitialDestination(
    BuildContext context,
    Tenant tenant, {
    required BillingNavigationDispatchSnapshot dispatchSnapshot,
    required bool showPersistentCart,
  }) {
    final session = BillingManagementNavigationSession.productWorkspace(
      dispatchSnapshot: dispatchSnapshot,
      tenant: tenant,
    );

    BillingManagementNavigationCoordinator.fromSession(
      context: context,
      session: session,
      onLocalNavigation:
          (localTarget) => _handleLocalNavigationTarget(
            context,
            tenant,
            localTarget,
            showPersistentCart: showPersistentCart,
          ),
    ).scheduleInitialDestination(
      destinationId: widget.initialDestination,
      hasHandledInitialDestination: _hasHandledInitialDestination,
      markInitialDestinationHandled: () => _hasHandledInitialDestination = true,
      resolveLocalTarget: billingInitialProductWorkspaceLocalTargetFor,
      canHandleLocalNavigation: () => mounted,
    );
  }

  void _activateDestination(BillingNavigationDestinationId destination) {
    if (_activeDestination == destination) return;

    setState(() {
      _activeDestination = destination;
    });
  }

  void _activateCartCheckout(
    BuildContext context,
    Tenant tenant, {
    required bool showPersistentCart,
  }) {
    _activateDestination(BillingNavigationDestinationId.cartCheckout);
    if (!showPersistentCart) {
      _showCartBottomSheet(context, tenant);
    }
  }

  Future<void> _openInvoiceCreate(BuildContext context, Tenant tenant) async {
    final invoice = await showBillingInvoiceCreateSheet(
      context,
      tenant: billingTenantAccountFromTenant(tenant),
    );
    if (invoice == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invoice ${invoice.id} was created.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _BillingProductWorkspaceBody extends StatelessWidget {
  final Tenant tenant;
  final bool showPersistentCart;
  final VoidCallback onCheckout;

  const _BillingProductWorkspaceBody({
    required this.tenant,
    required this.showPersistentCart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final catalogPane = _BillingProductCatalogPane(tenant: tenant);

    if (!showPersistentCart) {
      return catalogPane;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: catalogPane),
        SizedBox(
          width: 380,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BillingCartPanel(
                  tenantId: tenant.id,
                  preferences: tenant.preferences,
                  onCheckout: onCheckout,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BillingProductCatalogPane extends StatelessWidget {
  final Tenant tenant;

  const _BillingProductCatalogPane({required this.tenant});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(
            'Products & Services',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
            ),
          ),
        ),
        BillingProductCatalogToolbar(tenantId: tenant.id),
        BillingProductCategoryFilter(tenantId: tenant.id),
        Expanded(child: BillingProductGrid(tenant: tenant)),
      ],
    );
  }
}

class _CartButton extends StatelessWidget {
  final int itemCount;
  final VoidCallback onPressed;

  const _CartButton({required this.itemCount, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: 'Open cart',
          icon: const Icon(
            Icons.shopping_cart_outlined,
            color: Color(0xFF4A5568),
          ),
          onPressed: onPressed,
        ),
        if (itemCount > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$itemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
