class DashboardActionDetailSectionProgress {
  final String sectionLabel;
  final String ownerActionCue;
  final int sectionIndex;
  final int sectionCount;

  const DashboardActionDetailSectionProgress({
    required this.sectionLabel,
    required this.ownerActionCue,
    required this.sectionIndex,
    required this.sectionCount,
  });

  static const initial = DashboardActionDetailSectionProgress(
    sectionLabel: 'Overview',
    ownerActionCue: 'Confirm the owner, due window, and risk level',
    sectionIndex: 1,
    sectionCount: 5,
  );

  double get value {
    if (sectionCount <= 0) {
      return 0;
    }

    return sectionIndex / sectionCount;
  }

  String get positionLabel => 'Section $sectionIndex of $sectionCount';

  String get actionLabel => 'Do next: $ownerActionCue';

  String get semanticLabel => '$sectionLabel, $positionLabel, $actionLabel';

  @override
  bool operator ==(Object other) {
    return other is DashboardActionDetailSectionProgress &&
        other.sectionLabel == sectionLabel &&
        other.ownerActionCue == ownerActionCue &&
        other.sectionIndex == sectionIndex &&
        other.sectionCount == sectionCount;
  }

  @override
  int get hashCode =>
      Object.hash(sectionLabel, ownerActionCue, sectionIndex, sectionCount);
}
