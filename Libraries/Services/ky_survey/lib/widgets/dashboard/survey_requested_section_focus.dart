import 'dart:async';

import 'package:flutter/material.dart';

import 'survey_focused_section_highlight.dart';

/// Wraps a dashboard section that can respond to one-shot focus requests.
class SurveyRequestedSectionFocus extends StatefulWidget {
  final Widget child;
  final int requestId;
  final String? semanticsLabel;
  final Duration highlightDuration;
  final Duration scrollDuration;
  final Curve scrollCurve;
  final double alignment;
  final EdgeInsetsGeometry padding;

  const SurveyRequestedSectionFocus({
    super.key,
    required this.child,
    this.requestId = 0,
    this.semanticsLabel,
    this.highlightDuration = const Duration(milliseconds: 1800),
    this.scrollDuration = const Duration(milliseconds: 420),
    this.scrollCurve = Curves.easeOutCubic,
    this.alignment = 0.08,
    this.padding = const EdgeInsets.all(10),
  });

  @override
  State<SurveyRequestedSectionFocus> createState() =>
      _SurveyRequestedSectionFocusState();
}

/// Maintains handled request ids, scroll scheduling, and highlight timing.
class _SurveyRequestedSectionFocusState
    extends State<SurveyRequestedSectionFocus> {
  final GlobalKey _sectionKey = GlobalKey();
  int _handledRequestId = 0;
  Timer? _highlightTimer;
  bool _highlighted = false;

  @override
  void initState() {
    super.initState();
    _handleFocusRequest();
  }

  @override
  void didUpdateWidget(covariant SurveyRequestedSectionFocus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.requestId != oldWidget.requestId) {
      _handleFocusRequest();
    }
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SurveyFocusedSectionHighlight(
      key: _sectionKey,
      highlighted: _highlighted,
      semanticsLabel: widget.semanticsLabel,
      padding: widget.padding,
      child: widget.child,
    );
  }

  void _handleFocusRequest() {
    final requestId = widget.requestId;
    if (requestId <= 0 || requestId == _handledRequestId) {
      return;
    }

    _handledRequestId = requestId;
    _showHighlight();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final focusContext = _sectionKey.currentContext;
      if (focusContext == null) {
        return;
      }

      Scrollable.ensureVisible(
        focusContext,
        duration: widget.scrollDuration,
        curve: widget.scrollCurve,
        alignment: widget.alignment,
      );
    });
  }

  void _showHighlight() {
    _highlightTimer?.cancel();
    _highlighted = true;

    _highlightTimer = Timer(widget.highlightDuration, () {
      if (!mounted) {
        return;
      }

      setState(() => _highlighted = false);
    });
  }
}
