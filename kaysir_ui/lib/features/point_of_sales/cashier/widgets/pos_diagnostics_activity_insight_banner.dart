import 'package:flutter/material.dart';

import '../experiences/pos_diagnostics_activity.dart';
import '../experiences/pos_diagnostics_activity_insight.dart';
import 'pos_inline_notice.dart';
import 'pos_insight_notice.dart';

class POSDiagnosticsActivityInsightBanner extends StatelessWidget {
  final POSDiagnosticsActivityInsight insight;
  final bool showNextStep;

  const POSDiagnosticsActivityInsightBanner({
    super.key,
    required this.insight,
    this.showNextStep = true,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _visuals(insight.severity);

    return POSInlineNotice(
      tone: visuals.noticeTone,
      icon: visuals.icon,
      title: insight.headline,
      message: insight.detail,
      footer:
          showNextStep
              ? POSInsightNextStep(
                message: insight.nextStep,
                tone: visuals.previewTone,
              )
              : null,
    );
  }

  POSInsightNoticeVisuals _visuals(POSDiagnosticsActivitySeverity severity) {
    switch (severity) {
      case POSDiagnosticsActivitySeverity.ready:
        return POSInsightNoticeVisuals.ready;
      case POSDiagnosticsActivitySeverity.review:
        return POSInsightNoticeVisuals.review;
      case POSDiagnosticsActivitySeverity.attention:
        return POSInsightNoticeVisuals.attention;
    }
  }
}
