import 'package:flutter/material.dart';

class SearchResultPage extends StatefulWidget {
  SearchResultPage({Key? key}) : super(key: key);

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 1, length: 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.7,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: <Widget>[
            Tab(text:'Terkait'),
            Tab(text: "Terbaru"),
            Tab(text: "Terlaris",),
            Tab(text: "Harga"),
          ],
        ),
        actions: [
          Container(margin: EdgeInsets.only(top:15, left:60),
            child:Text('search')), Spacer(), Text('filter')],
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Text('camera'),
          Text('wer'),
          Text('dfdfg'),
          Text('bbbb'),
        ],
      ),
    );
  }
}
