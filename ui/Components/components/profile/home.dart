import 'package:flutter/material.dart';
import 'package:klib_scroll_tile/views/k_scroll_tile.dart';
import 'package:klib_scroll_tile/views/tile_model.dart';
import 'package:klib_scroll_tile/klib_scroll_tile.dart';
import 'package:klib_scroll_tile/views/k_list_tile.dart';
import 'data/data.dart';
import 'model/country_model.dart';
import 'model/popular_tours.dart';
import 'model/popular_tours_model.dart';


class ProfilePage extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<ProfilePage> {
  List<PopularTourModel> popularTourModels = [];
  List<CountryModel> country = [];
  @override
  void initState() {
    country = getCountrys();
    popularTourModels = getPopularTours();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          padding: EdgeInsets.all(7),
          child: Image.asset(
            "assets/menu.png",
            height: 20,
            width: 20,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo.png",
              height: 30,
            ),
            Text(
              "DiscountTour",
              style:
                  TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
            )
          ],
        ),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          )
        ],
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Find the best tour",
                style: TextStyle(
                    fontSize: 28,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "Country",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 16,
              ),
              KScrollTile(
                axis: Axis.horizontal,
                items: List.generate(
                    country.length,
                    (index) => TileModel(
                          label: country[index].label!,
                          title: country[index].countryName!,
                          subtitle: country[index].noOfTours!.toString(),
                          rating: country[index].rating!,
                          imgUrl: country[index].imgUrl,
                        )),
              ),
              KScrollTile(
                type: TileType.capsule,
                axis: Axis.vertical,
                items: List.generate(
                    popularTourModels.length,
                    (index) => TileModel(
                          subtitle: popularTourModels[index].desc,
                          imgUrl: popularTourModels[index].imgUrl,
                          title: popularTourModels[index].title,
                          label: popularTourModels[index].price,
                          rating: popularTourModels[index].rating,
                        )),
              ),
              Container(
                height: 240,
                child: ListView.builder(
                    itemCount: country.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return KTile(
                        label: country[index].label!,
                        title: country[index].countryName!,
                        subtitle: country[index].noOfTours!.toString(),
                        rating: country[index].rating!,
                        imgUrl: country[index].imgUrl,
                      );
                    }),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "Popular Tours",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 16,
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: popularTourModels.length,
                  itemBuilder: (context, index) {
                    return PopularTours(
                      desc: popularTourModels[index].desc,
                      imgUrl: popularTourModels[index].imgUrl,
                      title: popularTourModels[index].title,
                      price: popularTourModels[index].price,
                      rating: popularTourModels[index].rating,
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
