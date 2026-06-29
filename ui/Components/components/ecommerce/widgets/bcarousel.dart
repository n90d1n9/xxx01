import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BCarousel extends StatelessWidget {
  final bool autoPlay;

  const BCarousel({super.key, required this.slides, this.autoPlay = true});

  final List<String> slides;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 150,
        autoPlay: autoPlay,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        enlargeCenterPage: true,
        viewportFraction: 0.8,
      ),
      items: slides
          .map((item) => Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(item),
                    fit: BoxFit.cover,
                  ),
                ),
              ))
          .toList(),
    );
  }
}
