import 'package:flutter/material.dart';
import 'package:kayys_components/components/ecommerce/widgets/bcarousel.dart';
import 'package:kayys_components/components/ecommerce/widgets/grid_menu.dart';

import 'widgets/search_bar.dart';

class SyirkahHome extends StatefulWidget {
  const SyirkahHome({super.key});

  @override
  State<SyirkahHome> createState() => _SyirkahHomeState();
}

class _SyirkahHomeState extends State<SyirkahHome> {
  var valueCart = 0;
  var valueNotif = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BSearchBar(
            onTapCart: () {},
            onTapNotif: () {},
            onPressed: () {},
            valueCart: valueCart,
            valueNotif: valueNotif,
            onPressedQRcode: () {},
          ),
          SingleChildScrollView(
              child: Column(
            children: [
              BCarousel(slides: imgList),
              GridMenu(
                items: items,
              ),
            ],
          ))
        ],
      ),
    );
  }
}

var items = [
  GridItem(1, 'Syirkah', '/dashboard', Icons.abc_rounded),
  GridItem(2, 'Store', '/dashboard', Icons.abc_rounded),
  GridItem(3, 'Retail', '/dashboard', Icons.abc_rounded),
  GridItem(4, 'Akuntansi', '/dashboard', Icons.abc_rounded),
  GridItem(5, 'Tools', '/dashboard', Icons.abc_rounded),
  GridItem(6, 'judul6', '/dashboard', Icons.abc_rounded),
  GridItem(7, 'judul7', '/dashboard', Icons.abc_rounded),
];

final List<String> imgList = [
  'assets/bag_1.png',
  'assets/bag_2.png',
  'assets/bag_3.png',
];
