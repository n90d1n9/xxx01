import 'package:flutter/material.dart';
import 'package:kayys_components/kayys_components.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/config.dart';
import '../../core/utils/constants.dart';

class LargeLayout extends StatefulWidget {
  final Widget? body;
  final List<Menu> menuItems;
  final int? currentIndex;
  final Widget? title;
  final void Function(Menu)? onMenuClick;
  
  const LargeLayout({
    super.key,
    required this.body,
    required this.menuItems,
    this.onMenuClick,
      this.currentIndex,
      this.title,
  });

  @override
  State<LargeLayout> createState() => _LargeLayoutState();
}

class _LargeLayoutState extends State<LargeLayout> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Side Menu
        SideMenu(
            width: sideMenuWidth,
            image: imageSplash,
            menuItems: widget.menuItems,
            currentIndex: widget.currentIndex,
            title: widget.title,
            onMenuClick: (val) {
              print('------$val----');
              goTo(val);
            }),
        // Divider
        VerticalDivider(
          width: 2,
          thickness: 100,
          color: Theme.of(context).dividerColor,
        ),
        // Main Section
        Expanded(
          child: Scaffold(
            appBar: AppBar(
             // actions: widget.actions,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            body: widget.body,
          ),
        )
      ],
    );
  }

  goTo(Menu menu)=> context.go(menu.path!);
}
