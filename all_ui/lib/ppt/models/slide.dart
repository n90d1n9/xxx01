import 'dart:typed_data';
import 'dart:ui';

import 'presentation_component.dart';
import 'slide_transition_type.dart';
import 'style/gradient_animation.dart';
import 'style/particle_effect.dart';

class Slide {
  final String id;
  final List<PresentationComponent> components;
  final Color? backgroundColor;
  final String? notes;
  final String? title;
  final SlideTransitionType transition;
  final Uint8List? backgroundImage;
  final GradientAnimation? backgroundGradient;
  final ParticleEffect? backgroundParticles;
  final String? backgroundVideo;

  Slide({
    required this.id,
    required this.components,
    this.backgroundColor,
    this.notes,
    this.title,
    this.transition = SlideTransitionType.fade,
    this.backgroundImage,
    this.backgroundGradient,
    this.backgroundParticles,
    this.backgroundVideo,
  });

  Slide copyWith({
    List<PresentationComponent>? components,
    Color? backgroundColor,
    String? notes,
    String? title,
    SlideTransitionType? transition,
    Uint8List? backgroundImage,
    GradientAnimation? backgroundGradient,
    ParticleEffect? backgroundParticles,
    String? backgroundVideo,
  }) {
    return Slide(
      id: id,
      components: components ?? this.components,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      notes: notes ?? this.notes,
      title: title ?? this.title,
      transition: transition ?? this.transition,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      backgroundParticles: backgroundParticles ?? this.backgroundParticles,
      backgroundVideo: backgroundVideo ?? this.backgroundVideo,
    );
  }
}
