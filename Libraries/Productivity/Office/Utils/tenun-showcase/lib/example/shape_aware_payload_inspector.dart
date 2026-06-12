import 'package:flutter/material.dart' hide Align;
import 'package:flutter/widgets.dart' as widgets;

import 'shape_aware_switch_diff.dart';

typedef ShapePayloadCopyCallback =
    void Function(String text, String successMessage);

class ShapePayloadInspector extends StatelessWidget {
  final Map<String, dynamic> currentJson;
  final Map<String, dynamic>? previousJson;
  final String lastSwitchMode;
  final List<String> lastDiffPaths;
  final bool showPinnedOnlyDiffPaths;
  final int maxJsonPreviewChars;
  final VoidCallback onResetPayload;
  final ValueChanged<bool> onPinnedOnlyChanged;
  final ShapePayloadCopyCallback onCopy;

  const ShapePayloadInspector({
    super.key,
    required this.currentJson,
    required this.previousJson,
    required this.lastSwitchMode,
    required this.lastDiffPaths,
    required this.showPinnedOnlyDiffPaths,
    required this.maxJsonPreviewChars,
    required this.onResetPayload,
    required this.onPinnedOnlyChanged,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final prettyCurrent = ShapeAwareSwitchDiff.truncateJson(
      currentJson,
      maxChars: maxJsonPreviewChars,
    );
    final prettyPrevious = previousJson != null
        ? ShapeAwareSwitchDiff.truncateJson(
            previousJson!,
            maxChars: maxJsonPreviewChars,
          )
        : null;
    final semanticSummary = previousJson != null
        ? ShapeAwareSwitchDiff.semanticSummary(previousJson!, currentJson)
        : null;
    final allVisiblePaths = ShapeAwareSwitchDiff.visiblePaths(
      lastDiffPaths,
      pinnedOnly: showPinnedOnlyDiffPaths,
    );
    final paths = allVisiblePaths.take(8).toList();
    final pinnedCount = lastDiffPaths
        .where(ShapeAwareSwitchDiff.isPinnedPath)
        .length;

    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        dense: true,
        title: Text(
          prettyPrevious == null
              ? 'Payload Preview'
              : 'Payload Diff (${lastSwitchMode.toUpperCase()})',
        ),
        subtitle: Text(
          prettyPrevious == null
              ? 'Current JSON snapshot'
              : '${lastDiffPaths.length} changed path(s) • $pinnedCount pinned',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            alignment: WrapAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onResetPayload,
                icon: const Icon(Icons.restore, size: 16),
                label: const Text('Reset Payload'),
              ),
              TextButton.icon(
                onPressed: () {
                  final summary =
                      semanticSummary ?? 'No semantic changes detected';
                  onCopy(summary, 'Semantic summary copied');
                },
                icon: const Icon(Icons.summarize, size: 16),
                label: const Text('Copy Summary'),
              ),
              TextButton.icon(
                onPressed: () {
                  final diffText = allVisiblePaths.isEmpty
                      ? 'No changed paths'
                      : allVisiblePaths.join('\n');
                  onCopy(diffText, 'Diff paths copied');
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy Diff Paths'),
              ),
            ],
          ),
          widgets.Align(
            alignment: Alignment.centerLeft,
            child: FilterChip(
              label: const Text('Pinned paths only'),
              selected: showPinnedOnlyDiffPaths,
              onSelected: onPinnedOnlyChanged,
            ),
          ),
          if (lastSwitchMode != 'none')
            widgets.Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Last action: ${lastSwitchMode.toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (semanticSummary != null)
            widgets.Align(
              alignment: Alignment.centerLeft,
              child: Text(
                semanticSummary,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (showPinnedOnlyDiffPaths && paths.isEmpty)
            widgets.Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No pinned path changed.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (paths.isNotEmpty)
            widgets.Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: paths
                    .map(
                      (path) => Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(path, style: const TextStyle(fontSize: 11)),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (prettyPrevious != null) ...[
            const SizedBox(height: 6),
            ShapePayloadJsonBlock(
              title: 'Before',
              content: prettyPrevious,
              onCopy: onCopy,
            ),
          ],
          const SizedBox(height: 6),
          ShapePayloadJsonBlock(
            title: prettyPrevious != null ? 'After' : 'Current',
            content: prettyCurrent,
            onCopy: onCopy,
          ),
        ],
      ),
    );
  }
}

class ShapePayloadJsonBlock extends StatelessWidget {
  final String title;
  final String content;
  final ShapePayloadCopyCallback onCopy;

  const ShapePayloadJsonBlock({
    super.key,
    required this.title,
    required this.content,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => onCopy(content, '$title JSON copied'),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy JSON'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 180),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              content,
              style: const TextStyle(
                fontSize: 11,
                height: 1.25,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
