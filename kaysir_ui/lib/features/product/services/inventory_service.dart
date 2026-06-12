import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../models/product.dart';

// Sample Product model if you don't have one already
/* class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String image;
  final int stockQuantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.image,
    required this.stockQuantity,
  });
}
 */
class InventoryService {
  // In a real app, this would likely fetch data from an API or database
  Future<List<Product>> fetchAllProducts() async {
    // Simulating network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return dummy data for demonstration
    return [
      Product(
        id: '1',
        name: 'Laptop',
        description: 'High performance laptop for developers',
        category: 'electronics',
        price: 1299.99,
        image: 'assets/images/laptop.jpg',
        stockQuantity: 15,
      ),
      Product(
        id: '2',
        name: 'Smartphone',
        description: 'Latest model with advanced camera',
        category: 'electronics',
        price: 899.99,
        image: 'assets/images/smartphone.jpg',
        stockQuantity: 25,
      ),
      Product(
        id: '3',
        name: 'Desk Chair',
        description: 'Ergonomic chair for home office',
        category: 'furniture',
        price: 249.99,
        image: 'assets/images/chair.jpg',
        stockQuantity: 8,
      ),
      Product(
        id: '4',
        name: 'Coffee Table',
        description: 'Modern design with storage space',
        category: 'furniture',
        price: 149.99,
        image: 'assets/images/table.jpg',
        stockQuantity: 5,
      ),
      Product(
        id: '5',
        name: 'Headphones',
        description: 'Noise cancelling wireless headphones',
        category: 'electronics',
        price: 199.99,
        image: 'assets/images/headphones.jpg',
        stockQuantity: 20,
      ),
      Product(
        id: '6',
        name: 'Bookshelf',
        description: 'Wooden bookshelf with 5 shelves',
        category: 'furniture',
        price: 179.99,
        image: 'assets/images/bookshelf.jpg',
        stockQuantity: 7,
      ),
      Product(
        id: '7',
        name: 'Smart Watch',
        description: 'Fitness and health tracking features',
        category: 'electronics',
        price: 249.99,
        image: 'assets/images/smartwatch.jpg',
        stockQuantity: 12,
      ),
      Product(
        id: '8',
        name: 'Desk Lamp',
        description: 'Adjustable LED desk lamp',
        category: 'furniture',
        price: 49.99,
        image: 'assets/images/lamp.jpg',
        stockQuantity: 18,
      ),
    ];
  }

  // Optional: Method to fetch products by category
  Future<List<Product>> fetchProductsByCategory(String category) async {
    final allProducts = await fetchAllProducts();
    if (category == 'all') {
      return allProducts;
    }
    return allProducts
        .where((product) => product.category == category)
        .toList();
  }

  // Optional: Method to get all available categories
  Future<List<String>> fetchCategories() async {
    final products = await fetchAllProducts();
    final categories =
        products.map((product) => product.category!).toSet().toList();
    return ['all', ...categories];
  }
}

// Provider for the inventory service
final inventoryServiceProvider = Provider<InventoryService>((ref) {
  return InventoryService();
});
