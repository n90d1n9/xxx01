import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_approval_rule.dart';

class CompanyApprovalRuleFormPanel extends StatefulWidget {
  final CompanyApprovalRuleDraft draft;
  final List<String> entities;
  final List<String> scopes;
  final ValueChanged<CompanyApprovalDomain> onDomainChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<String> onScopeChanged;
  final ValueChanged<String> onApproverChanged;
  final ValueChanged<String> onBackupChanged;
  final ValueChanged<String> onThresholdChanged;
  final ValueChanged<String> onSlaChanged;
  final ValueChanged<CompanyApprovalRuleStatus> onStatusChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyApprovalRuleFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.scopes,
    required this.onDomainChanged,
    required this.onEntityChanged,
    required this.onScopeChanged,
    required this.onApproverChanged,
    required this.onBackupChanged,
    required this.onThresholdChanged,
    required this.onSlaChanged,
    required this.onStatusChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyApprovalRuleFormPanel> createState() =>
      _CompanyApprovalRuleFormPanelState();
}

class _CompanyApprovalRuleFormPanelState
    extends State<CompanyApprovalRuleFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _approverController;
  late final TextEditingController _backupController;
  late final TextEditingController _thresholdController;
  late final TextEditingController _slaController;

  @override
  void initState() {
    super.initState();
    _approverController = TextEditingController(
      text: widget.draft.approverRole,
    );
    _backupController = TextEditingController(
      text: widget.draft.backupApproverRole,
    );
    _thresholdController = TextEditingController(
      text: widget.draft.thresholdLabel,
    );
    _slaController = TextEditingController(text: widget.draft.slaHoursText);
  }

  @override
  void didUpdateWidget(covariant CompanyApprovalRuleFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_approverController, widget.draft.approverRole);
    _sync(_backupController, widget.draft.backupApproverRole);
    _sync(_thresholdController, widget.draft.thresholdLabel);
    _sync(_slaController, widget.draft.slaHoursText);
  }

  @override
  void dispose() {
    _approverController.dispose();
    _backupController.dispose();
    _thresholdController.dispose();
    _slaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectableEntities =
        widget.entities.where((entity) => entity != 'All').toList();
    final selectedEntity =
        selectableEntities.contains(widget.draft.entityName)
            ? widget.draft.entityName
            : selectableEntities.firstOrNull;
    final selectedScope =
        widget.scopes.contains(widget.draft.scopeName)
            ? widget.draft.scopeName
            : null;

    return HrisSectionPanel(
      icon: Icons.route_outlined,
      title: 'Approval Rule Form',
      subtitle: 'Configure approvals for HR and payroll workflows',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<CompanyApprovalDomain>(
                initialValue: widget.draft.domain,
                decoration: const InputDecoration(
                  labelText: 'Domain',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.rule_outlined),
                ),
                items:
                    CompanyApprovalDomain.values
                        .map(
                          (domain) => DropdownMenuItem(
                            value: domain,
                            child: Text(domain.label),
                          ),
                        )
                        .toList(),
                onChanged: (domain) {
                  if (domain != null) widget.onDomainChanged(domain);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedEntity,
                decoration: const InputDecoration(
                  labelText: 'Legal entity',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                items:
                    selectableEntities
                        .map(
                          (entity) => DropdownMenuItem(
                            value: entity,
                            child: Text(entity),
                          ),
                        )
                        .toList(),
                onChanged: (entity) {
                  if (entity != null) widget.onEntityChanged(entity);
                },
                validator:
                    (value) => CompanyApprovalRuleDraft.validateRequired(
                      value,
                      'legal entity',
                    ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedScope,
                decoration: const InputDecoration(
                  labelText: 'Scope',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_tree_outlined),
                ),
                items:
                    widget.scopes
                        .map(
                          (scope) => DropdownMenuItem(
                            value: scope,
                            child: Text(scope),
                          ),
                        )
                        .toList(),
                onChanged: (scope) {
                  if (scope != null) widget.onScopeChanged(scope);
                },
                validator:
                    (value) => CompanyApprovalRuleDraft.validateRequired(
                      value,
                      'scope',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-approval-approver-field'),
                controller: _approverController,
                label: 'Approver role',
                icon: Icons.verified_user_outlined,
                onChanged: widget.onApproverChanged,
                validator:
                    (value) => CompanyApprovalRuleDraft.validateRequired(
                      value,
                      'approver',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-approval-backup-field'),
                controller: _backupController,
                label: 'Backup approver',
                icon: Icons.people_alt_outlined,
                onChanged: widget.onBackupChanged,
                validator:
                    (value) => CompanyApprovalRuleDraft.validateRequired(
                      value,
                      'backup approver',
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-approval-threshold-field'),
                      controller: _thresholdController,
                      label: 'Threshold',
                      icon: Icons.tune_outlined,
                      onChanged: widget.onThresholdChanged,
                      validator:
                          (value) => CompanyApprovalRuleDraft.validateRequired(
                            value,
                            'threshold',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-approval-sla-field'),
                      controller: _slaController,
                      label: 'SLA hours',
                      icon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onSlaChanged,
                      validator: CompanyApprovalRuleDraft.validateSlaHours,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CompanyApprovalRuleStatus>(
                initialValue: widget.draft.status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items:
                    CompanyApprovalRuleStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.label),
                          ),
                        )
                        .toList(),
                onChanged: (status) {
                  if (status != null) widget.onStatusChanged(status);
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.onClear,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    key: const Key('company-approval-save-button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.add_task_outlined),
                    label: const Text('Add rule'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit();
    }
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  const _TextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
