import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kayys_components/carousel/bcarousel.dart';
import 'package:kayys_components/menu/grid_menu.dart';
import 'package:kayys_components/search/search_bar.dart';
import 'package:syirkah/shared/data/data.dart';
import '../../modules/social_preneur/bloc/search_bloc.dart';
import '../../core/utils/constants.dart';

class HomePhonePage extends ConsumerStatefulWidget {
  const HomePhonePage({super.key});

  @override
  ConsumerState<HomePhonePage> createState() => _HomePhonePageState();
}

class _HomePhonePageState extends ConsumerState<HomePhonePage> {
  int? currentIndex = 0;
  int selctedNavIndex = 0;
  Color bottonNavBgColor = Colors.red;
  var bottomNavItems = [];
  var valueCart = 0;
  var valueNotif = 0;
@override
  void dispose() {
    
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final SearchState searchState = ref.read(searchProvider.notifier).getData();
    //ref.read(appsState.notifier).atHome(true);
    return Column(
      children: [
        //  const Expanded(child:  SizedBox(width: 300,height: 500, child: MergeImage())),
        //ConvertWidget(),
        // const DigiClock(),

        /* BSearchBar(
          onTapCart: () {},
          onTapNotif: () {},
          onPressed: () {},
          valueCart: valueCart,
          valueNotif: valueNotif,
          onPressedQRcode: () {},
          data: searchState.results,
          onChanged: (query) {
            ref.read(searchProvider.notifier).updateQuery(query);
          },
        ), */
        const SizedBox(height: 70,),
        BCarousel(slides: imgList),
        Expanded(
            child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.elliptical(10, 10)),
                    color: bgHome//Colors.black12
                  ),
                  child: 
            GridMenu(
              items: gridMenuItems,
            )),
        )),
      ],
    );
  }
}

final List<String> imgList = [
  'assets/bag_1.png',
  'assets/bag_2.png',
  'assets/bag_3.png',
];

// ImageProvider<Object>