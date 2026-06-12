import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

class DashboardActionCompletedHiddenState extends StatelessWidget {
  final VoidCallback? onShowCompleted;

  const DashboardActionCompletedHiddenState({super.key, this.onShowCompleted});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final copy = _CompletedHiddenCopy();
          final action =
              onShowCompleted == null
                  ? null
                  : OutlinedButton.icon(
                    onPressed: onShowCompleted,
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Review completed'),
                  );

          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                if (action != null) ...[
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerLeft, child: action),
                ],
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: copy),
              if (action != null) ...[const SizedBox(width: 12), action],
            ],
          );
        },
      ),
    );
  }
}

class _CompletedHiddenCopy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.task_alt_rounded,
            color: Colors.green.shade700,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All recommended actions are done',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Review completed work or keep the queue focused on active work.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
