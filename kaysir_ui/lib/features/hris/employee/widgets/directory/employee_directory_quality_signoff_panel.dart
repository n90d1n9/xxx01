import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_quality_gate_models.dart';
import '../../models/employee_directory_quality_signoff_models.dart';
import 'employee_directory_quality_signoff_tiles.dart';

/// Governed sign-off form for roster quality gate cutoff approval.
class EmployeeDirectoryQualitySignoffPanel extends StatefulWidget {
  final EmployeeDirectoryQualityGateSignoffReview review;
  final ValueChanged<String> onReviewerChanged;
  final ValueChanged<String> onNoteChanged;
  final ValueChanged<bool> onAcceptReviewItemsChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const EmployeeDirectoryQualitySignoffPanel({
    super.key,
    required this.review,
    required this.onReviewerChanged,
    required this.onNoteChanged,
    required this.onAcceptReviewItemsChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<EmployeeDirectoryQualitySignoffPanel> createState() =>
      _EmployeeDirectoryQualitySignoffPanelState();
}

/// Synchronizes local text controllers with the roster sign-off draft.
class _EmployeeDirectoryQualitySignoffPanelState
    extends State<EmployeeDirectoryQualitySignoffPanel> {
  late final TextEditingController _reviewerController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _reviewerController = TextEditingController(
      text: widget.review.draft.reviewer,
    );
    _noteController = TextEditingController(text: widget.review.draft.note);
  }

  @override
  void didUpdateWidget(EmployeeDirectoryQualitySignoffPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_reviewerController, widget.review.draft.reviewer);
    _syncController(_noteController, widget.review.draft.note);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    return HrisSectionPanel(
      key: const ValueKey('employee-directory-quality-signoff-panel'),
      icon: Icons.fact_check_outlined,
      title: 'Roster gate sign-off',
      subtitle:
          review.latestSignoff == null
              ? 'Review cutoff readiness and capture accountable approval'
              : 'Latest sign-off by ${review.latestSignoff!.reviewer}',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Gate', value: review.gate.status.label),
            HrisMetricStripItem(
              label: 'Readiness',
              value: '${review.gate.readinessScore}%',
            ),
            HrisMetricStripItem(
              label: 'Review',
              value: '${review.reviewItemCount}',
            ),
            HrisMetricStripItem(label: 'Ready', value: review.statusLabel),
          ],
        ),
        if (review.latestSignoff != null)
          EmployeeDirectoryQualityGateSignoffTile(
            key: ValueKey(
              'employee-directory-quality-signoff-${review.latestSignoff!.id}',
            ),
            signoff: review.latestSignoff!,
          ),
        _buildForm(context, review),
      ],
    );
  }

  Widget _buildForm(
    BuildContext context,
    EmployeeDirectoryQualityGateSignoffReview review,
  ) {
    final blocked =
        review.gate.status == EmployeeDirectoryQualityGateStatus.blocked;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 720) {
                return Column(
                  children: [
                    _reviewerField(),
                    const SizedBox(height: 12),
                    _noteField(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _reviewerField()),
                  const SizedBox(width: 12),
                  Expanded(child: _noteField()),
                ],
              );
            },
          ),
          if (review.reviewItemCount > 0) ...[
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap:
                  blocked
                      ? null
                      : () => widget.onAcceptReviewItemsChanged(
                        !review.draft.acceptReviewItems,
                      ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      key: const ValueKey(
                        'employee-directory-quality-signoff-accept-review-toggle',
                      ),
                      value: review.draft.acceptReviewItems,
                      onChanged:
                          blocked
                              ? null
                              : (value) => widget.onAcceptReviewItemsChanged(
                                value ?? false,
                              ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Accept ${review.reviewItemCount} open review item'
                        '${review.reviewItemCount == 1 ? '' : 's'} for this cutoff',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          HrisProgressBar(
            value: review.completionRatio,
            color:
                review.canSubmit ? const Color(0xFF15803D) : HrisColors.primary,
            label: '${(review.completionRatio * 100).round()}% ready',
          ),
          if (review.errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                key: const ValueKey(
                  'employee-directory-quality-signoff-submit-button',
                ),
                onPressed: review.canSubmit ? widget.onSubmit : null,
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('Sign off roster gate'),
              ),
              OutlinedButton.icon(
                key: const ValueKey(
                  'employee-directory-quality-signoff-clear-button',
                ),
                onPressed: review.draft.hasInput ? widget.onClear : null,
                icon: const Icon(Icons.clear_all_outlined),
                label: const Text('Clear sign-off'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewerField() {
    return TextField(
      key: const ValueKey('employee-directory-quality-signoff-reviewer-field'),
      controller: _reviewerController,
      decoration: const InputDecoration(
        labelText: 'Reviewer',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onReviewerChanged,
    );
  }

  Widget _noteField() {
    return TextField(
      key: const ValueKey('employee-directory-quality-signoff-note-field'),
      controller: _noteController,
      minLines: 2,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Sign-off note',
        prefixIcon: Icon(Icons.notes_outlined),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onNoteChanged,
    );
  }
}

@Preview(name: 'Employee quality gate sign-off')
Widget employeeDirectoryQualitySignoffPanelPreview() {
  const gate = EmployeeDirectoryQualityGate(
    status: EmployeeDirectoryQualityGateStatus.review,
    memberCount: 3,
    readinessScore: 67,
    blockerCount: 0,
    reviewCount: 1,
    advisoryCount: 0,
    nextIssue: null,
    checks: [],
  );
  final review = EmployeeDirectoryQualityGateSignoffReview.fromState(
    gate: gate,
    draft: const EmployeeDirectoryQualityGateSignoffDraft(
      reviewer: 'Alya Rahman',
      note: 'Reviewed remaining routing item for cutoff.',
      acceptReviewItems: true,
    ),
    signoffs: const [],
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryQualitySignoffPanel(
          review: review,
          onReviewerChanged: (_) {},
          onNoteChanged: (_) {},
          onAcceptReviewItemsChanged: (_) {},
          onSubmit: () {},
          onClear: () {},
        ),
      ),
    ),
  );
}

void _syncController(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.text = value;
}
