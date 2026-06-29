import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BCarousel extends StatelessWidget {
  final bool autoPlay;
  final int autoPlayInterval;
  final int autoPlayAnimationDuration;
  final Color color;
  const BCarousel(
      {super.key,
      required this.slides,
      this.autoPlayAnimationDuration = 1000,
      this.autoPlayInterval = 4,
      this.color = Colors.blue,
      this.autoPlay = true});

  final List<String> slides;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 150,
        autoPlay: autoPlay,
        autoPlayInterval: Duration(seconds: autoPlayInterval),
        autoPlayAnimationDuration:
            Duration(milliseconds: autoPlayAnimationDuration),
        enlargeCenterPage: true,
        viewportFraction: 0.8,
      ),
      items: slides
          .map((item) => Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                height: 100,
                // width: 650,
                decoration: BoxDecoration(
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      offset: const Offset(0, 3),
                      blurRadius: 5,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: /* AssetImage(item)?? */
                        AssetImage('assets/images/default.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ))
          .toList(),
    );
  }
}
