import 'report_generation_request.dart';

class ReportExportPackageProfile {
  final int selectedSectionCount;
  final int estimatedKilobytes;
  final int estimatedGenerationSeconds;

  const ReportExportPackageProfile({
    required this.selectedSectionCount,
    required this.estimatedKilobytes,
    required this.estimatedGenerationSeconds,
  });

  factory ReportExportPackageProfile.fromRequest(
    ReportGenerationRequest request,
  ) {
    return ReportExportPackageProfile(
      selectedSectionCount: request.contentLabels.length,
      estimatedKilobytes: _estimateKilobytes(request),
      estimatedGenerationSeconds: _estimateGenerationSeconds(request),
    );
  }

  String get sectionCountLabel {
    final noun = selectedSectionCount == 1 ? 'section' : 'sections';
    return '$selectedSectionCount $noun';
  }

  String get estimatedSizeLabel {
    return 'Est. ${_formatSize(estimatedKilobytes)}';
  }

  String get estimatedGenerationLabel {
    return '${_formatDuration(estimatedGenerationSeconds)} generation';
  }
}

int _estimateKilobytes(ReportGenerationRequest request) {
  var kilobytes = switch (request.format) {
    ReportFileFormat.pdf => 520,
    ReportFileFormat.excel => 420,
    ReportFileFormat.csv => 180,
  };

  if (request.includeExecutiveSummary) kilobytes += 280;
  if (request.includeTrendCharts) {
    kilobytes += switch (request.format) {
      ReportFileFormat.pdf => 900,
      ReportFileFormat.excel => 720,
      ReportFileFormat.csv => 120,
    };
  }
  if (request.includeRawData) {
    kilobytes += switch (request.format) {
      ReportFileFormat.pdf => 1600,
      ReportFileFormat.excel => 2400,
      ReportFileFormat.csv => 1800,
    };
  }

  return kilobytes;
}

String _formatSize(int kilobytes) {
  if (kilobytes < 1024) return '$kilobytes KB';

  final megabytes = kilobytes / 1024;
  final formatted = megabytes.toStringAsFixed(1);
  return '${formatted.endsWith('.0') ? formatted.substring(0, formatted.length - 2) : formatted} MB';
}

int _estimateGenerationSeconds(ReportGenerationRequest request) {
  var seconds = switch (request.format) {
    ReportFileFormat.pdf => 35,
    ReportFileFormat.excel => 30,
    ReportFileFormat.csv => 20,
  };

  if (request.includeExecutiveSummary) seconds += 15;
  if (request.includeTrendCharts) {
    seconds += switch (request.format) {
      ReportFileFormat.pdf => 30,
      ReportFileFormat.excel => 25,
      ReportFileFormat.csv => 10,
    };
  }
  if (request.includeRawData) {
    seconds += switch (request.format) {
      ReportFileFormat.pdf => 45,
      ReportFileFormat.excel => 60,
      ReportFileFormat.csv => 35,
    };
  }

  return seconds;
}

String _formatDuration(int seconds) {
  if (seconds < 60) return '~${seconds}s';

  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  if (remainingSeconds == 0) return '~${minutes}m';

  return '~${minutes}m ${remainingSeconds}s';
}
