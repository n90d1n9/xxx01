class DashboardActionImpactEstimate {
  final String title;
  final String currentLabel;
  final String currentValue;
  final String targetLabel;
  final String targetValue;
  final String timeframe;
  final String description;

  const DashboardActionImpactEstimate({
    required this.title,
    required this.currentLabel,
    required this.currentValue,
    required this.targetLabel,
    required this.targetValue,
    required this.timeframe,
    required this.description,
  });
}
