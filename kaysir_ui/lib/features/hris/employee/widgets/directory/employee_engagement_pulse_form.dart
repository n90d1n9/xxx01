import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_engagement_models.dart';
import 'employee_engagement_styles.dart';

class EmployeeEngagementPulseForm extends StatelessWidget {
  final EmployeeEngagementPulseDraft draft;
  final TextEditingController summaryController;
  final TextEditingController nextStepController;
  final ValueChanged<EmployeeEngagementSentiment> onSentimentChanged;
  final ValueChanged<int> onScoreChanged;
  final ValueChanged<String> onSummaryChanged;
  final ValueChanged<String> onNextStepChanged;
  final VoidCallback onAdd;

  const EmployeeEngagementPulseForm({
    super.key,
    required this.draft,
    required this.summaryController,
    required this.nextStepController,
    required this.onSentimentChanged,
    required this.onScoreChanged,
    required this.onSummaryChanged,
    required this.onNextStepChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;
    final sentimentColor = employeeEngagementSentimentColor(draft.sentiment);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<EmployeeEngagementSentiment>(
            segments:
                EmployeeEngagementSentiment.values
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
          Text(
            'Pulse score ${draft.score}/5',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          Slider(
            value: draft.score.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '${draft.score}',
            activeColor: sentimentColor,
            onChanged: (value) => onScoreChanged(value.round()),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: summaryController,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Pulse summary',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.favorite_border_outlined),
            ),
            onChanged: onSummaryChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nextStepController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Follow-up action',
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
              onPressed: draft.isReadyToAdd ? onAdd : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Add pulse'),
            ),
          ),
        ],
      ),
    );
  }
}
