import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kays_home/config/Constants.dart';
import 'package:kays_home/ecommerce.dart';

import 'package:dio/dio.dart';

class HomeCommerce extends StatefulWidget {
  HomeCommerce({Key? key}) : super(key: key);

  @override
  _HomeCommerceState createState() => _HomeCommerceState();
}

class _HomeCommerceState extends State<HomeCommerce> {
  var indexData;
  var bestsellersData;
  @override
  void initState() {
    super.initState();
    getIndexData(); //得到首页的数据
  }

  @override
  Widget build(BuildContext context) {
    return Home1(indexData: indexData, bestsellersData: bestsellersData);
  }

  getIndexData() async {
    var dataId = AppDataIds.GlobalHomeId;
    var response =
        await Dio().get('https://mstone-api.jd.com/ept/page?id=$dataId');

    var _bestsellersData = await Dio().get(
        'https://mstone-api.jd.com/ept/page?id=${AppDataIds.sellerRankingId}');
    print(response);

    var result = response.data;
    setState(() {
      var jsonRes = json.decode(result);
      indexData = jsonRes['data'];
      bestsellersData = _bestsellersData;
    });
    //var jsonRes = json.decode(result);
    //indexData = jsonRes['data'];
  }

  getBestsellersData() async {
    int dataId = AppDataIds.sellerRankingId;
    var responseBestsellers =
        await Dio().get('https://mstone-api.jd.com/ept/page?id=$dataId');
    var rspbestsellers = responseBestsellers.data;
    setState(() {
      var jsonRes = json.decode(rspbestsellers);
      var data = jsonRes['data'];
      if (data.length > 0 &&
          data["floors"].length > 0 &&
          data["floors"][0]["tabList"].length > 0) {
        bestsellersData = data["floors"][0]["tabList"];
      }
      int size = indexData['floors'].length;
      for (var i = 0; i < size; i++) {
        var floors = indexData['floors'];
        var item = floors[i];

        if (item['floorType'] == 5 && item['styleType'] == 2) {
          indexData['floors'][i]["skus"] = bestsellersData[0]["skus"];
        }
      }
    });
  }
}
