import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/workspace_provider.dart';
import 'icon_action_button.dart';
import 'profile_picker_dialog.dart';
import 'tone.dart';

class ProfileMenu extends ConsumerWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref
        .watch(productProfilesProvider)
        .where((profile) => profile.id.trim().isNotEmpty)
        .toList(growable: false);
    final activeProfile = ref.watch(productProfileProvider);

    if (profiles.length <= 1) return const SizedBox.shrink();

    return IconActionButton(
      valueKey: 'profile_menu',
      tooltip: 'Commerce profile: ${activeProfile.label}',
      icon: Icons.view_quilt_outlined,
      tone: VisualTone.primary,
      onPressed: () {
        showProfilePicker(
          context: context,
          profiles: profiles,
          activeProfile: activeProfile,
          onProfileSelected:
              (profileId) => ref
                  .read(productProfileIdProvider.notifier)
                  .selectProfile(profileId),
        );
      },
    );
  }
}
