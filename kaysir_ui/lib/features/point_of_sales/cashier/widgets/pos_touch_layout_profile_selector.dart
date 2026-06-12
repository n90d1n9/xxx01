import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../experiences/default_pos_touch_layout_profiles.dart';
import '../models/pos_touch_layout_profile.dart';
import '../models/pos_touch_layout_profile_catalog.dart';
import 'pos_ui.dart';

/// Compact selector for switching active POS touch layout profiles.
class POSTouchLayoutProfileSelector extends StatelessWidget {
  final POSTouchLayoutProfileCatalog catalog;
  final POSTouchLayoutProfile selectedProfile;
  final ValueChanged<String> onProfileSelected;
  final bool compact;

  const POSTouchLayoutProfileSelector({
    super.key,
    required this.catalog,
    required this.selectedProfile,
    required this.onProfileSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return POSSurface(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      color: theme.colorScheme.surfaceContainerLowest,
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.72),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedProfile.id,
          isDense: true,
          icon: const Icon(Icons.expand_more),
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          selectedItemBuilder: (context) {
            return [
              for (final profile in catalog.profiles)
                _SelectedProfileLabel(profile: profile, compact: compact),
            ];
          },
          items: [
            for (final profile in catalog.profiles)
              DropdownMenuItem<String>(
                value: profile.id,
                child: _ProfileMenuItem(profile: profile),
              ),
          ],
          onChanged: (value) {
            if (value == null || value == selectedProfile.id) return;
            onProfileSelected(value);
          },
        ),
      ),
    );
  }
}

class _SelectedProfileLabel extends StatelessWidget {
  final POSTouchLayoutProfile profile;
  final bool compact;

  const _SelectedProfileLabel({required this.profile, required this.compact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.dashboard_customize_outlined, size: compact ? 16 : 18),
        const SizedBox(width: POSUiTokens.gap),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: compact ? 118 : 180),
          child: Text(
            profile.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final POSTouchLayoutProfile profile;

  const _ProfileMenuItem({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            profile.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '${profile.productLine} | ${profile.density.label} | ${profile.catalogEmphasis.label}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'POS touch layout selector')
Widget posTouchLayoutProfileSelectorPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: POSTouchLayoutProfileSelector(
          catalog: defaultPOSTouchLayoutProfileCatalog,
          selectedProfile: coffeeCounterTouchLayoutProfile,
          onProfileSelected: (_) {},
        ),
      ),
    ),
  );
}
