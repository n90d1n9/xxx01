import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

// Entities
class Supplier {
  final String id;
  final String name;
  final String contact;
  final String email;

  Supplier({
    required this.id,
    required this.name,
    required this.contact,
    required this.email,
  });
}

class PurchaseOrder {
  final String id;
  final String supplierId;
  final DateTime date;
  final double totalAmount;

  PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.date,
    required this.totalAmount,
  });
}

class PurchaseOrderItem {
  final String id;
  final String purchaseOrderId;
  final String productName;
  final int quantity;
  final double unitPrice;

  PurchaseOrderItem({
    required this.id,
    required this.purchaseOrderId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });
}

// Providers
final supplierProvider = StateProvider<List<Supplier>>((ref) => []);
final selectedSupplierProvider = StateProvider<Supplier?>((ref) => null);
final purchaseOrdersProvider = StateProvider<List<PurchaseOrder>>((ref) => []);

// Supplier Management Screen
class SupplierManagementScreen extends ConsumerWidget {
  const SupplierManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliers = ref.watch(supplierProvider);
    final selectedSupplier = ref.watch(selectedSupplierProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Supplier Management',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
            onPressed: () => _showAddSupplierDialog(context, ref),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: Row(
          children: [
            // Supplier List
            Expanded(
              flex: 1,
              child: Card(
                margin: const EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: suppliers.length,
                  itemBuilder: (context, index) {
                    final supplier = suppliers[index];
                    return SupplierTile(
                      supplier: supplier,
                      isSelected: selectedSupplier?.id == supplier.id,
                      onTap: () =>
                          ref.read(selectedSupplierProvider.notifier).state =
                              supplier,
                    );
                  },
                ),
              ),
            ),
            // Supplier Details and Purchase Orders
            Expanded(
              flex: 2,
              child: selectedSupplier == null
                  ? const Center(
                      child: Text(
                        'Select a supplier to view details',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : SupplierDetailsSection(supplier: selectedSupplier),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSupplierDialog(BuildContext context, WidgetRef ref) {
    // Implementation for adding new supplier
    showDialog(
      context: context,
      builder: (context) => const AddSupplierDialog(),
    );
  }
}

// Supplier Tile Widget
class SupplierTile extends StatelessWidget {
  final Supplier supplier;
  final bool isSelected;
  final VoidCallback onTap;

  const SupplierTile({
    super.key,
    required this.supplier,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        supplier.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(supplier.email),
      tileColor: isSelected ? Colors.blue[50] : null,
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}

// Supplier Details Section
class SupplierDetailsSection extends ConsumerWidget {
  final Supplier supplier;

  const SupplierDetailsSection({super.key, required this.supplier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseOrders = ref
        .watch(purchaseOrdersProvider)
        .where((po) => po.supplierId == supplier.id)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Supplier Info Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplier.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Contact: ${supplier.contact}'),
                  Text('Email: ${supplier.email}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Purchase Orders
          Text(
            'Purchase Orders',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: purchaseOrders.length,
              itemBuilder: (context, index) {
                return PurchaseOrderCard(order: purchaseOrders[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Purchase Order Card
class PurchaseOrderCard extends StatelessWidget {
  final PurchaseOrder order;

  const PurchaseOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('PO#${order.id}'),
        subtitle: Text('Date: ${order.date.toString().substring(0, 10)}'),
        trailing: Text(
          '\$${order.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Add Supplier Dialog
class AddSupplierDialog extends ConsumerStatefulWidget {
  const AddSupplierDialog({super.key});

  @override
  ConsumerState<AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends ConsumerState<AddSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _contactController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Supplier'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(labelText: 'Contact'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final newSupplier = Supplier(
                id: DateTime.now().toString(),
                name: _nameController.text,
                contact: _contactController.text,
                email: _emailController.text,
              );
              ref
                  .read(supplierProvider.notifier)
                  .update((state) => [...state, newSupplier]);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
