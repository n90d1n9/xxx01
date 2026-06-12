import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:async';

// Models
enum DeliveryType { pickup, delivery }

class DeliveryAddress {
  final String address;
  final String city;
  final String zipCode;

  DeliveryAddress({
    required this.address,
    required this.city,
    required this.zipCode,
  });
}

class Order {
  final DeliveryType type;
  final DeliveryAddress? address;
  final DateTime scheduledTime;

  Order({required this.type, this.address, required this.scheduledTime});
}

// Providers
final deliveryTypeProvider = StateProvider<DeliveryType>(
  (ref) => DeliveryType.delivery,
);

final selectedTimeProvider = StateProvider<DateTime>((ref) {
  // Default to the next available time slot (now + 30 min)
  final now = DateTime.now();
  return DateTime(
    now.year,
    now.month,
    now.day,
    now.hour,
    (now.minute ~/ 30 + 1) * 30,
  );
});

final deliveryAddressProvider = StateProvider<DeliveryAddress?>((ref) => null);

final orderProvider = Provider<Order>((ref) {
  final type = ref.watch(deliveryTypeProvider);
  final time = ref.watch(selectedTimeProvider);
  final address = ref.watch(deliveryAddressProvider);

  return Order(
    type: type,
    address: type == DeliveryType.delivery ? address : null,
    scheduledTime: time,
  );
});

// Creating an order
final orderProcessingProvider = FutureProvider.autoDispose<bool>((ref) async {
  final order = ref.watch(orderProvider);
  // Simulate network request
  await Future.delayed(const Duration(seconds: 2));
  return true;
});

// UI Components
class DeliveryOptionButton extends ConsumerWidget {
  final DeliveryType type;
  final IconData icon;
  final String label;

  const DeliveryOptionButton({
    Key? key,
    required this.type,
    required this.icon,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(deliveryTypeProvider);
    final isSelected = type == selectedType;

    return GestureDetector(
      onTap: () => ref.read(deliveryTypeProvider.notifier).state = type,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade700,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeSlotPicker extends ConsumerWidget {
  const TimeSlotPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTime = ref.watch(selectedTimeProvider);

    // Generate time slots for the next 24 hours in 30-minute intervals
    final now = DateTime.now();
    final startTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      (now.minute ~/ 30 + 1) * 30,
    );
    final timeSlots = List.generate(
      48, // 24 hours * 2 (30-minute intervals)
      (index) => startTime.add(Duration(minutes: 30 * index)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: timeSlots.length,
            itemBuilder: (context, index) {
              final time = timeSlots[index];
              final isSelected =
                  time.hour == selectedTime.hour &&
                  time.minute == selectedTime.minute;

              return GestureDetector(
                onTap: () =>
                    ref.read(selectedTimeProvider.notifier).state = time,
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AddressForm extends ConsumerWidget {
  const AddressForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final address = ref.watch(deliveryAddressProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Address',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: address?.address ?? '',
          decoration: InputDecoration(
            labelText: 'Address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
          onChanged: (value) {
            final current = ref.read(deliveryAddressProvider);
            ref.read(deliveryAddressProvider.notifier).state = DeliveryAddress(
              address: value,
              city: current?.city ?? '',
              zipCode: current?.zipCode ?? '',
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: address?.city ?? '',
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onChanged: (value) {
                  final current = ref.read(deliveryAddressProvider);
                  ref
                      .read(deliveryAddressProvider.notifier)
                      .state = DeliveryAddress(
                    address: current?.address ?? '',
                    city: value,
                    zipCode: current?.zipCode ?? '',
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: TextFormField(
                initialValue: address?.zipCode ?? '',
                decoration: InputDecoration(
                  labelText: 'Zip Code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onChanged: (value) {
                  final current = ref.read(deliveryAddressProvider);
                  ref
                      .read(deliveryAddressProvider.notifier)
                      .state = DeliveryAddress(
                    address: current?.address ?? '',
                    city: current?.city ?? '',
                    zipCode: value,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PickupDeliveryScreen extends ConsumerWidget {
  const PickupDeliveryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryType = ref.watch(deliveryTypeProvider);
    final orderProcessing = ref.watch(orderProcessingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Order'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How would you like to receive your order?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(
                    child: DeliveryOptionButton(
                      type: DeliveryType.pickup,
                      icon: Icons.store,
                      label: 'Pickup',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: DeliveryOptionButton(
                      type: DeliveryType.delivery,
                      icon: Icons.delivery_dining,
                      label: 'Delivery',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const TimeSlotPicker(),
              const SizedBox(height: 24),
              if (deliveryType == DeliveryType.delivery) const AddressForm(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: orderProcessing.isLoading
                      ? null
                      : () => ref.refresh(orderProcessingProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: orderProcessing.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Place Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (orderProcessing.hasValue) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600),
                      const SizedBox(width: 12),
                      Text(
                        'Order placed successfully!',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Main App
class PickupDeliveryApp extends ConsumerWidget {
  const PickupDeliveryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Pickup & Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF5C6BC0),
        scaffoldBackgroundColor: Colors.grey.shade50,
        fontFamily: 'Poppins',
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.grey.shade50,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const PickupDeliveryScreen(),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: PickupDeliveryApp()));
}
