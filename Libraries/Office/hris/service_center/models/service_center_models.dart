enum ServiceCasePriority { low, medium, high, urgent }

enum ServiceCaseStatus { newCase, inProgress, waiting, resolved }

enum DocumentRequestStatus { draft, pendingApproval, ready, delivered }

enum PolicyArticleType { policy, guide, faq }

enum AnnouncementTone { info, success, warning }

class ServiceDeskCase {
  final String id;
  final String requesterName;
  final String category;
  final String subject;
  final String assignedTo;
  final DateTime createdAt;
  final DateTime dueAt;
  final ServiceCasePriority priority;
  final ServiceCaseStatus status;

  const ServiceDeskCase({
    required this.id,
    required this.requesterName,
    required this.category,
    required this.subject,
    required this.assignedTo,
    required this.createdAt,
    required this.dueAt,
    required this.priority,
    required this.status,
  });

  bool get isOpen => status != ServiceCaseStatus.resolved;

  bool isSlaAtRiskAt(DateTime asOfDate) {
    if (!isOpen) return false;
    return !dueAt.isAfter(asOfDate.add(const Duration(hours: 8)));
  }

  bool get isSlaAtRisk => isSlaAtRiskAt(DateTime.now());
}

class DocumentRequest {
  final String id;
  final String employeeName;
  final String documentType;
  final String purpose;
  final String owner;
  final DateTime requestedAt;
  final DateTime neededBy;
  final DocumentRequestStatus status;

  const DocumentRequest({
    required this.id,
    required this.employeeName,
    required this.documentType,
    required this.purpose,
    required this.owner,
    required this.requestedAt,
    required this.neededBy,
    required this.status,
  });

  bool get isPending => status != DocumentRequestStatus.delivered;

  bool isDueSoonAt(DateTime asOfDate) {
    if (!isPending) return false;
    return !neededBy.isAfter(asOfDate.add(const Duration(days: 3)));
  }

  bool get isDueSoon => isDueSoonAt(DateTime.now());
}

class PolicyArticle {
  final String id;
  final String title;
  final String category;
  final String summary;
  final int views;
  final int helpfulVotes;
  final PolicyArticleType type;

  const PolicyArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.views,
    required this.helpfulVotes,
    required this.type,
  });

  double get helpfulRate => views == 0 ? 0 : helpfulVotes / views;
}

class ServiceAnnouncement {
  final String id;
  final String title;
  final String audience;
  final String message;
  final DateTime publishAt;
  final AnnouncementTone tone;

  const ServiceAnnouncement({
    required this.id,
    required this.title,
    required this.audience,
    required this.message,
    required this.publishAt,
    required this.tone,
  });
}

class ServiceCenterSummary {
  final int openCases;
  final int slaRisks;
  final int documentBacklog;
  final int policies;
  final double helpfulRate;

  const ServiceCenterSummary({
    required this.openCases,
    required this.slaRisks,
    required this.documentBacklog,
    required this.policies,
    required this.helpfulRate,
  });
}

class ServiceCenterRiskSummary {
  final int urgentCases;
  final int slaRiskCases;
  final int dueSoonDocuments;
  final int lowHelpfulnessPolicies;
  final int warningAnnouncements;
  final int dueWithinTwentyFourHours;

  const ServiceCenterRiskSummary({
    required this.urgentCases,
    required this.slaRiskCases,
    required this.dueSoonDocuments,
    required this.lowHelpfulnessPolicies,
    required this.warningAnnouncements,
    required this.dueWithinTwentyFourHours,
  });

  int get totalRisks =>
      urgentCases +
      slaRiskCases +
      dueSoonDocuments +
      lowHelpfulnessPolicies +
      warningAnnouncements;

  factory ServiceCenterRiskSummary.fromData({
    required List<ServiceDeskCase> cases,
    required List<DocumentRequest> documents,
    required List<PolicyArticle> policies,
    required List<ServiceAnnouncement> announcements,
    required DateTime asOfDate,
  }) {
    final dayThreshold = asOfDate.add(const Duration(hours: 24));

    return ServiceCenterRiskSummary(
      urgentCases:
          cases
              .where((item) => item.priority == ServiceCasePriority.urgent)
              .length,
      slaRiskCases: cases.where((item) => item.isSlaAtRiskAt(asOfDate)).length,
      dueSoonDocuments:
          documents.where((item) => item.isDueSoonAt(asOfDate)).length,
      lowHelpfulnessPolicies:
          policies.where((item) => item.helpfulRate < 0.8).length,
      warningAnnouncements:
          announcements
              .where((item) => item.tone == AnnouncementTone.warning)
              .length,
      dueWithinTwentyFourHours:
          cases
              .where((item) => item.isOpen && !item.dueAt.isAfter(dayThreshold))
              .length +
          documents
              .where(
                (item) =>
                    item.isPending && !item.neededBy.isAfter(dayThreshold),
              )
              .length +
          announcements
              .where((item) => !item.publishAt.isAfter(dayThreshold))
              .length,
    );
  }
}
