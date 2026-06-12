import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';

// Models
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });
}

class DeliveryAddress {
  final String street;
  final String city;
  final String state;
  final String zipCode;

  DeliveryAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  String get fullAddress => '$street, $city, $state $zipCode';
}

class PaymentMethod {
  final String id;
  final String type;
  final String lastFourDigits;
  final String cardHolderName;
  final String expiryDate;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.lastFourDigits,
    required this.cardHolderName,
    required this.expiryDate,
  });
}

// Providers
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier()
    : super([
        CartItem(
          id: '1',
          name: 'Premium Wireless Earbuds',
          price: 129.99,
          quantity: 1,
          imageUrl: 'assets/earbuds.png',
        ),
        CartItem(
          id: '2',
          name: 'Smart Fitness Tracker',
          price: 89.95,
          quantity: 1,
          imageUrl: 'assets/tracker.png',
        ),
      ]);

  void updateQuantity(String id, int quantity) {
    state = [
      for (final item in state)
        if (item.id == id)
          CartItem(
            id: item.id,
            name: item.name,
            price: item.price,
            quantity: quantity,
            imageUrl: item.imageUrl,
          )
        else
          item,
    ];
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final selectedDeliveryAddressProvider = StateProvider<DeliveryAddress?>((ref) {
  return DeliveryAddress(
    street: '123 Main Street',
    city: 'San Francisco',
    state: 'CA',
    zipCode: '94105',
  );
});

final selectedPaymentMethodProvider = StateProvider<PaymentMethod?>((ref) {
  return PaymentMethod(
    id: '1',
    type: 'Visa',
    lastFourDigits: '4242',
    cardHolderName: 'Jamie Smith',
    expiryDate: '05/27',
  );
});

final deliveryOptionsProvider = StateProvider<String>((ref) {
  return 'standard';
});

final promoCodeProvider = StateProvider<String>((ref) {
  return '';
});

final checkoutStepProvider = StateProvider<int>((ref) {
  return 0;
});

final isProcessingPaymentProvider = StateProvider<bool>((ref) {
  return false;
});

// Checkout Screen
class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(checkoutStepProvider);
    final isProcessing = ref.watch(isProcessingPaymentProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Checkout',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (currentStep > 0) {
              ref.read(checkoutStepProvider.notifier).state--;
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: isProcessing
          ? const ProcessingPaymentView()
          : Column(
              children: [
                CheckoutStepper(currentStep: currentStep),
                Expanded(child: _buildStepContent(currentStep, ref, context)),
              ],
            ),
    );
  }

  Widget _buildStepContent(int step, WidgetRef ref, BuildContext context) {
    switch (step) {
      case 0:
        return const CartReviewStep();
      case 1:
        return const DeliveryStep();
      case 2:
        return const PaymentStep();
      case 3:
        return const OrderSummaryStep();
      default:
        return const CartReviewStep();
    }
  }
}

class CheckoutStepper extends StatelessWidget {
  final int currentStep;

  const CheckoutStepper({Key? key, required this.currentStep})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepCircle(0, 'Cart', currentStep >= 0),
          _buildStepConnector(currentStep > 0),
          _buildStepCircle(1, 'Delivery', currentStep >= 1),
          _buildStepConnector(currentStep > 1),
          _buildStepCircle(2, 'Payment', currentStep >= 2),
          _buildStepConnector(currentStep > 2),
          _buildStepCircle(3, 'Review', currentStep >= 3),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? Colors.purple : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(_getStepIcon(step), color: Colors.white, size: 16),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black87 : Colors.grey,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 40,
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isActive ? Colors.purple : Colors.grey[300],
    );
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 0:
        return Icons.shopping_cart;
      case 1:
        return Icons.local_shipping;
      case 2:
        return Icons.payment;
      case 3:
        return Icons.check_circle;
      default:
        return Icons.circle;
    }
  }
}

class CartReviewStep extends ConsumerWidget {
  const CartReviewStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalPrice = cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Cart',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemCard(item: item);
                    },
                  ),
          ),
          const SizedBox(height: 20),
          // Coupon Code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Promo Code',
                      border: InputBorder.none,
                      isDense: true,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    onChanged: (value) {
                      ref.read(promoCodeProvider.notifier).state = value;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Apply promo code logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Order Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal'),
                    Text('\$${totalPrice.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('Shipping'), const Text('\$4.99')],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax'),
                    Text('\$${(totalPrice * 0.08).toStringAsFixed(2)}'),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '\$${(totalPrice + 4.99 + (totalPrice * 0.08)).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(checkoutStepProvider.notifier).state = 1;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue to Delivery',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemCard extends ConsumerWidget {
  final CartItem item;

  const CartItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(Icons.image, color: Colors.grey[400], size: 32),
            ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.purple[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (item.quantity > 1) {
                          ref
                              .read(cartProvider.notifier)
                              .updateQuantity(item.id, item.quantity - 1);
                        }
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.remove, size: 16),
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 28,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ref
                            .read(cartProvider.notifier)
                            .updateQuantity(item.id, item.quantity + 1);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.add, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Remove Button
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              ref.read(cartProvider.notifier).removeItem(item.id);
            },
            color: Colors.grey,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class DeliveryStep extends ConsumerWidget {
  const DeliveryStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAddress = ref.watch(selectedDeliveryAddressProvider);
    final deliveryOption = ref.watch(deliveryOptionsProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Shipping Address
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Edit address logic
                      },
                      child: const Text(
                        'Change',
                        style: TextStyle(color: Colors.purple),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (selectedAddress != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jamie Smith',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(selectedAddress.street),
                      const SizedBox(height: 2),
                      Text(
                        '${selectedAddress.city}, ${selectedAddress.state} ${selectedAddress.zipCode}',
                      ),
                      const SizedBox(height: 4),
                      const Text('United States'),
                      const SizedBox(height: 4),
                      const Text('+1 (555) 123-4567'),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Delivery Options
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Options',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DeliveryOptionTile(
                  title: 'Standard Delivery',
                  subtitle: '3-5 Business Days',
                  price: '\$4.99',
                  value: 'standard',
                  groupValue: deliveryOption,
                  onChanged: (value) {
                    ref.read(deliveryOptionsProvider.notifier).state = value!;
                  },
                ),
                const Divider(height: 1),
                DeliveryOptionTile(
                  title: 'Express Delivery',
                  subtitle: '1-2 Business Days',
                  price: '\$9.99',
                  value: 'express',
                  groupValue: deliveryOption,
                  onChanged: (value) {
                    ref.read(deliveryOptionsProvider.notifier).state = value!;
                  },
                ),
                const Divider(height: 1),
                DeliveryOptionTile(
                  title: 'Next Day Delivery',
                  subtitle: 'Next Business Day',
                  price: '\$14.99',
                  value: 'nextday',
                  groupValue: deliveryOption,
                  onChanged: (value) {
                    ref.read(deliveryOptionsProvider.notifier).state = value!;
                  },
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(checkoutStepProvider.notifier).state = 2;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue to Payment',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                ref.read(checkoutStepProvider.notifier).state = 0;
              },
              child: const Text(
                'Back to Cart',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String value;
  final String groupValue;
  final Function(String?) onChanged;

  const DeliveryOptionTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 12),
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: Colors.purple,
          ),
        ],
      ),
    );
  }
}

class PaymentStep extends ConsumerWidget {
  const PaymentStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPaymentMethod = ref.watch(selectedPaymentMethodProvider);
    final cartItems = ref.watch(cartProvider);
    final deliveryOption = ref.watch(deliveryOptionsProvider);

    double deliveryPrice = 4.99;
    if (deliveryOption == 'express') {
      deliveryPrice = 9.99;
    } else if (deliveryOption == 'nextday') {
      deliveryPrice = 14.99;
    }

    final subtotal = cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final tax = subtotal * 0.08;
    final total = subtotal + tax + deliveryPrice;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Payment Methods
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Credit/Debit Card',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Add new card logic
                      },
                      child: const Text(
                        'Add New',
                        style: TextStyle(color: Colors.purple),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (selectedPaymentMethod != null)
                  PaymentMethodTile(
                    type: selectedPaymentMethod.type,
                    lastFourDigits: selectedPaymentMethod.lastFourDigits,
                    expiryDate: selectedPaymentMethod.expiryDate,
                    cardHolderName: selectedPaymentMethod.cardHolderName,
                    isSelected: true,
                  ),
                const SizedBox(height: 8),
                PaymentMethodTile(
                  type: 'Mastercard',
                  lastFourDigits: '6789',
                  expiryDate: '08/26',
                  cardHolderName: 'Jamie Smith',
                  isSelected: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Billing Address
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Billing Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: true,
                        onChanged: (value) {},
                        activeColor: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Same as shipping address'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Order Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal'),
                    Text('\$${subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Shipping'),
                    Text('\$${deliveryPrice.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax'),
                    Text('\$${tax.toStringAsFixed(2)}'),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(checkoutStepProvider.notifier).state = 3;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Review Order', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                ref.read(checkoutStepProvider.notifier).state = 1;
              },
              child: const Text(
                'Back to Delivery',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodTile extends StatelessWidget {
  final String type;
  final String lastFourDigits;
  final String expiryDate;
  final String cardHolderName;
  final bool isSelected;

  const PaymentMethodTile({
    Key? key,
    required this.type,
    required this.lastFourDigits,
    required this.expiryDate,
    required this.cardHolderName,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.purple : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              color: type == 'Visa'
                  ? Colors.blue.shade700
                  : Colors.red.shade700,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                type,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•••• •••• •••• $lastFourDigits',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expires $expiryDate',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  cardHolderName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Radio<bool>(
            value: true,
            groupValue: isSelected,
            onChanged: (value) {},
            activeColor: Colors.purple,
          ),
        ],
      ),
    );
  }
}

class OrderSummaryStep extends ConsumerWidget {
  const OrderSummaryStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final selectedAddress = ref.watch(selectedDeliveryAddressProvider);
    final selectedPaymentMethod = ref.watch(selectedPaymentMethodProvider);
    final deliveryOption = ref.watch(deliveryOptionsProvider);

    double deliveryPrice = 4.99;
    if (deliveryOption == 'express') {
      deliveryPrice = 9.99;
    } else if (deliveryOption == 'nextday') {
      deliveryPrice = 14.99;
    }

    String deliveryName = 'Standard Delivery (3-5 Business Days)';
    if (deliveryOption == 'express') {
      deliveryName = 'Express Delivery (1-2 Business Days)';
    } else if (deliveryOption == 'nextday') {
      deliveryName = 'Next Day Delivery (Next Business Day)';
    }

    final subtotal = cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final tax = subtotal * 0.08;
    final total = subtotal + tax + deliveryPrice;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Items
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Items',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...cartItems
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.grey[400],
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Quantity: ${item.quantity}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Shipping Information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shipping Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Delivery Address',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (selectedAddress != null)
                                    Text(
                                      'Jamie Smith\n${selectedAddress.street}\n${selectedAddress.city}, ${selectedAddress.state} ${selectedAddress.zipCode}\nUnited States\n+1 (555) 123-4567',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        height: 1.4,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.local_shipping_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Delivery Method',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    deliveryName,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${deliveryPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Payment Information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.credit_card_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Payment Method',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (selectedPaymentMethod != null)
                                    Text(
                                      '${selectedPaymentMethod.type} ending in ${selectedPaymentMethod.lastFourDigits}\nExpires ${selectedPaymentMethod.expiryDate}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        height: 1.4,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.receipt_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Billing Address',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (selectedAddress != null)
                                    Text(
                                      'Same as shipping address',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Order Total
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal'),
                            Text('\$${subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Shipping'),
                            Text('\$${deliveryPrice.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tax'),
                            Text('\$${tax.toStringAsFixed(2)}'),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(isProcessingPaymentProvider.notifier).state = true;
                // Simulate payment processing
                Future.delayed(const Duration(seconds: 2), () {
                  ref.read(isProcessingPaymentProvider.notifier).state = false;
                  // Navigate to confirmation
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderConfirmationScreen(),
                    ),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Place Order', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                ref.read(checkoutStepProvider.notifier).state = 2;
              },
              child: const Text(
                'Back to Payment',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProcessingPaymentView extends StatelessWidget {
  const ProcessingPaymentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
          const SizedBox(height: 24),
          const Text(
            'Processing Payment',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Please wait while we process your payment...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class OrderConfirmationScreen extends ConsumerWidget {
  const OrderConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Generate a random order number
    final orderNumber =
        'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Order Confirmation',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            // Clear the cart and navigate home
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.purple,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Thank You!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order has been placed successfully',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Number',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        orderNumber,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimated Delivery',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        _getEstimatedDeliveryDate(ref),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'We\'ll send you a confirmation email shortly with your order details and tracking information.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // View order details
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple,
                      side: const BorderSide(color: Colors.purple),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('View Order'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Continue shopping
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Continue Shopping'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getEstimatedDeliveryDate(WidgetRef ref) {
    final deliveryOption = ref.watch(deliveryOptionsProvider);
    final now = DateTime.now();
    late DateTime estimatedDate;

    if (deliveryOption == 'nextday') {
      // Next business day
      estimatedDate = now.add(const Duration(days: 1));

      // Skip weekend
      if (estimatedDate.weekday == DateTime.saturday) {
        estimatedDate = estimatedDate.add(const Duration(days: 2));
      } else if (estimatedDate.weekday == DateTime.sunday) {
        estimatedDate = estimatedDate.add(const Duration(days: 1));
      }
    } else if (deliveryOption == 'express') {
      // 1-2 business days
      estimatedDate = now.add(const Duration(days: 2));
    } else {
      // Standard 3-5 business days
      estimatedDate = now.add(const Duration(days: 5));
    }

    // Format date as: Mar 15, 2025
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[estimatedDate.month - 1]} ${estimatedDate.day}, ${estimatedDate.year}';
  }
}

// Main entry point for the app
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'E-Commerce Checkout',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
      home: const CheckoutScreen(),
    );
  }
}
