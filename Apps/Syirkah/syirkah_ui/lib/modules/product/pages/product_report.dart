import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class Product {
  final String code;
  final String name;
  final int qty;
  final int minimum;
  final String unit;
  final double price;
  final double lastPrice;
  final double sellPrice;

  Product({
    required this.code,
    required this.name,
    required this.qty,
    required this.minimum,
    required this.unit,
    required this.price,
    required this.lastPrice,
    required this.sellPrice,
  });
}

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier() : super([]);

  void addProduct(Product product) {
    state = [...state, product];
  }

  void updateProduct(Product product) {
    state = state.map((p) {
      if (p.code == product.code) {
        return product;
      }
      return p;
    }).toList();
  }

  void deleteProduct(String code) {
    state = state.where((p) => p.code != code).toList();
  }
}

final productProvider =
    StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier();
});

class ProductList extends ConsumerWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: Text(product.name),
            subtitle: Text('${product.qty} ${product.unit}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Rp. ${product.sellPrice}'),
                IconButton(
                  onPressed: () {
                    ref
                        .read(productProvider.notifier)
                        .deleteProduct(product.code);
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddProductScreen extends ConsumerWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController codeController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController qtyController = TextEditingController();
    final TextEditingController minimumController = TextEditingController();
    final TextEditingController unitController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController lastPriceController = TextEditingController();
    final TextEditingController sellPriceController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Code'),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(labelText: 'Qty'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: minimumController,
              decoration: const InputDecoration(labelText: 'Minimum'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(labelText: 'Unit'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: lastPriceController,
              decoration: const InputDecoration(labelText: 'Last Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: sellPriceController,
              decoration: const InputDecoration(labelText: 'Sell Price'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                final product = Product(
                  code: codeController.text,
                  name: nameController.text,
                  qty: int.parse(qtyController.text),
                  minimum: int.parse(minimumController.text),
                  unit: unitController.text,
                  price: double.parse(priceController.text),
                  lastPrice: double.parse(lastPriceController.text),
                  sellPrice: double.parse(sellPriceController.text),
                );
                ref.read(productProvider.notifier).addProduct(product);
                Navigator.pop(context);
              },
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
