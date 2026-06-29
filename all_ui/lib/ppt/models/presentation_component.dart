import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'animation.dart';
import 'chart_data.dart';
import 'component.dart';
import 'enums.dart';
import 'interactive_element.dart';
import 'rich_text_content.dart';
import 'style/glasmorphism_style.dart';
import 'style/gradient_animation.dart';
import 'style/neumorphism_style.dart';
import 'style/particle_effect.dart';

class PresentationComponent {
  final String id;
  final ComponentType type;
  final Offset position;
  final Size size;
  final RichTextContent? richText;
  final Uint8List? imageData;
  final Color? backgroundColor;
  final double rotation;
  final int zIndex;
  final AnimationType animation;
  final double opacity;
  final BorderSide? border;
  final bool isEditing;
  final ChartData? chartData;
  final String? videoUrl;
  final String? audioUrl;
  final double animationDelay;
  final double animationDuration;
  final VisualEffect? visualEffect;
  final GlassmorphismStyle? glassStyle;
  final NeumorphismStyle? neumoStyle;
  final ParticleEffect? particleEffect;
  final GradientAnimation? gradientAnim;
  final InteractiveElement? interactive;
  final String? lottieAsset;
  final bool hasGlow;
  final Color? glowColor;

  PresentationComponent({
    required this.id,
    required this.type,
    required this.position,
    required this.size,
    this.richText,
    this.imageData,
    this.backgroundColor,
    this.rotation = 0,
    this.zIndex = 0,
    this.animation = AnimationType.none,
    this.opacity = 1.0,
    this.border,
    this.isEditing = false,
    this.chartData,
    this.videoUrl,
    this.audioUrl,
    this.animationDelay = 0,
    this.animationDuration = 0.6,
    this.visualEffect,
    this.glassStyle,
    this.neumoStyle,
    this.particleEffect,
    this.gradientAnim,
    this.interactive,
    this.lottieAsset,
    this.hasGlow = false,
    this.glowColor,
  });

  PresentationComponent copyWith({
    Offset? position,
    Size? size,
    RichTextContent? richText,
    Uint8List? imageData,
    Color? backgroundColor,
    double? rotation,
    int? zIndex,
    AnimationType? animation,
    double? opacity,
    BorderSide? border,
    bool? isEditing,
    ChartData? chartData,
    String? videoUrl,
    String? audioUrl,
    double? animationDelay,
    double? animationDuration,
    VisualEffect? visualEffect,
    GlassmorphismStyle? glassStyle,
    NeumorphismStyle? neumoStyle,
    ParticleEffect? particleEffect,
    GradientAnimation? gradientAnim,
    InteractiveElement? interactive,
    String? lottieAsset,
    bool? hasGlow,
    Color? glowColor,
  }) {
    return PresentationComponent(
      id: id,
      type: type,
      position: position ?? this.position,
      size: size ?? this.size,
      richText: richText ?? this.richText,
      imageData: imageData ?? this.imageData,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      animation: animation ?? this.animation,
      opacity: opacity ?? this.opacity,
      border: border ?? this.border,
      isEditing: isEditing ?? this.isEditing,
      chartData: chartData ?? this.chartData,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      animationDelay: animationDelay ?? this.animationDelay,
      animationDuration: animationDuration ?? this.animationDuration,
      visualEffect: visualEffect ?? this.visualEffect,
      glassStyle: glassStyle ?? this.glassStyle,
      neumoStyle: neumoStyle ?? this.neumoStyle,
      particleEffect: particleEffect ?? this.particleEffect,
      gradientAnim: gradientAnim ?? this.gradientAnim,
      interactive: interactive ?? this.interactive,
      lottieAsset: lottieAsset ?? this.lottieAsset,
      hasGlow: hasGlow ?? this.hasGlow,
      glowColor: glowColor ?? this.glowColor,
    );
  }
}
