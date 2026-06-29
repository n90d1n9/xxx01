import 'package:flutter/material.dart';

class AppBarBasic extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Function? onClickTheme;
  const AppBarBasic({this.title, this.actions, this.onClickTheme});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          title: Text(title!),
          actions: [
            ...actions!,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: FloatingActionButton(
                child: const Icon(Icons.brightness_6),
                onPressed: ()=>onClickTheme,
              ),
            )
          ],
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(100.0);
}
