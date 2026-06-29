import 'package:flutter/material.dart';

class Checkout3 extends StatefulWidget {
  const Checkout3({Key? key}) : super(key: key);

  @override
  State<Checkout3> createState() => _Checkout3State();
}

class _Checkout3State extends State<Checkout3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Keranjang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          CartItem(
            title: 'FunToys711',
            imageUrl: 'assets/images/keychain.jpg',
            price: 'Rp49.000',
            quantity: 1,
            isPro: true,
            beliRp: 'Rp20rb',
            bebasOngkir: true,
          ),
          CartItem(
            title: 'BIO SQUALENE ASLI',
            imageUrl: 'assets/images/squalene.jpg',
            price: 'Rp110.000',
            quantity: 1,
            isPro: true,
            beliRp: 'Rp30rb',
            bebasOngkir: true,
          ),
          CartItem(
            title: 'MINIPOS Indonesia',
            imageUrl: 'assets/images/barcode_scanner.jpg',
            price: 'Rp597.500',
            quantity: 1,
            isPro: true,
            beliRp: 'Rp30rb',
            bebasOngkir: true,
            discount: 'Rp668.000',
          ),
          CartItem(
            title: 'Iware Official Store',
            imageUrl: 'assets/images/barcode_scanner_2.jpg',
            price: 'Rp325.000',
            quantity: 1,
            isPro: false,
            beliRp: 'Rp30rb',
            bebasOngkir: true,
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Pilih barang dulu sebelum pakai promo',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                const Text('Semua'),
                const Text('Total'),
                const Text('-'),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Beli'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String price;
  final int quantity;
  final bool isPro;
  final String beliRp;
  final bool bebasOngkir;
  final String? discount;

  const CartItem({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.isPro,
    required this.beliRp,
    required this.bebasOngkir,
    this.discount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: false,
              onChanged: (value) {},
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isPro)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8.0),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Image.asset(
                    imageUrl,
                    height: 80.0,
                    width: 80.0,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Rp$price',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (discount != null)
                    Text(
                      'Rp$discount',
                      style: const TextStyle(
                        fontSize: 12.0,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite),
                        onPressed: () {},
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {},
                            ),
                            Text('$quantity'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'BELI $beliRp',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                        ),
                      ),
                      if (bebasOngkir)
                        Text(
                          'BEBAS ONGKIR',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.0,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}