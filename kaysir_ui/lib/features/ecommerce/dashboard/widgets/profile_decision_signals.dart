import 'package:flutter/material.dart';

import '../models/product_profile.dart';
import '../models/profile_business_motion.dart';
import '../models/profile_comparison.dart';
import 'profile_business_motion_chip.dart';
import 'profile_launch_complexity_chip.dart';

class ProfileDecisionSignals extends StatelessWidget {
  final ProfileBusinessMotion? businessMotion;
  final ProfileLaunchComplexity? launchComplexity;
  final int? launchComplexityScore;
  final double spacing;
  final double runSpacing;

  const ProfileDecisionSignals({
    super.key,
    this.businessMotion,
    this.launchComplexity,
    this.launchComplexityScore,
    this.spacing = 6,
    this.runSpacing = 6,
  }) : assert(
         launchComplexity == null || launchComplexityScore != null,
         'Launch complexity needs a score.',
       ),
       assert(launchComplexityScore == null || launchComplexityScore >= 0);

  factory ProfileDecisionSignals.forProfile({
    Key? key,
    required ProductProfile profile,
    bool showBusinessMotion = true,
    bool showLaunchComplexity = true,
    double spacing = 6,
    double runSpacing = 6,
  }) {
    final launchComplexityScore =
        showLaunchComplexity
            ? profileLaunchComplexityScoreForProfile(profile)
            : null;

    return ProfileDecisionSignals(
      key: key,
      businessMotion:
          showBusinessMotion ? profileBusinessMotionForProfile(profile) : null,
      launchComplexity:
          launchComplexityScore == null
              ? null
              : profileLaunchComplexityFor(launchComplexityScore),
      launchComplexityScore: launchComplexityScore,
      spacing: spacing,
      runSpacing: runSpacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      if (businessMotion != null)
        ProfileBusinessMotionChip(motion: businessMotion!),
      if (launchComplexity != null)
        ProfileLaunchComplexityChip(
          complexity: launchComplexity!,
          score: launchComplexityScore!,
        ),
    ];

    if (children.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: spacing, runSpacing: runSpacing, children: children);
  }
}
