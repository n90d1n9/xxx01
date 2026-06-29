import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_filter_models.dart';
import '../models/holiday_models.dart';
import '../states/holiday_provider.dart';
import '../widgets/holiday_audit_trail_panel.dart';
import '../widgets/holiday_calendar_panel.dart';
import '../widgets/holiday_communication_panel.dart';
import '../widgets/holiday_coverage_planner_panel.dart';
import '../widgets/holiday_discovery_panel.dart';
import '../widgets/holiday_form_panel.dart';
import '../widgets/holiday_policy_review_panel.dart';
import '../widgets/holiday_publish_readiness_panel.dart';
import '../widgets/holiday_release_approval_panel.dart';
import '../widgets/holiday_release_package_panel.dart';
import '../widgets/holiday_summary_grid.dart';
import '../widgets/holiday_timeline_panel.dart';
import '../widgets/holiday_workforce_impact_panel.dart';

class HolidayManagementScreen extends ConsumerStatefulWidget {
  const HolidayManagementScreen({super.key});

  @override
  ConsumerState<HolidayManagementScreen> createState() =>
      _HolidayManagementScreenState();
}

class _HolidayManagementScreenState
    extends ConsumerState<HolidayManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _observedDateController = TextEditingController();
  final _scopeController = TextEditingController();
  final _descriptionController = TextEditingController();
  HolidayType _selectedType = HolidayType.custom;
  HolidayRecord? _editingHoliday;
  bool _isFormVisible = false;
  bool _isPaid = true;
  bool _isRecurring = false;
  bool _requiresCoveragePlan = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _observedDateController.dispose();
    _scopeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(holidaySummaryProvider);
    final publishReadiness = ref.watch(holidayPublishReadinessProvider);
    final releaseApprovalPlan = ref.watch(holidayReleaseApprovalPlanProvider);
    final releasePackage = ref.watch(holidayReleasePackageProvider);
    final timeline = ref.watch(holidayTimelineProvider);
    final workforceImpact = ref.watch(holidayWorkforceImpactProvider);
    final coveragePlan = ref.watch(holidayCoveragePlanProvider);
    final policyReview = ref.watch(holidayPolicyReviewProvider);
    final communicationPlan = ref.watch(holidayCommunicationPlanProvider);
    final auditSummary = ref.watch(holidayAuditSummaryProvider);
    final selectedFilter = ref.watch(selectedHolidayTypeProvider);
    final selectedQuickView = ref.watch(selectedHolidayQuickViewProvider);
    final searchQuery = ref.watch(holidaySearchQueryProvider);
    final viewCounts = ref.watch(holidayCalendarViewCountsProvider);
    final holidays = ref.watch(filteredHolidayRecordsProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Holiday Management'),
        actions: [
          IconButton(
            tooltip: 'Add holiday',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showCreateForm,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HolidayCommandPanel(onAddHoliday: _showCreateForm),
              const SizedBox(height: 16),
              HolidaySummaryGrid(summary: summary),
              const SizedBox(height: 16),
              HolidayPublishReadinessPanel(readiness: publishReadiness),
              const SizedBox(height: 16),
              HolidayReleaseApprovalPanel(
                plan: releaseApprovalPlan,
                onApprove: (stepId) {
                  ref
                      .read(holidayReleaseApprovalDecisionsProvider.notifier)
                      .approveStep(stepId);
                },
                onRevoke: (stepId) {
                  ref
                      .read(holidayReleaseApprovalDecisionsProvider.notifier)
                      .revokeStep(stepId);
                },
              ),
              const SizedBox(height: 16),
              HolidayReleasePackagePanel(package: releasePackage),
              const SizedBox(height: 16),
              HolidayTimelinePanel(timeline: timeline),
              const SizedBox(height: 16),
              HolidayWorkforceImpactPanel(impact: workforceImpact),
              const SizedBox(height: 16),
              HolidayCoveragePlannerPanel(plan: coveragePlan),
              const SizedBox(height: 16),
              HolidayPolicyReviewPanel(review: policyReview),
              const SizedBox(height: 16),
              HolidayCommunicationPanel(plan: communicationPlan),
              const SizedBox(height: 16),
              HolidayAuditTrailPanel(summary: auditSummary),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child:
                    _isFormVisible
                        ? Padding(
                          key: const ValueKey('holiday-form'),
                          padding: const EdgeInsets.only(top: 16),
                          child: HolidayFormPanel(
                            formKey: _formKey,
                            nameController: _nameController,
                            dateController: _dateController,
                            observedDateController: _observedDateController,
                            scopeController: _scopeController,
                            descriptionController: _descriptionController,
                            selectedType: _selectedType,
                            isPaid: _isPaid,
                            isRecurring: _isRecurring,
                            requiresCoveragePlan: _requiresCoveragePlan,
                            isEditing: _editingHoliday != null,
                            onTypeChanged: (type) {
                              if (type == null) return;
                              setState(() => _selectedType = type);
                            },
                            onPaidChanged:
                                (value) => setState(() => _isPaid = value),
                            onRecurringChanged:
                                (value) => setState(() => _isRecurring = value),
                            onCoverageChanged:
                                (value) => setState(
                                  () => _requiresCoveragePlan = value,
                                ),
                            onSubmit: _submitHoliday,
                            onCancel: _resetForm,
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              HolidayDiscoveryPanel(
                searchQuery: searchQuery,
                selectedQuickView: selectedQuickView,
                viewCounts: viewCounts,
                selectedType: selectedFilter,
                summary: summary,
                onSearchChanged: (query) {
                  ref.read(holidaySearchQueryProvider.notifier).state = query;
                },
                onQuickViewChanged: (view) {
                  ref.read(selectedHolidayQuickViewProvider.notifier).state =
                      view;
                },
                onTypeChanged: (type) {
                  ref.read(selectedHolidayTypeProvider.notifier).state = type;
                },
                onClearFilters: _clearDiscoveryFilters,
              ),
              const SizedBox(height: 16),
              HolidayCalendarPanel(
                holidays: holidays,
                onEdit: _editHoliday,
                onDelete: _deleteHoliday,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateForm() {
    _resetControllers();
    setState(() {
      _isFormVisible = true;
      _editingHoliday = null;
      _selectedType = HolidayType.custom;
      _isPaid = true;
      _isRecurring = false;
      _requiresCoveragePlan = false;
    });
  }

  void _editHoliday(HolidayRecord holiday) {
    _nameController.text = holiday.name;
    _dateController.text = _formatIsoDate(holiday.date);
    _observedDateController.text =
        holiday.observedDate == null
            ? ''
            : _formatIsoDate(holiday.observedDate!);
    _scopeController.text = holiday.scope;
    _descriptionController.text = holiday.description;
    setState(() {
      _editingHoliday = holiday;
      _selectedType = holiday.type;
      _isPaid = holiday.isPaid;
      _isRecurring = holiday.isRecurring;
      _requiresCoveragePlan = holiday.requiresCoveragePlan;
      _isFormVisible = true;
    });
  }

  void _deleteHoliday(HolidayRecord holiday) {
    ref.read(holidayRecordsProvider.notifier).deleteHoliday(holiday.id);
    if (_editingHoliday?.id == holiday.id) _resetForm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${holiday.name} removed from calendar')),
    );
  }

  void _submitHoliday() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final observedText = _observedDateController.text.trim();
    final holiday = HolidayRecord(
      id:
          _editingHoliday?.id ??
          'holiday-${DateTime.now().microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      type: _selectedType,
      date: DateTime.parse(_dateController.text.trim()),
      observedDate: observedText.isEmpty ? null : DateTime.parse(observedText),
      scope: _scopeController.text.trim(),
      description: _descriptionController.text.trim(),
      isPaid: _isPaid,
      isRecurring: _isRecurring,
      requiresCoveragePlan: _requiresCoveragePlan,
    );

    final notifier = ref.read(holidayRecordsProvider.notifier);
    if (_editingHoliday == null) {
      notifier.addHoliday(holiday);
    } else {
      notifier.updateHoliday(holiday);
    }

    final action = _editingHoliday == null ? 'added' : 'updated';
    _resetForm();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${holiday.name} $action')));
  }

  void _resetForm() {
    _resetControllers();
    setState(() {
      _editingHoliday = null;
      _isFormVisible = false;
      _selectedType = HolidayType.custom;
      _isPaid = true;
      _isRecurring = false;
      _requiresCoveragePlan = false;
    });
  }

  void _resetControllers() {
    _nameController.clear();
    _dateController.clear();
    _observedDateController.clear();
    _scopeController.text = 'All employees';
    _descriptionController.clear();
  }

  void _clearDiscoveryFilters() {
    ref.read(holidaySearchQueryProvider.notifier).state = '';
    ref.read(selectedHolidayQuickViewProvider.notifier).state =
        HolidayCalendarQuickView.all;
    ref.read(selectedHolidayTypeProvider.notifier).state = null;
  }
}

class _HolidayCommandPanel extends StatelessWidget {
  final VoidCallback onAddHoliday;

  const _HolidayCommandPanel({required this.onAddHoliday});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: hrisPanelDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final heading = Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: HrisColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  color: HrisColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Holiday Calendar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage national, fixed, anniversary, and custom days',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          );
          final action = FilledButton.icon(
            onPressed: onAddHoliday,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add holiday'),
          );

          if (constraints.maxWidth < 720) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [heading, const SizedBox(height: 14), action],
            );
          }

          return Row(
            children: [
              Expanded(child: heading),
              const SizedBox(width: 16),
              action,
            ],
          );
        },
      ),
    );
  }
}

String _formatIsoDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
