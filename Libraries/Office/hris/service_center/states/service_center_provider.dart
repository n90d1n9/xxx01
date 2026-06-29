import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/service_center_seed_data.dart';
import '../models/service_center_models.dart';

const serviceCenterAllCategories = 'All';

final serviceCenterCategoryProvider = StateProvider<String>(
  (ref) => serviceCenterAllCategories,
);
final serviceCenterUrgentOnlyProvider = StateProvider<bool>((ref) => false);
final serviceCenterAsOfDateProvider = Provider<DateTime>(
  (ref) => DateTime.now(),
);

final serviceDeskCasesProvider = Provider<List<ServiceDeskCase>>((ref) {
  return buildServiceDeskCases(ref.watch(serviceCenterAsOfDateProvider));
});

final documentRequestsProvider = Provider<List<DocumentRequest>>((ref) {
  return buildDocumentRequests(ref.watch(serviceCenterAsOfDateProvider));
});

final policyArticlesProvider = Provider<List<PolicyArticle>>((ref) {
  return servicePolicyArticles;
});

final serviceAnnouncementsProvider = Provider<List<ServiceAnnouncement>>((ref) {
  return buildServiceAnnouncements(ref.watch(serviceCenterAsOfDateProvider));
});

final serviceCenterCategoriesProvider = Provider<List<String>>((ref) {
  final categories =
      <String>{
          ...ref.watch(serviceDeskCasesProvider).map((item) => item.category),
          ...ref.watch(policyArticlesProvider).map((item) => item.category),
        }.where((category) => category != serviceCenterAllCategories).toList()
        ..sort();

  return [serviceCenterAllCategories, ...categories];
});

final filteredServiceDeskCasesProvider = Provider<List<ServiceDeskCase>>((ref) {
  final asOfDate = ref.watch(serviceCenterAsOfDateProvider);

  return ref
      .watch(serviceDeskCasesProvider)
      .where(
        (item) =>
            _matchesCategory(ref, item.category) &&
            _matchesUrgency(
              ref,
              item.isSlaAtRiskAt(asOfDate) ||
                  item.priority == ServiceCasePriority.urgent,
            ),
      )
      .toList();
});

final filteredDocumentRequestsProvider = Provider<List<DocumentRequest>>((ref) {
  final asOfDate = ref.watch(serviceCenterAsOfDateProvider);

  return ref
      .watch(documentRequestsProvider)
      .where((item) => _matchesUrgency(ref, item.isDueSoonAt(asOfDate)))
      .toList();
});

final filteredPolicyArticlesProvider = Provider<List<PolicyArticle>>((ref) {
  return ref
      .watch(policyArticlesProvider)
      .where(
        (item) =>
            _matchesCategory(ref, item.category) &&
            _matchesUrgency(ref, item.helpfulRate < 0.8),
      )
      .toList();
});

final filteredServiceAnnouncementsProvider =
    Provider<List<ServiceAnnouncement>>((ref) {
      return ref
          .watch(serviceAnnouncementsProvider)
          .where(
            (item) =>
                _matchesUrgency(ref, item.tone == AnnouncementTone.warning),
          )
          .toList();
    });

final serviceCenterRiskSummaryProvider = Provider<ServiceCenterRiskSummary>((
  ref,
) {
  return ServiceCenterRiskSummary.fromData(
    cases: ref.watch(filteredServiceDeskCasesProvider),
    documents: ref.watch(filteredDocumentRequestsProvider),
    policies: ref.watch(filteredPolicyArticlesProvider),
    announcements: ref.watch(filteredServiceAnnouncementsProvider),
    asOfDate: ref.watch(serviceCenterAsOfDateProvider),
  );
});

final serviceCenterSummaryProvider = Provider<ServiceCenterSummary>((ref) {
  final asOfDate = ref.watch(serviceCenterAsOfDateProvider);
  final cases = ref.watch(filteredServiceDeskCasesProvider);
  final documents = ref.watch(filteredDocumentRequestsProvider);
  final policies = ref.watch(filteredPolicyArticlesProvider);

  final totalViews = policies.fold<int>(0, (total, item) => total + item.views);
  final helpfulVotes = policies.fold<int>(
    0,
    (total, item) => total + item.helpfulVotes,
  );

  return ServiceCenterSummary(
    openCases: cases.where((item) => item.isOpen).length,
    slaRisks: cases.where((item) => item.isSlaAtRiskAt(asOfDate)).length,
    documentBacklog: documents.where((item) => item.isPending).length,
    policies: policies.length,
    helpfulRate: totalViews == 0 ? 0 : helpfulVotes / totalViews,
  );
});

bool _matchesCategory(Ref ref, String category) {
  final selectedCategory = ref.watch(serviceCenterCategoryProvider);
  return selectedCategory == serviceCenterAllCategories ||
      category == selectedCategory;
}

bool _matchesUrgency(Ref ref, bool isUrgent) {
  return !ref.watch(serviceCenterUrgentOnlyProvider) || isUrgent;
}
