import 'package:flutter/material.dart';

import '../models/reservation_qr_scan_action_plan.dart';
import '../models/reservation_qr_session_section_plan.dart';
import '../models/reservation_qr_session_state.dart';
import '../services/reservation_qr_presentation_builder.dart';
import '../services/reservation_qr_session_section_presenter.dart';
import '../services/reservation_qr_session_summary_presenter.dart';
import 'reservation_qr_activity_trail.dart';
import 'reservation_qr_link_card.dart';
import 'reservation_qr_scan_status_card.dart';
import 'reservation_qr_selected_action_notice.dart';
import 'reservation_qr_session_callbacks.dart';
import 'reservation_qr_session_summary_header.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';

/// Composes the active reservation QR link and latest scan result for hosts.
class RestaurantReservationQrSessionPanel extends StatelessWidget {
  const RestaurantReservationQrSessionPanel({
    super.key,
    required this.state,
    this.linkTitle = 'Active QR handoff',
    this.scanTitle = 'Latest scan',
    this.callbacks = RestaurantReservationQrSessionCallbacks.empty,
    this.onCopyLink,
    this.onOpenLink,
    this.onRefreshLink,
    this.onScanActionSelected,
    this.onContinue,
    this.onRefreshScan,
    this.onDismissScan,
    this.showActivityTrail = true,
    this.presentationBuilder =
        const RestaurantReservationQrPresentationBuilder(),
    this.sectionPresenter =
        const RestaurantReservationQrSessionSectionPresenter(),
    this.summaryPresenter =
        const RestaurantReservationQrSessionSummaryPresenter(),
    this.summaryNow,
  });

  final RestaurantReservationQrSessionState state;
  final String linkTitle;
  final String scanTitle;
  final RestaurantReservationQrSessionCallbacks callbacks;
  final ValueChanged<Uri>? onCopyLink;
  final ValueChanged<Uri>? onOpenLink;
  final VoidCallback? onRefreshLink;
  final ValueChanged<RestaurantReservationQrScanAction>? onScanActionSelected;
  final VoidCallback? onContinue;
  final VoidCallback? onRefreshScan;
  final VoidCallback? onDismissScan;
  final bool showActivityTrail;
  final RestaurantReservationQrPresentationBuilder presentationBuilder;
  final RestaurantReservationQrSessionSectionPresenter sectionPresenter;
  final RestaurantReservationQrSessionSummaryPresenter summaryPresenter;
  final DateTime? summaryNow;

  @override
  Widget build(BuildContext context) {
    final effectiveCallbacks = callbacks.mergeWith(
      onCopyLink: onCopyLink,
      onOpenLink: onOpenLink,
      onRefreshLink: onRefreshLink,
      onScanActionSelected: onScanActionSelected,
      onContinue: onContinue,
      onRefreshScan: onRefreshScan,
      onDismissScan: onDismissScan,
    );
    final sectionPlan = sectionPresenter.build(
      state,
      showActivityTrail: showActivityTrail,
    );
    final children = [
      for (final section in sectionPlan.sections)
        ?_widgetForSection(section, effectiveCallbacks),
    ];

    if (children.isEmpty) return const _ReservationQrSessionEmptyState();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          children[index],
        ],
      ],
    );
  }

  Widget? _widgetForSection(
    RestaurantReservationQrSessionSection section,
    RestaurantReservationQrSessionCallbacks effectiveCallbacks,
  ) {
    return switch (section) {
      RestaurantReservationQrSessionSection.summary =>
        RestaurantReservationQrSessionSummaryHeader(
          summary: summaryPresenter.build(state, now: summaryNow),
        ),
      RestaurantReservationQrSessionSection.activeLink => _activeLinkSection(
        effectiveCallbacks,
      ),
      RestaurantReservationQrSessionSection.scanStatus => _scanStatusSection(
        effectiveCallbacks,
      ),
      RestaurantReservationQrSessionSection.selectedAction =>
        _selectedActionSection(),
      RestaurantReservationQrSessionSection.activityTrail =>
        RestaurantReservationQrActivityTrail(activities: state.activityTrail),
    };
  }

  Widget? _activeLinkSection(
    RestaurantReservationQrSessionCallbacks effectiveCallbacks,
  ) {
    final activeLink = state.activeLink;
    if (activeLink == null) return null;

    return RestaurantReservationQrLinkCard.fromLink(
      link: activeLink,
      title: linkTitle,
      onCopyLink: effectiveCallbacks.onCopyLink,
      onOpenLink: effectiveCallbacks.onOpenLink,
      onRefresh: effectiveCallbacks.onRefreshLink,
      presentationBuilder: presentationBuilder,
      now: summaryNow,
    );
  }

  Widget? _scanStatusSection(
    RestaurantReservationQrSessionCallbacks effectiveCallbacks,
  ) {
    final scanWorkflow = state.scanWorkflow;
    if (scanWorkflow == null) return null;

    return RestaurantReservationQrScanStatusCard(
      result: scanWorkflow.result,
      title: scanTitle,
      actionPlan: scanWorkflow.actionPlan,
      onActionSelected: effectiveCallbacks.onScanActionSelected,
      onContinue: effectiveCallbacks.onContinue,
      onRefresh: effectiveCallbacks.onRefreshScan,
      onDismiss: effectiveCallbacks.onDismissScan,
      presentationBuilder: presentationBuilder,
    );
  }

  Widget? _selectedActionSection() {
    final selectedAction = state.selectedAction;
    if (selectedAction == null) return null;

    return RestaurantReservationQrSelectedActionNotice(action: selectedAction);
  }
}

/// Shows a compact neutral state when no QR link or scan is active.
class _ReservationQrSessionEmptyState extends StatelessWidget {
  const _ReservationQrSessionEmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return RestaurantSectionSurface(
      borderColor: colors.outlineVariant.withValues(alpha: .55),
      backgroundColor: colors.surfaceContainerHighest.withValues(alpha: .22),
      child: const RestaurantSectionHeader(
        icon: Icons.qr_code_scanner_outlined,
        title: 'QR session',
        subtitle: 'No active QR handoff.',
      ),
    );
  }
}
