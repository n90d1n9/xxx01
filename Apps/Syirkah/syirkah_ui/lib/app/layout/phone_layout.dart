import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kayys_components/bottom_bar/floating_bottom_bar.dart';
import 'package:kayys_components/kayys_components.dart';
import 'package:syirkah/core/utils/constants.dart';

import '../../modules/social_preneur/bloc/search_bloc.dart';

class PhoneLayout extends ConsumerStatefulWidget {
  final Widget body;
  final List<Menu>? menuItems;

  const PhoneLayout({
    super.key,
    required this.body,
    required this.menuItems,
  });

  @override
  ConsumerState<PhoneLayout> createState() => _PhoneLayoutState();
}

class _PhoneLayoutState extends ConsumerState<PhoneLayout> {
  int? currentIndex = 0;
  int selctedNavIndex = 0;
  Color bottonNavBgColor = Colors.red;
  var bottomNavItems = [];
  var valueCart = 0;
  var valueNotif = 0;

  String syirkahLogo = 'assets/icons/syirkah-logo.svg';

@override
  void dispose() {
    //ref.read(appsState.notifier).dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final SearchState searchState = ref.read(searchProvider.notifier).getData();
    return Material(
        child: Stack(alignment: Alignment.bottomCenter, children: [
      widget.body,
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        // Expanded(child:
        BSearchBar(
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
        ),
        const SizedBox(),
        FloatingBottomBar(
          bottonNavBgColor: bgHome,
          items: [
            const Menu(
                path: '/',
                iconWidget: Icon(Icons.home_rounded, color: Colors.white)),
            const Menu(
                path: '/about',
                iconWidget: Icon(Icons.info, color: Colors.white)),
            Menu(
                path: '/syirkah',
                iconWidget: Image.asset(
                  'assets/icons/syirkah-logo.png',
                  width: 20,
                  height: 20,
                )),
            const Menu(
                path: '/',
                iconWidget: Icon(
                  Icons.pie_chart_sharp,
                  color: Colors.white,
                )),
            const Menu(
                path: '/img2',
                iconWidget: Icon(Icons.person, color: Colors.white))
          ],
        )
      ])
    ]));
  }
}
