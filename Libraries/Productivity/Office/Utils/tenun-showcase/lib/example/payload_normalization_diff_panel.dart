import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide FontWeight;

class PayloadNormalizationDiffPanel extends StatelessWidget {
  const PayloadNormalizationDiffPanel({
    super.key,
    required this.diffs,
    required this.summary,
    required this.highlightDiff,
  });

  final List<PayloadDiff> diffs;
  final PayloadDiffSummary summary;
  final bool highlightDiff;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diff (Raw -> Normalized)',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _DiffLegendChip(
                kind: PayloadDiffKind.added,
                count: summary.added,
              ),
              _DiffLegendChip(
                kind: PayloadDiffKind.removed,
                count: summary.removed,
              ),
              _DiffLegendChip(
                kind: PayloadDiffKind.changed,
                count: summary.changed,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: diffs.isEmpty
                ? const Text(
                    'No changed paths.',
                    style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
                  )
                : ListView.builder(
                    itemCount: diffs.length > 30 ? 30 : diffs.length,
                    itemBuilder: (context, index) {
                      final diff = diffs[index];
                      if (!highlightDiff) {
                        return Text(
                          '${diff.path}: ${diff.rawText} -> ${diff.normalizedText}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            height: 1.25,
                          ),
                        );
                      }
                      return _HighlightedDiffRow(diff: diff);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DiffLegendChip extends StatelessWidget {
  const _DiffLegendChip({required this.kind, required this.count});

  final PayloadDiffKind kind;
  final int count;

  @override
  Widget build(BuildContext context) {
    final color = payloadDiffKindColor(kind);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${payloadDiffKindLabel(kind)}: $count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.95),
        ),
      ),
    );
  }
}

class _HighlightedDiffRow extends StatelessWidget {
  const _HighlightedDiffRow({required this.diff});

  final PayloadDiff diff;

  @override
  Widget build(BuildContext context) {
    final color = payloadDiffKindColor(diff.kind);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  payloadDiffKindLabel(diff.kind).toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: color.withValues(alpha: 0.95),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  diff.path,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'raw: ${diff.rawText}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9.5,
              fontFamily: 'monospace',
              height: 1.2,
            ),
          ),
          Text(
            'new: ${diff.normalizedText}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9.5,
              fontFamily: 'monospace',
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

Color payloadDiffKindColor(PayloadDiffKind kind) {
  switch (kind) {
    case PayloadDiffKind.added:
      return Colors.green;
    case PayloadDiffKind.removed:
      return Colors.red;
    case PayloadDiffKind.changed:
      return Colors.orange;
  }
}

String payloadDiffKindLabel(PayloadDiffKind kind) {
  switch (kind) {
    case PayloadDiffKind.added:
      return 'added';
    case PayloadDiffKind.removed:
      return 'removed';
    case PayloadDiffKind.changed:
      return 'changed';
  }
}
