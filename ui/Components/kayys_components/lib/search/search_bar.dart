import 'package:flutter/material.dart';

import '../icon/icon_badge.dart';

class BSearchBar extends StatefulWidget {
  final String hintText;
  final Function() onPressed;
  final Function() onTapNotif;
  final Function() onTapCart;
  final int? valueNotif;
  final int? valueCart;
  final double height;
  final List<SearchResultModel> data;
  final Function(String) onChanged;

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
      required this.onPressedQRcode,
      required this.data,
      required this.onChanged});

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
            /* IconButton(onPressed: (){
              Navigator.of(context).pop();
            }, icon: Icon(Icons.arrow_back_ios)), */
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
                  onChanged: (value) => print('$value <<<<<<'),
                  /* onChanged: (value) {
                    print('?????? $value.');
                   // widget.onChanged(value);
                   controller.openView();
                  }, */
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
                return List<ListTile>.generate(widget.data.length, (int index) {
                  return ListTile(
                    title: Text(widget.data[index].title),
                    onTap: () {
                      setState(() {
                        controller.closeView(widget.data[index].title);
                      });
                    },
                  );
                });
              }),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                child: IconButton(
                    onPressed: widget.onPressed,
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ))),
            /*  Padding(
                padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                child: IconButton(
                    onPressed: widget.onPressed,
                    icon: Icon(
                      Icons.notifications,
                      color: Colors.red,
                    ))), */
            IconBadge(
              color: Colors.amber,
              //value: widget.valueCart,
              value: 13,
              icon: Icons.notifications,
              onTap: widget.onTapNotif,
            ),
            const SizedBox(width: 8.0),
            IconBadge(
              color: Colors.grey,
              //value: widget.valueCart,
              value: 3,
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

class SearchState {
  final String query;
  final List<SearchResultModel> results;

  SearchState({required this.query, required this.results});
}

class SearchResultModel {
  final String title;
  final String category;

  SearchResultModel({required this.title, required this.category});
}
