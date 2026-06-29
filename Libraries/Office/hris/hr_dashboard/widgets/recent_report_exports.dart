import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_export_clear_finished_confirmation.dart';
import '../models/report_export_queue_date_section.dart';
import '../models/report_export_queue_empty_guidance.dart';
import '../models/report_export_queue_filter.dart';
import '../models/report_export_queue_health_insight.dart';
import '../models/report_export_queue_result_summary.dart';
import '../models/report_export_queue_search_query.dart';
import '../models/report_export_queue_sort.dart';
import '../models/report_export_queue_summary.dart';
import '../models/report_generation_job.dart';
import 'recent_report_clear_finished_dialog.dart';
import 'recent_report_export_date_header.dart';
import 'recent_report_export_empty_state.dart';
import 'recent_report_export_health_card.dart';
import 'recent_report_export_queue_controls.dart';
import 'recent_report_export_result_bar.dart';
import 'recent_report_export_section_controls.dart';
import 'recent_report_export_summary_strip.dart';
import 'recent_report_export_tile.dart';
import 'recent_report_exports_header.dart';

class RecentReportExports extends StatefulWidget {
  final List<ReportGenerationJob> jobs;
  final ValueChanged<ReportGenerationJob>? onDownload;
  final ValueChanged<List<ReportGenerationJob>>? onDownloadReady;
  final ValueChanged<ReportGenerationJob>? onRetry;
  final VoidCallback? onRetryFailed;
  final VoidCallback? onClearFinished;

  const RecentReportExports({
    super.key,
    required this.jobs,
    this.onDownload,
    this.onDownloadReady,
    this.onRetry,
    this.onRetryFailed,
    this.onClearFinished,
  });

  @override
  State<RecentReportExports> createState() => _RecentReportExportsState();
}

class _RecentReportExportsState extends State<RecentReportExports> {
  ReportExportQueueFilter _filter = ReportExportQueueFilter.all;
  ReportExportQueueSort _sort = ReportExportQueueSort.newest;
  String _searchText = '';
  final Set<String> _collapsedSectionKeys = <String>{};

  @override
  void didUpdateWidget(covariant RecentReportExports oldWidget) {
    super.didUpdateWidget(oldWidget);
    _filter = _normalizeFilter(widget.jobs);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.jobs.isEmpty) return const SizedBox.shrink();

    final summary = ReportExportQueueSummary.fromJobs(widget.jobs);
    final selectedFilter = _normalizeFilter(widget.jobs, summary: summary);
    final healthInsight = ReportExportQueueHealthInsight.fromSummary(summary);
    final searchQuery = ReportExportQueueSearchQuery(_searchText);
    final filteredJobs = selectedFilter.apply(widget.jobs);
    final visibleJobs = _sort.apply(searchQuery.apply(filteredJobs));
    final dateSections = ReportExportQueueDateSection.fromJobs(visibleJobs);
    final visibleSectionKeys = _sectionKeys(dateSections);
    final collapsedSectionCount = _collapsedSectionCount(visibleSectionKeys);
    final emptyGuidance = ReportExportQueueEmptyGuidance(
      filter: selectedFilter,
      searchQuery: searchQuery,
    );
    final resultSummary = ReportExportQueueResultSummary(
      totalCount: widget.jobs.length,
      visibleCount: visibleJobs.length,
      filter: selectedFilter,
      searchQuery: searchQuery,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: hrisPanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecentReportExportsHeader(
            summary: summary,
            onDownloadReady:
                widget.onDownloadReady == null ? null : _downloadReady,
            onRetryFailed: widget.onRetryFailed,
            onClearFinished:
                widget.onClearFinished == null
                    ? null
                    : () => _requestClearFinished(summary),
          ),
          const SizedBox(height: 12),
          RecentReportExportSummaryStrip(summary: summary),
          const SizedBox(height: 12),
          RecentReportExportHealthCard(
            insight: healthInsight,
            onFocusFilter: _healthFocusHandler(
              summary: summary,
              selectedFilter: selectedFilter,
              insight: healthInsight,
            ),
          ),
          if (summary.hasMultipleStatusGroups || summary.total > 1) ...[
            const SizedBox(height: 12),
            RecentReportExportQueueControls(
              summary: summary,
              selectedFilter: selectedFilter,
              onFilterSelected: (filter) {
                setState(() => _filter = filter);
              },
              selectedSort: _sort,
              onSortSelected: (sort) {
                setState(() => _sort = sort);
              },
              searchText: _searchText,
              onSearchChanged: (value) {
                setState(() => _searchText = value);
              },
            ),
            if (resultSummary.isActive) ...[
              const SizedBox(height: 10),
              RecentReportExportResultBar(
                summary: resultSummary,
                onClearFilter: _clearFilter,
                onClearSearch: _clearSearch,
                onClearAll: _clearConstraints,
              ),
            ],
          ],
          const SizedBox(height: 12),
          if (visibleJobs.isEmpty)
            RecentReportExportEmptyState(
              guidance: emptyGuidance,
              onClearFilter: _clearFilter,
              onClearSearch: _clearSearch,
              onClearAll: _clearConstraints,
            )
          else ...[
            if (dateSections.length > 1) ...[
              RecentReportExportSectionControls(
                sectionCount: dateSections.length,
                collapsedCount: collapsedSectionCount,
                onCollapseAll: () => _collapseSections(visibleSectionKeys),
                onExpandAll: () => _expandSections(visibleSectionKeys),
              ),
              const SizedBox(height: 12),
            ],
            ..._spacedDateSections(dateSections),
          ],
        ],
      ),
    );
  }

  List<Widget> _spacedDateSections(
    List<ReportExportQueueDateSection> sections,
  ) {
    final sectionWidgets = <Widget>[];

    for (var sectionIndex = 0; sectionIndex < sections.length; sectionIndex++) {
      final section = sections[sectionIndex];
      final sectionKey = _sectionKey(section, sectionIndex);
      final isExpanded = !_collapsedSectionKeys.contains(sectionKey);
      if (sectionIndex > 0) sectionWidgets.add(const SizedBox(height: 14));
      sectionWidgets.add(
        RecentReportExportDateHeader(
          label: section.label,
          countLabel: section.countLabel,
          statusCounts: section.statusCounts,
          keySuffix: sectionKey,
          isExpanded: isExpanded,
          downloadReadyLabel: section.downloadReadyLabel,
          retryFailedLabel: section.retryFailedLabel,
          onToggleExpanded: () => _toggleSection(sectionKey),
          onDownloadReady: _sectionDownloadReady(section),
          onRetryFailed: _sectionRetryFailed(section),
        ),
      );

      if (!isExpanded) continue;

      for (final job in section.jobs) {
        sectionWidgets.add(const SizedBox(height: 10));
        sectionWidgets.add(
          RecentReportExportTile(
            job: job,
            onDownload: widget.onDownload,
            onRetry: widget.onRetry,
          ),
        );
      }
    }

    return sectionWidgets;
  }

  void _toggleSection(String sectionKey) {
    setState(() {
      if (!_collapsedSectionKeys.remove(sectionKey)) {
        _collapsedSectionKeys.add(sectionKey);
      }
    });
  }

  void _collapseSections(Iterable<String> sectionKeys) {
    setState(() => _collapsedSectionKeys.addAll(sectionKeys));
  }

  void _expandSections(Iterable<String> sectionKeys) {
    setState(() {
      for (final sectionKey in sectionKeys) {
        _collapsedSectionKeys.remove(sectionKey);
      }
    });
  }

  VoidCallback? _sectionDownloadReady(ReportExportQueueDateSection section) {
    final onDownloadReady = widget.onDownloadReady;
    if (onDownloadReady == null || !section.hasDownloadableExports) {
      return null;
    }

    return () => onDownloadReady(section.readyJobs);
  }

  VoidCallback? _sectionRetryFailed(ReportExportQueueDateSection section) {
    final onRetry = widget.onRetry;
    if (onRetry == null || !section.hasRetryableExports) return null;

    return () {
      for (final job in section.retryableJobs) {
        onRetry(job);
      }
    };
  }

  void _downloadReady() {
    final onDownloadReady = widget.onDownloadReady;
    if (onDownloadReady == null) return;

    final readyJobs = [
      for (final job in widget.jobs)
        if (job.canDownload) job,
    ];
    if (readyJobs.isEmpty) return;

    onDownloadReady(readyJobs);
  }

  void _requestClearFinished(ReportExportQueueSummary summary) {
    unawaited(_confirmClearFinished(summary));
  }

  void _clearFilter() {
    setState(() => _filter = ReportExportQueueFilter.all);
  }

  void _clearSearch() {
    setState(() => _searchText = '');
  }

  void _clearConstraints() {
    setState(() {
      _filter = ReportExportQueueFilter.all;
      _searchText = '';
    });
  }

  ValueChanged<ReportExportQueueFilter>? _healthFocusHandler({
    required ReportExportQueueSummary summary,
    required ReportExportQueueFilter selectedFilter,
    required ReportExportQueueHealthInsight insight,
  }) {
    final suggestedFilter = insight.suggestedFilter;
    if (!summary.hasMultipleStatusGroups ||
        suggestedFilter == null ||
        suggestedFilter == selectedFilter) {
      return null;
    }

    return (filter) {
      setState(() => _filter = filter);
    };
  }

  Future<void> _confirmClearFinished(ReportExportQueueSummary summary) async {
    final onClearFinished = widget.onClearFinished;
    if (onClearFinished == null || !summary.hasFinishedExports) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return RecentReportClearFinishedDialog(
          confirmation: ReportExportClearFinishedConfirmation.fromSummary(
            summary,
          ),
        );
      },
    );

    if (!mounted || confirmed != true) return;
    onClearFinished();
  }

  ReportExportQueueFilter _normalizeFilter(
    List<ReportGenerationJob> jobs, {
    ReportExportQueueSummary? summary,
  }) {
    if (jobs.isEmpty) return ReportExportQueueFilter.all;

    return ReportExportQueueFilter.normalize(
      selected: _filter,
      summary: summary ?? ReportExportQueueSummary.fromJobs(jobs),
    );
  }

  String _sectionKey(ReportExportQueueDateSection section, int sectionIndex) {
    final date = section.date;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day-$sectionIndex';
  }

  List<String> _sectionKeys(List<ReportExportQueueDateSection> sections) {
    return [
      for (final (index, section) in sections.indexed)
        _sectionKey(section, index),
    ];
  }

  int _collapsedSectionCount(Iterable<String> sectionKeys) {
    return sectionKeys.where(_collapsedSectionKeys.contains).length;
  }
}
