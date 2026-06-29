import 'package:flutter/material.dart';

import '../models/recruitment_models.dart';

Color recruitmentPriorityColor(RecruitmentPriority priority) {
  switch (priority) {
    case RecruitmentPriority.high:
      return const Color(0xFFDC2626);
    case RecruitmentPriority.medium:
      return const Color(0xFFD97706);
    case RecruitmentPriority.low:
      return const Color(0xFF059669);
  }
}

Color candidateStageColor(CandidateStage stage) {
  switch (stage) {
    case CandidateStage.applied:
      return const Color(0xFF7C3AED);
    case CandidateStage.screening:
      return const Color(0xFF2563EB);
    case CandidateStage.interview:
      return const Color(0xFFD97706);
    case CandidateStage.offer:
      return const Color(0xFF0F766E);
    case CandidateStage.hired:
      return const Color(0xFF059669);
    case CandidateStage.rejected:
      return const Color(0xFF6B7280);
  }
}

Color interviewStatusColor(InterviewStatus status) {
  switch (status) {
    case InterviewStatus.scheduled:
      return const Color(0xFF2563EB);
    case InterviewStatus.needsFeedback:
      return const Color(0xFFD97706);
    case InterviewStatus.completed:
      return const Color(0xFF059669);
  }
}

Color offerStatusColor(OfferStatus status) {
  switch (status) {
    case OfferStatus.draft:
      return const Color(0xFF7C3AED);
    case OfferStatus.sent:
      return const Color(0xFF2563EB);
    case OfferStatus.accepted:
      return const Color(0xFF059669);
    case OfferStatus.declined:
      return const Color(0xFFDC2626);
  }
}

Color sourceHealthColor(SourceHealth health) {
  switch (health) {
    case SourceHealth.strong:
      return const Color(0xFF059669);
    case SourceHealth.watch:
      return const Color(0xFFD97706);
    case SourceHealth.weak:
      return const Color(0xFFDC2626);
  }
}

String requisitionStatusLabel(RequisitionStatus status) {
  switch (status) {
    case RequisitionStatus.draft:
      return 'Draft';
    case RequisitionStatus.open:
      return 'Open';
    case RequisitionStatus.interviewing:
      return 'Interviewing';
    case RequisitionStatus.offer:
      return 'Offer';
    case RequisitionStatus.closed:
      return 'Closed';
  }
}

String candidateStageLabel(CandidateStage stage) {
  switch (stage) {
    case CandidateStage.applied:
      return 'Applied';
    case CandidateStage.screening:
      return 'Screening';
    case CandidateStage.interview:
      return 'Interview';
    case CandidateStage.offer:
      return 'Offer';
    case CandidateStage.hired:
      return 'Hired';
    case CandidateStage.rejected:
      return 'Rejected';
  }
}

String interviewStatusLabel(InterviewStatus status) {
  switch (status) {
    case InterviewStatus.scheduled:
      return 'Scheduled';
    case InterviewStatus.needsFeedback:
      return 'Feedback';
    case InterviewStatus.completed:
      return 'Completed';
  }
}

String offerStatusLabel(OfferStatus status) {
  switch (status) {
    case OfferStatus.draft:
      return 'Draft';
    case OfferStatus.sent:
      return 'Sent';
    case OfferStatus.accepted:
      return 'Accepted';
    case OfferStatus.declined:
      return 'Declined';
  }
}

String sourceHealthLabel(SourceHealth health) {
  switch (health) {
    case SourceHealth.strong:
      return 'Strong';
    case SourceHealth.watch:
      return 'Watch';
    case SourceHealth.weak:
      return 'Weak';
  }
}
