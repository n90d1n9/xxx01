import 'package:flutter/material.dart';

import '../models/compensation_models.dart';

Color compensationStatusColor(CompensationStatus status) {
  switch (status) {
    case CompensationStatus.approved:
      return const Color(0xFF059669);
    case CompensationStatus.inReview:
      return const Color(0xFF2563EB);
    case CompensationStatus.draft:
      return const Color(0xFF7C3AED);
    case CompensationStatus.blocked:
      return const Color(0xFFDC2626);
  }
}

String compensationStatusLabel(CompensationStatus status) {
  switch (status) {
    case CompensationStatus.draft:
      return 'Draft';
    case CompensationStatus.inReview:
      return 'In review';
    case CompensationStatus.approved:
      return 'Approved';
    case CompensationStatus.blocked:
      return 'Blocked';
  }
}

Color benefitStatusColor(BenefitEnrollmentStatus status) {
  switch (status) {
    case BenefitEnrollmentStatus.enrolled:
      return const Color(0xFF059669);
    case BenefitEnrollmentStatus.pending:
      return const Color(0xFF2563EB);
    case BenefitEnrollmentStatus.open:
      return const Color(0xFFD97706);
    case BenefitEnrollmentStatus.issue:
      return const Color(0xFFDC2626);
  }
}

String benefitStatusLabel(BenefitEnrollmentStatus status) {
  switch (status) {
    case BenefitEnrollmentStatus.open:
      return 'Open';
    case BenefitEnrollmentStatus.pending:
      return 'Pending';
    case BenefitEnrollmentStatus.enrolled:
      return 'Enrolled';
    case BenefitEnrollmentStatus.issue:
      return 'Issue';
  }
}

Color allowanceStatusColor(AllowanceBudgetStatus status) {
  switch (status) {
    case AllowanceBudgetStatus.healthy:
      return const Color(0xFF059669);
    case AllowanceBudgetStatus.watch:
      return const Color(0xFFD97706);
    case AllowanceBudgetStatus.overBudget:
      return const Color(0xFFDC2626);
  }
}

String allowanceStatusLabel(AllowanceBudgetStatus status) {
  switch (status) {
    case AllowanceBudgetStatus.healthy:
      return 'Healthy';
    case AllowanceBudgetStatus.watch:
      return 'Watch';
    case AllowanceBudgetStatus.overBudget:
      return 'Over budget';
  }
}

Color incentiveStatusColor(IncentiveStatus status) {
  switch (status) {
    case IncentiveStatus.paid:
      return const Color(0xFF059669);
    case IncentiveStatus.approved:
      return const Color(0xFF2563EB);
    case IncentiveStatus.pendingApproval:
      return const Color(0xFFD97706);
    case IncentiveStatus.draft:
      return const Color(0xFF7C3AED);
  }
}

String incentiveStatusLabel(IncentiveStatus status) {
  switch (status) {
    case IncentiveStatus.draft:
      return 'Draft';
    case IncentiveStatus.pendingApproval:
      return 'Pending';
    case IncentiveStatus.approved:
      return 'Approved';
    case IncentiveStatus.paid:
      return 'Paid';
  }
}
