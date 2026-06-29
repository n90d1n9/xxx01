import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GridMenu extends StatefulWidget {
  final List<GridItem> items;
  final Color bgItemColor;
  final TextStyle style;

  const GridMenu({
    super.key,
    this.bgItemColor = Colors.white,
    required this.items,
    this.style = const TextStyle(
        color: Colors.white,
        fontSize: 10,
        decorationStyle: TextDecorationStyle.dashed),
  });

  @override
  State<GridMenu> createState() => _GridMenuState();
}

class _GridMenuState extends State<GridMenu> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        /* crossAxisSpacing: 5,
        mainAxisSpacing: 5, */
        // padding: const EdgeInsets.symmetric(horizontal: 10),
        children: widget.items
            .map((el) => _item(el.id, el.title, el.path, el.icon, el.imagePath,
                el.color ?? widget.bgItemColor))
            .toList());
  }

  Widget _item(id, title, path, icon, imagePath, color) {
    return Column(
      children: [
        InkWell(
            onTap: () => context.go(path),
            child: Container(
                    width: 50,
                    height: 50,
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
                      width: 40,
                      height: 40,
                    )) ??
                Icon(icon)),
        Text(
          title,
          style: widget.style,
        )
      ],
    );
  }
}

class GridItem {
  final double? id;
  final IconData? icon;
  final String? path;
  final String? title;
  final String? imagePath;
  final Color? color;
  GridItem(
      {this.id, this.title, this.path, this.icon, this.imagePath, this.color});
}
