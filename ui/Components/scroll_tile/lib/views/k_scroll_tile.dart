import 'package:flutter/material.dart';
import 'k_capsule_tile.dart';
import 'tile_model.dart';

import 'k_list_tile.dart';

enum TileType { card, capsule }

class KScrollTile extends StatelessWidget {
  final List<TileModel>? items;
  final Axis axis;
  final TileType type;

  const KScrollTile(
      {Key? key,
      this.items,
      this.axis: Axis.horizontal,
      this.type = TileType.card})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      child: ListView.builder(
          itemCount: items!.length,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          scrollDirection: axis,
          itemBuilder: (context, index) {
            switch (type) {
              case TileType.capsule:
                return KCapsuleTile(
                  rating: items![index].rating!,
                  imgUrl: items![index].imgUrl,
                  desc: items![index].subtitle!,
                  title: items![index].title!,
                  price: items![index].label!,
                );
              default:
                return KTile(
                  label: items![index].label!,
                  title: items![index].title!,
                  subtitle: items![index].subtitle!,
                  rating: items![index].rating!,
                  imgUrl: items![index].imgUrl,
                );
            }
          }),
    );
  }
}
