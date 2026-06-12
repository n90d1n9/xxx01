import 'package:flutter/material.dart';

import 'financial_report_tinted_surface_components.dart';

class FinancialReportScheduleEvidenceTrail extends StatelessWidget {
  const FinancialReportScheduleEvidenceTrail({
    required this.sourceCategory,
    required this.noteReference,
    required this.isDarkMode,
    super.key,
  });

  final String? sourceCategory;
  final String? noteReference;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final source = sourceCategory?.trim();
    final note = noteReference == null ? null : 'Note $noteReference';
    if ((source == null || source.isEmpty) && note == null) {
      return const SizedBox.shrink();
    }

    final parts =
        source == null || source.isEmpty
            ? const <String>[]
            : source
                .split(RegExp(r'\s+/\s+'))
                .map((part) => part.trim())
                .where((part) => part.isNotEmpty)
                .toList();

    if (parts.length <= 1) {
      return Text(
        [
          if (source != null && source.isNotEmpty) source,
          if (note != null) note,
        ].join(' - '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
          fontSize: 12,
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final part in parts)
          _EvidencePill(label: part, isDarkMode: isDarkMode),
        if (note != null)
          _EvidencePill(
            label: note,
            isDarkMode: isDarkMode,
            tone: _EvidencePillTone.neutral,
          ),
      ],
    );
  }
}

class _EvidencePill extends StatelessWidget {
  const _EvidencePill({
    required this.label,
    required this.isDarkMode,
    this.tone,
  });

  final String label;
  final bool isDarkMode;
  final _EvidencePillTone? tone;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(tone ?? _toneFor(label), isDarkMode);

    return Tooltip(
      message: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: FinancialReportTintedSurface(
          color: color,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          fillAlpha: isDarkMode ? 0.16 : 0.09,
          borderAlpha: 0.28,
          borderRadius: 999,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

enum _EvidencePillTone { neutral, risk, warning, ready, review }

_EvidencePillTone _toneFor(String label) {
  final normalized = label.toLowerCase();
  if (normalized.contains('overdue') ||
      normalized.contains('escalate') ||
      normalized.contains('unassigned')) {
    return _EvidencePillTone.risk;
  }
  if (normalized.contains('due soon') ||
      normalized.contains('monitor') ||
      normalized.contains('deferred')) {
    return _EvidencePillTone.warning;
  }
  if (normalized.contains('cleared') ||
      normalized.contains('adjusted') ||
      normalized.contains('resolved')) {
    return _EvidencePillTone.ready;
  }
  if (normalized.startsWith('review') ||
      normalized.startsWith('owner') ||
      normalized.startsWith('reviewed')) {
    return _EvidencePillTone.review;
  }
  return _EvidencePillTone.neutral;
}

Color _colorFor(_EvidencePillTone tone, bool isDarkMode) {
  switch (tone) {
    case _EvidencePillTone.risk:
      return isDarkMode ? const Color(0xFFFF8A80) : Colors.red.shade700;
    case _EvidencePillTone.warning:
      return isDarkMode ? const Color(0xFFFFD166) : Colors.amber.shade800;
    case _EvidencePillTone.ready:
      return isDarkMode ? const Color(0xFF7BD88F) : Colors.green.shade700;
    case _EvidencePillTone.review:
      return isDarkMode ? const Color(0xFF80DEEA) : Colors.cyan.shade800;
    case _EvidencePillTone.neutral:
      return isDarkMode ? Colors.grey.shade300 : Colors.blueGrey.shade700;
  }
}
