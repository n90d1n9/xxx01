import 'package:flutter/material.dart';
import 'package:k_lib_search/k_lib_search.dart';

class KAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
          title: Image.network(
            "https://static.joybuy.com/ept_m/index/v20181225/logo.png",
            fit: BoxFit.fill,
            width: 80,
            height: 15,
          ),
          // centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.grey),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchList(),
                    ));
              },
            ),
          ],
        );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.0);
}