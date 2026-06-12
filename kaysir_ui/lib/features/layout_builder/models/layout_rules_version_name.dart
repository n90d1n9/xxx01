import 'layout_config.dart';

/// Builds concise Layout Rules version history names from the applied change.
String layoutRulesVersionName({
  required LayoutMechanism mechanism,
  required bool snapVisiblePositions,
  required bool snapVisibleSizes,
  required bool resolveAutoGridConflicts,
  required bool hasRuleChanges,
}) {
  if (snapVisibleSizes || resolveAutoGridConflicts) {
    return 'Layout rules: Convert to ${mechanism.label}';
  }

  if (snapVisiblePositions) {
    return hasRuleChanges
        ? 'Layout rules: Update and snap visible'
        : 'Layout rules: Snap visible';
  }

  return 'Layout rules: Update rules';
}
