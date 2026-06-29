import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/recipe.dart';
import '../states/order_provicer.dart';
import '../states/recipe_provider.dart';

class OrderScreen extends ConsumerWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Order Management')),
      body: DefaultTabController(
        length: OrderStatus.values.length,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabs:
                  OrderStatus.values.map((status) {
                    return Tab(text: status.toString().split('.').last);
                  }).toList(),
            ),
            Expanded(
              child: TabBarView(
                children:
                    OrderStatus.values.map((status) {
                      final filteredOrders = ref
                          .read(orderProvider.notifier)
                          .getOrdersByStatus(status);

                      return filteredOrders.isEmpty
                          ? Center(
                            child: Text(
                              'No ${status.toString().split('.').last} orders',
                            ),
                          )
                          : ListView.builder(
                            itemCount: filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    'Order #${order.id} - ${order.customerName}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${_formatDateTime(order.orderTime)} • \$${order.totalAmount.toStringAsFixed(2)}',
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Order Items:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: order.items.length,
                                            itemBuilder: (context, i) {
                                              final item = order.items[i];
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 4.0,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${item.quantity}x ${item.name}',
                                                    ),
                                                    Text(
                                                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          const Divider(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Total:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '\$${order.totalAmount.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (order.notes != null &&
                                              order.notes!.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            const Text(
                                              'Notes:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(order.notes!),
                                          ],
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              if (order.status !=
                                                      OrderStatus.cancelled &&
                                                  order.status !=
                                                      OrderStatus.delivered)
                                                TextButton(
                                                  onPressed: () {
                                                    _showUpdateStatusDialog(
                                                      context,
                                                      ref,
                                                      order,
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Update Status',
                                                  ),
                                                ),
                                              TextButton(
                                                onPressed: () {
                                                  _confirmDelete(
                                                    context,
                                                    ref,
                                                    order.id,
                                                  );
                                                },
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateOrderDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final date =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  void _showUpdateStatusDialog(
    BuildContext context,
    WidgetRef ref,
    Order order,
  ) {
    OrderStatus selectedStatus = order.status;
    final nextStatus = _getNextStatus(order.status);

    if (nextStatus != null) {
      selectedStatus = nextStatus;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Order Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<OrderStatus>(
                    value: selectedStatus,
                    items:
                        OrderStatus.values.map((status) {
                          return DropdownMenuItem<OrderStatus>(
                            value: status,
                            child: Text(status.toString().split('.').last),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    ref
                        .read(orderProvider.notifier)
                        .updateOrderStatus(order.id, selectedStatus);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  OrderStatus? _getNextStatus(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.pending:
        return OrderStatus.processing;
      case OrderStatus.processing:
        return OrderStatus.ready;
      case OrderStatus.ready:
        return OrderStatus.delivered;
      default:
        return null;
    }
  }

  void _showCreateOrderDialog(BuildContext context, WidgetRef ref) {
    final customerNameController = TextEditingController();
    final notesController = TextEditingController();
    final List<OrderItem> orderItems = [];
    final recipes = ref.read(recipeProvider);
    double totalAmount = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Order'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Order Items:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orderItems.length,
                      itemBuilder: (context, index) {
                        final item = orderItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.name} (\$${item.price.toStringAsFixed(2)})',
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    totalAmount -= item.price * item.quantity;
                                    orderItems.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showAddOrderItemDialog(context, recipes, (orderItem) {
                          setState(() {
                            orderItems.add(orderItem);
                            totalAmount += orderItem.price * orderItem.quantity;
                          });
                        });
                      },
                      child: const Text('Add Item'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (customerNameController.text.isNotEmpty &&
                        orderItems.isNotEmpty) {
                      final newOrder = Order(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        orderTime: DateTime.now(),
                        items: orderItems,
                        status: OrderStatus.pending,
                        customerName: customerNameController.text,
                        totalAmount: totalAmount,
                        notes:
                            notesController.text.isEmpty
                                ? null
                                : notesController.text,
                      );
                      ref.read(orderProvider.notifier).addOrder(newOrder);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddOrderItemDialog(
    BuildContext context,
    List<Recipe> recipes,
    Function(OrderItem) onAdd,
  ) {
    Recipe? selectedRecipe;
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Order Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Recipe>(
                    hint: const Text('Select Recipe'),
                    items:
                        recipes.map((recipe) {
                          return DropdownMenuItem<Recipe>(
                            value: recipe,
                            child: Text(
                              '${recipe.name} - \$${recipe.cost.toStringAsFixed(2)}',
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRecipe = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Quantity:'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) quantity--;
                          });
                        },
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedRecipe != null) {
                      final orderItem = OrderItem(
                        recipeId: selectedRecipe!.id,
                        name: selectedRecipe!.name,
                        quantity: quantity,
                        price: selectedRecipe!.cost,
                      );
                      onAdd(orderItem);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this order?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(orderProvider.notifier).deleteOrder(id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
