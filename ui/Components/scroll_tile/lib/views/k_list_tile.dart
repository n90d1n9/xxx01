import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class KTile extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final double rating;
  final String? imgUrl;
  KTile(
      {this.title = '',
      this.label = '',
      this.subtitle = '',
      this.rating = 0.0,
      this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          background(),
          Container(
            height: 200,
            width: 150,
            child: Column(
              children: [top(), Spacer(), bottom()],
            ),
          )
        ],
      ),
    );
  }

  Widget top() {
    return Row(
      children: [
        Container(
            margin: EdgeInsets.only(left: 8, top: 8),
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: Colors.white38),
            child: Text(
              label,
              style: TextStyle(color: Colors.white),
            ))
      ],
    );
  }

  Widget bottom() {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 10, left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  title,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                ),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                subtitle,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              )
            ],
          ),
        ),
        Spacer(),
        Container(
            margin: EdgeInsets.only(bottom: 10, right: 8),
            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 7),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3), color: Colors.white38),
            child: Column(
              children: [
                Text(
                  rating.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
                SizedBox(
                  height: 2,
                ),
                Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 20,
                )
              ],
            ))
      ],
    );
  }

  Widget background() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: imgUrl!,
        height: 220,
        width: 150,
        fit: BoxFit.cover,
      ),
    );
  }
}
