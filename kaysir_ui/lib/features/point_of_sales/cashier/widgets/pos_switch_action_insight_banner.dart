import 'package:flutter/material.dart';

import '../experiences/pos_switch_action_history_insight.dart';
import 'pos_inline_notice.dart';
import 'pos_insight_notice.dart';

class POSSwitchActionInsightBanner extends StatelessWidget {
  final POSSwitchActionHistoryInsight insight;
  final bool showNextStep;

  const POSSwitchActionInsightBanner({
    super.key,
    required this.insight,
    this.showNextStep = true,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _visuals(insight.level);

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

  POSInsightNoticeVisuals _visuals(POSSwitchActionHistoryInsightLevel level) {
    switch (level) {
      case POSSwitchActionHistoryInsightLevel.ready:
        return POSInsightNoticeVisuals.ready;
      case POSSwitchActionHistoryInsightLevel.review:
        return POSInsightNoticeVisuals.review;
      case POSSwitchActionHistoryInsightLevel.attention:
        return POSInsightNoticeVisuals.attention;
    }
  }
}
