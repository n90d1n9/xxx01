import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import 'employee_management_record_tiles.dart';
import 'employee_management_status_styles.dart';

class EmployeeManagementSnapshotPanel extends StatelessWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeManagementSnapshotPanel({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.manage_accounts_outlined,
      title: 'Employee management',
      subtitle: '${snapshot.payrollGroup} - ${snapshot.employmentType}',
      children: [
        _RecordHealthCard(snapshot: snapshot),
        _EmploymentProfileCard(snapshot: snapshot),
        _LifecycleCard(events: snapshot.lifecycle),
        _DocumentCard(documents: snapshot.documents),
        _AssetCard(assets: snapshot.assets),
      ],
    );
  }
}

class _RecordHealthCard extends StatelessWidget {
  final EmployeeManagementSnapshot snapshot;

  const _RecordHealthCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final color = employeeManagementHealthColor(snapshot.health);

    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final score = Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${snapshot.readinessScore}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HrisStatusPill(label: snapshot.health.label, color: color),
                    const SizedBox(height: 6),
                    Text(
                      snapshot.nextAction,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final metrics = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              EmployeeManagementMiniMetric(
                label: 'Documents',
                value: '${snapshot.documentAttentionCount}',
              ),
              EmployeeManagementMiniMetric(
                label: 'Overdue',
                value: '${snapshot.overdueDocumentCount}',
              ),
              EmployeeManagementMiniMetric(
                label: 'Assets',
                value: '${snapshot.activeAssetCount}',
              ),
              EmployeeManagementMiniMetric(
                label: 'Pending',
                value: '${snapshot.pendingAssetCount}',
              ),
            ],
          );

          if (constraints.maxWidth < 700) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [score, const SizedBox(height: 12), metrics],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: score),
              const SizedBox(width: 16),
              Expanded(child: metrics),
            ],
          );
        },
      ),
    );
  }
}

class _EmploymentProfileCard extends StatelessWidget {
  final EmployeeManagementSnapshot snapshot;

  const _EmploymentProfileCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        children: [
          EmployeeManagementProfileChip(
            icon: Icons.badge_outlined,
            label: 'Level',
            value: snapshot.jobLevel,
          ),
          EmployeeManagementProfileChip(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Payroll',
            value: snapshot.payrollGroup,
          ),
          EmployeeManagementProfileChip(
            icon: Icons.business_center_outlined,
            label: 'Cost center',
            value: snapshot.costCenter,
          ),
          EmployeeManagementProfileChip(
            icon: Icons.assignment_outlined,
            label: 'Type',
            value: snapshot.employmentType,
          ),
        ],
      ),
    );
  }
}

class _LifecycleCard extends StatelessWidget {
  final List<EmployeeLifecycleEvent> events;

  const _LifecycleCard({required this.events});

  @override
  Widget build(BuildContext context) {
    return EmployeeManagementSubsectionSurface(
      icon: Icons.timeline_outlined,
      title: 'Lifecycle',
      children:
          events
              .take(3)
              .map((event) => EmployeeManagementLifecycleEventRow(event: event))
              .toList(),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final List<EmployeeComplianceDocument> documents;

  const _DocumentCard({required this.documents});

  @override
  Widget build(BuildContext context) {
    return EmployeeManagementSubsectionSurface(
      icon: Icons.folder_copy_outlined,
      title: 'Documents',
      children:
          documents
              .map(
                (document) => EmployeeManagementRecordItemRow(
                  title: document.title,
                  detail:
                      '${document.owner} - due ${DateFormat('MMM d').format(document.dueDate)}',
                  status: document.status,
                ),
              )
              .toList(),
    );
  }
}

class _AssetCard extends StatelessWidget {
  final List<EmployeeAssetAssignment> assets;

  const _AssetCard({required this.assets});

  @override
  Widget build(BuildContext context) {
    return EmployeeManagementSubsectionSurface(
      icon: Icons.devices_other_outlined,
      title: 'Assets and access',
      children:
          assets
              .map(
                (asset) => EmployeeManagementRecordItemRow(
                  title: asset.name,
                  detail: asset.owner,
                  status: asset.status,
                ),
              )
              .toList(),
    );
  }
}
