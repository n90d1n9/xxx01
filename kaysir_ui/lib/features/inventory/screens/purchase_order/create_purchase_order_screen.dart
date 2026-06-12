import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../../../ecommerce/order/order.dart';
import '../../../product/models/product.dart';
import '../../models/inventory_purchase_order_create.dart';
import '../../models/purchase_order_item.dart';
import '../../states/product_provider.dart';
import '../../states/purchase_order_provider.dart';
import '../../utils/inventory_formatters.dart';
import '../../widgets/inventory_dialog.dart';
import '../../widgets/inventory_navigation_drawer.dart';
import '../../widgets/inventory_navigation_scaffold.dart';
import '../../widgets/inventory_purchase_order_create_components.dart';
import 'add_order_item_dialog.dart';

class CreatePurchaseOrderScreen extends ConsumerStatefulWidget {
  const CreatePurchaseOrderScreen({super.key});

  @override
  ConsumerState<CreatePurchaseOrderScreen> createState() =>
      _CreatePurchaseOrderScreenState();
}

class _CreatePurchaseOrderScreenState
    extends ConsumerState<CreatePurchaseOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supplierController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _expectedDeliveryDate;
  final _items = <PurchaseOrderItem>[];

  InventoryPurchaseOrderCreateDraft get _draft {
    return InventoryPurchaseOrderCreateDraft(
      supplierName: _supplierController.text,
      expectedDeliveryDate: _expectedDeliveryDate,
      notes: _notesController.text,
      items: List.unmodifiable(_items),
    );
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final draft = _draft;
    final createIssue = validateInventoryPurchaseOrderCreateDraft(draft);

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.purchaseOrders,
      appBar: AppBar(title: const Text('Create Purchase Order')),
      body: Form(
        key: _formKey,
        child: AppListSurface(
          padding: const EdgeInsets.all(20),
          sectionSpacing: 20,
          header: AppTextCluster(
            eyebrow: 'Inventory Procurement',
            title: 'Create Purchase Order',
            subtitle:
                'Build a supplier order from ${products.length} available products',
            titleStyle: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          metrics: InventoryPurchaseOrderCreateSummaryGrid(draft: draft),
          children: [
            InventoryPurchaseOrderCreateDetailsPanel(
              supplierController: _supplierController,
              notesController: _notesController,
              expectedDeliveryDate: _expectedDeliveryDate,
              onExpectedDatePressed: _selectExpectedDeliveryDate,
              onChanged: () => setState(() {}),
            ),
            InventoryPurchaseOrderCreateItemsPanel(
              items: _items,
              onAddItem: () => _openAddItemDialog(products),
              onRemoveItem: (index) {
                setState(() => _items.removeAt(index));
              },
            ),
            AppContentPanel(
              title: 'Create Order',
              subtitle:
                  createIssue == null
                      ? 'Ready to send this purchase order to receiving.'
                      : inventoryPurchaseOrderCreateIssueLabel(createIssue),
              leadingIcon: Icons.playlist_add_check_rounded,
              child: FilledButton.icon(
                onPressed:
                    createIssue == null
                        ? () => _createPurchaseOrder(draft)
                        : null,
                icon: const Icon(Icons.check_circle_rounded),
                label: Text(
                  draft.totalAmount == 0
                      ? 'Create purchase order'
                      : 'Create ${formatInventoryCurrency(draft.totalAmount)} order',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectExpectedDeliveryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expectedDeliveryDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;

    setState(() => _expectedDeliveryDate = picked);
  }

  Future<void> _openAddItemDialog(List<Product> products) async {
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add products before creating purchase order items.'),
        ),
      );
      return;
    }

    await showInventoryDialog<void>(
      context: context,
      builder:
          (dialogContext) => AddOrderItemDialog(
            products: products,
            onCancel: () => Navigator.of(dialogContext).pop(),
            onItemAdded: (item) {
              setState(() => _items.add(item));
              Navigator.of(dialogContext).pop();
            },
          ),
    );
  }

  void _createPurchaseOrder(InventoryPurchaseOrderCreateDraft draft) {
    if (!_formKey.currentState!.validate()) return;
    final issue = validateInventoryPurchaseOrderCreateDraft(draft);
    if (issue != null) return;

    final now = DateTime.now();
    final order = draft.toPurchaseOrder(
      id: inventoryPurchaseOrderIdForDate(now),
      orderDate: now,
      status: OrderStatus.confirmed,
    );
    ref.read(purchaseOrdersProvider.notifier).addPurchaseOrder(order);
    Navigator.pop(context);
  }
}
