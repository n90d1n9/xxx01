import 'package:flutter/material.dart';

import '../../logic/survey_evidence_capture_adapter.dart';
import '../../logic/survey_evidence_capture_factory.dart';
import '../../models/survey_attachment.dart';
import '../../models/survey_evidence.dart';
import '../../models/survey_evidence_requirement.dart';
import 'evidence_capture_attachment_fields.dart';
import 'evidence_capture_device_action.dart';
import 'evidence_capture_form_helpers.dart';
import 'evidence_capture_location_fields.dart';

class SurveyEvidenceCaptureSheet extends StatefulWidget {
  final SurveyEvidenceRequirement requirement;
  final ValueChanged<SurveyEvidence> onCaptured;
  final String? collectorId;
  final String? collectorName;
  final SurveyEvidenceCaptureRegistry captureRegistry;

  const SurveyEvidenceCaptureSheet({
    super.key,
    required this.requirement,
    required this.onCaptured,
    this.collectorId,
    this.collectorName,
    this.captureRegistry = const SurveyEvidenceCaptureRegistry(),
  });

  static Future<void> show({
    required BuildContext context,
    required SurveyEvidenceRequirement requirement,
    required ValueChanged<SurveyEvidence> onCaptured,
    String? collectorId,
    String? collectorName,
    SurveyEvidenceCaptureRegistry captureRegistry =
        const SurveyEvidenceCaptureRegistry(),
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SurveyEvidenceCaptureSheet(
        requirement: requirement,
        onCaptured: onCaptured,
        collectorId: collectorId,
        collectorName: collectorName,
        captureRegistry: captureRegistry,
      ),
    );
  }

  @override
  State<SurveyEvidenceCaptureSheet> createState() =>
      _SurveyEvidenceCaptureSheetState();
}

class _SurveyEvidenceCaptureSheetState
    extends State<SurveyEvidenceCaptureSheet> {
  final _formKey = GlobalKey<FormState>();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _accuracyController = TextEditingController();
  final _altitudeController = TextEditingController();
  final _providerController = TextEditingController(text: 'device');
  final _fileNameController = TextEditingController();
  final _localPathController = TextEditingController();
  final _remoteUrlController = TextEditingController();
  final _mimeTypeController = TextEditingController();
  final _sizeMegabytesController = TextEditingController();
  final _durationSecondsController = TextEditingController();
  final _noteController = TextEditingController();

  late SurveyAttachmentUploadStatus _uploadStatus;
  bool _isMocked = false;
  bool _isCapturing = false;

  SurveyEvidenceRequirement get _requirement => widget.requirement;

  SurveyEvidenceCaptureAdapter? get _deviceAdapter {
    return widget.captureRegistry.adapterFor(_requirement);
  }

  @override
  void initState() {
    super.initState();
    _uploadStatus = _requirement.requireUploaded
        ? SurveyAttachmentUploadStatus.uploaded
        : SurveyAttachmentUploadStatus.local;
    _fileNameController.text = defaultFileNameForEvidenceKind(
      _requirement.kind,
    );
    _mimeTypeController.text = _defaultMimeType(_requirement.kind);
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _accuracyController.dispose();
    _altitudeController.dispose();
    _providerController.dispose();
    _fileNameController.dispose();
    _localPathController.dispose();
    _remoteUrlController.dispose();
    _mimeTypeController.dispose();
    _sizeMegabytesController.dispose();
    _durationSecondsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        evidenceKindIcon(_requirement.kind),
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _requirement.labelOrFallback,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (_requirement.instructions.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _requirement.instructions.trim(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _RequirementChip(label: 'Min ${_requirement.minCount}'),
                    _RequirementChip(
                      label: _requirement.scope == SurveyEvidenceScope.question
                          ? 'Question'
                          : 'Response',
                    ),
                    if (_requirement.requireUploaded)
                      const _RequirementChip(label: 'Upload required'),
                  ],
                ),
                const SizedBox(height: 18),
                EvidenceCaptureDeviceAction(
                  requirement: _requirement,
                  adapter: _deviceAdapter,
                  isCapturing: _isCapturing,
                  onCapture: _captureWithDevice,
                ),
                if (_deviceAdapter != null) const SizedBox(height: 18),
                if (_requirement.kind == SurveyEvidenceKind.location)
                  EvidenceCaptureLocationFields(
                    latitudeController: _latitudeController,
                    longitudeController: _longitudeController,
                    accuracyController: _accuracyController,
                    altitudeController: _altitudeController,
                    providerController: _providerController,
                    isMocked: _isMocked,
                    onMockedChanged: (value) {
                      setState(() => _isMocked = value);
                    },
                  )
                else
                  EvidenceCaptureAttachmentFields(
                    kind: _requirement.kind,
                    fileNameController: _fileNameController,
                    localPathController: _localPathController,
                    remoteUrlController: _remoteUrlController,
                    mimeTypeController: _mimeTypeController,
                    sizeMegabytesController: _sizeMegabytesController,
                    durationSecondsController: _durationSecondsController,
                    uploadStatus: _uploadStatus,
                    onUploadStatusChanged: (value) {
                      setState(() => _uploadStatus = value);
                    },
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: evidenceCaptureInputDecoration(
                    label: 'Note',
                    icon: Icons.notes_outlined,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save evidence'),
                        onPressed: _saveEvidence,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveEvidence() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final evidence = _requirement.kind == SurveyEvidenceKind.location
        ? _buildLocationEvidence()
        : _buildAttachmentEvidence();
    widget.onCaptured(evidence);
    Navigator.of(context).pop();
  }

  Future<void> _captureWithDevice() async {
    final adapter = _deviceAdapter;
    if (adapter == null || _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final evidence = await adapter.capture(
        SurveyEvidenceCaptureRequest(
          requirement: _requirement,
          collectorId: widget.collectorId,
          collectorName: widget.collectorName,
          captureSource: 'device_adapter:${adapter.id}',
        ),
      );

      if (!mounted) {
        return;
      }

      if (evidence == null) {
        setState(() => _isCapturing = false);
        return;
      }

      widget.onCaptured(evidence);
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isCapturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Capture failed: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  SurveyEvidence _buildLocationEvidence() {
    return SurveyEvidenceCaptureFactory.createLocationEvidence(
      requirement: _requirement,
      latitude: EvidenceCaptureFieldParsers.requiredDouble(
        _latitudeController.text,
      )!,
      longitude: EvidenceCaptureFieldParsers.requiredDouble(
        _longitudeController.text,
      )!,
      accuracyMeters: EvidenceCaptureFieldParsers.optionalDouble(
        _accuracyController.text,
      ),
      altitudeMeters: EvidenceCaptureFieldParsers.optionalDouble(
        _altitudeController.text,
      ),
      isMocked: _isMocked,
      provider: _emptyToNull(_providerController.text),
      collectorId: widget.collectorId,
      collectorName: widget.collectorName,
      note: _emptyToNull(_noteController.text),
      metadata: const {'captureSource': 'response_sheet'},
    );
  }

  SurveyEvidence _buildAttachmentEvidence() {
    return SurveyEvidenceCaptureFactory.createAttachmentEvidence(
      requirement: _requirement,
      fileName: _fileNameController.text.trim(),
      localPath: _localPathController.text,
      remoteUrl: _remoteUrlController.text,
      mimeType: _emptyToNull(_mimeTypeController.text),
      sizeBytes: EvidenceCaptureFieldParsers.optionalMegabytesToBytes(
        _sizeMegabytesController.text,
      ),
      durationMilliseconds:
          EvidenceCaptureFieldParsers.optionalSecondsToMilliseconds(
            _durationSecondsController.text,
          ),
      uploadStatus: _uploadStatus,
      collectorId: widget.collectorId,
      collectorName: widget.collectorName,
      note: _emptyToNull(_noteController.text),
      metadata: const {'captureSource': 'response_sheet'},
    );
  }

  String _defaultMimeType(SurveyEvidenceKind kind) {
    switch (kind) {
      case SurveyEvidenceKind.image:
        return 'image/jpeg';
      case SurveyEvidenceKind.audio:
        return 'audio/mp4';
      case SurveyEvidenceKind.file:
        return 'application/pdf';
      case SurveyEvidenceKind.location:
        return '';
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}

class _RequirementChip extends StatelessWidget {
  final String label;

  const _RequirementChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(label),
      labelStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
