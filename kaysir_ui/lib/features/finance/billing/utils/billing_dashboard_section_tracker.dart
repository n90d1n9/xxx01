class BillingDashboardSectionPosition<T> {
  final T section;
  final double leadingOffset;

  const BillingDashboardSectionPosition({
    required this.section,
    required this.leadingOffset,
  });
}

T? activeBillingDashboardSection<T>(
  Iterable<BillingDashboardSectionPosition<T>> sections, {
  double activationOffset = 96,
}) {
  final sortedSections =
      sections.where((section) => section.leadingOffset.isFinite).toList()
        ..sort((a, b) => a.leadingOffset.compareTo(b.leadingOffset));

  if (sortedSections.isEmpty) return null;

  var activeSection = sortedSections.first.section;
  for (final section in sortedSections) {
    if (section.leadingOffset > activationOffset) break;
    activeSection = section.section;
  }

  return activeSection;
}
