import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:queue_ui/fmcg/price.dart';

class CreateSalesOrderScreen extends StatefulWidget {
  const CreateSalesOrderScreen({super.key});

  @override
  _CreateSalesOrderScreenState createState() => _CreateSalesOrderScreenState();
}

class _CreateSalesOrderScreenState extends State<CreateSalesOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final SalesOrderService _salesOrderService = SalesOrderService();
  final ProductService _productService = ProductService();
  final CustomerService _customerService = CustomerService();

  final TextEditingController _orderNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchProductController =
      TextEditingController();

  Customer? _selectedCustomer;
  List<Customer> _customers = [];
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<SalesOrderItem> _orderItems = [];

  String _paymentMethod = 'Credit Card';
  String _shippingMethod = 'Standard Shipping';
  DateTime _orderDate = DateTime.now();

  bool _isLoadingCustomers = true;
  bool _isLoadingProducts = true;
  bool _isSubmitting = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadProducts();

    // Generate a new order number
    _orderNumberController.text =
        'SO-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
  }

  @override
  void dispose() {
    _orderNumberController.dispose();
    _notesController.dispose();
    _searchProductController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoadingCustomers = true;
    });

    try {
      final customers = await _customerService.getCustomers();
      setState(() {
        _customers = customers;
        _isLoadingCustomers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCustomers = false;
      });
      _showErrorSnackBar('Failed to load customers');
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final products = await _productService.getProducts();
      setState(() {
        _products = products;
        _filteredProducts = List.from(products);
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
      _showErrorSnackBar('Failed to load products');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(_products);
      } else {
        final lowercaseQuery = query.toLowerCase();
        _filteredProducts =
            _products.where((product) {
              return product.name.toLowerCase().contains(lowercaseQuery) ||
                  product.sku.toLowerCase().contains(lowercaseQuery);
            }).toList();
      }
    });
  }

  void _addItemToOrder(Product product) {
    // Check if product already exists in order
    final existingItemIndex = _orderItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    setState(() {
      if (existingItemIndex >= 0) {
        // Increment quantity if already in order
        _orderItems[existingItemIndex] = _orderItems[existingItemIndex]
            .copyWith(quantity: _orderItems[existingItemIndex].quantity + 1);
      } else {
        // Add new item
        _orderItems.add(
          SalesOrderItem(
            id: 'item_${DateTime.now().millisecondsSinceEpoch}',
            product: product,
            quantity: 1,
            unitPrice: product.price,
            discountPercent: 0,
            notes: '',
            totalPrice: product.price,
          ),
        );
      }

      _searchProductController.clear();
      _filteredProducts = List.from(_products);
    });
  }

  void _updateItemQuantity(int index, int quantity) {
    if (quantity <= 0) {
      setState(() {
        _orderItems.removeAt(index);
      });
      return;
    }

    setState(() {
      final item = _orderItems[index];
      _orderItems[index] = item.copyWith(
        quantity: quantity,
        totalPrice:
            item.unitPrice * quantity * (1 - item.discountPercent / 100),
      );
    });
  }

  void _updateItemDiscount(int index, double discount) {
    setState(() {
      final item = _orderItems[index];
      _orderItems[index] = item.copyWith(
        discountPercent: discount,
        totalPrice: item.unitPrice * item.quantity * (1 - discount / 100),
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
  }

  double get _subtotal {
    return _orderItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get _taxAmount {
    // Assume tax rate of 8.5%
    return _subtotal * 0.085;
  }

  double get _shippingAmount {
    // Base shipping fee
    return _orderItems.isEmpty ? 0 : 15.0;
  }

  double get _totalAmount {
    return _subtotal + _taxAmount + _shippingAmount;
  }

  Future<void> _createOrder() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_selectedCustomer == null) {
      _showErrorSnackBar('Please select a customer');
      return;
    }

    if (_orderItems.isEmpty) {
      _showErrorSnackBar('Please add at least one item');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final newOrder = SalesOrder(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        orderNumber: _orderNumberController.text,
        customer: _selectedCustomer!,
        orderDate: _orderDate,
        items: _orderItems,
        subtotal: _subtotal,
        taxAmount: _taxAmount,
        shippingAmount: _shippingAmount,
        discountAmount: 0,
        totalAmount: _totalAmount,
        status: 'Pending',
        paymentMethod: _paymentMethod,
        shippingMethod: _shippingMethod,
        notes: _notesController.text,
      );

      await _salesOrderService.createSalesOrder(newOrder);

      setState(() {
        _isSubmitting = false;
      });

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorSnackBar('Failed to create order');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Sales Order'),
        actions: [
          TextButton.icon(
            onPressed: _isSubmitting ? null : _createOrder,
            icon:
                _isSubmitting
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.check, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body:
          _isLoadingCustomers || _isLoadingProducts
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left panel - Order details
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Order Information',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _orderNumberController,
                                            decoration: const InputDecoration(
                                              labelText: 'Order Number',
                                              border: OutlineInputBorder(),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter an order number';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              final picked =
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate: _orderDate,
                                                    firstDate: DateTime(2020),
                                                    lastDate: DateTime(2030),
                                                  );
                                              if (picked != null) {
                                                setState(() {
                                                  _orderDate = picked;
                                                });
                                              }
                                            },
                                            child: InputDecorator(
                                              decoration: const InputDecoration(
                                                labelText: 'Order Date',
                                                border: OutlineInputBorder(),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    DateFormat(
                                                      'MMM dd, yyyy',
                                                    ).format(_orderDate),
                                                  ),
                                                  const Icon(
                                                    Icons.calendar_today,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<Customer>(
                                      value: _selectedCustomer,
                                      decoration: const InputDecoration(
                                        labelText: 'Customer',
                                        border: OutlineInputBorder(),
                                      ),
                                      items:
                                          _customers.map((customer) {
                                            return DropdownMenuItem<Customer>(
                                              value: customer,
                                              child: Text(customer.name),
                                            );
                                          }).toList(),
                                      onChanged: (customer) {
                                        setState(() {
                                          _selectedCustomer = customer;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Please select a customer';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<
                                            String
                                          >(
                                            value: _paymentMethod,
                                            decoration: const InputDecoration(
                                              labelText: 'Payment Method',
                                              border: OutlineInputBorder(),
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'Credit Card',
                                                child: Text('Credit Card'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Bank Transfer',
                                                child: Text('Bank Transfer'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'PayPal',
                                                child: Text('PayPal'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Cash on Delivery',
                                                child: Text('Cash on Delivery'),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                _paymentMethod =
                                                    value ?? 'Credit Card';
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: DropdownButtonFormField<
                                            String
                                          >(
                                            value: _shippingMethod,
                                            decoration: const InputDecoration(
                                              labelText: 'Shipping Method',
                                              border: OutlineInputBorder(),
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'Standard Shipping',
                                                child: Text(
                                                  'Standard Shipping',
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Express Shipping',
                                                child: Text('Express Shipping'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Overnight Shipping',
                                                child: Text(
                                                  'Overnight Shipping',
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Pickup',
                                                child: Text('Pickup'),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                _shippingMethod =
                                                    value ??
                                                    'Standard Shipping';
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _notesController,
                                      decoration: const InputDecoration(
                                        labelText: 'Notes',
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Order Items',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${_orderItems.length} ${_orderItems.length == 1 ? 'item' : 'items'}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    TextField(
                                      controller: _searchProductController,
                                      decoration: InputDecoration(
                                        labelText: 'Search Products',
                                        hintText: 'Search by name or SKU',
                                        prefixIcon: const Icon(Icons.search),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        suffixIcon:
                                            _searchProductController
                                                    .text
                                                    .isNotEmpty
                                                ? IconButton(
                                                  icon: const Icon(Icons.clear),
                                                  onPressed: () {
                                                    setState(() {
                                                      _searchProductController
                                                          .clear();
                                                      _filteredProducts =
                                                          List.from(_products);
                                                    });
                                                  },
                                                )
                                                : null,
                                      ),
                                      onChanged: _filterProducts,
                                    ),
                                    const SizedBox(height: 16),
                                    _searchProductController.text.isNotEmpty
                                        ? _buildProductSearchResults()
                                        : const SizedBox(),
                                    const SizedBox(height: 16),
                                    _orderItems.isEmpty
                                        ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(32.0),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.shopping_cart_outlined,
                                                  size: 64,
                                                  color: Colors.grey.shade400,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'No items added yet',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Search for products above to add them to this order',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        : ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          separatorBuilder:
                                              (_, __) => const Divider(),
                                          itemCount: _orderItems.length,
                                          itemBuilder: (context, index) {
                                            final item = _orderItems[index];
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Product image/icon
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Center(
                                                      child:
                                                          item.product.imageUrl !=
                                                                  null
                                                              ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                                child: Image.network(
                                                                  item
                                                                      .product
                                                                      .imageUrl!,
                                                                  width: 60,
                                                                  height: 60,
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                ),
                                                              )
                                                              : Icon(
                                                                Icons
                                                                    .inventory_2_outlined,
                                                                size: 30,
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade600,
                                                              ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  // Product details
                                                  Expanded(
                                                    flex: 3,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          item.product.name,
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          'SKU: ${item.product.sku}',
                                                          style: TextStyle(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade600,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          'Unit Price: ${_currencyFormat.format(item.unitPrice)}',
                                                          style: TextStyle(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade800,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Quantity field
                                                  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons
                                                                .remove_circle_outline,
                                                          ),
                                                          onPressed: () {
                                                            _updateItemQuantity(
                                                              index,
                                                              item.quantity - 1,
                                                            );
                                                          },
                                                        ),
                                                        SizedBox(
                                                          width: 50,
                                                          child: TextFormField(
                                                            initialValue:
                                                                item.quantity
                                                                    .toString(),
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            decoration: const InputDecoration(
                                                              isDense: true,
                                                              contentPadding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical: 8,
                                                                  ),
                                                              border:
                                                                  OutlineInputBorder(),
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            onChanged: (value) {
                                                              final qty =
                                                                  int.tryParse(
                                                                    value,
                                                                  ) ??
                                                                  0;
                                                              _updateItemQuantity(
                                                                index,
                                                                qty,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons
                                                                .add_circle_outline,
                                                          ),
                                                          onPressed: () {
                                                            _updateItemQuantity(
                                                              index,
                                                              item.quantity + 1,
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Discount field
                                                  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      children: [
                                                        const Text(
                                                          'Discount: ',
                                                        ),
                                                        SizedBox(
                                                          width: 60,
                                                          child: TextFormField(
                                                            initialValue:
                                                                item.discountPercent
                                                                    .toString(),
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            decoration: const InputDecoration(
                                                              isDense: true,
                                                              contentPadding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical: 8,
                                                                  ),
                                                              border:
                                                                  OutlineInputBorder(),
                                                              suffixText: '%',
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            onChanged: (value) {
                                                              final discount =
                                                                  double.tryParse(
                                                                    value,
                                                                  ) ??
                                                                  0;
                                                              _updateItemDiscount(
                                                                index,
                                                                discount,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Total price
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      _currencyFormat.format(
                                                        item.totalPrice,
                                                      ),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                      textAlign:
                                                          TextAlign.right,
                                                    ),
                                                  ),
                                                  // Remove button
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () {
                                                      _removeItem(index);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Right panel - Order summary
                    Expanded(
                      flex: 2,
                      child: Card(
                        margin: const EdgeInsets.all(16.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Order Summary',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (_selectedCustomer != null) ...[
                                const Text(
                                  'Customer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedCustomer!.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (_selectedCustomer!.email != null)
                                        Text(
                                          _selectedCustomer!.email!,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      if (_selectedCustomer!.phone != null)
                                        Text(
                                          _selectedCustomer!.phone!,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                              const Divider(),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal'),
                                  Text(
                                    _currencyFormat.format(_subtotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Tax (8.5%)'),
                                  Text(_currencyFormat.format(_taxAmount)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Shipping'),
                                  Text(_currencyFormat.format(_shippingAmount)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    _currencyFormat.format(_totalAmount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _isSubmitting ? null : _createOrder,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child:
                                      _isSubmitting
                                          ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : const Text(
                                            'Create Order',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildProductSearchResults() {
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No products found matching "${_searchProductController.text}"',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: _filteredProducts.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child:
                    product.imageUrl != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            product.imageUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                        : Icon(
                          Icons.inventory_2_outlined,
                          size: 24,
                          color: Colors.grey.shade600,
                        ),
              ),
            ),
            title: Text(product.name),
            subtitle: Text('SKU: ${product.sku}'),
            trailing: Text(
              _currencyFormat.format(product.price),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              _addItemToOrder(product);
            },
          );
        },
      ),
    );
  }
}

// Models that would be defined in separate files

class SalesOrder {
  final String id;
  final String orderNumber;
  final Customer customer;
  final DateTime orderDate;
  final List<SalesOrderItem> items;
  final double subtotal;
  final double taxAmount;
  final double shippingAmount;
  final double discountAmount;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final String shippingMethod;
  final String notes;

  const SalesOrder({
    required this.id,
    required this.orderNumber,
    required this.customer,
    required this.orderDate,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.notes,
  });
}

class SalesOrderItem {
  final String id;
  final Product product;
  final int quantity;
  final double unitPrice;
  final double discountPercent;
  final String notes;
  final double totalPrice;

  const SalesOrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.discountPercent,
    required this.notes,
    required this.totalPrice,
  });

  SalesOrderItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    double? unitPrice,
    double? discountPercent,
    String? notes,
    double? totalPrice,
  }) {
    return SalesOrderItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      notes: notes ?? this.notes,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

class Customer {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;

  final String? billingAddress;

  final String? shippingAddress;

  const Customer({
    this.billingAddress,
    this.shippingAddress,
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
  });
}

class Product {
  final String id;
  final String name;
  final String sku;
  final double price;
  final String? description;
  final String? imageUrl;
  final int? stockQuantity;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    this.description,
    this.imageUrl,
    this.stockQuantity,
  });
}

// Service classes (these would be actual implementations in separate files)

/* class SalesOrderService {
  Future<void> createSalesOrder(SalesOrder order) async {
    // Implementation would connect to backend API
    await Future.delayed(const Duration(seconds: 1));
    // Return success or throw error
  }

  getSalesOrderById(String salesOrderId) {}

  getSalesOrders() {}
} */

class SalesOrderService {
  // In-memory store for demo purposes - would be replaced with API calls
  final List<SalesOrder> _orders = [];

  // Create a new sales order
  Future<void> createSalesOrder(SalesOrder order) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // In a real implementation, this would send a POST request to the backend
      // Example: final response = await http.post(Uri.parse('$apiBaseUrl/sales-orders'),
      //                          body: jsonEncode(order.toJson()), headers: {'Content-Type': 'application/json'});

      // For demo purposes, just add to local list
      _orders.add(order);

      // Simulate potential API errors (randomly with 10% chance)
      if (Random().nextInt(10) == 0) {
        throw Exception('Server error: Could not create sales order');
      }
    } catch (e) {
      // Log the error
      print('Error creating sales order: $e');
      // Rethrow to allow the UI to handle it
      throw Exception('Failed to create sales order: ${e.toString()}');
    }
  }

  // Get a specific sales order by ID
  Future<SalesOrder?> getSalesOrderById(String salesOrderId) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // In a real implementation, this would send a GET request to the backend
      // Example: final response = await http.get(Uri.parse('$apiBaseUrl/sales-orders/$salesOrderId'));

      // For demo purposes, find in local list
      final order = _orders.firstWhere(
        (order) => order.id == salesOrderId,
        orElse: () => throw Exception('Sales order not found'),
      );

      return order;
    } catch (e) {
      // Log the error
      print('Error fetching sales order: $e');
      // Rethrow to allow the UI to handle it
      throw Exception('Failed to fetch sales order: ${e.toString()}');
    }
  }

  // Get all sales orders with optional filtering
  Future<List<SalesOrder>> getSalesOrders({
    String? customerName,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    bool ascending = true,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // In a real implementation, this would send a GET request with query parameters
      // Example: final queryParams = {
      //   if (customerName != null) 'customerName': customerName,
      //   if (status != null) 'status': status,
      //   if (startDate != null) 'startDate': startDate.toIso8601String(),
      //   ...
      // };
      // final response = await http.get(Uri.parse('$apiBaseUrl/sales-orders').replace(queryParameters: queryParams));

      // For demo purposes, if list is empty, return sample data
      if (_orders.isEmpty) {
        // Return sample data for demo
        final customers = await CustomerService().getCustomers();
        final sampleOrders = await _generateSampleOrders(customers);
        _orders.addAll(sampleOrders);
      }

      // Apply filters
      var filteredOrders = List<SalesOrder>.from(_orders);

      if (customerName != null) {
        filteredOrders =
            filteredOrders
                .where(
                  (order) => order.customer.name.toLowerCase().contains(
                    customerName.toLowerCase(),
                  ),
                )
                .toList();
      }

      if (status != null) {
        filteredOrders =
            filteredOrders.where((order) => order.status == status).toList();
      }

      if (startDate != null) {
        filteredOrders =
            filteredOrders
                .where(
                  (order) =>
                      order.orderDate.isAfter(startDate) ||
                      order.orderDate.isAtSameMomentAs(startDate),
                )
                .toList();
      }

      if (endDate != null) {
        filteredOrders =
            filteredOrders
                .where(
                  (order) =>
                      order.orderDate.isBefore(endDate) ||
                      order.orderDate.isAtSameMomentAs(endDate),
                )
                .toList();
      }

      // Apply sorting
      if (sortBy != null) {
        filteredOrders.sort((a, b) {
          dynamic valueA;
          dynamic valueB;

          switch (sortBy) {
            case 'orderNumber':
              valueA = a.orderNumber;
              valueB = b.orderNumber;
              break;
            case 'customerName':
              valueA = a.customer.name;
              valueB = b.customer.name;
              break;
            case 'orderDate':
              valueA = a.orderDate.millisecondsSinceEpoch;
              valueB = b.orderDate.millisecondsSinceEpoch;
              break;
            case 'totalAmount':
              valueA = a.totalAmount;
              valueB = b.totalAmount;
              break;
            case 'status':
              valueA = a.status;
              valueB = b.status;
              break;
            default:
              valueA = a.orderDate.millisecondsSinceEpoch;
              valueB = b.orderDate.millisecondsSinceEpoch;
          }

          int comparison = valueA.compareTo(valueB);
          return ascending ? comparison : -comparison;
        });
      }

      return filteredOrders;
    } catch (e) {
      // Log the error
      print('Error fetching sales orders: $e');
      // Rethrow to allow the UI to handle it
      throw Exception('Failed to fetch sales orders: ${e.toString()}');
    }
  }

  // Helper method to generate sample orders for the demo
  Future<List<SalesOrder>> _generateSampleOrders(List<Customer> customers) {
    final Random random = Random();
    final statuses = [
      'Pending',
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled',
    ];
    final paymentMethods = [
      'Credit Card',
      'Bank Transfer',
      'PayPal',
      'Cash on Delivery',
    ];
    final shippingMethods = [
      'Standard Shipping',
      'Express Shipping',
      'Overnight Shipping',
      'Pickup',
    ];

    final productService = ProductService();

    return Future.wait(
      List.generate(15, (index) async {
        final orderDate = DateTime.now().subtract(
          Duration(days: random.nextInt(60)),
        );
        final customer = customers[random.nextInt(customers.length)];
        final products = await productService.getProducts();

        // Generate between 1 and 5 order items
        final numItems = random.nextInt(4) + 1;
        final orderItems = List.generate(numItems, (i) {
          final product = products[random.nextInt(products.length)];
          final quantity = random.nextInt(5) + 1;
          final discountPercent = random.nextDouble() * 15; // 0-15% discount

          return SalesOrderItem(
            id: 'item_${DateTime.now().millisecondsSinceEpoch}_$i',
            product: product,
            quantity: quantity,
            unitPrice: product.price,
            discountPercent: discountPercent,
            notes: '',
            totalPrice: product.price * quantity * (1 - discountPercent / 100),
          );
        });

        // Calculate totals
        final subtotal = orderItems.fold(
          0.0,
          (sum, item) => sum + item.totalPrice,
        );
        final taxAmount = subtotal * 0.085;
        final shippingAmount = 15.0;
        final totalAmount = subtotal + taxAmount + shippingAmount;

        return SalesOrder(
          id: 'order_${DateTime.now().millisecondsSinceEpoch}_$index',
          orderNumber: 'SO-${10000 + index}',
          customer: customer,
          orderDate: orderDate,
          items: orderItems,
          subtotal: subtotal,
          taxAmount: taxAmount,
          shippingAmount: shippingAmount,
          discountAmount: 0,
          totalAmount: totalAmount,
          status: statuses[random.nextInt(statuses.length)],
          paymentMethod: paymentMethods[random.nextInt(paymentMethods.length)],
          shippingMethod:
              shippingMethods[random.nextInt(shippingMethods.length)],
          notes:
              random.nextBool()
                  ? 'Sample note for order #${10000 + index}'
                  : '',
        );
      }),
    ).then((value) => value);
  }

  // Update an existing sales order
  Future<void> updateSalesOrder(SalesOrder order) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // In a real implementation, this would send a PUT request to the backend
      // Example: final response = await http.put(Uri.parse('$apiBaseUrl/sales-orders/${order.id}'),
      //                          body: jsonEncode(order.toJson()), headers: {'Content-Type': 'application/json'});

      // For demo purposes, update in local list
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index >= 0) {
        _orders[index] = order;
      } else {
        throw Exception('Sales order not found');
      }
    } catch (e) {
      // Log the error
      print('Error updating sales order: $e');
      // Rethrow to allow the UI to handle it
      throw Exception('Failed to update sales order: ${e.toString()}');
    }
  }

  // Delete a sales order
  Future<void> deleteSalesOrder(String orderId) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // In a real implementation, this would send a DELETE request to the backend
      // Example: final response = await http.delete(Uri.parse('$apiBaseUrl/sales-orders/$orderId'));

      // For demo purposes, remove from local list
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index >= 0) {
        _orders.removeAt(index);
      } else {
        throw Exception('Sales order not found');
      }
    } catch (e) {
      // Log the error
      print('Error deleting sales order: $e');
      // Rethrow to allow the UI to handle it
      throw Exception('Failed to delete sales order: ${e.toString()}');
    }
  }
}

class ProductService {
  Future<List<Product>> getProducts() async {
    // Implementation would connect to backend API
    await Future.delayed(const Duration(seconds: 1));

    // Return sample data for demo
    return [
      Product(
        id: 'p1',
        name: 'Wireless Bluetooth Headphones',
        sku: 'SKU-001',
        price: 79.99,
        description: 'High-quality wireless headphones with noise cancellation',
        stockQuantity: 45,
      ),
      Product(
        id: 'p2',
        name: 'USB-C Fast Charging Cable',
        sku: 'SKU-002',
        price: 14.99,
        description: '6ft USB-C charging cable with fast charging support',
        stockQuantity: 120,
      ),
      Product(
        id: 'p3',
        name: 'Smartphone Power Bank 10000mAh',
        sku: 'SKU-003',
        price: 49.99,
        description: 'Portable power bank with dual USB ports',
        stockQuantity: 78,
      ),
      Product(
        id: 'p4',
        name: 'Wireless Mouse',
        sku: 'SKU-004',
        price: 29.99,
        description: 'Ergonomic wireless mouse with long battery life',
        stockQuantity: 56,
      ),
      Product(
        id: 'p5',
        name: 'Smart Watch',
        sku: 'SKU-005',
        price: 149.99,
        description: 'Smart watch with heart rate monitor and GPS',
        stockQuantity: 34,
      ),
    ];
  }
}

class CustomerService {
  Future<List<Customer>> getCustomers() async {
    // Implementation would connect to backend API
    await Future.delayed(const Duration(seconds: 1));

    // Return sample data for demo
    return [
      Customer(
        id: 'c1',
        name: 'John Smith',
        email: 'john.smith@example.com',
        phone: '(555) 123-4567',
        address: '123 Main St, Anytown, CA 94001',
      ),
      Customer(
        id: 'c2',
        name: 'Jane Doe',
        email: 'jane.doe@example.com',
        phone: '(555) 987-6543',
        address: '456 Oak Ave, Somewhere, NY 10001',
      ),
      Customer(
        id: 'c3',
        name: 'Robert Johnson',
        email: 'robert.johnson@example.com',
        phone: '(555) 456-7890',
        address: '789 Pine Rd, Nowhere, TX 75001',
      ),
      Customer(
        id: 'c4',
        name: 'Emily Wilson',
        email: 'emily.wilson@example.com',
        phone: '(555) 321-0987',
        address: '321 Elm Blvd, Anywhere, IL 60001',
      ),
      Customer(
        id: 'c5',
        name: 'Michael Brown',
        email: 'michael.brown@example.com',
        phone: '(555) 789-4561',
        address: '654 Maple Dr, Everywhere, FL 33101',
      ),
    ];
  }
}

void main(List<String> args) {
  runApp(
    const ProviderScope(child: MaterialApp(home: CreateSalesOrderScreen())),
  );
}
