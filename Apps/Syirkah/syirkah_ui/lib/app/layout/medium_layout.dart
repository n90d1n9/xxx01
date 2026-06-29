import 'package:flutter/material.dart';
import 'package:kayys_components/kayys_components.dart';


class MediumLayout extends StatefulWidget {
  final Widget? body;
   final List<Menu> menuItems;
  /* final Widget? title;
  final List<Widget> actions;
  
  final int currentIndex;
 
  final ValueChanged<int>? onFoldMenuTap;
  final ValueChanged<int>? onBottomTap;
  final ValueChanged<Menu>? onMenuClick;
  final FloatingActionButton? floatingActionButton; */

  const MediumLayout(
      {super.key,
        required this.menuItems,
        
       required this.body,
      /* required this.actions,
      required this.currentIndex,
      this.title,
      this.onMenuClick,
      this.onBottomTap,
      this.floatingActionButton,
      this.onFoldMenuTap, */
      });

  @override
  State<MediumLayout> createState() => _MediumLayoutState();
}

class _MediumLayoutState extends State<MediumLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Text('icon'),
       /*  title: widget.title,
        actions: widget.actions, */
      ),
      body: Row(
        children: [
          // Side Menu
          SideMenuFold(
            menuItems: widget.menuItems,
            //currentIndex: widget.currentIndex,
            //onMenuClick: widget.onFoldMenuTap,
          ),

          // Divider
          verticalDivider(),

          // Main Section
          Expanded(
            child: widget.body!,
          ),
        ],
      ),
    );
  }

  Widget verticalDivider() => VerticalDivider(
        width: 1,
        thickness: 1,
        color: Theme.of(context).dividerColor,
      );
}
