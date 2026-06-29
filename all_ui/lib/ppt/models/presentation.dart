import 'dart:ui';

import 'slide.dart';
import 'style/presentation_theme.dart';

class Presentation {
  final String id;
  final String title;
  final List<Slide> slides;
  final int currentSlideIndex;
  final PresentationTheme theme;
  final Size slideSize;

  Presentation({
    required this.id,
    required this.title,
    required this.slides,
    this.currentSlideIndex = 0,
    PresentationTheme? theme,
    this.slideSize = const Size(1920, 1080),
  }) : theme = theme ?? PresentationTheme.modernGlass;

  Presentation copyWith({
    String? title,
    List<Slide>? slides,
    int? currentSlideIndex,
    PresentationTheme? theme,
    Size? slideSize,
  }) {
    return Presentation(
      id: id,
      title: title ?? this.title,
      slides: slides ?? this.slides,
      currentSlideIndex: currentSlideIndex ?? this.currentSlideIndex,
      theme: theme ?? this.theme,
      slideSize: slideSize ?? this.slideSize,
    );
  }
}
