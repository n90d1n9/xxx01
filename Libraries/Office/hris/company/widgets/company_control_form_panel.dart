import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_control.dart';

class CompanyControlFormPanel extends StatefulWidget {
  final CompanyControlDraft draft;
  final List<String> entities;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<CompanyControlDomain> onDomainChanged;
  final ValueChanged<CompanyControlStatus> onStatusChanged;
  final ValueChanged<CompanyControlSeverity> onSeverityChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onReviewDateChanged;
  final ValueChanged<String> onEvidenceChanged;
  final ValueChanged<String> onRemediationChanged;
  final ValueChanged<String> onLinkedRecordChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyControlFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.onTitleChanged,
    required this.onEntityChanged,
    required this.onDomainChanged,
    required this.onStatusChanged,
    required this.onSeverityChanged,
    required this.onOwnerChanged,
    required this.onReviewDateChanged,
    required this.onEvidenceChanged,
    required this.onRemediationChanged,
    required this.onLinkedRecordChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyControlFormPanel> createState() =>
      _CompanyControlFormPanelState();
}

class _CompanyControlFormPanelState extends State<CompanyControlFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _ownerController;
  late final TextEditingController _reviewDateController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _remediationController;
  late final TextEditingController _linkedRecordController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.title);
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _reviewDateController = TextEditingController(
      text: widget.draft.nextReviewDateText,
    );
    _evidenceController = TextEditingController(
      text: widget.draft.evidenceSummary,
    );
    _remediationController = TextEditingController(
      text: widget.draft.remediationAction,
    );
    _linkedRecordController = TextEditingController(
      text: widget.draft.linkedRecord,
    );
  }

  @override
  void didUpdateWidget(covariant CompanyControlFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_titleController, widget.draft.title);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_reviewDateController, widget.draft.nextReviewDateText);
    _sync(_evidenceController, widget.draft.evidenceSummary);
    _sync(_remediationController, widget.draft.remediationAction);
    _sync(_linkedRecordController, widget.draft.linkedRecord);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _reviewDateController.dispose();
    _evidenceController.dispose();
    _remediationController.dispose();
    _linkedRecordController.dispose();
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

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Company Control Form',
      subtitle: 'Track control evidence, remediation, and review ownership',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-control-title-field'),
                controller: _titleController,
                label: 'Control title',
                icon: Icons.rule_folder_outlined,
                onChanged: widget.onTitleChanged,
                validator:
                    (value) => CompanyControlDraft.validateRequired(
                      value,
                      'control title',
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
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
                                  child: Text(
                                    entity,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (entity) {
                        if (entity != null) widget.onEntityChanged(entity);
                      },
                      validator:
                          (value) => CompanyControlDraft.validateRequired(
                            value,
                            'legal entity',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanyControlDomain>(
                      isExpanded: true,
                      initialValue: widget.draft.domain,
                      decoration: const InputDecoration(
                        labelText: 'Domain',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items:
                          CompanyControlDomain.values
                              .map(
                                (domain) => DropdownMenuItem(
                                  value: domain,
                                  child: Text(
                                    domain.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (domain) {
                        if (domain != null) widget.onDomainChanged(domain);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<CompanyControlStatus>(
                      isExpanded: true,
                      initialValue: widget.draft.status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.task_alt_outlined),
                      ),
                      items:
                          CompanyControlStatus.values
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (status) {
                        if (status != null) widget.onStatusChanged(status);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanyControlSeverity>(
                      isExpanded: true,
                      initialValue: widget.draft.severity,
                      decoration: const InputDecoration(
                        labelText: 'Severity',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.priority_high_outlined),
                      ),
                      items:
                          CompanyControlSeverity.values
                              .map(
                                (severity) => DropdownMenuItem(
                                  value: severity,
                                  child: Text(
                                    severity.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (severity) {
                        if (severity != null) {
                          widget.onSeverityChanged(severity);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-control-owner-field'),
                      controller: _ownerController,
                      label: 'Owner',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onOwnerChanged,
                      validator:
                          (value) => CompanyControlDraft.validateRequired(
                            value,
                            'owner',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-control-review-field'),
                      controller: _reviewDateController,
                      label: 'Next review date',
                      icon: Icons.event_available_outlined,
                      keyboardType: TextInputType.datetime,
                      onChanged: widget.onReviewDateChanged,
                      validator: CompanyControlDraft.validateDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-control-evidence-field'),
                controller: _evidenceController,
                label: 'Evidence summary',
                icon: Icons.attach_file_outlined,
                onChanged: widget.onEvidenceChanged,
                validator:
                    (value) => CompanyControlDraft.validateRequired(
                      value,
                      'evidence summary',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-control-action-field'),
                controller: _remediationController,
                label: 'Remediation action',
                icon: Icons.construction_outlined,
                onChanged: widget.onRemediationChanged,
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-control-linked-field'),
                controller: _linkedRecordController,
                label: 'Linked record',
                icon: Icons.link_outlined,
                onChanged: widget.onLinkedRecordChanged,
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
                    key: const Key('company-control-save-button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.add_task_outlined),
                    label: const Text('Add control'),
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
        hintText: keyboardType == TextInputType.datetime ? 'YYYY-MM-DD' : null,
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
