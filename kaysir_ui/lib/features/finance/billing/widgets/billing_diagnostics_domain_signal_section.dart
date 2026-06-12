import 'package:flutter/material.dart';

import 'billing_diagnostics_domain_signal_card.dart';
import 'billing_diagnostics_section_registry.dart';

class BillingDiagnosticsDomainSignalSection {
  final String id;
  final int priority;
  final String title;
  final String summary;
  final IconData icon;
  final Color accentColor;
  final List<String> signals;
  final BillingDiagnosticsSectionPredicate? isEnabled;

  factory BillingDiagnosticsDomainSignalSection({
    required String id,
    int priority = 150,
    required String title,
    required String summary,
    required IconData icon,
    required Color accentColor,
    Iterable<String> signals = const [],
    BillingDiagnosticsSectionPredicate? isEnabled,
  }) {
    return BillingDiagnosticsDomainSignalSection._(
      id: _validatedDiagnosticsSignalText(id, 'id'),
      priority: priority,
      title: _validatedDiagnosticsSignalText(title, 'title'),
      summary: _validatedDiagnosticsSignalText(summary, 'summary'),
      icon: icon,
      accentColor: accentColor,
      signals: List.unmodifiable(
        signals
            .map((signal) => signal.trim())
            .where((signal) => signal.isNotEmpty),
      ),
      isEnabled: isEnabled,
    );
  }

  const BillingDiagnosticsDomainSignalSection._({
    required this.id,
    required this.priority,
    required this.title,
    required this.summary,
    required this.icon,
    required this.accentColor,
    required this.signals,
    required this.isEnabled,
  });

  Widget buildCard() {
    return BillingDiagnosticsDomainSignalCard(
      title: title,
      summary: summary,
      icon: icon,
      accentColor: accentColor,
      signals: signals,
    );
  }

  BillingDiagnosticsSectionDescriptor toDescriptor() {
    final predicate = isEnabled;
    if (predicate == null) {
      return BillingDiagnosticsSectionDescriptor(
        id: id,
        priority: priority,
        builder: (_) => buildCard(),
      );
    }

    return BillingDiagnosticsSectionDescriptor(
      id: id,
      priority: priority,
      isEnabled: predicate,
      builder: (_) => buildCard(),
    );
  }
}

String _validatedDiagnosticsSignalText(String value, String fieldName) {
  final normalizedValue = value.trim();
  if (normalizedValue.isEmpty) {
    throw ArgumentError.value(value, fieldName, 'must not be blank');
  }
  if (normalizedValue != value) {
    throw ArgumentError.value(
      value,
      fieldName,
      'must not contain leading or trailing whitespace',
    );
  }

  return normalizedValue;
}
