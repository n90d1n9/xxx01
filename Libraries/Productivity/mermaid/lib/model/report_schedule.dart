import 'package:flutter/material.dart';

import 'data_type.dart';

class ReportSchedule {
  final String id;
  final ScheduleFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final TimeOfDay time;
  final List<String> recipients;
  final List<ExportFormat> formats;
  final bool isActive;

  final List<String> ccRecipients;

  final Map<String, dynamic> emailTemplate;
  final String? timezone;

  ReportSchedule({
    String? id,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.time,
    required this.recipients,
    required this.formats,
    this.isActive = true,
    this.ccRecipients = const [],
    this.emailTemplate = const {},
    this.timezone,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}
