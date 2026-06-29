import 'package:flutter/material.dart';

import '../models/talent_models.dart';

Color skillStatusColor(SkillGapStatus status) {
  switch (status) {
    case SkillGapStatus.strength:
      return const Color(0xFF059669);
    case SkillGapStatus.growing:
      return const Color(0xFF2563EB);
    case SkillGapStatus.gap:
      return const Color(0xFFDC2626);
  }
}

Color learningStatusColor(LearningPlanStatus status) {
  switch (status) {
    case LearningPlanStatus.completed:
      return const Color(0xFF059669);
    case LearningPlanStatus.inProgress:
      return const Color(0xFF2563EB);
    case LearningPlanStatus.planned:
      return const Color(0xFF7C3AED);
    case LearningPlanStatus.overdue:
      return const Color(0xFFDC2626);
  }
}

Color certificationStatusColor(CertificationStatus status) {
  switch (status) {
    case CertificationStatus.active:
      return const Color(0xFF059669);
    case CertificationStatus.expiring:
      return const Color(0xFFD97706);
    case CertificationStatus.expired:
      return const Color(0xFFDC2626);
  }
}

Color mentorshipHealthColor(MentorshipHealth health) {
  switch (health) {
    case MentorshipHealth.healthy:
      return const Color(0xFF059669);
    case MentorshipHealth.watch:
      return const Color(0xFFD97706);
    case MentorshipHealth.blocked:
      return const Color(0xFFDC2626);
  }
}

IconData certificationStatusIcon(CertificationStatus status) {
  switch (status) {
    case CertificationStatus.active:
      return Icons.check_circle_outline;
    case CertificationStatus.expiring:
      return Icons.schedule_outlined;
    case CertificationStatus.expired:
      return Icons.error_outline;
  }
}

String skillStatusLabel(SkillGapStatus status) {
  switch (status) {
    case SkillGapStatus.strength:
      return 'Strength';
    case SkillGapStatus.growing:
      return 'Growing';
    case SkillGapStatus.gap:
      return 'Gap';
  }
}

String learningStatusLabel(LearningPlanStatus status) {
  switch (status) {
    case LearningPlanStatus.planned:
      return 'Planned';
    case LearningPlanStatus.inProgress:
      return 'In progress';
    case LearningPlanStatus.completed:
      return 'Completed';
    case LearningPlanStatus.overdue:
      return 'Overdue';
  }
}

String certificationStatusLabel(CertificationStatus status) {
  switch (status) {
    case CertificationStatus.active:
      return 'Active';
    case CertificationStatus.expiring:
      return 'Expiring';
    case CertificationStatus.expired:
      return 'Expired';
  }
}

String mentorshipHealthLabel(MentorshipHealth health) {
  switch (health) {
    case MentorshipHealth.healthy:
      return 'Healthy';
    case MentorshipHealth.watch:
      return 'Watch';
    case MentorshipHealth.blocked:
      return 'Blocked';
  }
}
