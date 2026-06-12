import 'package:flutter/material.dart';

import '../../analytics/survey_response_sync_readiness.dart';
import 'survey_read_only_pill.dart';

part 'survey_response_sync_readiness_panel_empty.dart';
part 'survey_response_sync_readiness_panel_header.dart';
part 'survey_response_sync_readiness_panel_queue.dart';
part 'survey_response_sync_readiness_panel_snapshot.dart';
part 'survey_response_sync_readiness_panel_stats.dart';

/// Summarizes response draft readiness and the next fieldwork actions.
class SurveyResponseSyncReadinessPanel extends StatelessWidget {
  final SurveyResponseSyncReadinessInsights insights;
  final int visibleItemLimit;
  final ValueChanged<SurveyResponseSyncReadiness>? onOpenResponse;

  const SurveyResponseSyncReadinessPanel({
    super.key,
    required this.insights,
    this.visibleItemLimit = 5,
    this.onOpenResponse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final snapshot = _ReadinessPanelSnapshot.fromInsights(
      insights,
      visibleItemLimit: visibleItemLimit,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReadinessHeader(snapshot: snapshot),
            const SizedBox(height: 16),
            _ReadinessStatWrap(snapshot: snapshot),
            const SizedBox(height: 18),
            Divider(color: colorScheme.outlineVariant, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Fieldwork Action Queue',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                if (snapshot.hiddenQueueCount > 0)
                  Text(
                    '+${snapshot.hiddenQueueCount} more',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (snapshot.items.isEmpty)
              const _ReadinessQuietState(
                icon: Icons.assignment_turned_in_outlined,
                title: 'No response drafts yet',
                subtitle:
                    'Drafts, evidence blockers, and upload waits will appear here as fieldwork starts.',
              )
            else if (snapshot.queue.isEmpty)
              const _ReadinessQuietState(
                icon: Icons.verified_outlined,
                title: 'No fieldwork blockers',
                subtitle:
                    'Responses are either submitted or ready for the next review step.',
              )
            else
              Column(
                children: [
                  for (var index = 0; index < snapshot.queue.length; index++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: index == snapshot.queue.length - 1 ? 0 : 10,
                      ),
                      child: _ReadinessQueueRow(
                        item: snapshot.queue[index],
                        onOpenResponse: onOpenResponse,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
