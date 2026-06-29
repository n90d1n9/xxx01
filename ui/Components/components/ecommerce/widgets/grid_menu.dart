import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GridMenu extends StatelessWidget {
  final List<GridItem> items;

  final TextStyle style;

  const GridMenu({
    super.key,
    required this.items,
    this.style = const TextStyle(fontSize: 10),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        /* crossAxisSpacing: 5,
        mainAxisSpacing: 5, */
        // padding: const EdgeInsets.symmetric(horizontal: 10),
        children: items
            .map((el) => _item(context, el.id, el.title, el.path, el.icon))
            .toList());
  }

  Widget _item(BuildContext context, id, title, path, icon) {
    return Column(
      children: [
        InkWell(
            onTap: () => context.go(path),
            child: Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon))),
        Text(
          title,
          style: style,
        )
      ],
    );
  }
}

class GridItem {
  final double id;
  final IconData icon;
  final String path;
  final String title;
  GridItem(
    this.id,
    this.title,
    this.path,
    this.icon,
  );
}
