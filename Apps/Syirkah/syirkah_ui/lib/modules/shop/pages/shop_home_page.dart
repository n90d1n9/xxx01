import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syirkah/modules/shop/pages/shop_page.dart';
import 'package:syirkah/modules/shop/shop_module.dart';

import '../../social_preneur/bloc/search_bloc.dart';
import '../models/grid_item.dart';

class ShopHomePage extends ConsumerStatefulWidget {
  const ShopHomePage({super.key});

  @override
  ConsumerState<ShopHomePage> createState() => _ShopHomePageState();
}

class _ShopHomePageState extends ConsumerState<ShopHomePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<GridItem> items = [
      GridItem(
          id: 1,
          title: 'Toko',
          path: ShopModule.shop,
          imagePath: 'assets/icons/toko.png'),
      GridItem(
          id: 2,
          title: 'Kasir',
          path: '/pos',
          imagePath: 'assets/icons/kasir.png'),
      GridItem(
          id: 3,
          title: 'Akuntasi',
          path: '',
          imagePath: 'assets/icons/akuntansi.png'),
          GridItem(
          id: 1,
          title: 'Toko',
          path: ShopModule.shop,
          imagePath: 'assets/icons/toko.png'),
      GridItem(
          id: 2,
          title: 'Kasir',
          path: '/pos',
          imagePath: 'assets/icons/kasir.png'),
    ];
    Color bgItemColor = Colors.white;
    ref.read(searchProvider.notifier).getData();
    //ref.read(appsState.notifier).atHome(false);
    return Material(
        child: Column(
      children: [
        shopHeader(),
        const SizedBox(height: 10,),
        Expanded(
            child: SingleChildScrollView(
                child:
        GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            children: items
                .map((el) => _item(el.id, el.title, el.path, el.icon,
                    el.imagePath, el.color ?? bgItemColor))
                .toList())))
      ],
    ));
  }

  Widget shopHeader() => Container(
        height: 200,
        decoration: const BoxDecoration(color: Colors.blueAccent),
      );

  Widget _item(id, title, path, icon, imagePath, color) {
    
    return Column(
      children: [
        InkWell(
            //onTap: () => context.go(path),
            onTap: (){
             // Navigator.pushNamed(context, path);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ShopPage()));
            },
            child: Container(
                   // width: 50,
                    height: 150,
                    padding: const EdgeInsets.all(3),
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      imagePath ?? 'assets/icons/belanja.png',
                      /* width: 40,
                      height: 40, */
                    ))),
        Text(
          title,
          //style: widget.style,
        )
      ],
    );
  }
}
