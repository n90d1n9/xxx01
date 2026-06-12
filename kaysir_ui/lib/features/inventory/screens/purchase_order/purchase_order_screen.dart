import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../../inventory_routes.dart';
import '../../models/inventory_purchase_order_saved_view.dart';
import '../../models/inventory_purchase_order_workspace.dart';
import '../../states/purchase_order_provider.dart';
import '../../widgets/inventory_navigation_drawer.dart';
import '../../widgets/inventory_navigation_scaffold.dart';
import '../../widgets/inventory_purchase_order_components.dart';
import 'purchase_order_detail_screen.dart';

/// Purchase-order command center with searchable procurement status queues.
class PurchaseOrdersScreen extends ConsumerStatefulWidget {
  const PurchaseOrdersScreen({
    super.key,
    this.initialQuery = '',
    this.asOfDate,
  });

  final String initialQuery;

  /// Date used to classify overdue orders; defaults to the current day.
  final DateTime? asOfDate;

  @override
  ConsumerState<PurchaseOrdersScreen> createState() =>
      _PurchaseOrdersScreenState();
}

/// Holds transient purchase-order toolbar state while providers own order data.
class _PurchaseOrdersScreenState extends ConsumerState<PurchaseOrdersScreen> {
  late final TextEditingController _searchController;
  late String _query;
  var _filter = InventoryPurchaseOrderFilter.all;
  var _sort = InventoryPurchaseOrderSort.urgency;

  @override
  void initState() {
    super.initState();
    _query = _resolveInitialQuery(widget.initialQuery);
    _searchController = TextEditingController(text: _query);
  }

  @override
  void didUpdateWidget(covariant PurchaseOrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != oldWidget.initialQuery) {
      final query = widget.initialQuery.trim();
      if (query.isEmpty) return;
      setState(() => _query = query);
      _syncSearchController(query);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query;
    _syncSearchController(query);

    final purchaseOrders = ref.watch(purchaseOrdersProvider);
    final records = buildInventoryPurchaseOrderRecords(
      orders: purchaseOrders,
      asOfDate: widget.asOfDate ?? DateTime.now(),
    );
    final summary = summarizeInventoryPurchaseOrderRecords(records);
    final visibleRecords = sortInventoryPurchaseOrderRecords(
      records: filterInventoryPurchaseOrderRecords(
        records: records,
        query: query,
        filter: _filter,
      ),
      sort: _sort,
    );
    final scheduleBuckets = buildInventoryPurchaseOrderScheduleBuckets(
      visibleRecords,
    );
    final hasActiveFilters = hasActiveInventoryPurchaseOrderFilters(
      query: query,
      filter: _filter,
    );
    final hasActiveControls = hasActiveInventoryPurchaseOrderControls(
      query: query,
      filter: _filter,
      sort: _sort,
    );
    final activeSavedView = matchingInventoryPurchaseOrderSavedView(
      query: query,
      filter: _filter,
      sort: _sort,
    );

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.purchaseOrders,
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        actions: [
          IconButton(
            tooltip: 'Create purchase order',
            icon: const Icon(Icons.add_shopping_cart_rounded),
            onPressed: _openCreatePurchaseOrder,
          ),
        ],
      ),
      body: AppListSurface(
        padding: const EdgeInsets.all(20),
        sectionSpacing: 20,
        header: AppTextCluster(
          eyebrow: 'Inventory Procurement',
          title: 'Purchase Order Command Center',
          subtitle:
              '${summary.activeCount} active orders, ${summary.needsReceivingCount} awaiting receipt, ${summary.overdueCount} overdue',
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        metrics: InventoryPurchaseOrderSummaryGrid(summary: summary),
        filters: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InventoryPurchaseOrderToolbar(
              searchController: _searchController,
              filter: _filter,
              sort: _sort,
              summary: summary,
              onSearchChanged: _handleSearchChanged,
              onFilterChanged: (value) => setState(() => _filter = value),
              onSortChanged: (value) => setState(() => _sort = value),
              activeSavedViewId: activeSavedView?.id,
              onSavedViewSelected: _applySavedView,
            ),
            if (hasActiveControls) ...[
              const SizedBox(height: 10),
              InventoryPurchaseOrderActiveFilterBar(
                query: query,
                filter: _filter,
                sort: _sort,
                onQueryCleared: _clearSearch,
                onFilterCleared: _clearFilter,
                onSortCleared: _clearSort,
                onClearAll: _clearAllFilters,
              ),
            ],
          ],
        ),
        children: [
          InventoryPurchaseOrderSchedulePanel(buckets: scheduleBuckets),
          InventoryPurchaseOrderPanel(
            records: visibleRecords,
            hasActiveFilters: hasActiveFilters,
            onClearFilters: _clearAllFilters,
            onCreateOrder: _openCreatePurchaseOrder,
            onOpen: (record) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          PurchaseOrderDetailScreen(order: record.order),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePurchaseOrder,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New order'),
      ),
    );
  }

  void _openCreatePurchaseOrder() {
    Navigator.pushNamed(context, InventoryRoutes.createPurchaseOrder);
  }

  void _handleSearchChanged(String value) {
    setState(() => _query = value);
    ref.read(purchaseOrderFilterProvider.notifier).state = value;
  }

  void _clearSearch() {
    _handleSearchChanged('');
  }

  void _clearFilter() {
    setState(() => _filter = InventoryPurchaseOrderFilter.all);
  }

  void _clearSort() {
    setState(() => _sort = InventoryPurchaseOrderSort.urgency);
  }

  void _clearAllFilters() {
    setState(() {
      _query = '';
      _filter = InventoryPurchaseOrderFilter.all;
      _sort = InventoryPurchaseOrderSort.urgency;
    });
    ref.read(purchaseOrderFilterProvider.notifier).state = '';
  }

  void _applySavedView(InventoryPurchaseOrderSavedView view) {
    setState(() {
      _query = view.query;
      _filter = view.filter;
      _sort = view.sort;
    });
    ref.read(purchaseOrderFilterProvider.notifier).state = view.query;
  }

  String _resolveInitialQuery(String initialQuery) {
    final query = initialQuery.trim();
    if (query.isNotEmpty) return query;
    return ref.read(purchaseOrderFilterProvider).trim();
  }

  void _syncSearchController(String query) {
    if (_searchController.text == query) return;

    _searchController.text = query;
    _searchController.selection = TextSelection.collapsed(offset: query.length);
  }
}
