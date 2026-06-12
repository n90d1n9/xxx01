import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_exception_event.dart';
import '../models/billing_policy_capability.dart';
import '../models/billing_policy_config.dart';
import '../models/split_allocation_plan.dart';
import '../utils/billing_policy_presets.dart';
import '../utils/exception_relief_planner.dart';
import '../utils/policy_exception_planner.dart';
import '../utils/relief_application_packet_builder.dart';
import '../utils/relief_approval_guidance_resolver.dart';
import '../utils/relief_execution_plan_builder.dart';
import '../utils/relief_follow_up_work_items.dart';
import '../utils/relief_impact_analyzer.dart';
import '../utils/relief_monitoring_plan_builder.dart';
import '../utils/split_allocation_planner.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_exception_policy_panel.dart';
import 'billing_policy_capability_matrix.dart';
import 'exception_relief_plan_panel.dart';
import 'follow_up_work_queue_panel.dart';
import 'policy_exception_decision_panel.dart';
import 'relief_application_packet_panel.dart';
import 'relief_approval_guidance_panel.dart';
import 'relief_execution_plan_panel.dart';
import 'relief_impact_summary_panel.dart';
import 'relief_monitoring_plan_panel.dart';
import 'split_allocation_preview_panel.dart';

/// Composed billing policy center content for capabilities and exceptions.
class BillingPolicyCenterContent extends StatelessWidget {
  final BillingPolicyConfig config;
  final List<BillingPolicyCapability> capabilities;
  final String businessDomainLabel;
  final void Function(BillingPolicyCapabilityId capabilityId, bool enabled)?
  onCapabilityChanged;

  const BillingPolicyCenterContent({
    super.key,
    required this.config,
    required this.capabilities,
    this.businessDomainLabel = 'Agnostic',
    this.onCapabilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final summary = BillingPolicyConfigSummary(
      config: config,
      totalCapabilityCount: capabilities.length,
    );
    final forceMajeurePlan = planBillingPolicyException(
      config: config,
      kind: BillingExceptionEventKind.forceMajeure,
    );
    final splitAllocationPlan = planBillingSplitAllocation(
      config: config,
      totalAmount: 1200,
      recipients: _policyCenterSplitRecipients,
    );
    final reliefPlan = planBillingExceptionRelief(
      config: config,
      kind: BillingExceptionEventKind.forceMajeure,
      affectedInvoiceCount: 12,
      openAmount: 42600,
      reliefDurationDays: 21,
      approvalGranted: true,
      evidenceCaptured: true,
    );
    final reliefApplicationPacket =
        buildBillingExceptionReliefApplicationPacket(
          plan: reliefPlan,
          requestedBy: 'Ops lead',
          requestedAt: DateTime.utc(2026, 1, 15, 9),
        );
    final reliefImpactSummary = summarizeBillingExceptionReliefImpact(
      packet: reliefApplicationPacket,
    );
    final reliefApprovalGuidance =
        resolveBillingExceptionReliefApprovalGuidance(
          summary: reliefImpactSummary,
        );
    final reliefExecutionPlan = buildBillingExceptionReliefExecutionPlan(
      guidance: reliefApprovalGuidance,
    );
    final reliefMonitoringPlan = buildBillingExceptionReliefMonitoringPlan(
      executionPlan: reliefExecutionPlan,
    );
    final reliefFollowUpQueue = buildReliefMonitoringFollowUpWorkQueue(
      plan: reliefMonitoringPlan,
    );

    return BillingReadinessPanelScaffold(
      title: 'Billing policy center',
      summary:
          '$businessDomainLabel policy profile for capability gates, split billing, and exception handling.',
      icon: Icons.policy_outlined,
      iconColor: const Color(0xFF1D4ED8),
      iconBackgroundColor: const Color(0xFFEFF6FF),
      metrics: [
        BillingReadinessMetric(
          label: 'Capabilities',
          value:
              '${summary.enabledCapabilityCount}/${summary.totalCapabilityCount}',
          icon: Icons.tune_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Split limit',
          value: '${config.maxSplitRecipients}',
          icon: Icons.call_split_outlined,
          color: const Color(0xFF7C3AED),
        ),
        BillingReadinessMetric(
          label: 'Exceptions',
          value: '${summary.exceptionPolicyCount}',
          icon: Icons.gpp_maybe_outlined,
          color: const Color(0xFFB45309),
        ),
        BillingReadinessMetric(
          label: 'Approval',
          value: config.requireApprovalForExceptions ? 'On' : 'Off',
          icon: Icons.verified_user_outlined,
          color: const Color(0xFF047857),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PolicySectionHeader(
            title: 'Capability gates',
            subtitle: summary.capabilitySummaryLabel,
          ),
          const SizedBox(height: 12),
          BillingPolicyCapabilityMatrix(
            capabilities: capabilities,
            config: config,
            onCapabilityChanged: onCapabilityChanged,
          ),
          const SizedBox(height: 18),
          _PolicySectionHeader(
            title: 'Split preview',
            subtitle: splitAllocationPlan.statusLabel,
          ),
          const SizedBox(height: 12),
          BillingSplitAllocationPreviewPanel(plan: splitAllocationPlan),
          const SizedBox(height: 4),
          _PolicySectionHeader(
            title: 'Exception conditions',
            subtitle: summary.exceptionSummaryLabel,
          ),
          const SizedBox(height: 12),
          BillingExceptionPolicyPanel(policies: config.exceptionPolicies),
          const SizedBox(height: 18),
          _PolicySectionHeader(
            title: 'Relief workflow',
            subtitle: reliefPlan.statusLabel,
          ),
          const SizedBox(height: 12),
          BillingExceptionReliefPlanPanel(plan: reliefPlan),
          const SizedBox(height: 18),
          _PolicySectionHeader(
            title: 'Application packet',
            subtitle: reliefApplicationPacket.statusLabel,
          ),
          const SizedBox(height: 12),
          BillingExceptionReliefApplicationPacketPanel(
            packet: reliefApplicationPacket,
          ),
          const SizedBox(height: 18),
          _PolicySectionHeader(
            title: 'Impact summary',
            subtitle: reliefImpactSummary.statusLabel,
          ),
          const SizedBox(height: 12),
          BillingExceptionReliefImpactSummaryPanel(
            summary: reliefImpactSummary,
          ),
          const SizedBox(height: 18),
          _PolicySectionHeader(
            title: 'Approval guidance',
            subtitle: reliefApprovalGuidance.statusLabel,
          ),
          const SizedBox(height: 12),
          BillingExceptionReliefApprovalGuidancePanel(
            guidance: reliefApprovalGuidance,
          ),
          const SizedBox(height: 18),
          _PolicySectionHeader(
            title: 'Execution handoff',
            subtitle: reliefExecutionPlan.statusLabel,
          ),
          const SizedBox(height: 12),
          BillingExceptionReliefExecutionPlanPanel(plan: reliefExecutionPlan),
          const SizedBox(height: 18),
          _PolicySectionHeader(
            title: 'Monitoring plan',
            subtitle: reliefMonitoringPlan.statusLabel,
          ),
          const SizedBox(height: 12),
          BillingExceptionReliefMonitoringPlanPanel(plan: reliefMonitoringPlan),
          const SizedBox(height: 18),
          _PolicySectionHeader(
            title: 'Follow-up queue',
            subtitle: reliefFollowUpQueue.headlineLabel,
          ),
          const SizedBox(height: 12),
          BillingFollowUpWorkQueuePanel(queue: reliefFollowUpQueue),
          const SizedBox(height: 18),
          _PolicySectionHeader(
            title: 'Decision preview',
            subtitle: forceMajeurePlan.statusLabel,
          ),
          const SizedBox(height: 12),
          BillingPolicyExceptionDecisionPanel(plan: forceMajeurePlan),
        ],
      ),
    );
  }
}

const _policyCenterSplitRecipients = [
  BillingSplitAllocationRecipient(
    id: 'primary',
    label: 'Primary payer',
    share: 0.5,
  ),
  BillingSplitAllocationRecipient(
    id: 'co-payer',
    label: 'Co-payer',
    share: 0.3,
  ),
  BillingSplitAllocationRecipient(id: 'sponsor', label: 'Sponsor', share: 0.2),
];

@Preview(name: 'Billing policy center content')
Widget billingPolicyCenterContentPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: BillingPolicyCenterContent(
          config: constructionBillingPolicyConfig(),
          capabilities: standardBillingPolicyCapabilities(),
          businessDomainLabel: 'Construction',
        ),
      ),
    ),
  );
}

class _PolicySectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PolicySectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
