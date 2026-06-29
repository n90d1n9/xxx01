
import 'package:flutter/material.dart';

class Tab02 extends StatefulWidget {
  const Tab02({Key? key}) : super(key: key);

  @override
  State<Tab02> createState() => _Tab02State();
}

class _Tab02State extends State<Tab02>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Untukmu'),
              Tab(text: 'Rumah Tangga'),
              Tab(text: 'Others'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Untukmu
                GridView.count(
                  crossAxisCount: 3,
                  children: [
                    _buildCategoryItem(
                      icon: Icons.shopping_bag,
                      title: 'Pilihan Untukmu',
                    ),
                    _buildCategoryItem(
                      icon: Icons.kitchen,
                      title: 'Dapur',
                    ),
                    _buildCategoryItem(
                      icon: Icons.person,
                      title: 'Fashion Pria',
                    ),
                    _buildCategoryItem(
                      icon: Icons.camera_alt,
                      title: 'Audio, Kamera & Elektronik',
                    ),
                    _buildCategoryItem(
                      icon: Icons.woman,
                      title: 'Fashion Wanita',
                    ),
                    _buildCategoryItem(
                      icon: Icons.baby_changing_station,
                      title: 'Ibu & Bayi',
                    ),
                    _buildCategoryItem(
                      icon: Icons.book,
                      title: 'Buku',
                    ),
                    _buildCategoryItem(
                      icon: Icons.health_and_safety,
                      title: 'Kesehatan',
                    ),
                    _buildCategoryItem(
                      icon: Icons.restaurant_menu,
                      title: 'Makanan & Minuman',
                    ),
                  ],
                ),
                // Rumah Tangga
                GridView.count(
                  crossAxisCount: 3,
                  children: [
                    _buildCategoryItem(
                      icon: Icons.person,
                      title: 'Fashion Anak & Bayi',
                    ),
                    _buildCategoryItem(
                      icon: Icons.person,
                      title: 'Fashion Muslim',
                    ),
                    _buildCategoryItem(
                      icon: Icons.woman,
                      title: 'Gamis Wanita',
                    ),
                    _buildCategoryItem(
                      icon: Icons.phone_android,
                      title: 'Soft Case Handphone',
                    ),
                    _buildCategoryItem(
                      icon: Icons.baby_changing_station,
                      title: 'Popok Sekali Pakai',
                    ),
                    _buildCategoryItem(
                      icon: Icons.person,
                      title: 'Fashion Pria',
                    ),
                    _buildCategoryItem(
                      icon: Icons.woman,
                      title: 'Fashion Wanita',
                    ),
                    _buildCategoryItem(
                      icon: Icons.link_sharp,
                      title: 'Lipstik',
                    ),
                    _buildCategoryItem(
                      icon: Icons.local_pharmacy,
                      title: 'Obat Herbal',
                    ),
                    _buildCategoryItem(
                      icon: Icons.coffee,
                      title: 'Kopi Kemasan',
                    ),
                  ],
                ),
                // Others
                GridView.count(
                  crossAxisCount: 3,
                  children: [
                    _buildCategoryItem(
                      icon: Icons.kitchen,
                      title: 'Dapur',
                    ),
                    _buildCategoryItem(
                      icon: Icons.headset,
                      title: 'Elektronik',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({required IconData icon, required String title}) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to the category page
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}