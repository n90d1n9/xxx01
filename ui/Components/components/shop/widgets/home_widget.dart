import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kayys_components/search/search_bar.dart';
import 'package:kasir/modules/shop/models/grid_item.dart';
import 'package:kasir/modules/syirkah/bloc/search_bloc.dart';

class HomeWidget extends ConsumerStatefulWidget {
  final List<GridItem> items;
  const HomeWidget({super.key, required this.items});

  @override
  ConsumerState<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends ConsumerState<HomeWidget> {
  var bottomNavItems = [];
  var valueCart = 0;
  var valueNotif = 0;
  @override
  Widget build(BuildContext context) {
final SearchState searchState = ref.read(searchProvider.notifier).getData();
    return Column(
      children: [
       /*  BSearchBar(
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
        ),  */
        shopHeader(),
        const SizedBox(height: 10,),
        Expanded(
            child: SingleChildScrollView(
                child:
        GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            children: widget.items
                .map((el) => _item(el.id, el.title, el.path, el.icon,
                    el.imagePath, el.color ))
                .toList())))
      ],
    );
  }

  Widget shopHeader() => Container(
        height: 200,
        decoration: const BoxDecoration(color: Colors.blueAccent),
      );

  Widget _item(id, title, path, icon, imagePath, color) {
    return Column(
      children: [
        InkWell(
            onTap: () => context.go(path),
            //onTap: () => context.goNamed(),
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
                    )) //?? Icon(icon)
                ),
        Text(
          title,
          //style: widget.style,
        )
      ],
    );
  }
}