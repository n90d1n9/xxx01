import 'package:flutter/material.dart';

import '../models/profile_business_motion.dart';
import 'chip_tone.dart';
import 'icon_label_chip.dart';

class ProfileBusinessMotionChip extends StatelessWidget {
  final ProfileBusinessMotion motion;

  const ProfileBusinessMotionChip({super.key, required this.motion});

  @override
  Widget build(BuildContext context) {
    final colors = mutedChipColors(Theme.of(context), backgroundAlpha: 0.55);

    return IconLabelChip(
      icon: _businessMotionIcon(motion),
      label: motion.label,
      colors: colors,
      fontWeight: FontWeight.w900,
    );
  }
}

IconData _businessMotionIcon(ProfileBusinessMotion motion) {
  return switch (motion) {
    ProfileBusinessMotion.omnichannel => Icons.hub_outlined,
    ProfileBusinessMotion.operations => Icons.fact_check_outlined,
    ProfileBusinessMotion.assistedSelling => Icons.forum_outlined,
    ProfileBusinessMotion.subscription => Icons.autorenew_outlined,
    ProfileBusinessMotion.fulfillment => Icons.local_shipping_outlined,
    ProfileBusinessMotion.marketplace => Icons.storefront_outlined,
    ProfileBusinessMotion.focused => Icons.track_changes_outlined,
  };
}
