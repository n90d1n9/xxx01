import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

class InteractionReliabilitySyncPanel extends StatelessWidget {
  const InteractionReliabilitySyncPanel({
    super.key,
    required this.primaryConfig,
    required this.secondaryConfig,
    required this.zoomController,
    required this.showMinimap,
  });

  final BaseChartConfig primaryConfig;
  final BaseChartConfig secondaryConfig;
  final ChartZoomController zoomController;
  final bool showMinimap;

  @override
  Widget build(BuildContext context) {
    return _InteractionPanelScaffold(
      title: 'Synced Zoom',
      subtitle: 'Pinch/pan/scroll one chart and both update in lockstep.',
      child: Column(
        children: [
          Expanded(
            child: ZoomableTenunChart(
              config: primaryConfig,
              zoomController: zoomController,
              showMinimap: false,
              showResetButton: true,
              showBreadcrumbs: false,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ZoomableTenunChart(
              config: secondaryConfig,
              zoomController: zoomController,
              showMinimap: showMinimap,
              minimapHeight: 24,
              showResetButton: false,
              showBreadcrumbs: false,
            ),
          ),
        ],
      ),
    );
  }
}

class InteractionReliabilityDrillPanel extends StatelessWidget {
  const InteractionReliabilityDrillPanel({
    super.key,
    required this.drillController,
    required this.zoomController,
    required this.showMinimap,
    required this.showBreadcrumbs,
    required this.onTap,
  });

  final ChartDrillDownController drillController;
  final ChartZoomController zoomController;
  final bool showMinimap;
  final bool showBreadcrumbs;
  final void Function(double fraction, ChartZoomController zoom) onTap;

  @override
  Widget build(BuildContext context) {
    return _InteractionPanelScaffold(
      title: 'Drilldown + Zoom',
      subtitle: 'Tap bars/lines to go deeper, then zoom history/breadcrumbs.',
      child: ZoomableTenunChart.drillDown(
        drillController: drillController,
        zoomController: zoomController,
        showMinimap: showMinimap,
        showBreadcrumbs: showBreadcrumbs,
        minimapHeight: 24,
        onTap: onTap,
      ),
    );
  }
}

class _InteractionPanelScaffold extends StatelessWidget {
  const _InteractionPanelScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
