import 'dart:typed_data';

enum FinancialReportExportFormat { pdf, csv }

extension FinancialReportExportFormatLabel on FinancialReportExportFormat {
  String get label {
    switch (this) {
      case FinancialReportExportFormat.pdf:
        return 'PDF';
      case FinancialReportExportFormat.csv:
        return 'CSV';
    }
  }

  String get extension {
    switch (this) {
      case FinancialReportExportFormat.pdf:
        return 'pdf';
      case FinancialReportExportFormat.csv:
        return 'csv';
    }
  }

  String get mimeType {
    switch (this) {
      case FinancialReportExportFormat.pdf:
        return 'application/pdf';
      case FinancialReportExportFormat.csv:
        return 'text/csv';
    }
  }
}

class FinancialReportExportArtifact {
  final String fileName;
  final String mimeType;
  final FinancialReportExportFormat format;
  final Uint8List bytes;

  const FinancialReportExportArtifact({
    required this.fileName,
    required this.mimeType,
    required this.format,
    required this.bytes,
  });
}
