import 'package:flutter/material.dart';

import '../models/report_generation_request.dart';
import '../models/report_type.dart';

Future<void> showReportGenerationFeedback(
  BuildContext context,
  ReportType report,
  ReportGenerationRequest request, {
  Duration delay = const Duration(seconds: 2),
}) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Generating ${report.name}', textAlign: TextAlign.center),
            ],
          ),
        ),
  );

  await Future<void>.delayed(delay);

  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop();

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${request.exportFileNameFor(report)} is ready'),
      action: SnackBarAction(label: 'VIEW', onPressed: () {}),
    ),
  );
}
