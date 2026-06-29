
import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: const Text('Search'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Find services, food, or places',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Your history',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: const [
                  Chip(
                    label: Text('ticket'),
                  ),
                  Chip(
                    label: Text('tick'),
                  ),
                  Chip(
                    label: Text('stas'),
                  ),
                  Chip(
                    label: Text('grand hyatt'),
                  ),
                  Chip(
                    label: Text('grand hyat'),
                  ),
                  Chip(
                    label: Text('grand hya'),
                  ),
                  Chip(
                    label: Text('grand hy'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Search by category',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: const [
                      Icon(Icons.restaurant),
                      Text('Restaurants'),
                    ],
                  ),
                  Column(
                    children: const [
                      Icon(Icons.location_pin),
                      Text('Places'),
                    ],
                  ),
                  Column(
                    children: const [
                      Icon(Icons.shopping_cart),
                      Text('Groceries'),
                    ],
                  ),
                  Column(
                    children: const [
                      Icon(Icons.person_pin),
                      Text('Services'),
                    ],
                  ),
                  Column(
                    children: const [
                      Icon(Icons.payment),
                      Text('Bills'),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Discover all the good eats on GoFood',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 200.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.yellow[200],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Butuh makan dianter cepat?',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Pesan dari resto terdekat',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1565958011703-44f9758f9440?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Trending searches',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: const [
                  Chip(
                    label: Text('chatime'),
                  ),
                  Chip(
                    label: Text('martabak'),
                  ),
                  Chip(
                    label: Text('salad buah'),
                  ),
                  Chip(
                    label: Text('geprek bensu'),
                  ),
                  Chip(
                    label: Text('pempek'),
                  ),
                  Chip(
                    label: Text('mcd'),
                  ),
                  Chip(
                    label: Text('kfc'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}