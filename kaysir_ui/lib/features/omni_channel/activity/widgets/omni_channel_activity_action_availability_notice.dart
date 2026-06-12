import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_status_pill.dart';
import '../models/omni_channel_activity_action.dart';
import 'omni_channel_activity_presentation.dart';

/// Inline notice that explains why contributed activity actions are unavailable.
class OmniChannelActivityActionAvailabilityNotice extends StatelessWidget {
  final List<OmniChannelActivityAction> actions;

  const OmniChannelActivityActionAvailabilityNotice({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final disabledActions = actions
        .where((action) => !action.isEnabled)
        .toList(growable: false);
    if (disabledActions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.lock_clock_outlined, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  'Unavailable actions',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final action in disabledActions)
                  _UnavailableActionReason(action: action),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Omni-channel action availability notice')
Widget omniChannelActivityActionAvailabilityNoticePreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: OmniChannelActivityActionAvailabilityNotice(
          actions: [
            OmniChannelActivityAction(
              label: 'Open sync queue',
              location: '/cashier',
              tooltip: 'Retry failed sync',
              intent: OmniChannelActivityActionIntent.retry,
              enabled: false,
              disabledReason: 'Sync is already running.',
            ),
          ],
        ),
      ),
    ),
  );
}

/// Compact label and reason pair for one unavailable action.
class _UnavailableActionReason extends StatelessWidget {
  final OmniChannelActivityAction action;

  const _UnavailableActionReason({required this.action});

  @override
  Widget build(BuildContext context) {
    final presentation = OmniChannelActivityActionPresentation(action);
    final colorScheme = Theme.of(context).colorScheme;
    final color = omniChannelActivityToneColor(colorScheme, presentation.tone);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppStatusPill(
            label: presentation.label,
            color: color,
            icon: presentation.icon,
            maxWidth: 172,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                presentation.tooltip,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
