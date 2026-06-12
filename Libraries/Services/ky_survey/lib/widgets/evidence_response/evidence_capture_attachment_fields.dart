import 'package:flutter/material.dart';

import '../../models/survey_attachment.dart';
import '../../models/survey_evidence.dart';
import 'evidence_capture_form_helpers.dart';

class EvidenceCaptureAttachmentFields extends StatelessWidget {
  final SurveyEvidenceKind kind;
  final TextEditingController fileNameController;
  final TextEditingController localPathController;
  final TextEditingController remoteUrlController;
  final TextEditingController mimeTypeController;
  final TextEditingController sizeMegabytesController;
  final TextEditingController durationSecondsController;
  final SurveyAttachmentUploadStatus uploadStatus;
  final ValueChanged<SurveyAttachmentUploadStatus> onUploadStatusChanged;

  const EvidenceCaptureAttachmentFields({
    super.key,
    required this.kind,
    required this.fileNameController,
    required this.localPathController,
    required this.remoteUrlController,
    required this.mimeTypeController,
    required this.sizeMegabytesController,
    required this.durationSecondsController,
    required this.uploadStatus,
    required this.onUploadStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: fileNameController,
          decoration: evidenceCaptureInputDecoration(
            label: 'File name',
            icon: Icons.description_outlined,
          ),
          validator: (value) =>
              EvidenceCaptureFieldValidators.requiredText(value, 'File name'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: localPathController,
          decoration: evidenceCaptureInputDecoration(
            label: 'Local path',
            icon: Icons.folder_outlined,
          ),
          validator: (_) {
            if (localPathController.text.trim().isEmpty &&
                remoteUrlController.text.trim().isEmpty) {
              return 'Add a local path or remote URL';
            }

            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: remoteUrlController,
          decoration: evidenceCaptureInputDecoration(
            label: 'Remote URL',
            icon: Icons.cloud_done_outlined,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: mimeTypeController,
                decoration: evidenceCaptureInputDecoration(
                  label: 'MIME type',
                  icon: Icons.badge_outlined,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: sizeMegabytesController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: evidenceCaptureInputDecoration(
                  label: 'Size MB',
                  icon: Icons.data_usage_outlined,
                ),
                validator: (value) =>
                    EvidenceCaptureFieldValidators.optionalNonNegativeDouble(
                      value,
                      'size',
                    ),
              ),
            ),
          ],
        ),
        if (kind == SurveyEvidenceKind.audio) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: durationSecondsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: evidenceCaptureInputDecoration(
              label: 'Duration seconds',
              icon: Icons.timer_outlined,
            ),
            validator: (value) =>
                EvidenceCaptureFieldValidators.optionalNonNegativeDouble(
                  value,
                  'duration',
                ),
          ),
        ],
        const SizedBox(height: 12),
        DropdownButtonFormField<SurveyAttachmentUploadStatus>(
          initialValue: uploadStatus,
          decoration: evidenceCaptureInputDecoration(
            label: 'Upload status',
            icon: Icons.sync_outlined,
          ),
          items: [
            for (final status in SurveyAttachmentUploadStatus.values)
              DropdownMenuItem(
                value: status,
                child: Text(uploadStatusLabel(status)),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              onUploadStatusChanged(value);
            }
          },
        ),
      ],
    );
  }
}
