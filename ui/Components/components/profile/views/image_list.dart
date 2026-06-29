
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageListTile extends StatelessWidget {
  final String? imgUrl;
  ImageListTile({@required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: imgUrl!,
          height: 220,
          width: 150,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}