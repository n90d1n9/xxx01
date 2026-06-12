import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_models.dart';
import '../../models/employee_directory_quality_fix_models.dart';
import '../../models/employee_directory_quality_models.dart';
import 'employee_directory_quality_fix_fields.dart';

/// Remediation workspace for turning detected roster quality issues into fixes.
class EmployeeDirectoryQualityFixPanel extends StatefulWidget {
  final EmployeeDirectoryQualityFixReview review;
  final ValueChanged<String> onIssueSelected;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onManagerChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onJoiningDateChanged;
  final ValueChanged<String> onAuditNoteChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const EmployeeDirectoryQualityFixPanel({
    super.key,
    required this.review,
    required this.onIssueSelected,
    required this.onEmailChanged,
    required this.onPhoneChanged,
    required this.onManagerChanged,
    required this.onDepartmentChanged,
    required this.onLocationChanged,
    required this.onJoiningDateChanged,
    required this.onAuditNoteChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<EmployeeDirectoryQualityFixPanel> createState() =>
      _EmployeeDirectoryQualityFixPanelState();
}

/// Keeps local text controllers synchronized with the selected quality fix draft.
class _EmployeeDirectoryQualityFixPanelState
    extends State<EmployeeDirectoryQualityFixPanel> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _managerController;
  late final TextEditingController _departmentController;
  late final TextEditingController _locationController;
  late final TextEditingController _joiningDateController;
  late final TextEditingController _auditNoteController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.review.draft.email);
    _phoneController = TextEditingController(text: widget.review.draft.phone);
    _managerController = TextEditingController(
      text: widget.review.draft.manager,
    );
    _departmentController = TextEditingController(
      text: widget.review.draft.department,
    );
    _locationController = TextEditingController(
      text: widget.review.draft.location,
    );
    _joiningDateController = TextEditingController(
      text: widget.review.draft.joiningDate,
    );
    _auditNoteController = TextEditingController(
      text: widget.review.draft.auditNote,
    );
  }

  @override
  void didUpdateWidget(EmployeeDirectoryQualityFixPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_emailController, widget.review.draft.email);
    _syncController(_phoneController, widget.review.draft.phone);
    _syncController(_managerController, widget.review.draft.manager);
    _syncController(_departmentController, widget.review.draft.department);
    _syncController(_locationController, widget.review.draft.location);
    _syncController(_joiningDateController, widget.review.draft.joiningDate);
    _syncController(_auditNoteController, widget.review.draft.auditNote);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _managerController.dispose();
    _departmentController.dispose();
    _locationController.dispose();
    _joiningDateController.dispose();
    _auditNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    return HrisSectionPanel(
      key: const ValueKey('employee-directory-quality-fix-panel'),
      icon: Icons.build_circle_outlined,
      title: 'Quality fix workspace',
      subtitle:
          review.hasIssue
              ? '${review.issue!.type.label} for ${review.issue!.employeeName}'
              : 'No roster quality issues ready for remediation',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Open', value: '${review.issueCount}'),
            HrisMetricStripItem(
              label: 'Target',
              value: review.member?.name ?? 'None',
            ),
            HrisMetricStripItem(
              label: 'Fields',
              value: '${review.requiredFieldCount}',
            ),
            HrisMetricStripItem(label: 'Ready', value: review.statusLabel),
          ],
        ),
        if (review.issues.isEmpty)
          const HrisListSurface(
            child: Text('No roster quality issues require a fix right now.'),
          )
        else ...[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                review.issues.take(8).map((issue) {
                  final selected = issue.fixKey == review.selectedIssueKey;
                  return ChoiceChip(
                    key: ValueKey(
                      'employee-directory-quality-fix-issue-${issue.fixKey}',
                    ),
                    selected: selected,
                    avatar: Icon(
                      employeeDirectoryQualityFixIssueIcon(issue.type),
                      size: 18,
                      color: selected ? Colors.white : HrisColors.primary,
                    ),
                    label: Text('${issue.type.label}: ${issue.employeeName}'),
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(
                      color: selected ? Colors.white : HrisColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                    selectedColor: HrisColors.primary,
                    backgroundColor: HrisColors.surfaceSubtle,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color:
                            selected ? HrisColors.primary : HrisColors.border,
                      ),
                    ),
                    onSelected: (_) => widget.onIssueSelected(issue.fixKey),
                  );
                }).toList(),
          ),
          if (review.hasIssue)
            EmployeeDirectoryQualityFixIssueTile(issue: review.issue!)
          else
            const HrisListSurface(child: Text('Select an issue to fix.')),
          ..._buildFields(context, review),
          TextField(
            key: const ValueKey(
              'employee-directory-quality-fix-audit-note-field',
            ),
            controller: _auditNoteController,
            minLines: 2,
            maxLines: 3,
            onChanged: widget.onAuditNoteChanged,
            decoration: const InputDecoration(
              labelText: 'Audit note',
              prefixIcon: Icon(Icons.notes_outlined),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          if (review.errors.isNotEmpty)
            HrisListSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    review.errors
                        .map(
                          (error) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              error,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFFB91C1C),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                key: const ValueKey(
                  'employee-directory-quality-fix-submit-button',
                ),
                onPressed: review.canSubmit ? widget.onSubmit : null,
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Apply fix'),
              ),
              OutlinedButton.icon(
                key: const ValueKey(
                  'employee-directory-quality-fix-clear-button',
                ),
                onPressed: review.draft.hasInput ? widget.onClear : null,
                icon: const Icon(Icons.clear_all_outlined),
                label: const Text('Clear fix'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  List<Widget> _buildFields(
    BuildContext context,
    EmployeeDirectoryQualityFixReview review,
  ) {
    final fields = <Widget>[];
    if (review.requiresEmail) {
      fields.add(
        EmployeeDirectoryQualityFixTextField(
          key: const ValueKey('employee-directory-quality-fix-email-field'),
          controller: _emailController,
          label: 'Correct email',
          icon: Icons.alternate_email_outlined,
          onChanged: widget.onEmailChanged,
        ),
      );
    }
    if (review.requiresPhone) {
      fields.add(
        EmployeeDirectoryQualityFixTextField(
          key: const ValueKey('employee-directory-quality-fix-phone-field'),
          controller: _phoneController,
          label: 'Correct phone',
          icon: Icons.phone_outlined,
          onChanged: widget.onPhoneChanged,
        ),
      );
    }
    if (review.requiresManager) {
      fields.add(
        EmployeeDirectoryQualityFixTextField(
          key: const ValueKey('employee-directory-quality-fix-manager-field'),
          controller: _managerController,
          label: 'Reporting manager',
          icon: Icons.supervisor_account_outlined,
          onChanged: widget.onManagerChanged,
        ),
      );
    }
    if (review.requiresDepartment) {
      fields.add(
        EmployeeDirectoryQualityFixTextField(
          key: const ValueKey(
            'employee-directory-quality-fix-department-field',
          ),
          controller: _departmentController,
          label: 'Department',
          icon: Icons.account_tree_outlined,
          onChanged: widget.onDepartmentChanged,
        ),
      );
    }
    if (review.requiresLocation) {
      fields.add(
        EmployeeDirectoryQualityFixTextField(
          key: const ValueKey('employee-directory-quality-fix-location-field'),
          controller: _locationController,
          label: 'Work location',
          icon: Icons.location_city_outlined,
          onChanged: widget.onLocationChanged,
        ),
      );
    }
    if (review.requiresJoiningDate) {
      fields.add(
        EmployeeDirectoryQualityFixTextField(
          key: const ValueKey(
            'employee-directory-quality-fix-joining-date-field',
          ),
          controller: _joiningDateController,
          label: 'Joining date (YYYY-MM-DD)',
          icon: Icons.event_outlined,
          onChanged: widget.onJoiningDateChanged,
        ),
      );
    }

    if (fields.isEmpty) return const [];

    return [
      LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 820 || fields.length == 1) {
            return Column(
              children:
                  fields
                      .map(
                        (field) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: field,
                        ),
                      )
                      .toList(),
            );
          }

          final rows = <Widget>[];
          for (var index = 0; index < fields.length; index += 2) {
            rows.add(
              Row(
                children: [
                  Expanded(child: fields[index]),
                  if (index + 1 < fields.length) ...[
                    const SizedBox(width: 12),
                    Expanded(child: fields[index + 1]),
                  ] else
                    const Spacer(),
                ],
              ),
            );
          }

          return Column(
            children:
                rows
                    .map(
                      (row) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: row,
                      ),
                    )
                    .toList(),
          );
        },
      ),
    ];
  }
}

@Preview(name: 'Employee quality fix panel')
Widget employeeDirectoryQualityFixPanelPreview() {
  final member = EmployeeDirectoryMember(
    id: '2',
    name: 'Maya Santoso',
    position: 'People Operations Lead',
    department: 'People',
    avatarUrl: '',
    email: 'maya@example.com',
    phone: '+62 812 0000 2002',
    joiningDate: DateTime(2023, 4, 3),
    performance: 4.4,
    location: 'Jakarta',
    manager: 'Alya Rahman',
    status: EmployeeDirectoryStatus.active,
  );
  const issue = EmployeeDirectoryQualityIssue(
    type: EmployeeDirectoryQualityIssueType.duplicateEmail,
    severity: EmployeeDirectoryQualitySeverity.critical,
    employeeId: '2',
    employeeName: 'Maya Santoso',
    detail: 'maya@example.com appears on more than one profile.',
  );
  final review = EmployeeDirectoryQualityFixReview.fromState(
    report: EmployeeDirectoryQualityReport(members: [member], issues: [issue]),
    members: [member],
    draft: const EmployeeDirectoryQualityFixDraft(
      issueKey: '2:duplicateEmail',
      email: 'maya.fixed@example.com',
      auditNote: 'Correct duplicate email.',
    ),
    asOfDate: DateTime(2026, 6, 9),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryQualityFixPanel(
          review: review,
          onIssueSelected: (_) {},
          onEmailChanged: (_) {},
          onPhoneChanged: (_) {},
          onManagerChanged: (_) {},
          onDepartmentChanged: (_) {},
          onLocationChanged: (_) {},
          onJoiningDateChanged: (_) {},
          onAuditNoteChanged: (_) {},
          onSubmit: () {},
          onClear: () {},
        ),
      ),
    ),
  );
}

void _syncController(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.text = value;
}
