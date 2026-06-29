// Shopping List Page (Enhanced)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shopping_item.dart';
import '../states/budget_provider.dart';
import '../states/shopping_list_provider.dart';

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(shoppingListProvider);
    final total = ref.watch(shoppingTotalProvider);
    final purchasedTotal = items
        .where((item) => item.purchased)
        .fold(0.0, (sum, item) => sum + (item.price * item.quantity));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearPurchasedDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Section
          _buildSummarySection(total, purchasedTotal),

          // List Section
          Expanded(
            child:
                items.isEmpty
                    ? _buildEmptyState()
                    : _buildShoppingList(items, ref, context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context, ref),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummarySection(double total, double purchasedTotal) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.orange.shade50,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Remaining:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Purchased:', style: TextStyle(fontSize: 16)),
              Text(
                '\$${purchasedTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No items yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            'Tap + to add your first item',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingList(
    List<ShoppingItem> items,
    WidgetRef ref,
    BuildContext context,
  ) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildShoppingItem(item, ref, context);
      },
    );
  }

  Widget _buildShoppingItem(
    ShoppingItem item,
    WidgetRef ref,
    BuildContext context,
  ) {
    final totalPrice = item.price * item.quantity;

    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(shoppingListProvider.notifier).deleteItem(item.id);
        _showUndoSnackBar(context, ref, item);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: 2,
        child: ListTile(
          leading: Checkbox(
            value: item.purchased,
            onChanged: (_) {
              ref.read(shoppingListProvider.notifier).togglePurchased(item.id);
            },
            activeColor: Colors.orange,
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: item.purchased ? TextDecoration.lineThrough : null,
              color: item.purchased ? Colors.grey : Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(item.category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Qty: ${item.quantity}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.notes!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: item.purchased ? Colors.grey : Colors.orange.shade700,
                ),
              ),
              Text(
                '@\$${item.price.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          onTap: () => _showEditItemDialog(context, ref, item),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Groceries': Colors.green,
      'Utilities': Colors.blue,
      'Entertainment': Colors.purple,
      'Transportation': Colors.orange,
      'Healthcare': Colors.red,
      'Education': Colors.indigo,
    };
    return colors[category] ?? Colors.grey;
  }

  void _showClearPurchasedDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Purchased Items'),
            content: const Text('Remove all purchased items from the list?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(shoppingListProvider.notifier).clearPurchased();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchased items cleared')),
                  );
                },
                child: const Text('Clear', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showUndoSnackBar(
    BuildContext context,
    WidgetRef ref,
    ShoppingItem item,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${item.name}" removed'),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.orange,
          onPressed: () {
            ref
                .read(shoppingListProvider.notifier)
                .addItem(
                  item.name,
                  item.price,
                  item.quantity,
                  item.category,
                  item.notes,
                  item.budgetCategory,
                );
          },
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final notesController = TextEditingController();
    String category = 'Groceries';
    String? budgetCategory;

    // Get available budget categories
    final budgetCategories = ref.read(budgetProvider);
    final availableBudgetCategories =
        budgetCategories.map((cat) => cat.name).toList();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add Shopping Item'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Item Name
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Item Name *',
                            border: OutlineInputBorder(),
                            hintText: 'Enter item name',
                          ),
                          autofocus: true,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),

                        // Price and Quantity Row
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: priceController,
                                decoration: const InputDecoration(
                                  labelText: 'Price *',
                                  border: OutlineInputBorder(),
                                  prefixText: '\$',
                                  hintText: '0.00',
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: quantityController,
                                decoration: const InputDecoration(
                                  labelText: 'Qty',
                                  border: OutlineInputBorder(),
                                  hintText: '1',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),

                        // Total Price Preview
                        if (priceController.text.isNotEmpty &&
                            quantityController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Total: \$${_calculateTotal(priceController.text, quantityController.text).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Notes
                        TextField(
                          controller: notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                            border: OutlineInputBorder(),
                            hintText: 'Additional details...',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),

                        // Shopping Category
                        DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(
                            labelText: 'Shopping Category *',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              [
                                    'Groceries',
                                    'Utilities',
                                    'Entertainment',
                                    'Transportation',
                                    'Healthcare',
                                    'Education',
                                    'Household',
                                    'Personal Care',
                                    'Clothing',
                                    'Other',
                                  ]
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(cat),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              category = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Budget Category (Optional)
                        DropdownButtonFormField<String>(
                          value: budgetCategory,
                          decoration: const InputDecoration(
                            labelText: 'Link to Budget Category (optional)',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('No budget category'),
                            ),
                            ...availableBudgetCategories
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                )
                                .toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              budgetCategory = value;
                            });
                          },
                        ),

                        // Budget Info if linked
                        if (budgetCategory != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _buildBudgetInfo(ref, budgetCategory!),
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
                        if (_validateForm(
                          nameController.text,
                          priceController.text,
                        )) {
                          _addShoppingItem(
                            ref,
                            nameController.text,
                            priceController.text,
                            quantityController.text,
                            category,
                            notesController.text,
                            budgetCategory,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add Item'),
                    ),
                  ],
                ),
          ),
    );
  }

  double _calculateTotal(String priceText, String quantityText) {
    final price = double.tryParse(priceText) ?? 0;
    final quantity = int.tryParse(quantityText) ?? 1;
    return price * quantity;
  }

  bool _validateForm(String name, String price) {
    if (name.isEmpty) {
      ScaffoldMessenger.of(FlutterErrorDetails as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Please enter an item name'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (price.isEmpty || double.tryParse(price) == null) {
      ScaffoldMessenger.of(FlutterErrorDetails as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final priceValue = double.tryParse(price) ?? 0;
    if (priceValue <= 0) {
      ScaffoldMessenger.of(FlutterErrorDetails as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Price must be greater than 0'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  void _addShoppingItem(
    WidgetRef ref,
    String name,
    String priceText,
    String quantityText,
    String category,
    String notes,
    String? budgetCategory,
  ) {
    final price = double.tryParse(priceText) ?? 0;
    final quantity = int.tryParse(quantityText) ?? 1;

    ref
        .read(shoppingListProvider.notifier)
        .addItem(
          name,
          price,
          quantity,
          category,
          notes.isEmpty ? null : notes,
          budgetCategory,
        );

    // Show success message
    ScaffoldMessenger.of(FlutterErrorDetails as BuildContext).showSnackBar(
      SnackBar(
        content: Text('"$name" added to shopping list'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // If linked to budget category, show budget info
    if (budgetCategory != null) {
      final budgetCategories = ref.read(budgetProvider);
      final budgetCat = budgetCategories.firstWhere(
        (cat) => cat.name == budgetCategory,
        orElse: () => budgetCategories.first,
      );

      final totalCost = price * quantity;
      final remaining = budgetCat.budget - budgetCat.spent;

      if (totalCost > remaining) {
        ScaffoldMessenger.of(FlutterErrorDetails as BuildContext).showSnackBar(
          SnackBar(
            content: Text(
              'Warning: This item exceeds your $budgetCategory budget by \$${(totalCost - remaining).toStringAsFixed(2)}',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildBudgetInfo(WidgetRef ref, String budgetCategoryName) {
    final budgetCategories = ref.read(budgetProvider);
    final budgetCategory = budgetCategories.firstWhere(
      (cat) => cat.name == budgetCategoryName,
      orElse: () => budgetCategories.first,
    );

    final remaining = budgetCategory.budget - budgetCategory.spent;
    final percentage =
        budgetCategory.budget > 0
            ? (budgetCategory.spent / budgetCategory.budget) * 100
            : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget: $budgetCategoryName',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: \$${budgetCategory.spent.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              Text(
                'Remaining: \$${remaining.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: remaining < 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0).toDouble(),
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(
              percentage > 100
                  ? Colors.red
                  : percentage > 80
                  ? Colors.orange
                  : Colors.green,
            ),
            minHeight: 6,
          ),
          const SizedBox(height: 2),
          Text(
            '${percentage.toStringAsFixed(1)}% used',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(
    BuildContext context,
    WidgetRef ref,
    ShoppingItem item,
  ) {
    final nameController = TextEditingController(text: item.name);
    final priceController = TextEditingController(text: item.price.toString());
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    final notesController = TextEditingController(text: item.notes ?? '');
    String category = item.category;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Edit Item'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Item name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            border: OutlineInputBorder(),
                            prefixText: '\$',
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              [
                                    'Groceries',
                                    'Utilities',
                                    'Entertainment',
                                    'Transportation',
                                    'Healthcare',
                                    'Education',
                                  ]
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(cat),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              category = value!;
                            });
                          },
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
                        if (nameController.text.isNotEmpty &&
                            priceController.text.isNotEmpty) {
                          ref
                              .read(shoppingListProvider.notifier)
                              .updateItem(
                                item.copyWith(
                                  name: nameController.text,
                                  price:
                                      double.tryParse(priceController.text) ??
                                      0,
                                  quantity:
                                      int.tryParse(quantityController.text) ??
                                      1,
                                  category: category,
                                  notes:
                                      notesController.text.isEmpty
                                          ? null
                                          : notesController.text,
                                ),
                              );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }
}
