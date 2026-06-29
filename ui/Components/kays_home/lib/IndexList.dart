import 'package:flutter/material.dart';
import 'SliderWidget.dart';
import 'NavWidget.dart';
import 'ImageWidget.dart';
import 'SupperDeals.dart';
import 'BestSellers.dart';
import 'TopShop.dart';
import 'Recommend.dart';
import 'dart:convert' show json;
import 'package:cached_network_image/cached_network_image.dart';

import 'config/Constants.dart';
import 'package:dio/dio.dart';

//Dio dio = Dio();

class IndexList extends StatefulWidget {
  final indexData;
  final bestsellersData;
  IndexList(
      {Key? key,
      @required this.mt,
      @required this.indexData,
      @required this.bestsellersData})
      : super(key: key);
  final String? mt;

  _IndexListState createState() => _IndexListState();
}

class _IndexListState extends State<IndexList>
    with AutomaticKeepAliveClientMixin {
  // var indexData;
  var getSellerTopData = false;
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    //getIndexData(); //得到首页的数据
  }

  @override
  Widget build(BuildContext content) {
    // return Text('这是电影列表页面---'+widget.mt+'---${mlist.length}');
    if (widget.indexData == null) {
      return Image(
          image: new NetworkImage(
              "https://static.joybuy.com/ept/home-en/1.1.0/components/header/i/logo.png"));
    }
    int size = widget.indexData['floors'].length;
    if (!getSellerTopData) {
      getSellerTopData = true;
      getBestsellersData(widget.bestsellersData);
    }
    List<Widget> list = [];
    var floors = widget.indexData['floors'];
    for (int i = 0; i < size; i++) {
      var item = floors[i];
      Widget wg;
      if (item['floorType'] == 1 && item['styleType'] == 3) {
        wg = SliderWidget(itemData: item);
        list.add(wg);
      } else if (item['floorType'] == 6 && item['styleType'] == 3) {
        wg = NavWidget(itemData: item);
        list.add(wg);
      } else if (item['floorType'] == 6 && item['styleType'] == 4) {
        wg = ImageWidget(itemData: item);
        list.add(wg);
      } else if (item['floorType'] == 5 && item['styleType'] == 3) {
        wg = SupperDealsWidget(
            titleData: floors[i - 1], itemData: item, moreData: floors[i + 1]);
        list.add(wg);
      } else if (item['floorType'] == 10 && item['styleType'] == 1) {
        wg = ImageWidget(itemData: item);
        list.add(wg);
      } else if (item['floorType'] == 5 && item['styleType'] == 2) {
        wg = BestSellersWidget(
          titleData: floors[i - 1],
          itemData: item,
          moreData: floors[i + 1],
        );
        list.add(wg);
      } else if (item['floorType'] == 10 && item['styleType'] == 2) {
        wg = ImageWidget(itemData: item);
        list.add(wg);
      } else if (item['floorType'] == 6) {
        wg = ImageWidget(itemData: item);
        list.add(wg);
      } else if (item['floorType'] == 4) {
        wg = TopShopWidget(titleData: floors[i - 1], itemData: item);
        list.add(wg);
      } else if (item['floorType'] == 5 && item['styleType'] == 1) {
        wg = RecommendWidget(titleData: floors[i - 1], itemData: item);
        list.add(wg);
      }
    }
    // return   new Row(

    //   children: list,
    // );
    return Container(
        color: Color(0xffeeeeee),
        child: new ListView.builder(
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (BuildContext ctx, int i) {
              return list.elementAt(i);
            }));

    // return new ListView.builder(
    //     shrinkWrap: true,
    //     itemCount: size,
    //     itemBuilder: (BuildContext ctx, int i) {
    //       var item = indexData['floors'][i];
    //       return Container(
    //         child: IndexWidget(
    //           styleType: item['styleType'],
    //           floorType: item['floorType'],
    //           itemData: item,
    //         ),
    //       );
    //     });
  }

  getBestsellersData(responseBestsellers) async {
    //int dataId = AppDataIds.sellerRankingId;
    //var responseBestsellers =  await Dio().get('https://mstone-api.jd.com/ept/page?id=$dataId');
    var rspbestsellers = responseBestsellers.data;
    setState(() {
      var jsonRes = json.decode(rspbestsellers);
      var data = jsonRes['data'];
      var bestsellersData;
      if (data.length > 0 &&
          data["floors"].length > 0 &&
          data["floors"][0]["tabList"].length > 0) {
        bestsellersData = data["floors"][0]["tabList"];
      }
      int size = widget.indexData['floors'].length;
      for (var i = 0; i < size; i++) {
        var floors = widget.indexData['floors'];
        var item = floors[i];

        if (item['floorType'] == 5 && item['styleType'] == 2) {
          widget.indexData['floors'][i]["skus"] = bestsellersData[0]["skus"];
        }
      }
    });
  }
}
