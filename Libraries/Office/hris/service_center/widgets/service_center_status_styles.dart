import 'package:flutter/material.dart';

import '../models/service_center_models.dart';

Color casePriorityColor(ServiceCasePriority priority) {
  switch (priority) {
    case ServiceCasePriority.urgent:
      return const Color(0xFFDC2626);
    case ServiceCasePriority.high:
      return const Color(0xFFD97706);
    case ServiceCasePriority.medium:
      return const Color(0xFF2563EB);
    case ServiceCasePriority.low:
      return const Color(0xFF059669);
  }
}

Color documentStatusColor(DocumentRequestStatus status) {
  switch (status) {
    case DocumentRequestStatus.delivered:
      return const Color(0xFF059669);
    case DocumentRequestStatus.ready:
      return const Color(0xFF2563EB);
    case DocumentRequestStatus.pendingApproval:
      return const Color(0xFFD97706);
    case DocumentRequestStatus.draft:
      return const Color(0xFF7C3AED);
  }
}

Color policyTypeColor(PolicyArticleType type) {
  switch (type) {
    case PolicyArticleType.policy:
      return const Color(0xFF0F766E);
    case PolicyArticleType.guide:
      return const Color(0xFF2563EB);
    case PolicyArticleType.faq:
      return const Color(0xFF7C3AED);
  }
}

Color announcementToneColor(AnnouncementTone tone) {
  switch (tone) {
    case AnnouncementTone.success:
      return const Color(0xFF059669);
    case AnnouncementTone.warning:
      return const Color(0xFFD97706);
    case AnnouncementTone.info:
      return const Color(0xFF2563EB);
  }
}

String caseStatusLabel(ServiceCaseStatus status) {
  switch (status) {
    case ServiceCaseStatus.newCase:
      return 'New';
    case ServiceCaseStatus.inProgress:
      return 'In progress';
    case ServiceCaseStatus.waiting:
      return 'Waiting';
    case ServiceCaseStatus.resolved:
      return 'Resolved';
  }
}

String documentStatusLabel(DocumentRequestStatus status) {
  switch (status) {
    case DocumentRequestStatus.draft:
      return 'Draft';
    case DocumentRequestStatus.pendingApproval:
      return 'Pending';
    case DocumentRequestStatus.ready:
      return 'Ready';
    case DocumentRequestStatus.delivered:
      return 'Delivered';
  }
}

String policyTypeLabel(PolicyArticleType type) {
  switch (type) {
    case PolicyArticleType.policy:
      return 'Policy';
    case PolicyArticleType.guide:
      return 'Guide';
    case PolicyArticleType.faq:
      return 'FAQ';
  }
}
