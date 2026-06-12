class ReportState  {
   factory ReportState({
    required List<AdvancedReport> reports,
    required ReportFilter filter,
    required ReportMetadata metadata,
    required bool isLoading,
    required String? error,
  });

  factory ReportState.initial() => const ReportState(
        reports: [],
        filter: ReportFilter(),
        metadata: ReportMetadata(),
        isLoading: false,
        error: null,
      );
}
