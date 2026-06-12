import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_performance_models.dart';

class EmployeePerformanceCheckInForm extends StatelessWidget {
  final EmployeePerformanceCheckInDraft draft;
  final TextEditingController summaryController;
  final TextEditingController nextStepController;
  final ValueChanged<EmployeePerformanceCheckInSentiment> onSentimentChanged;
  final ValueChanged<String> onSummaryChanged;
  final ValueChanged<String> onNextStepChanged;
  final VoidCallback onSubmit;

  const EmployeePerformanceCheckInForm({
    super.key,
    required this.draft,
    required this.summaryController,
    required this.nextStepController,
    required this.onSentimentChanged,
    required this.onSummaryChanged,
    required this.onNextStepChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<EmployeePerformanceCheckInSentiment>(
            segments:
                EmployeePerformanceCheckInSentiment.values
                    .map(
                      (sentiment) => ButtonSegment(
                        value: sentiment,
                        label: Text(sentiment.label),
                      ),
                    )
                    .toList(),
            selected: {draft.sentiment},
            onSelectionChanged:
                (selection) => onSentimentChanged(selection.single),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: summaryController,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Check-in summary',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.summarize_outlined),
            ),
            onChanged: onSummaryChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nextStepController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Next step',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.next_plan_outlined),
            ),
            onChanged: onNextStepChanged,
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                draft.isReadyToAdd
                    ? const Color(0xFF15803D)
                    : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% ready',
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: draft.isReadyToAdd ? onSubmit : null,
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('Add check-in'),
            ),
          ),
        ],
      ),
    );
  }
}
