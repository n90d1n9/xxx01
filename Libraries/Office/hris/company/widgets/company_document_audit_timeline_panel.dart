import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_document_audit_activity_summary.dart';
import '../models/company_document_audit_event.dart';
import '../models/company_document_audit_filter.dart';
import 'company_status_styles.dart';

class CompanyDocumentAuditTimelinePanel extends StatelessWidget {
  final List<CompanyDocumentAuditEvent> events;
  final CompanyDocumentAuditActivitySummary summary;
  final CompanyDocumentAuditTimelineFilter filter;
  final String? selectedEventId;
  final ValueChanged<CompanyDocumentAuditFilterPreset> onPresetSelected;
  final ValueChanged<CompanyDocumentAuditTimelineScope> onScopeChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onEventSelected;

  const CompanyDocumentAuditTimelinePanel({
    super.key,
    required this.events,
    required this.summary,
    required this.filter,
    required this.selectedEventId,
    required this.onPresetSelected,
    required this.onScopeChanged,
    required this.onSearchChanged,
    required this.onEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.manage_search_outlined,
      title: 'Document Audit Timeline',
      subtitle: '${events.length} compliance events',
      emptyMessage: 'No matching document audit events',
      children: [
        _AuditActivitySummaryStrip(summary: summary),
        _AuditTimelineControls(
          filter: filter,
          onPresetSelected: onPresetSelected,
          onScopeChanged: onScopeChanged,
          onSearchChanged: onSearchChanged,
        ),
        if (events.isEmpty)
          const HrisEmptyState(message: 'No matching document audit events')
        else
          ...events.map(
            (event) => _AuditEventTile(
              event: event,
              isSelected: event.id == selectedEventId,
              onSelected: () => onEventSelected(event.id),
            ),
          ),
      ],
    );
  }
}

class _AuditActivitySummaryStrip extends StatelessWidget {
  final CompanyDocumentAuditActivitySummary summary;

  const _AuditActivitySummaryStrip({required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Total',
          value: '${summary.totalEventCount}',
        ),
        HrisMetricStripItem(
          label: 'Company',
          value: '${summary.companyDocumentEventCount}',
        ),
        HrisMetricStripItem(
          label: 'Employee',
          value: '${summary.employeeDocumentEventCount}',
        ),
        HrisMetricStripItem(
          label: 'Showing',
          value: '${summary.filteredEventCount}',
        ),
      ],
    );
  }
}

class _AuditTimelineControls extends StatelessWidget {
  final CompanyDocumentAuditTimelineFilter filter;
  final ValueChanged<CompanyDocumentAuditFilterPreset> onPresetSelected;
  final ValueChanged<CompanyDocumentAuditTimelineScope> onScopeChanged;
  final ValueChanged<String> onSearchChanged;

  const _AuditTimelineControls({
    required this.filter,
    required this.onPresetSelected,
    required this.onScopeChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AuditSearchField(
            value: filter.searchText,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                CompanyDocumentAuditFilterPreset.values.map((preset) {
                  final selected = preset.isActiveFor(filter);
                  return ChoiceChip(
                    key: Key('company-audit-preset-${preset.name}'),
                    label: Text(preset.label),
                    selected: selected,
                    onSelected: (_) => onPresetSelected(preset),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    selectedColor: HrisColors.primary.withValues(alpha: 0.12),
                    side: BorderSide(
                      color: selected ? HrisColors.primary : HrisColors.border,
                    ),
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(
                      color: selected ? HrisColors.primary : HrisColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                CompanyDocumentAuditTimelineScope.values.map((scope) {
                  final selected = scope == filter.scope;
                  return ChoiceChip(
                    key: Key('company-audit-scope-${scope.name}'),
                    label: Text(scope.label),
                    selected: selected,
                    onSelected: (_) => onScopeChanged(scope),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    selectedColor: HrisColors.primary.withValues(alpha: 0.12),
                    side: BorderSide(
                      color: selected ? HrisColors.primary : HrisColors.border,
                    ),
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(
                      color: selected ? HrisColors.primary : HrisColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AuditSearchField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _AuditSearchField({required this.value, required this.onChanged});

  @override
  State<_AuditSearchField> createState() => _AuditSearchFieldState();
}

class _AuditSearchFieldState extends State<_AuditSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _AuditSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == _controller.text) return;

    _controller.value = TextEditingValue(
      text: widget.value,
      selection: TextSelection.collapsed(offset: widget.value.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasSearch = widget.value.trim().isNotEmpty;

    return TextField(
      key: const Key('company-audit-search-field'),
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon:
            hasSearch
                ? IconButton(
                  tooltip: 'Clear audit search',
                  onPressed: () => widget.onChanged(''),
                  icon: const Icon(Icons.close_rounded),
                )
                : null,
        hintText: 'Search audit events',
        isDense: true,
        filled: true,
        fillColor: HrisColors.surface,
        border: _inputBorder(HrisColors.border),
        enabledBorder: _inputBorder(HrisColors.border),
        focusedBorder: _inputBorder(HrisColors.primary),
      ),
    );
  }
}

OutlineInputBorder _inputBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );
}

class _AuditEventTile extends StatelessWidget {
  final CompanyDocumentAuditEvent event;
  final bool isSelected;
  final VoidCallback onSelected;

  const _AuditEventTile({
    required this.event,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = companyDocumentAuditEventColor(event.type);

    return InkWell(
      key: Key('company-audit-event-${event.id}'),
      borderRadius: BorderRadius.circular(8),
      onTap: onSelected,
      child: HrisListSurface(
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
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const HrisStatusPill(label: 'Selected', color: Colors.indigo),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${event.entityName} - ${event.actorName} - ${_formatDateTime(event.happenedAt)}',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
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
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute';
  }
}
