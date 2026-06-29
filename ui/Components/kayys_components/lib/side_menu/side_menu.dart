import 'package:flutter/material.dart';

import '../../models/menu.dart';
import '../utils/helper.dart';

class SideMenu extends StatefulWidget {
  const SideMenu(
      {super.key,
      this.floatingActionButton,
      required this.menuItems,
      this.onMenuClick,
      this.currentIndex,
      this.title,
      this.width,
      this.image,
      this.backgroundColor});
  final Widget? floatingActionButton;
  final List<Menu>? menuItems;
  final void Function(Menu)? onMenuClick;
  final int? currentIndex;
  final Widget? title;
  final double? width;
  final String? image;
  final Color? backgroundColor;

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(0), bottomRight: Radius.circular(0)),
        ),
        backgroundColor:
            widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        width: widget.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Side menu header
              DrawerHeader(
                child: Center(
                    child: Column(children: [
                  Image.asset(
                    widget.image!,
                    width: 60,
                    height: 60,
                  ),
                  widget.title ?? const SizedBox()
                ])),
              ),

              // Menu list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.menuItems!.length,
                itemBuilder: (context, index) {
                  return _buildList(widget.menuItems![index]);
                },
              )
            ],
          ),
        ));
  }

  Widget _buildList(Menu menu) {
    return menu.items.isEmpty
        ? /* Builder(builder: (context) {
            return  */
        ListTile(
            onTap: () => widget.onMenuClick!(menu),
            leading: menu.iconWidget ?? getIcon(menu.icon ?? 'home'),
            title: Text(menu.title!)) //;
        //})
        : ExpansionTile(
            leading: getIcon(menu.icon??'home'),
            title: Text(
              menu.title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            children: menu.items.map(_buildList).toList(),
          );
  }
}
