import 'pos_switch_action_result.dart';

class POSSwitchActionText {
  final String feedbackMessage;
  final String historyMessage;
  final String supportSummary;
  final String? operatorGuidance;

  const POSSwitchActionText({
    required this.feedbackMessage,
    required this.historyMessage,
    required this.supportSummary,
    this.operatorGuidance,
  });

  factory POSSwitchActionText.fromResult(POSSwitchActionResult result) {
    final reason = result.reason?.trim();

    return POSSwitchActionText(
      feedbackMessage: _feedbackMessage(result, reason),
      historyMessage: _historyMessage(result, reason),
      supportSummary: _supportSummary(result, reason),
      operatorGuidance: _operatorGuidance(result),
    );
  }

  static String _feedbackMessage(POSSwitchActionResult result, String? reason) {
    switch (result.outcome) {
      case POSSwitchActionOutcome.applied:
        return '${result.kindLabel} switched to ${result.targetLabel}';
      case POSSwitchActionOutcome.blocked:
        return reason == null || reason.isEmpty
            ? '${result.kindLabel} switch blocked'
            : '${result.kindLabel} switch blocked: $reason';
      case POSSwitchActionOutcome.cancelled:
        return reason == null || reason.isEmpty
            ? '${result.kindLabel} switch cancelled'
            : '${result.kindLabel} switch cancelled: $reason';
    }
  }

  static String _historyMessage(POSSwitchActionResult result, String? reason) {
    if (reason == null || reason.isEmpty) {
      return '${result.kindLabel} switch ${result.outcomeLabel.toLowerCase()}.';
    }

    return '${result.kindLabel} switch ${result.outcomeLabel.toLowerCase()}: ${_sentence(reason)}';
  }

  static String _supportSummary(POSSwitchActionResult result, String? reason) {
    if (reason == null || reason.isEmpty) return result.summaryLabel;

    return '${result.summaryLabel} - ${_sentence(reason)}';
  }

  static String? _operatorGuidance(POSSwitchActionResult result) {
    switch (result.outcome) {
      case POSSwitchActionOutcome.applied:
        return null;
      case POSSwitchActionOutcome.blocked:
        return _blockedGuidance(result.kind);
      case POSSwitchActionOutcome.cancelled:
        return 'No change was applied. Operators can retry when ready.';
    }
  }

  static String _blockedGuidance(POSSwitchActionKind kind) {
    switch (kind) {
      case POSSwitchActionKind.mode:
        return 'Resolve the mode requirement, then retry this POS mode.';
      case POSSwitchActionKind.runtimePack:
        return 'Finish or hold the current order before retrying this runtime pack.';
      case POSSwitchActionKind.commerceChannel:
        return 'Review channel preflight requirements before retrying this channel.';
    }
  }

  static String _sentence(String value) {
    if (value.endsWith('.') || value.endsWith('?') || value.endsWith('!')) {
      return value;
    }

    return '$value.';
  }
}
