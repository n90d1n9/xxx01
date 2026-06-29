import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class Ecomhom2 extends StatefulWidget {
  const Ecomhom2({Key? key}) : super(key: key);

  @override
  State<Ecomhom2> createState() => _Ecomhom2State();
}

class _Ecomhom2State extends State<Ecomhom2> {
  final List<String> imgList = [
    'assets/bag_1.png',
    'assets/bag_2.png',
    'assets/bag_3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.black),
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Cari sofa',
            prefixIcon: Icon(Icons.search, color: Colors.black),
            border: InputBorder.none,
          ),
        ),
        actions: [
          Icon(Icons.favorite, color: Colors.black),
          SizedBox(width: 16),
          Stack(
            children: [
              Icon(Icons.notifications, color: Colors.black),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '1',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
          Icon(Icons.shopping_cart, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ATARU',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'GAJIAN SERU',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Diskon',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '85 + 5',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Potongan hingga',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Rp 50 Ribu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ATABUP0Y1234',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text('BELI SEKARANG'),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'S&K Berlaku. Periode Promo: 23-31 Maret 2024',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Carousel
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                enlargeCenterPage: true,
                viewportFraction: 0.8,
              ),
              items: imgList.map((item) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(item),
                    fit: BoxFit.cover,
                  ),
                ),
              )).toList(),
            ),
            SizedBox(height: 16),
            // Promo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Lihat Semua Promo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Grid
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildGridItem(
                  icon: Icons.local_offer,
                  title: '29 Voucher',
                ),
                _buildGridItem(
                  icon: Icons.star,
                  title: 'rewards',
                  subtitle: 'Silver\n23.845 Koin',
                ),
                _buildGridItem(
                  icon: Icons.grid_on,
                  title: 'Rupa Lainnya',
                ),
                _buildGridItem(
                  icon: Icons.star,
                  title: 'Tantangan Seru',
                  isnew: true,
                ),
                _buildGridItem(
                  icon: Icons.chair,
                  title: 'Furnitur',
                ),
                _buildGridItem(
                  icon: Icons.table_chart,
                  title: 'Rak dan Penyimpanan',
                ),
                _buildGridItem(
                  icon: Icons.kitchen,
                  title: 'Dapur Minimalis',
                ),
                _buildGridItem(
                  icon: Icons.electric_car,
                  title: 'Elek Ga',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isnew = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: Colors.red),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null)
            SizedBox(height: 4),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          if (isnew)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'NEW',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}