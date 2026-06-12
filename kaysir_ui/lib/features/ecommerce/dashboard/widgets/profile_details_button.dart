import 'package:flutter/material.dart';

import 'icon_action_button.dart';
import 'tone.dart';

class ProfileDetailsButton extends StatelessWidget {
  final String profileId;
  final String keyPrefix;
  final VoidCallback? onPressed;
  final String tooltip;

  const ProfileDetailsButton({
    super.key,
    required this.profileId,
    required this.keyPrefix,
    required this.onPressed,
    this.tooltip = 'View profile details',
  });

  @override
  Widget build(BuildContext context) {
    return IconActionButton(
      valueKey: '${keyPrefix}_$profileId',
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icons.info_outline,
      tone: VisualTone.secondary,
    );
  }
}
