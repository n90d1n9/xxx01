import 'package:flutter/material.dart';

import '../models/compliance_models.dart';

String controlStatusLabel(ComplianceControlStatus status) {
  switch (status) {
    case ComplianceControlStatus.compliant:
      return 'Compliant';
    case ComplianceControlStatus.dueSoon:
      return 'Due soon';
    case ComplianceControlStatus.overdue:
      return 'Overdue';
    case ComplianceControlStatus.blocked:
      return 'Blocked';
  }
}

Color controlStatusColor(ComplianceControlStatus status) {
  switch (status) {
    case ComplianceControlStatus.compliant:
      return const Color(0xFF15803D);
    case ComplianceControlStatus.dueSoon:
      return const Color(0xFFB45309);
    case ComplianceControlStatus.overdue:
      return const Color(0xFFDC2626);
    case ComplianceControlStatus.blocked:
      return const Color(0xFF7C3AED);
  }
}

String policyStatusLabel(PolicyAcknowledgementStatus status) {
  switch (status) {
    case PolicyAcknowledgementStatus.draft:
      return 'Draft';
    case PolicyAcknowledgementStatus.inProgress:
      return 'In progress';
    case PolicyAcknowledgementStatus.complete:
      return 'Complete';
    case PolicyAcknowledgementStatus.escalated:
      return 'Escalated';
  }
}

Color policyStatusColor(PolicyAcknowledgementStatus status) {
  switch (status) {
    case PolicyAcknowledgementStatus.draft:
      return const Color(0xFF64748B);
    case PolicyAcknowledgementStatus.inProgress:
      return const Color(0xFF2563EB);
    case PolicyAcknowledgementStatus.complete:
      return const Color(0xFF15803D);
    case PolicyAcknowledgementStatus.escalated:
      return const Color(0xFFDC2626);
  }
}

String documentRiskLabel(DocumentExpiryRisk risk) {
  switch (risk) {
    case DocumentExpiryRisk.low:
      return 'Low';
    case DocumentExpiryRisk.medium:
      return 'Medium';
    case DocumentExpiryRisk.high:
      return 'High';
  }
}

Color documentRiskColor(DocumentExpiryRisk risk) {
  switch (risk) {
    case DocumentExpiryRisk.low:
      return const Color(0xFF15803D);
    case DocumentExpiryRisk.medium:
      return const Color(0xFFB45309);
    case DocumentExpiryRisk.high:
      return const Color(0xFFDC2626);
  }
}

String findingSeverityLabel(AuditFindingSeverity severity) {
  switch (severity) {
    case AuditFindingSeverity.low:
      return 'Low';
    case AuditFindingSeverity.medium:
      return 'Medium';
    case AuditFindingSeverity.high:
      return 'High';
    case AuditFindingSeverity.critical:
      return 'Critical';
  }
}

Color findingSeverityColor(AuditFindingSeverity severity) {
  switch (severity) {
    case AuditFindingSeverity.low:
      return const Color(0xFF15803D);
    case AuditFindingSeverity.medium:
      return const Color(0xFFB45309);
    case AuditFindingSeverity.high:
      return const Color(0xFFDC2626);
    case AuditFindingSeverity.critical:
      return const Color(0xFF9F1239);
  }
}

String findingStatusLabel(AuditFindingStatus status) {
  switch (status) {
    case AuditFindingStatus.open:
      return 'Open';
    case AuditFindingStatus.remediating:
      return 'Remediating';
    case AuditFindingStatus.verified:
      return 'Verified';
    case AuditFindingStatus.waived:
      return 'Waived';
  }
}

Color findingStatusColor(AuditFindingStatus status) {
  switch (status) {
    case AuditFindingStatus.open:
      return const Color(0xFFDC2626);
    case AuditFindingStatus.remediating:
      return const Color(0xFF2563EB);
    case AuditFindingStatus.verified:
      return const Color(0xFF15803D);
    case AuditFindingStatus.waived:
      return const Color(0xFF64748B);
  }
}
