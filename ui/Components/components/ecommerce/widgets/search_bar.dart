import 'package:flutter/material.dart';

import 'icon_badge.dart';

class BSearchBar extends StatefulWidget {
  final String hintText;
  final Function() onPressed;
  final Function() onTapNotif;
  final Function() onTapCart;
  final int? valueNotif;
  final int? valueCart;
  final double height;

  final Function() onPressedQRcode;

  final Color iconColor;
  const BSearchBar(
      {super.key,
      this.hintText = 'Cari...',
      this.valueCart,
      this.valueNotif,
      this.height = 40,
      this.iconColor = Colors.black38,
      required this.onPressed,
      required this.onTapNotif,
      required this.onTapCart,
      required this.onPressedQRcode});

  @override
  State<BSearchBar> createState() => _BSearchBarState();
}

class _BSearchBarState extends State<BSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        height: widget.height,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SearchAnchor(
                  builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  backgroundColor:
                      const WidgetStatePropertyAll<Color>(Colors.white),
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.fromLTRB(20, 5, 10, 5)),
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (_) {
                    controller.openView();
                  },
                  leading: Icon(color: widget.iconColor, Icons.search),
                  trailing: [
                    IconButton(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 3),
                        onPressed: widget.onPressedQRcode,
                        icon: Icon(
                            color: widget.iconColor,
                            Icons.qr_code_scanner_rounded))
                  ],
                );
              }, suggestionsBuilder:
                      (BuildContext context, SearchController controller) {
                return List<ListTile>.generate(5, (int index) {
                  final String item = 'item $index';
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      setState(() {
                        controller.closeView(item);
                      });
                    },
                  );
                });
              }),
            ),

            //const SizedBox(width: 8.0),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                child: IconButton(
                    onPressed: widget.onPressed,
                    icon: Icon(
                      Icons.favorite_border,
                      color: widget.iconColor,
                    ))),
            //const SizedBox(width: 8.0),
            IconBadge(
              color: widget.iconColor,
              value: widget.valueNotif,
              icon: Icons.notifications_none_rounded,
              onTap: widget.onTapNotif,
            ),
            const SizedBox(width: 8.0),
            IconBadge(
              color: widget.iconColor,
              value: widget.valueCart,
              icon: Icons.shopping_cart_rounded,
              onTap: widget.onTapCart,
            ),
            const SizedBox(width: 8.0),
            IconBadge(
              color: widget.iconColor,
              value: widget.valueCart,
              icon: Icons.more_vert_rounded,
              onTap: widget.onTapCart,
            )
          ],
        ));
  }
}
