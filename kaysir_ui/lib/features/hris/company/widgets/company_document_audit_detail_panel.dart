import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../../employee/models/employee_compliance_models.dart';
import '../../employee/models/employee_document_request_models.dart';
import '../models/company_document.dart';
import '../models/company_document_audit_detail.dart';
import '../models/company_document_audit_event.dart';
import '../models/company_document_requirement.dart';
import '../models/company_employee_document_gap.dart';
import 'company_status_styles.dart';

class CompanyDocumentAuditDetailPanel extends StatelessWidget {
  final CompanyDocumentAuditDetail? detail;

  const CompanyDocumentAuditDetailPanel({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final current = detail;

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Audit Event Detail',
      subtitle:
          current == null
              ? 'Select an audit event to inspect linked records'
              : '${current.linkedRecordCount} linked records',
      emptyMessage: 'Select an audit event to inspect linked records',
      children:
          current == null
              ? const []
              : [
                _EventSummaryCard(detail: current),
                if (current.employeeDocumentGap != null)
                  _EmployeeGapCard(detail: current),
                if (current.employeeDocumentRequest != null)
                  _EmployeeRequestCard(
                    request: current.employeeDocumentRequest!,
                  ),
                if (current.evidenceRecords.isNotEmpty)
                  _EvidenceRecordsCard(records: current.evidenceRecords),
                if (current.companyDocument != null)
                  _CompanyDocumentCard(document: current.companyDocument!),
                if (current.isEmployeeDocumentEvent &&
                    !current.hasEmployeeDocumentContext)
                  const HrisEmptyState(
                    message: 'No linked employee document context found',
                  ),
              ],
    );
  }
}

class _EventSummaryCard extends StatelessWidget {
  final CompanyDocumentAuditDetail detail;

  const _EventSummaryCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final event = detail.event;
    final color = companyDocumentAuditEventColor(event.type);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: event.type.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Entity', value: event.entityName),
              HrisMetricStripItem(label: 'Actor', value: event.actorName),
              HrisMetricStripItem(
                label: 'When',
                value: _formatDateTime(event.happenedAt),
              ),
            ],
          ),
          if (event.correlationId.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            HrisMetricStrip(
              items: [
                HrisMetricStripItem(
                  label: 'Correlation',
                  value: event.correlationId,
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            event.note,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeGapCard extends StatelessWidget {
  final CompanyDocumentAuditDetail detail;

  const _EmployeeGapCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final gap = detail.employeeDocumentGap!;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  gap.employeeName,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: gap.status.label,
                color: companyEmployeeDocumentGapStatusColor(gap.status),
              ),
            ],
          ),
          const SizedBox(height: 10),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Stage', value: gap.stage.label),
              HrisMetricStripItem(label: 'Job', value: gap.jobProfileCode),
              HrisMetricStripItem(
                label: 'Verified',
                value:
                    '${gap.verifiedDocumentCount}/${gap.requiredDocumentCount}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            gap.requirementName,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeRequestCard extends StatelessWidget {
  final EmployeeDocumentRequest request;

  const _EmployeeRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: request.status.label,
                color: _requestStatusColor(request.status),
              ),
            ],
          ),
          const SizedBox(height: 10),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Request', value: request.id),
              HrisMetricStripItem(label: 'Owner', value: request.owner),
              HrisMetricStripItem(
                label: 'Due',
                value: _formatDate(request.dueDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvidenceRecordsCard extends StatelessWidget {
  final List<EmployeeComplianceDocumentRecord> records;

  const _EvidenceRecordsCard({required this.records});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evidence Records',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Linked', value: '${records.length}'),
              HrisMetricStripItem(
                label: 'Verified',
                value: '${records.where((record) => record.isVerified).length}',
              ),
              HrisMetricStripItem(
                label: 'Pending',
                value:
                    '${records.where((record) => record.status == EmployeeComplianceDocumentStatus.pending).length}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...records
              .take(4)
              .map((record) => _EvidenceRecordRow(record: record)),
        ],
      ),
    );
  }
}

class _EvidenceRecordRow extends StatelessWidget {
  final EmployeeComplianceDocumentRecord record;

  const _EvidenceRecordRow({required this.record});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              record.title,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          HrisStatusPill(
            label: record.status.label,
            color: _complianceStatusColor(record.status),
          ),
        ],
      ),
    );
  }
}

class _CompanyDocumentCard extends StatelessWidget {
  final CompanyDocumentRecord document;

  const _CompanyDocumentCard({required this.document});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  document.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: document.status.label,
                color: companyDocumentStatusColor(document.status),
              ),
            ],
          ),
          const SizedBox(height: 10),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Type', value: document.type.label),
              HrisMetricStripItem(label: 'Owner', value: document.ownerName),
              HrisMetricStripItem(
                label: 'Module',
                value: document.linkedModule,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _requestStatusColor(EmployeeDocumentRequestStatus status) {
  switch (status) {
    case EmployeeDocumentRequestStatus.requested:
      return const Color(0xFF2563EB);
    case EmployeeDocumentRequestStatus.reviewing:
      return const Color(0xFFB45309);
    case EmployeeDocumentRequestStatus.issued:
      return const Color(0xFF7C3AED);
    case EmployeeDocumentRequestStatus.acknowledged:
      return const Color(0xFF15803D);
    case EmployeeDocumentRequestStatus.rejected:
      return const Color(0xFFB91C1C);
  }
}

Color _complianceStatusColor(EmployeeComplianceDocumentStatus status) {
  switch (status) {
    case EmployeeComplianceDocumentStatus.pending:
      return const Color(0xFF2563EB);
    case EmployeeComplianceDocumentStatus.verified:
      return const Color(0xFF15803D);
    case EmployeeComplianceDocumentStatus.rejected:
    case EmployeeComplianceDocumentStatus.expired:
      return const Color(0xFFB91C1C);
    case EmployeeComplianceDocumentStatus.waived:
      return const Color(0xFF6B7280);
  }
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _formatDateTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${_formatDate(date)} $hour:$minute';
}
