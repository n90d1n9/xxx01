import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tenun/tenun_core.dart' hide Align, FontWeight;

import 'shape_aware_payload_inspector.dart';
import 'shape_aware_switch_controls.dart';
import 'shape_aware_switch_diff.dart';

class ShapeAwareSwitchPanel extends StatefulWidget {
  final Map<String, dynamic> baseJsonConfig;
  final List<ChartType> manualTargets;
  final List<ChartType> preferredOrder;
  final EdgeInsets chartPadding;
  final bool showPayloadInspector;
  final int maxJsonPreviewChars;

  const ShapeAwareSwitchPanel({
    super.key,
    required this.baseJsonConfig,
    required this.manualTargets,
    required this.preferredOrder,
    this.chartPadding = const EdgeInsets.all(8),
    this.showPayloadInspector = true,
    this.maxJsonPreviewChars = 1400,
  });

  @override
  State<ShapeAwareSwitchPanel> createState() => _ShapeAwareSwitchPanelState();
}

class _ShapeAwareSwitchPanelState extends State<ShapeAwareSwitchPanel> {
  final ChartController _controller = ChartController();

  late Map<String, dynamic> _currentJson;
  late ChartType _manualTarget;
  bool _includeCurrentType = false;
  bool _forceCrossShape = false;
  List<ChartType> _rankedTargets = const [];
  List<ChartSwitchOption> _switchOptions = const [];
  Map<String, dynamic>? _previousJson;
  List<String> _lastDiffPaths = const [];
  String _lastSwitchMode = 'none';
  bool _showPinnedOnlyDiffPaths = false;
  ValidationResult? _lastPayloadValidation;
  bool _lastPayloadRenderSafe = false;
  String _lastPayloadValidationSource = 'base';
  String _lastPayloadValidationMessage = 'Payload validation has not run yet.';

  @override
  void initState() {
    super.initState();
    _resetFromBase();
  }

  @override
  void didUpdateWidget(covariant ShapeAwareSwitchPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baseJsonConfig != widget.baseJsonConfig ||
        oldWidget.manualTargets != widget.manualTargets ||
        oldWidget.preferredOrder != widget.preferredOrder) {
      _resetFromBase();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ChartType get _currentType =>
      getChartType((_currentJson['type'] ?? 'line').toString());

  void _resetFromBase() {
    _currentJson = _deepClone(widget.baseJsonConfig);
    _manualTarget = widget.manualTargets.isNotEmpty
        ? widget.manualTargets.first
        : ChartType.line;
    _refreshSwitchOptions();
    _previousJson = null;
    _lastDiffPaths = const [];
    _lastSwitchMode = 'none';
    _showPinnedOnlyDiffPaths = false;
    _validateCurrentPayload(source: 'base');
  }

  @override
  Widget build(BuildContext context) {
    final shape = inferSeriesDataShape(_currentJson).name;
    final currentCapabilities = chartCapabilitiesForType(_currentType);
    final manualCompatibility = chartSwitchCompatibilityForJson(
      _currentJson,
      targetType: _manualTarget,
      registeredOnly: false,
    );
    final manualSwitchAllowed =
        manualCompatibility.isCompatible ||
        (_forceCrossShape && manualCompatibility.forceConversionAvailable);
    final rankedLabel = _rankedTargets.isEmpty
        ? 'No compatible target'
        : _rankedTargets.take(5).map((t) => t.name).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 160,
              child: DropdownButton<ChartType>(
                value: _manualTarget,
                isExpanded: true,
                items: widget.manualTargets
                    .map(
                      (type) => DropdownMenuItem<ChartType>(
                        value: type,
                        child: Text(type.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _manualTarget = value;
                  });
                },
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: manualSwitchAllowed ? _switchManual : null,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Manual'),
            ),
            FilledButton.icon(
              onPressed: _switchAuto,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Auto'),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.replay(),
              tooltip: 'Replay',
            ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            FilterChip(
              label: const Text('Include current'),
              selected: _includeCurrentType,
              onSelected: (value) {
                setState(() {
                  _includeCurrentType = value;
                  _refreshSwitchOptions();
                });
              },
            ),
            FilterChip(
              label: const Text('Force cross-shape'),
              selected: _forceCrossShape,
              onSelected: (value) {
                setState(() {
                  _forceCrossShape = value;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Current: ${_currentType.name} | Shape: $shape',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        ShapeSwitchCompatibilityBanner(
          compatibility: manualCompatibility,
          forceCrossShape: _forceCrossShape,
        ),
        const SizedBox(height: 4),
        ShapeSwitchRenderSafetyBanner(
          validation: _lastPayloadValidation,
          isRenderSafe: _lastPayloadRenderSafe,
          source: _lastPayloadValidationSource,
          message: _lastPayloadValidationMessage,
        ),
        const SizedBox(height: 4),
        ShapeSwitchCapabilityChips(
          capabilities: currentCapabilities,
          labelPrefix: 'Current',
        ),
        Text(
          'Targets: $rankedLabel',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (_switchOptions.isNotEmpty) ...[
          const SizedBox(height: 4),
          ShapeSwitchOptionsPreview(options: _switchOptions),
        ],
        if (widget.showPayloadInspector) ...[
          const SizedBox(height: 6),
          ShapePayloadInspector(
            currentJson: _currentJson,
            previousJson: _previousJson,
            lastSwitchMode: _lastSwitchMode,
            lastDiffPaths: _lastDiffPaths,
            showPinnedOnlyDiffPaths: _showPinnedOnlyDiffPaths,
            maxJsonPreviewChars: widget.maxJsonPreviewChars,
            onResetPayload: _resetFromBasePayload,
            onPinnedOnlyChanged: (value) {
              setState(() {
                _showPinnedOnlyDiffPaths = value;
              });
            },
            onCopy: _copyToClipboard,
          ),
        ],
        const SizedBox(height: 6),
        Expanded(
          child: Padding(
            padding: widget.chartPadding,
            child: TenunChartJson(
              jsonConfig: _currentJson,
              controller: _controller,
            ),
          ),
        ),
      ],
    );
  }

  void _switchManual() {
    final before = _deepClone(_currentJson);
    final result = DataShapeAdapter.tryAdaptValidated(
      _currentJson,
      _manualTarget,
      force: _forceCrossShape,
      registeredOnly: false,
    );
    if (!result.success || result.payload == null || !result.isRenderSafe) {
      setState(() {
        _recordPayloadValidation(
          validation: result.validation,
          isRenderSafe: result.isRenderSafe,
          source: 'manual blocked',
          message: result.renderSafetyMessage,
        );
      });
      _showSnack(result.renderSafetyMessage);
      return;
    }

    final switched = result.payload!;
    setState(() {
      _previousJson = before;
      _currentJson = switched;
      _lastDiffPaths = ShapeAwareSwitchDiff.collectPaths(before, switched);
      _lastSwitchMode = result.switchResult.usedForceConversion
          ? 'manual force'
          : 'manual';
      _recordPayloadValidation(
        validation: result.validation,
        isRenderSafe: result.isRenderSafe,
        source: _lastSwitchMode,
        message: result.renderSafetyMessage,
      );
      _refreshSwitchOptions();
    });
  }

  void _switchAuto() {
    final before = _deepClone(_currentJson);
    final preferred = widget.preferredOrder.isNotEmpty
        ? widget.preferredOrder
        : widget.manualTargets;
    final result = DataShapeAdapter.tryAdaptAutoValidated(
      _currentJson,
      preferredOrder: preferred,
      includeCurrentType: _includeCurrentType,
    );
    if (!result.success || result.payload == null || !result.isRenderSafe) {
      setState(() {
        _recordPayloadValidation(
          validation: result.validation,
          isRenderSafe: result.isRenderSafe,
          source: 'auto blocked',
          message: result.renderSafetyMessage,
        );
      });
      _showSnack(result.renderSafetyMessage);
      return;
    }

    final switched = result.payload!;
    setState(() {
      _previousJson = before;
      _currentJson = switched;
      _lastDiffPaths = ShapeAwareSwitchDiff.collectPaths(before, switched);
      _lastSwitchMode = result.switchResult.keptCurrentType
          ? 'auto keep'
          : 'auto';
      _recordPayloadValidation(
        validation: result.validation,
        isRenderSafe: result.isRenderSafe,
        source: _lastSwitchMode,
        message: result.renderSafetyMessage,
      );
      _manualTarget = _currentType;
      _refreshSwitchOptions();
    });
  }

  void _refreshSwitchOptions() {
    _switchOptions = _computeSwitchOptions();
    _rankedTargets = _switchOptions.map((option) => option.type).toList();
  }

  List<ChartSwitchOption> _computeSwitchOptions() {
    final preferred = widget.preferredOrder.isNotEmpty
        ? widget.preferredOrder
        : widget.manualTargets;
    return chartSwitchOptionsForJson(
      _currentJson,
      preferredOrder: preferred,
      includeCurrentType: _includeCurrentType,
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _validateCurrentPayload({required String source}) {
    final validation = ChartConfigValidator.validateJsonPayload(
      _currentJson,
      requireRegisteredType: true,
    );
    _recordPayloadValidation(
      validation: validation,
      isRenderSafe: validation.isValid,
      source: source,
      message: validation.isValid
          ? 'Current payload validation passed.'
          : 'Current payload failed validation.',
    );
  }

  void _recordPayloadValidation({
    required ValidationResult? validation,
    required bool isRenderSafe,
    required String source,
    required String message,
  }) {
    _lastPayloadValidation = validation;
    _lastPayloadRenderSafe = isRenderSafe;
    _lastPayloadValidationSource = source;
    _lastPayloadValidationMessage = message;
  }

  Map<String, dynamic> _deepClone(Map<String, dynamic> source) {
    return jsonDecode(jsonEncode(source)) as Map<String, dynamic>;
  }

  void _copyToClipboard(String text, String successMessage) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnack(successMessage);
  }

  void _resetFromBasePayload() {
    setState(() {
      _currentJson = _deepClone(widget.baseJsonConfig);
      _previousJson = null;
      _lastDiffPaths = const [];
      _lastSwitchMode = 'none';
      _showPinnedOnlyDiffPaths = false;
      _validateCurrentPayload(source: 'base');
      _refreshSwitchOptions();
      if (_rankedTargets.isNotEmpty) {
        _manualTarget = _rankedTargets.first;
      }
    });
    _showSnack('Payload reset to base config');
  }
}
