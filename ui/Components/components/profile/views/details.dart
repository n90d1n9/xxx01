import 'package:flutter/material.dart';
import '../data/data.dart';
import '../model/country_model.dart';
import 'image_list.dart';
import 'k_detail_card.dart';
import 'k_features_tile.dart';
import 'k_rating_bar.dart';

class DetailPage extends StatefulWidget {
  final String? imgUrl;
  final String? placeName;
  final double? rating;
  DetailPage(
      {@required this.rating, @required this.imgUrl, @required this.placeName});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<CountryModel> country = [];

  @override
  void initState() {
    country = getCountrys();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              header(),
              featuresIcons(),
              detailCard(),
              SizedBox(
                height: 8,
              ),
              summary(),
              SizedBox(
                height: 16,
              ),
              gallery(),
            ],
          ),
        ),
      ),
    );
  }

  backgroundImage() {
    return Image.network(
      widget.imgUrl!,
      height: 350,
      width: MediaQuery.of(context).size.width,
      fit: BoxFit.cover,
    );
  }

  summary() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut scelerisque arcu quis eros auctor, eu dapibus urna congue. Nunc nisi diam, semper maximus risus dignissim, semper maximus nibh. Sed finibus ipsum eu erat finibus efficitur. ",
        textAlign: TextAlign.start,
        style: TextStyle(
            fontSize: 15,
            height: 1.5,
            fontWeight: FontWeight.w600,
            color: Color(0xff879D95)),
      ),
    );
  }

  gallery() {
    return Container(
      height: 240,
      child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 24),
          itemCount: country.length,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return ImageListTile(
              imgUrl: country[index].imgUrl,
            );
          }),
    );
  }

  detailCard() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [DetailsCard(), DetailsCard()],
      ),
    );
  }

  featuresIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FeaturesTile(
          icon: Icon(Icons.wifi, color: Color(0xff5A6C64)),
          label: "Free Wi-Fi",
        ),
        FeaturesTile(
          icon: Icon(Icons.beach_access, color: Color(0xff5A6C64)),
          label: "Sand Beach",
        ),
        FeaturesTile(
          icon: Icon(Icons.card_travel, color: Color(0xff5A6C64)),
          label: "First Coastline",
        ),
        FeaturesTile(
          icon: Icon(Icons.local_drink, color: Color(0xff5A6C64)),
          label: "bar and Resturant",
        )
      ],
    );
  }

  header() {
    return Stack(
      children: [
        backgroundImage(),
        Container(
          height: 350,
          color: Colors.black12,
          padding: EdgeInsets.only(top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(
                      width: 24,
                    ),
                    Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 24,
                    )
                  ],
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.placeName!,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 23),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 25,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Koh Chang Tai, Thailand",
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: 17),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RatingBar(widget.rating!.round()),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "${widget.rating}",
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 17),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 18,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                height: 50,
              )
            ],
          ),
        )
      ],
    );
  }
}
