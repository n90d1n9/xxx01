import 'package:flutter/material.dart';

import '../../models/survey_attachment.dart';
import '../../models/survey_evidence.dart';

class EvidenceCaptureFieldParsers {
  const EvidenceCaptureFieldParsers._();

  static double? optionalDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return double.tryParse(trimmed);
  }

  static double? requiredDouble(String value) {
    return double.tryParse(value.trim());
  }

  static int? optionalMegabytesToBytes(String value) {
    final megabytes = optionalDouble(value);
    if (megabytes == null) {
      return null;
    }

    return (megabytes * 1024 * 1024).round();
  }

  static int? optionalSecondsToMilliseconds(String value) {
    final seconds = optionalDouble(value);
    if (seconds == null) {
      return null;
    }

    return (seconds * 1000).round();
  }
}

class EvidenceCaptureFieldValidators {
  const EvidenceCaptureFieldValidators._();

  static String? requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }

    return null;
  }

  static String? requiredDouble(String? value, String label) {
    final parsed = EvidenceCaptureFieldParsers.requiredDouble(value ?? '');
    if (parsed == null) {
      return 'Enter a valid $label';
    }

    return null;
  }

  static String? optionalNonNegativeDouble(String? value, String label) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return 'Enter a valid $label';
    }

    return null;
  }

  static String? optionalDouble(String? value, String label) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    if (double.tryParse(trimmed) == null) {
      return 'Enter a valid $label';
    }

    return null;
  }
}

InputDecoration evidenceCaptureInputDecoration({
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: const OutlineInputBorder(),
  );
}

IconData evidenceKindIcon(SurveyEvidenceKind kind) {
  switch (kind) {
    case SurveyEvidenceKind.location:
      return Icons.place_outlined;
    case SurveyEvidenceKind.image:
      return Icons.image_outlined;
    case SurveyEvidenceKind.audio:
      return Icons.mic_none_outlined;
    case SurveyEvidenceKind.file:
      return Icons.attach_file_outlined;
  }
}

String defaultFileNameForEvidenceKind(SurveyEvidenceKind kind) {
  switch (kind) {
    case SurveyEvidenceKind.image:
      return 'field-image.jpg';
    case SurveyEvidenceKind.audio:
      return 'interview-audio.m4a';
    case SurveyEvidenceKind.file:
      return 'supporting-file.pdf';
    case SurveyEvidenceKind.location:
      return 'location';
  }
}

String uploadStatusLabel(SurveyAttachmentUploadStatus status) {
  switch (status) {
    case SurveyAttachmentUploadStatus.local:
      return 'Local';
    case SurveyAttachmentUploadStatus.queued:
      return 'Queued';
    case SurveyAttachmentUploadStatus.uploading:
      return 'Uploading';
    case SurveyAttachmentUploadStatus.uploaded:
      return 'Uploaded';
    case SurveyAttachmentUploadStatus.failed:
      return 'Failed';
  }
}
