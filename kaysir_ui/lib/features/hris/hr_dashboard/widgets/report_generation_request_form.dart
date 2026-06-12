import 'package:flutter/material.dart';

import '../models/report_generation_request.dart';
import '../models/report_type.dart';
import 'report_generation_content_options.dart';
import 'report_generation_form_fields.dart';
import 'report_generation_package_presets.dart';
import 'report_generation_request_preview.dart';

class ReportGenerationRequestForm extends StatelessWidget {
  final ReportType report;
  final ReportGenerationRequest request;
  final ValueChanged<ReportGenerationRequest> onChanged;

  const ReportGenerationRequestForm({
    super.key,
    required this.report,
    required this.request,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReportGenerationPicker<ReportPeriod>(
          fieldKey: const Key('report-period-field'),
          label: 'Time Period',
          icon: Icons.calendar_month_outlined,
          value: request.period,
          values: ReportPeriod.values,
          labelFor: (period) => period.label,
          onChanged: (period) {
            if (period == null) return;
            onChanged(request.copyWith(period: period));
          },
        ),
        const SizedBox(height: 14),
        ReportGenerationPicker<ReportDepartmentScope>(
          fieldKey: const Key('report-department-field'),
          label: 'Department',
          icon: Icons.apartment_outlined,
          value: request.department,
          values: ReportDepartmentScope.values,
          labelFor: (department) => department.label,
          onChanged: (department) {
            if (department == null) return;
            onChanged(request.copyWith(department: department));
          },
        ),
        const SizedBox(height: 14),
        ReportGenerationPicker<ReportFileFormat>(
          fieldKey: const Key('report-format-field'),
          label: 'File Format',
          icon: Icons.description_outlined,
          value: request.format,
          values: ReportFileFormat.values,
          labelFor: (format) => format.label,
          onChanged: (format) {
            if (format == null) return;
            onChanged(request.copyWith(format: format));
          },
        ),
        const SizedBox(height: 14),
        ReportGenerationPackagePresets(request: request, onChanged: onChanged),
        const SizedBox(height: 14),
        ReportGenerationContentOptions(request: request, onChanged: onChanged),
        const SizedBox(height: 16),
        ReportGenerationRequestPreview(report: report, request: request),
      ],
    );
  }
}
