import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kayys_components/carousel/bcarousel.dart';
import 'package:kayys_components/menu/grid_menu.dart';
import 'package:kayys_components/search/search_bar.dart';


class SyirkahPage extends ConsumerStatefulWidget {
  const SyirkahPage({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  @override
  ConsumerState<SyirkahPage> createState() => _SyirkahPageState();
}

class _SyirkahPageState extends ConsumerState<SyirkahPage> {
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

