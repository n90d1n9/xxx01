import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_generation_request.dart';
import '../models/report_type.dart';
import 'report_generation_request_form.dart';

class ReportGenerationDialog extends StatefulWidget {
  final ReportType report;
  final ReportGenerationRequest initialRequest;
  final ValueChanged<ReportGenerationRequest>? onGenerate;

  const ReportGenerationDialog({
    super.key,
    required this.report,
    this.initialRequest = const ReportGenerationRequest(),
    this.onGenerate,
  });

  @override
  State<ReportGenerationDialog> createState() => _ReportGenerationDialogState();
}

class _ReportGenerationDialogState extends State<ReportGenerationDialog> {
  late ReportGenerationRequest _request;

  @override
  void initState() {
    super.initState();
    _request = widget.initialRequest;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: HrisColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.report.icon, color: HrisColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generate ${widget.report.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  widget.report.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: ReportGenerationRequestForm(
          report: widget.report,
          request: _request,
          onChanged: (request) {
            setState(() => _request = request);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed:
              _request.hasSelectedContent
                  ? () {
                    widget.onGenerate?.call(_request);
                    Navigator.of(context).pop(_request);
                  }
                  : null,
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('Generate'),
        ),
      ],
    );
  }
}
