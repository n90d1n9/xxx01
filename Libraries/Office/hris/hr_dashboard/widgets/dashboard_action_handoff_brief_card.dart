import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_handoff_brief.dart';

class DashboardActionHandoffBriefCard extends StatelessWidget {
  final DashboardActionHandoffBrief brief;
  final ValueChanged<String>? onCopy;

  const DashboardActionHandoffBriefCard({
    super.key,
    required this.brief,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    if (brief.lines.isEmpty) {
      return const SizedBox.shrink();
    }

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.ios_share_outlined, color: HrisColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Handoff brief',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${brief.lines.length} lines',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: HrisColors.muted),
              ),
              const SizedBox(width: 8),
              SizedBox.square(
                dimension: 36,
                child: IconButton(
                  tooltip: 'Copy handoff brief',
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 36,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => _copyBrief(context),
                  icon: const Icon(Icons.content_copy_rounded, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final (index, line) in brief.lines.indexed) ...[
            _HandoffLineTile(line: line, onCopyLine: _copyLine),
            if (index != brief.lines.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Future<void> _copyBrief(BuildContext context) async {
    await _copyText(
      context: context,
      text: brief.clipboardText,
      message: 'Handoff brief copied',
    );
  }

  Future<void> _copyLine(
    BuildContext context,
    DashboardActionHandoffLine line,
  ) async {
    await _copyText(
      context: context,
      text: line.clipboardText,
      message: '${line.label} copied',
    );
  }

  Future<void> _copyText({
    required BuildContext context,
    required String text,
    required String message,
  }) async {
    final copyHandler = onCopy;
    if (copyHandler == null) {
      await Clipboard.setData(ClipboardData(text: text));
    } else {
      copyHandler(text);
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }
}

class _HandoffLineTile extends StatelessWidget {
  final DashboardActionHandoffLine line;
  final Future<void> Function(BuildContext, DashboardActionHandoffLine)
  onCopyLine;

  const _HandoffLineTile({required this.line, required this.onCopyLine});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(line.kind);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_iconFor(line.kind), color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: HrisColors.muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  line.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  line.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox.square(
            dimension: 32,
            child: IconButton(
              tooltip: 'Copy ${line.label.toLowerCase()}',
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              padding: EdgeInsets.zero,
              onPressed: () => onCopyLine(context, line),
              icon: const Icon(Icons.content_copy_rounded, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(DashboardActionHandoffKind kind) {
    return switch (kind) {
      DashboardActionHandoffKind.ownerAsk => Icons.record_voice_over_outlined,
      DashboardActionHandoffKind.evidence => Icons.fact_check_outlined,
      DashboardActionHandoffKind.review => Icons.event_available_outlined,
    };
  }

  Color _colorFor(DashboardActionHandoffKind kind) {
    return switch (kind) {
      DashboardActionHandoffKind.ownerAsk => HrisColors.primary,
      DashboardActionHandoffKind.evidence => const Color(0xFF7C3AED),
      DashboardActionHandoffKind.review => const Color(0xFF0F766E),
    };
  }
}
