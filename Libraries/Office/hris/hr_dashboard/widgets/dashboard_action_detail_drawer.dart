import 'package:flutter/material.dart';

import '../models/dashboard_action_detail.dart';
import '../models/dashboard_action_detail_section.dart';
import '../models/dashboard_action_detail_section_progress.dart';
import '../models/dashboard_action_summary.dart';
import 'dashboard_action_detail_body.dart';
import 'dashboard_action_detail_body_controller.dart';
import 'dashboard_action_detail_footer.dart';
import 'dashboard_action_detail_header.dart';
import 'dashboard_action_detail_progress.dart';

class DashboardActionDetailDrawer extends StatefulWidget {
  final DashboardActionDetail detail;
  final ValueChanged<DashboardActionRecommendation>? onStart;
  final ValueChanged<DashboardActionRecommendation>? onComplete;
  final ValueChanged<DashboardActionRecommendation>? onReopen;

  const DashboardActionDetailDrawer({
    super.key,
    required this.detail,
    this.onStart,
    this.onComplete,
    this.onReopen,
  });

  @override
  State<DashboardActionDetailDrawer> createState() =>
      _DashboardActionDetailDrawerState();
}

class _DashboardActionDetailDrawerState
    extends State<DashboardActionDetailDrawer> {
  final _bodyController = DashboardActionDetailBodyController();
  var _sectionProgress = DashboardActionDetailSection.overview.progress;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DashboardActionDetailDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail.action.id != widget.detail.action.id) {
      _sectionProgress = DashboardActionDetailSection.overview.progress;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.86,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardActionDetailHeader(detail: widget.detail),
              const SizedBox(height: 14),
              DashboardActionDetailProgress(
                progress: _sectionProgress,
                onReturnToOverview: _bodyController.returnToOverview,
                onGoToPreviousSection: _bodyController.goToPreviousSection,
                onGoToNextSection: _bodyController.goToNextSection,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: DashboardActionDetailBody(
                  detail: widget.detail,
                  controller: _bodyController,
                  onSectionProgressChanged: _handleSectionProgressChanged,
                ),
              ),
              const SizedBox(height: 12),
              DashboardActionDetailFooter(
                detail: widget.detail,
                onStart: widget.onStart,
                onComplete: widget.onComplete,
                onReopen: widget.onReopen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSectionProgressChanged(
    DashboardActionDetailSectionProgress progress,
  ) {
    if (_sectionProgress == progress) {
      return;
    }

    setState(() => _sectionProgress = progress);
  }
}
