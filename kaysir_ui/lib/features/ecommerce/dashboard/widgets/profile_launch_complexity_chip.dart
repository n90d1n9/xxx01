import 'package:flutter/material.dart';

import '../models/product_profile.dart';
import '../models/profile_comparison.dart';
import 'icon_label_chip.dart';
import 'tone.dart';

class ProfileLaunchComplexityChip extends StatelessWidget {
  final ProfileLaunchComplexity complexity;
  final int score;

  const ProfileLaunchComplexityChip({
    super.key,
    required this.complexity,
    required this.score,
  }) : assert(score >= 0);

  factory ProfileLaunchComplexityChip.forProfile({
    Key? key,
    required ProductProfile profile,
  }) {
    final score = profileLaunchComplexityScoreForProfile(profile);

    return ProfileLaunchComplexityChip(
      key: key,
      complexity: profileLaunchComplexityFor(score),
      score: score,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = toneColors(
      Theme.of(context).colorScheme,
      _visualToneForComplexity(complexity),
      backgroundAlpha: 0.28,
    );

    return IconLabelChip(
      icon: Icons.rocket_launch_outlined,
      label: '${complexity.label} | $score pts',
      colors: colors,
      fontWeight: FontWeight.w900,
    );
  }
}

VisualTone _visualToneForComplexity(ProfileLaunchComplexity complexity) {
  return switch (complexity) {
    ProfileLaunchComplexity.lean => VisualTone.success,
    ProfileLaunchComplexity.standard => VisualTone.secondary,
    ProfileLaunchComplexity.advanced => VisualTone.primary,
  };
}
