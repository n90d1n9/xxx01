import 'dart:developer' as developer;

import '../../../product/models/product.dart';
import '../models/customer.dart';
import '../../order/models/order.dart';
import '../../order/utils/order_payload_envelope.dart';
import '../../promotion/models/promotion.dart';
import '../models/terminal.dart';

class ApiService {
  // Mocked API calls for demonstration
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Product(
        id: '1',
        name: 'MacBook Pro 16"',
        price: 2499.99,
        image: 'assets/images/macbook.png',
        category: 'Electronics',
        systemStock: 15,
        barcode: '8901234567890',
      ),
      Product(
        id: '2',
        name: 'iPhone 15 Pro',
        price: 999.99,
        image: 'assets/images/iphone.png',
        category: 'Electronics',
        systemStock: 25,
        barcode: '7890123456789',
      ),
      Product(
        id: '3',
        name: 'AirPods Pro',
        price: 249.99,
        image: 'assets/images/airpods.png',
        category: 'Electronics',
        systemStock: 30,
        barcode: '6789012345678',
      ),
      Product(
        id: '4',
        name: 'Nike Air Max',
        price: 129.99,
        image: 'assets/images/nike.png',
        category: 'Footwear',
        systemStock: 50,
        barcode: '5678901234567',
      ),
      Product(
        id: '5',
        name: 'Coffee Mug',
        price: 12.99,
        image: 'assets/images/mug.png',
        category: 'Kitchenware',
        systemStock: 100,
        barcode: '4567890123456',
      ),
    ];
  }

  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allProducts = await getProducts();
    final lowercaseQuery = query.toLowerCase();

    return allProducts
        .where(
          (product) =>
              product.name.toLowerCase().contains(lowercaseQuery) ||
              (product.barcode ?? '').contains(query),
        )
        .toList();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allProducts = await getProducts();

    return allProducts
        .where((product) => product.category == category)
        .toList();
  }

  Future<List<String>> getProductCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      'All',
      'Electronics',
      'Footwear',
      'Kitchenware',
      'Apparel',
      'Books',
    ];
  }

  Future<List<Customer>> getCustomers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Customer(
        id: '1',
        name: 'John Doe',
        phone: '123-456-7890',
        email: 'john.doe@example.com',
        loyaltyPoints: 150,
      ),
      Customer(
        id: '2',
        name: 'Jane Smith',
        phone: '987-654-3210',
        email: 'jane.smith@example.com',
        loyaltyPoints: 320,
      ),
      Customer(
        id: '3',
        name: 'Bob Johnson',
        phone: '555-123-4567',
        email: 'bob.j@example.com',
        loyaltyPoints: 75,
      ),
    ];
  }

  Future<List<Customer>> searchCustomers(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allCustomers = await getCustomers();
    final lowercaseQuery = query.toLowerCase();

    return allCustomers
        .where(
          (customer) =>
              customer.name.toLowerCase().contains(lowercaseQuery) ||
              customer.phone.contains(query) ||
              customer.email.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  Future<List<Promotion>> getActivePromotions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return [
      Promotion(
        id: '1',
        name: 'Spring Sale',
        code: 'SPRING25',
        discountPercentage: 25,
        discountAmount: 0,
        isActive: true,
        validUntil: now.add(const Duration(days: 15)),
      ),
      Promotion(
        id: '2',
        name: 'Electronics Discount',
        code: 'ELEC50',
        discountPercentage: 10,
        discountAmount: 50,
        isActive: true,
        validUntil: now.add(const Duration(days: 7)),
      ),
      Promotion(
        id: '3',
        name: 'New Customer',
        code: 'WELCOME15',
        discountPercentage: 15,
        discountAmount: 0,
        isActive: true,
        validUntil: now.add(const Duration(days: 30)),
      ),
    ];
  }

  Future<List<Terminal>> getTerminals() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      Terminal(
        id: '1',
        name: 'Terminal 1',
        location: 'Main Floor',
        isActive: true,
      ),
      Terminal(
        id: '2',
        name: 'Terminal 2',
        location: 'Second Floor',
        isActive: true,
      ),
      Terminal(
        id: '3',
        name: 'Terminal 3',
        location: 'Warehouse',
        isActive: false,
      ),
    ];
  }

  Future<void> saveOrder(Order order) async {
    final envelope = order.toPOSPayloadEnvelope();
    await saveOrderEnvelope(envelope);
  }

  Future<void> saveOrderEnvelope(POSOrderPayloadEnvelope envelope) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    // In a real app, this would save to a backend
    developer.log(
      'Order saved: ${envelope.payload['id']} (${envelope.idempotencyKey})',
      name: 'POSApiService',
    );
  }
}
