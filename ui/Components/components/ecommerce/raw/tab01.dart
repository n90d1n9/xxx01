import 'package:flutter/material.dart';

class Tab01 extends StatefulWidget {
  const Tab01({Key? key}) : super(key: key);

  @override
  State<Tab01> createState() => _Tab01State();
}

class _Tab01State extends State<Tab01>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

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
        title: const Text('Kategori'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Yang Lagi Hits'),
            Tab(text: 'Sering Kamu Lihat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          GridView.count(
            crossAxisCount: 3,
            children: [
              CategoryItem(
                icon: Icons.restaurant_menu,
                title: 'Dapur',
              ),
              CategoryItem(
                icon: Icons.person,
                title: 'Fashion Pria',
              ),
              CategoryItem(
                icon: Icons.woman,
                title: 'Fashion Wanita',
              ),
              CategoryItem(
                icon: Icons.baby_changing_station,
                title: 'Ibu & Bayi',
              ),
              CategoryItem(
                icon: Icons.restaurant_menu,
                title: 'Dapur',
              ),
              CategoryItem(
                icon: Icons.health_and_safety,
                title: 'Kesehatan',
              ),
              CategoryItem(
                icon: Icons.restaurant_menu,
                title: 'Makanan & Minuman',
              ),
            ],
          ),
          GridView.count(
            crossAxisCount: 3,
            children: [
              CategoryItem(
                icon: Icons.person,
                title: 'Fashion Anak & Bayi',
              ),
              CategoryItem(
                icon: Icons.woman,
                title: 'Fashion Muslim',
              ),
              CategoryItem(
                icon: Icons.woman,
                title: 'Gamis Wanita',
              ),
              CategoryItem(
                icon: Icons.phone_android,
                title: 'Soft Case Handphone',
              ),
              CategoryItem(
                icon: Icons.baby_changing_station,
                title: 'Popok Sekali Pakai',
              ),
              CategoryItem(
                icon: Icons.person,
                title: 'Fashion Pria',
              ),
              CategoryItem(
                icon: Icons.woman,
                title: 'Lipstik',
              ),
              CategoryItem(
                icon: Icons.local_pharmacy,
                title: 'Obat Herbal',
              ),
              CategoryItem(
                icon: Icons.coffee,
                title: 'Kopi Kemasan',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  const CategoryItem({Key? key, required this.icon, required this.title})
      : super(key: key);

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 10),
          Text(title),
        ],
      ),
    );
  }
}