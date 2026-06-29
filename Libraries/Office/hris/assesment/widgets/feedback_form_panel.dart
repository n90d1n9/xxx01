import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/feedback_state.dart';
import 'rating_card.dart';

class FeedbackFormPanel extends StatelessWidget {
  final FeedbackState state;
  final void Function(String categoryId, double rating) onRatingUpdate;
  final ValueChanged<String> onCommentsChanged;
  final VoidCallback onSubmit;

  const FeedbackFormPanel({
    super.key,
    required this.state,
    required this.onRatingUpdate,
    required this.onCommentsChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final employee = state.selectedEmployee!;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: hrisPanelDecoration(),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: HrisColors.primary.withValues(alpha: 0.12),
                child: Text(
                  _initials(employee.name),
                  style: const TextStyle(
                    color: HrisColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${employee.position ?? 'Role not set'} - ${employee.department ?? 'Department not set'}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(
                label: state.hasCompleteRatings ? 'Ready' : 'In progress',
                color:
                    state.hasCompleteRatings
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        HrisSectionPanel(
          title: 'Rate Performance',
          icon: Icons.star_rate_outlined,
          subtitle:
              '${state.ratedCount}/${state.categories.length} categories rated',
          children:
              state.categories
                  .map(
                    (category) => RatingCard(
                      category: category,
                      rating: state.ratings[category.id] ?? 0,
                      onRatingUpdate:
                          (rating) => onRatingUpdate(category.id, rating),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: hrisPanelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Additional Feedback',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: onCommentsChanged,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Share your observations and suggestions...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: state.canSubmit ? onSubmit : null,
                  icon:
                      state.isSubmitting
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.send_outlined),
                  label: const Text('Submit Feedback'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}
