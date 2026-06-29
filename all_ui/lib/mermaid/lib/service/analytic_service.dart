import 'package:flutter/widgets.dart';

import '../model/data_type.dart';

class AnalyticsService {
  void trackEvent(String event, Map<String, dynamic> properties) {
    debugPrint('Analytics: $event - $properties');
    // Send to Firebase Analytics, Mixpanel, etc.
  }

  void trackReportView(String reportId) {
    trackEvent('report_viewed', {'report_id': reportId});
  }

  void trackReportExport(String reportId, ExportFormat format) {
    trackEvent('report_exported', {
      'report_id': reportId,
      'format': format.name,
    });
  }
}
