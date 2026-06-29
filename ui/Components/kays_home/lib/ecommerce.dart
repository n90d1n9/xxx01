import 'package:flutter/material.dart';
import 'package:kays_home/widgets/k_appbar_widget.dart';
import 'package:kays_home/widgets/k_drawer_widget.dart';
import 'IndexList.dart';

class Home1 extends StatefulWidget {
  final indexData;
  final bestsellersData;

  Home1({this.indexData, this.bestsellersData});

  _MyhomeState createState() => _MyhomeState();
}

class _MyhomeState extends State<Home1> {
  @override
  Widget build(BuildContext content) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: KAppBar(),
        drawer: KDrawer(),
        body: TabBarView(
          children: <Widget>[
            IndexList(
                mt: 'in_theaters',
                bestsellersData: widget.bestsellersData,
                indexData: widget.indexData),
          ],
        ),
      ),
    );
  }
}
