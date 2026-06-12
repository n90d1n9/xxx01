import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../accounting_path.dart';
import '../models/financial_report_release_action_queue.dart';
import '../models/financial_report_release_distribution.dart';
import '../models/financial_report_release_signoff.dart';
import '../states/fin_statement/financial_provider.dart';
import '../states/fin_statement/financial_report_package_integrity_provider.dart';
import '../states/fin_statement/financial_report_going_concern_review_provider.dart';
import '../states/fin_statement/financial_report_pack_provider.dart';
import '../states/fin_statement/financial_report_release_action_queue_provider.dart';
import '../states/fin_statement/financial_report_release_archive_provider.dart';
import '../states/fin_statement/financial_report_release_distribution_provider.dart';
import '../states/fin_statement/financial_report_release_evidence_manifest_provider.dart';
import '../states/fin_statement/financial_report_release_milestone_provider.dart';
import '../states/fin_statement/financial_report_release_signoff_provider.dart';
import '../states/fin_statement/financial_report_standard_transition_provider.dart';
import '../states/fin_statement/financial_report_subsequent_event_review_provider.dart';
import '../widgets/financial_report_focus_highlight.dart';
import '../widgets/financial_report_release_signoff_components.dart';

enum FinancialReportReleaseCenterFocus {
  overview,
  signOff,
  evidenceManifest,
  distribution,
  archive,
  retention,
  statutoryFiling,
}

FinancialReportReleaseCenterFocus financialReportReleaseCenterFocusFromQuery(
  String? value,
) {
  switch (value) {
    case AccountingPath.reportReleaseSignOffFocus:
    case 'signoff':
    case 'signOff':
      return FinancialReportReleaseCenterFocus.signOff;
    case AccountingPath.reportReleaseEvidenceFocus:
    case 'evidenceManifest':
      return FinancialReportReleaseCenterFocus.evidenceManifest;
    case AccountingPath.reportReleaseDistributionFocus:
      return FinancialReportReleaseCenterFocus.distribution;
    case AccountingPath.reportReleaseArchiveFocus:
      return FinancialReportReleaseCenterFocus.archive;
    case AccountingPath.reportReleaseRetentionFocus:
      return FinancialReportReleaseCenterFocus.retention;
    case AccountingPath.reportReleaseStatutoryFilingFocus:
    case 'filing':
    case 'statutoryFiling':
      return FinancialReportReleaseCenterFocus.statutoryFiling;
    default:
      return FinancialReportReleaseCenterFocus.overview;
  }
}

class FinancialReportReleaseCenterScreen extends ConsumerStatefulWidget {
  const FinancialReportReleaseCenterScreen({
    this.initialFocus = FinancialReportReleaseCenterFocus.overview,
    super.key,
  });

  final FinancialReportReleaseCenterFocus initialFocus;

  @override
  ConsumerState<FinancialReportReleaseCenterScreen> createState() =>
      _FinancialReportReleaseCenterScreenState();
}

class _FinancialReportReleaseCenterScreenState
    extends ConsumerState<FinancialReportReleaseCenterScreen> {
  final _evidenceManifestKey = GlobalKey();
  final _archiveKey = GlobalKey();
  final _retentionKey = GlobalKey();
  final _statutoryFilingKey = GlobalKey();
  final _signOffKey = GlobalKey();
  final _distributionKey = GlobalKey();
  FinancialReportReleaseActionDestination? _focusedDestination;
  var _didApplyInitialFocus = false;

  @override
  void initState() {
    super.initState();
    _focusedDestination = _destinationForFocus(widget.initialFocus);
  }

  @override
  void didUpdateWidget(FinancialReportReleaseCenterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFocus != widget.initialFocus) {
      _focusedDestination = _destinationForFocus(widget.initialFocus);
      _didApplyInitialFocus = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pack = ref.watch(financialReportPackProvider);
    final period = ref.watch(selectedFinancialPeriodProvider);
    final signOffItems = ref.watch(
      currentFinancialReportReleaseSignOffItemsProvider,
    );
    final auditEvents = ref.watch(
      currentFinancialReportReleaseSignOffAuditProvider,
    );
    final distributionItems = ref.watch(
      currentFinancialReportReleaseDistributionItemsProvider,
    );
    final distributionAuditEvents = ref.watch(
      currentFinancialReportReleaseDistributionAuditProvider,
    );
    final distributionLockedReason = ref.watch(
      currentFinancialReportReleaseDistributionLockedReasonProvider,
    );
    final releaseControlSummary = ref.watch(
      currentFinancialReportReleaseControlSummaryProvider,
    );
    final releaseActionQueue = ref.watch(
      currentFinancialReportReleaseActionQueueProvider,
    );
    final releaseMilestones = ref.watch(
      currentFinancialReportReleaseMilestoneProvider,
    );
    final standardTransition = ref.watch(
      currentFinancialReportStandardTransitionProvider,
    );
    final subsequentEventReview = ref.watch(
      currentFinancialReportSubsequentEventReviewProvider,
    );
    final goingConcernReview = ref.watch(
      currentFinancialReportGoingConcernReviewProvider,
    );
    final releaseEvidenceManifest = ref.watch(
      currentFinancialReportReleaseEvidenceManifestProvider,
    );
    final releaseArchiveSummary = ref.watch(
      currentFinancialReportReleaseArchiveSummaryProvider,
    );
    final releaseArchiveAuditEvents = ref.watch(
      currentFinancialReportReleaseArchiveAuditProvider,
    );
    final releaseArchiveRetention = ref.watch(
      currentFinancialReportReleaseArchiveRetentionProvider,
    );
    final statutoryFiling = ref.watch(
      currentFinancialReportStatutoryFilingProvider,
    );
    final signOffService = ref.watch(
      financialReportReleaseSignOffServiceProvider,
    );
    final distributionService = ref.watch(
      financialReportReleaseDistributionServiceProvider,
    );
    final packageIntegrity = ref.watch(
      currentFinancialReportPackageIntegrityProvider,
    );
    final colorScheme = Theme.of(context).colorScheme;
    _scheduleInitialFocus();

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Report Release'),
        actions: [
          IconButton(
            tooltip: 'Financial notes',
            onPressed: () => context.go(AccountingPath.financialNotes),
            icon: const Icon(Icons.sticky_note_2_rounded),
          ),
          IconButton(
            tooltip: 'Report pack',
            onPressed: () => context.go(AccountingPath.reportPack),
            icon: const Icon(Icons.inventory_2_rounded),
          ),
          IconButton(
            tooltip: 'Period close',
            onPressed: () => context.go(AccountingPath.periodClose),
            icon: const Icon(Icons.lock_clock_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          FinancialReportReleaseSignOffHeader(
            periodLabel: period.label,
            frameworkName: pack.frameworkName,
            totalCount: signOffItems.length,
            signedCount: signOffService.signedCount(signOffItems),
            pendingCount: signOffService.pendingCount(signOffItems),
            returnedCount: signOffService.returnedCount(signOffItems),
            completionRatio: signOffService.completionRatio(signOffItems),
            integrityStatus: packageIntegrity.status,
          ),
          const SizedBox(height: 14),
          FinancialReportReleaseSectionNavigator(
            selectedDestination: _focusedDestination,
            onSelect:
                (destination) => _openReleaseDestination(context, destination),
          ),
          const SizedBox(height: 14),
          FinancialReportReleaseControlSummaryPanel(
            summary: releaseControlSummary,
          ),
          const SizedBox(height: 14),
          FinancialReportReleaseActionQueuePanel(
            summary: releaseActionQueue,
            onOpenAction: (item) => _openReleaseAction(context, item),
          ),
          const SizedBox(height: 14),
          FinancialReportReleaseMilestonePanel(summary: releaseMilestones),
          const SizedBox(height: 14),
          FinancialReportStandardTransitionPanel(summary: standardTransition),
          const SizedBox(height: 14),
          FinancialReportSubsequentEventReviewPanel(
            summary: subsequentEventReview,
          ),
          const SizedBox(height: 14),
          FinancialReportGoingConcernReviewPanel(summary: goingConcernReview),
          const SizedBox(height: 14),
          KeyedSubtree(
            key: _evidenceManifestKey,
            child: FinancialReportFocusHighlight(
              active:
                  _focusedDestination ==
                  FinancialReportReleaseActionDestination.evidenceManifest,
              child: FinancialReportReleaseEvidenceManifestPanel(
                summary: releaseEvidenceManifest,
                onOpenManagementMeasures:
                    () => context.go(
                      AccountingPath.managementMeasuresWithFocus(
                        AccountingPath.managementMeasuresAuditFocus,
                      ),
                    ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          KeyedSubtree(
            key: _archiveKey,
            child: FinancialReportFocusHighlight(
              active:
                  _focusedDestination ==
                  FinancialReportReleaseActionDestination.archive,
              child: FinancialReportReleaseArchivePanel(
                summary: releaseArchiveSummary,
                onArchive:
                    releaseArchiveSummary.canArchive
                        ? () => _archiveReleasePack(context, ref)
                        : null,
                onClear:
                    releaseArchiveSummary.isArchived
                        ? () => _clearArchiveRecord(context, ref)
                        : null,
              ),
            ),
          ),
          const SizedBox(height: 14),
          KeyedSubtree(
            key: _retentionKey,
            child: FinancialReportFocusHighlight(
              active:
                  _focusedDestination ==
                  FinancialReportReleaseActionDestination.retention,
              child: FinancialReportReleaseArchiveRetentionPanel(
                summary: releaseArchiveRetention,
                onReview:
                    releaseArchiveRetention.hasArchive
                        ? () => _markArchiveRetentionReviewed(context, ref)
                        : null,
                onRequestDisposalReview:
                    releaseArchiveRetention.hasArchive
                        ? () => _requestArchiveDisposalReview(context, ref)
                        : null,
              ),
            ),
          ),
          const SizedBox(height: 14),
          KeyedSubtree(
            key: _statutoryFilingKey,
            child: FinancialReportFocusHighlight(
              active:
                  _focusedDestination ==
                  FinancialReportReleaseActionDestination.statutoryFiling,
              child: FinancialReportStatutoryFilingPanel(
                summary: statutoryFiling,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (releaseArchiveAuditEvents.isNotEmpty) ...[
            FinancialReportReleaseArchiveAuditTrail(
              events: releaseArchiveAuditEvents,
              isDarkMode: Theme.of(context).brightness == Brightness.dark,
            ),
            const SizedBox(height: 14),
          ],
          KeyedSubtree(
            key: _signOffKey,
            child: FinancialReportFocusHighlight(
              active:
                  _focusedDestination ==
                  FinancialReportReleaseActionDestination.signOff,
              child: FinancialReportReleaseSignOffList(
                items: signOffItems,
                onResolve:
                    (item, status) =>
                        _saveResolution(context, ref, item, status),
                onClear: (item) => _clearResolution(context, ref, item),
              ),
            ),
          ),
          const SizedBox(height: 14),
          KeyedSubtree(
            key: _distributionKey,
            child: FinancialReportFocusHighlight(
              active:
                  _focusedDestination ==
                  FinancialReportReleaseActionDestination.distribution,
              child: FinancialReportReleaseDistributionPanel(
                items: distributionItems,
                completedCount: distributionService.completedCount(
                  distributionItems,
                ),
                acknowledgedCount: distributionService.acknowledgedCount(
                  distributionItems,
                ),
                exceptionCount: distributionService.exceptionCount(
                  distributionItems,
                ),
                overdueCount: distributionService.overdueCount(
                  distributionItems,
                  DateTime.now(),
                ),
                actionLockedReason: distributionLockedReason,
                onUpdate:
                    (item, status) =>
                        _saveDistributionStatus(context, ref, item, status),
                onClear: (item) => _clearDistributionStatus(context, ref, item),
              ),
            ),
          ),
          if (distributionAuditEvents.isNotEmpty) ...[
            const SizedBox(height: 14),
            FinancialReportReleaseDistributionAuditTrail(
              events: distributionAuditEvents,
              isDarkMode: Theme.of(context).brightness == Brightness.dark,
            ),
          ],
          if (auditEvents.isNotEmpty) ...[
            const SizedBox(height: 14),
            FinancialReportReleaseSignOffAuditTrail(
              events: auditEvents,
              isDarkMode: Theme.of(context).brightness == Brightness.dark,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _archiveReleasePack(BuildContext context, WidgetRef ref) async {
    final input = await showDialog<FinancialReportReleaseArchiveInput>(
      context: context,
      builder: (context) => const FinancialReportReleaseArchiveDialog(),
    );
    if (input == null || !context.mounted) {
      return;
    }

    final periodKey = ref.read(
      currentFinancialReportReleaseSignOffPeriodKeyProvider,
    );
    final periodLabel = ref.read(selectedFinancialPeriodProvider).label;
    try {
      final record = ref
          .read(financialReportReleaseArchiveProvider.notifier)
          .createArchiveRecord(
            periodKey: periodKey,
            periodLabel: periodLabel,
            packageIntegrity: ref.read(
              currentFinancialReportPackageIntegrityProvider,
            ),
            evidenceManifest: ref.read(
              currentFinancialReportReleaseEvidenceManifestProvider,
            ),
            archivedBy: input.archivedBy,
            custodian: input.custodian,
            storageLocation: input.storageLocation,
            note: input.note,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${record.archiveId} created.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on StateError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openReleaseAction(
    BuildContext context,
    FinancialReportReleaseActionItem item,
  ) {
    final destination = item.destination;
    if (destination == null) {
      return;
    }
    _openReleaseDestination(context, destination);
  }

  void _openReleaseDestination(
    BuildContext context,
    FinancialReportReleaseActionDestination destination,
  ) {
    switch (destination) {
      case FinancialReportReleaseActionDestination.reportPack:
        _clearLocalFocus();
        context.go(AccountingPath.reportPack);
        break;
      case FinancialReportReleaseActionDestination.signOff:
        _focusLocalReleaseSection(destination, _signOffKey);
        context.go(
          AccountingPath.reportReleaseWithFocus(
            AccountingPath.reportReleaseSignOffFocus,
          ),
        );
        break;
      case FinancialReportReleaseActionDestination.evidenceManifest:
        _focusLocalReleaseSection(destination, _evidenceManifestKey);
        context.go(
          AccountingPath.reportReleaseWithFocus(
            AccountingPath.reportReleaseEvidenceFocus,
          ),
        );
        break;
      case FinancialReportReleaseActionDestination.distribution:
        _focusLocalReleaseSection(destination, _distributionKey);
        context.go(
          AccountingPath.reportReleaseWithFocus(
            AccountingPath.reportReleaseDistributionFocus,
          ),
        );
        break;
      case FinancialReportReleaseActionDestination.archive:
        _focusLocalReleaseSection(destination, _archiveKey);
        context.go(
          AccountingPath.reportReleaseWithFocus(
            AccountingPath.reportReleaseArchiveFocus,
          ),
        );
        break;
      case FinancialReportReleaseActionDestination.retention:
        _focusLocalReleaseSection(destination, _retentionKey);
        context.go(
          AccountingPath.reportReleaseWithFocus(
            AccountingPath.reportReleaseRetentionFocus,
          ),
        );
        break;
      case FinancialReportReleaseActionDestination.statutoryFiling:
        _focusLocalReleaseSection(destination, _statutoryFilingKey);
        context.go(
          AccountingPath.reportReleaseWithFocus(
            AccountingPath.reportReleaseStatutoryFilingFocus,
          ),
        );
        break;
      case FinancialReportReleaseActionDestination
          .managementMeasureReleaseChecklist:
        _clearLocalFocus();
        context.go(
          AccountingPath.managementMeasuresWithFocus(
            AccountingPath.managementMeasuresReleaseChecklistFocus,
          ),
        );
        break;
      case FinancialReportReleaseActionDestination
          .managementMeasureApprovalCheck:
        _clearLocalFocus();
        context.go(
          AccountingPath.managementMeasuresWithFocus(
            AccountingPath.managementMeasuresApprovalFocus,
          ),
        );
        break;
      case FinancialReportReleaseActionDestination
          .managementMeasureReconciliationCheck:
        _clearLocalFocus();
        context.go(
          AccountingPath.managementMeasuresWithFocus(
            AccountingPath.managementMeasuresReconciliationFocus,
          ),
        );
        break;
      case FinancialReportReleaseActionDestination
          .managementMeasureExportEvidenceCheck:
        _clearLocalFocus();
        context.go(
          AccountingPath.managementMeasuresWithFocus(
            AccountingPath.managementMeasuresExportEvidenceFocus,
          ),
        );
        break;
      case FinancialReportReleaseActionDestination.managementMeasureAuditTrail:
        _clearLocalFocus();
        context.go(
          AccountingPath.managementMeasuresWithFocus(
            AccountingPath.managementMeasuresAuditFocus,
          ),
        );
        break;
    }
  }

  void _focusLocalReleaseSection(
    FinancialReportReleaseActionDestination destination,
    GlobalKey key,
  ) {
    setState(() => _focusedDestination = destination);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToKey(key));
  }

  void _clearLocalFocus() {
    if (_focusedDestination == null) {
      return;
    }
    setState(() => _focusedDestination = null);
  }

  void _scheduleInitialFocus() {
    if (_didApplyInitialFocus ||
        widget.initialFocus == FinancialReportReleaseCenterFocus.overview) {
      return;
    }
    final key = _keyForFocus(widget.initialFocus);
    if (key == null) {
      return;
    }
    _didApplyInitialFocus = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToKey(key));
  }

  void _scrollToKey(GlobalKey key) {
    if (!mounted) {
      return;
    }
    final targetContext = key.currentContext;
    if (targetContext == null) {
      return;
    }
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  GlobalKey? _keyForFocus(FinancialReportReleaseCenterFocus focus) {
    switch (focus) {
      case FinancialReportReleaseCenterFocus.signOff:
        return _signOffKey;
      case FinancialReportReleaseCenterFocus.evidenceManifest:
        return _evidenceManifestKey;
      case FinancialReportReleaseCenterFocus.distribution:
        return _distributionKey;
      case FinancialReportReleaseCenterFocus.archive:
        return _archiveKey;
      case FinancialReportReleaseCenterFocus.retention:
        return _retentionKey;
      case FinancialReportReleaseCenterFocus.statutoryFiling:
        return _statutoryFilingKey;
      case FinancialReportReleaseCenterFocus.overview:
        return null;
    }
  }

  FinancialReportReleaseActionDestination? _destinationForFocus(
    FinancialReportReleaseCenterFocus focus,
  ) {
    switch (focus) {
      case FinancialReportReleaseCenterFocus.signOff:
        return FinancialReportReleaseActionDestination.signOff;
      case FinancialReportReleaseCenterFocus.evidenceManifest:
        return FinancialReportReleaseActionDestination.evidenceManifest;
      case FinancialReportReleaseCenterFocus.distribution:
        return FinancialReportReleaseActionDestination.distribution;
      case FinancialReportReleaseCenterFocus.archive:
        return FinancialReportReleaseActionDestination.archive;
      case FinancialReportReleaseCenterFocus.retention:
        return FinancialReportReleaseActionDestination.retention;
      case FinancialReportReleaseCenterFocus.statutoryFiling:
        return FinancialReportReleaseActionDestination.statutoryFiling;
      case FinancialReportReleaseCenterFocus.overview:
        return null;
    }
  }

  void _clearArchiveRecord(BuildContext context, WidgetRef ref) {
    final periodKey = ref.read(
      currentFinancialReportReleaseSignOffPeriodKeyProvider,
    );
    final periodLabel = ref.read(selectedFinancialPeriodProvider).label;
    ref
        .read(financialReportReleaseArchiveProvider.notifier)
        .clearArchiveRecord(
          periodKey: periodKey,
          periodLabel: periodLabel,
          actor: 'Current user',
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Release archive record cleared.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _markArchiveRetentionReviewed(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final input =
        await showDialog<FinancialReportReleaseArchiveRetentionActionInput>(
          context: context,
          builder:
              (context) =>
                  const FinancialReportReleaseArchiveRetentionActionDialog(
                    title: 'Mark retention reviewed',
                    actionLabel: 'Mark reviewed',
                    initialNote:
                        'Custody, location, and retention policy reviewed.',
                  ),
        );
    if (input == null || !context.mounted) {
      return;
    }

    final periodKey = ref.read(
      currentFinancialReportReleaseSignOffPeriodKeyProvider,
    );
    final event = ref
        .read(financialReportReleaseArchiveProvider.notifier)
        .recordRetentionReview(
          periodKey: periodKey,
          actor: 'Current user',
          note: input.note,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${event.archiveId ?? event.periodLabel} reviewed.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _requestArchiveDisposalReview(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final input = await showDialog<
      FinancialReportReleaseArchiveRetentionActionInput
    >(
      context: context,
      builder:
          (context) => const FinancialReportReleaseArchiveRetentionActionDialog(
            title: 'Request disposal review',
            actionLabel: 'Request review',
            initialNote:
                'Review disposal eligibility and legal-hold requirements before action.',
          ),
    );
    if (input == null || !context.mounted) {
      return;
    }

    final periodKey = ref.read(
      currentFinancialReportReleaseSignOffPeriodKeyProvider,
    );
    final event = ref
        .read(financialReportReleaseArchiveProvider.notifier)
        .requestDisposalReview(
          periodKey: periodKey,
          actor: 'Current user',
          note: input.note,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${event.archiveId ?? event.periodLabel} disposal review requested.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _saveDistributionStatus(
    BuildContext context,
    WidgetRef ref,
    FinancialReportReleaseDistributionItem item,
    FinancialReportReleaseDistributionStatus status,
  ) {
    final periodKey = ref.read(
      currentFinancialReportReleaseSignOffPeriodKeyProvider,
    );
    final periodLabel = ref.read(selectedFinancialPeriodProvider).label;
    final resolution = FinancialReportReleaseDistributionResolution(
      recipientId: item.id,
      status: status,
      owner: 'Current user',
      updatedAt: DateTime.now(),
      note: _distributionNoteForStatus(status, item.recipient.name),
      evidenceReference:
          status == FinancialReportReleaseDistributionStatus.exception
              ? 'DIST-EXCEPTION-${item.id.toUpperCase()}'
              : 'DIST-${item.id.toUpperCase()}',
    );

    ref
        .read(financialReportReleaseDistributionProvider.notifier)
        .recordResolution(
          periodKey: periodKey,
          periodLabel: periodLabel,
          item: item,
          resolution: resolution,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.recipient.name} marked ${status.label}.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearDistributionStatus(
    BuildContext context,
    WidgetRef ref,
    FinancialReportReleaseDistributionItem item,
  ) {
    final periodKey = ref.read(
      currentFinancialReportReleaseSignOffPeriodKeyProvider,
    );
    final periodLabel = ref.read(selectedFinancialPeriodProvider).label;
    ref
        .read(financialReportReleaseDistributionProvider.notifier)
        .clearResolution(
          periodKey: periodKey,
          periodLabel: periodLabel,
          item: item,
          actor: 'Current user',
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.recipient.name} distribution status cleared.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _saveResolution(
    BuildContext context,
    WidgetRef ref,
    FinancialReportReleaseSignOffItem item,
    FinancialReportReleaseSignOffStatus status,
  ) {
    final periodKey = ref.read(
      currentFinancialReportReleaseSignOffPeriodKeyProvider,
    );
    final periodLabel = ref.read(selectedFinancialPeriodProvider).label;
    final resolution = FinancialReportReleaseSignOffResolution(
      requirementId: item.id,
      status: status,
      signer: 'Current user',
      signedAt: DateTime.now(),
      note: _noteForStatus(status, item.requirement.title),
      evidenceReference: 'SIGNOFF-${item.role.name.toUpperCase()}',
    );

    ref
        .read(financialReportReleaseSignOffProvider.notifier)
        .recordResolution(
          periodKey: periodKey,
          periodLabel: periodLabel,
          item: item,
          resolution: resolution,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.requirement.title} marked ${status.label}.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearResolution(
    BuildContext context,
    WidgetRef ref,
    FinancialReportReleaseSignOffItem item,
  ) {
    final periodKey = ref.read(
      currentFinancialReportReleaseSignOffPeriodKeyProvider,
    );
    final periodLabel = ref.read(selectedFinancialPeriodProvider).label;
    ref
        .read(financialReportReleaseSignOffProvider.notifier)
        .clearResolution(
          periodKey: periodKey,
          periodLabel: periodLabel,
          item: item,
          actor: 'Current user',
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.requirement.title} sign-off cleared.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _noteForStatus(
    FinancialReportReleaseSignOffStatus status,
    String title,
  ) {
    switch (status) {
      case FinancialReportReleaseSignOffStatus.signed:
        return '$title completed for the current report pack.';
      case FinancialReportReleaseSignOffStatus.returned:
        return '$title returned for follow-up before release.';
    }
  }

  String _distributionNoteForStatus(
    FinancialReportReleaseDistributionStatus status,
    String recipientName,
  ) {
    switch (status) {
      case FinancialReportReleaseDistributionStatus.pending:
        return '$recipientName distribution is pending.';
      case FinancialReportReleaseDistributionStatus.sent:
        return '$recipientName received the released report pack.';
      case FinancialReportReleaseDistributionStatus.acknowledged:
        return '$recipientName acknowledged the released report pack.';
      case FinancialReportReleaseDistributionStatus.exception:
        return '$recipientName has a distribution exception for follow-up.';
    }
  }
}
