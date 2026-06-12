import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_exception_event.dart';
import '../models/relief_application_packet.dart';
import '../utils/billing_policy_presets.dart';
import '../utils/exception_relief_planner.dart';
import '../utils/relief_application_packet_builder.dart';

/// Presents a relief application packet before execution or synchronization.
class BillingExceptionReliefApplicationPacketPanel extends StatelessWidget {
  final BillingExceptionReliefApplicationPacket packet;

  const BillingExceptionReliefApplicationPacketPanel({
    super.key,
    required this.packet,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _PacketVisuals.fromPacket(packet);

    return Container(
      key: const ValueKey('billing-exception-relief-application-packet'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: visuals.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: visuals.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: visuals.iconBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(visuals.icon, color: visuals.iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Relief application packet',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        _PacketStatusPill(
                          label: packet.statusLabel,
                          color: visuals.iconColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      packet.summaryLabel,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PacketMetricChip(
                icon: Icons.playlist_add_check_circle_outlined,
                label: 'Commands',
                value: '${packet.commandCount}',
              ),
              _PacketMetricChip(
                icon: Icons.fact_check_outlined,
                label: 'Audit facts',
                value: '${packet.auditFactCount}',
              ),
              _PacketMetricChip(
                icon: Icons.person_outline,
                label: 'Requested by',
                value: packet.requestedBy,
              ),
            ],
          ),
          if (packet.commands.isNotEmpty) ...[
            const SizedBox(height: 14),
            Column(
              children: [
                for (final command in packet.commands)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _CommandTile(command: command),
                  ),
              ],
            ),
          ],
          if (packet.auditFacts.isNotEmpty) ...[
            const SizedBox(height: 6),
            _AuditFactWrap(facts: packet.auditFacts),
          ],
          if (packet.issues.isNotEmpty) ...[
            const SizedBox(height: 12),
            _PacketIssueList(issues: packet.issues),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Relief application packet panel')
Widget billingExceptionReliefApplicationPacketPanelPreview() {
  final reliefPlan = planBillingExceptionRelief(
    config: constructionBillingPolicyConfig(),
    kind: BillingExceptionEventKind.forceMajeure,
    affectedInvoiceCount: 12,
    openAmount: 42600,
    reliefDurationDays: 21,
    approvalGranted: true,
    evidenceCaptured: true,
  );

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SizedBox(
          width: 660,
          child: BillingExceptionReliefApplicationPacketPanel(
            packet: buildBillingExceptionReliefApplicationPacket(
              plan: reliefPlan,
              requestedBy: 'Ops lead',
              requestedAt: DateTime.utc(2026, 1, 15, 9),
            ),
          ),
        ),
      ),
    ),
  );
}

class _CommandTile extends StatelessWidget {
  final BillingExceptionReliefApplicationCommand command;

  const _CommandTile({required this.command});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.task_alt_outlined,
            color: Color(0xFF047857),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  command.label,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  command.description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditFactWrap extends StatelessWidget {
  final List<BillingExceptionReliefAuditFact> facts;

  const _AuditFactWrap({required this.facts});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final fact in facts)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fact.label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  fact.value,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PacketIssueList extends StatelessWidget {
  final List<BillingExceptionReliefApplicationIssue> issues;

  const _PacketIssueList({required this.issues});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final issue in issues)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFB45309),
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      issue.message,
                      style: const TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 11,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PacketMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PacketMetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF475569), size: 15),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PacketStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _PacketStatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PacketVisuals {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _PacketVisuals({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  factory _PacketVisuals.fromPacket(
    BillingExceptionReliefApplicationPacket packet,
  ) {
    if (!packet.isReady) {
      return const _PacketVisuals(
        icon: Icons.lock_outline_rounded,
        iconColor: Color(0xFFB45309),
        iconBackgroundColor: Color(0xFFFEF3C7),
        backgroundColor: Color(0xFFFFFBEB),
        borderColor: Color(0xFFFDE68A),
      );
    }

    return const _PacketVisuals(
      icon: Icons.outbox_outlined,
      iconColor: Color(0xFF047857),
      iconBackgroundColor: Color(0xFFD1FAE5),
      backgroundColor: Color(0xFFF0FDF4),
      borderColor: Color(0xFFBBF7D0),
    );
  }
}
