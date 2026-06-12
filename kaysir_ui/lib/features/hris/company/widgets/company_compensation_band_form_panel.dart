import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_compensation_band.dart';

class CompanyCompensationBandFormPanel extends StatefulWidget {
  final CompanyCompensationBandDraft draft;
  final List<String> entities;
  final ValueChanged<String> onBandCodeChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<CompanyCompensationBandFamily> onFamilyChanged;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<CompanyCompensationBandStatus> onStatusChanged;
  final ValueChanged<String> onMinSalaryChanged;
  final ValueChanged<String> onMidpointSalaryChanged;
  final ValueChanged<String> onMaxSalaryChanged;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onApproverChanged;
  final ValueChanged<String> onEffectiveDateChanged;
  final ValueChanged<String> onNextReviewChanged;
  final ValueChanged<String> onLinkedPolicyChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyCompensationBandFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.onBandCodeChanged,
    required this.onEntityChanged,
    required this.onFamilyChanged,
    required this.onLevelChanged,
    required this.onStatusChanged,
    required this.onMinSalaryChanged,
    required this.onMidpointSalaryChanged,
    required this.onMaxSalaryChanged,
    required this.onCurrencyChanged,
    required this.onOwnerChanged,
    required this.onApproverChanged,
    required this.onEffectiveDateChanged,
    required this.onNextReviewChanged,
    required this.onLinkedPolicyChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyCompensationBandFormPanel> createState() =>
      _CompanyCompensationBandFormPanelState();
}

class _CompanyCompensationBandFormPanelState
    extends State<CompanyCompensationBandFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _levelController;
  late final TextEditingController _minController;
  late final TextEditingController _midpointController;
  late final TextEditingController _maxController;
  late final TextEditingController _currencyController;
  late final TextEditingController _ownerController;
  late final TextEditingController _approverController;
  late final TextEditingController _effectiveController;
  late final TextEditingController _reviewController;
  late final TextEditingController _policyController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.draft.bandCode);
    _levelController = TextEditingController(text: widget.draft.levelName);
    _minController = TextEditingController(text: widget.draft.minSalaryText);
    _midpointController = TextEditingController(
      text: widget.draft.midpointSalaryText,
    );
    _maxController = TextEditingController(text: widget.draft.maxSalaryText);
    _currencyController = TextEditingController(text: widget.draft.currency);
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _approverController = TextEditingController(
      text: widget.draft.approverName,
    );
    _effectiveController = TextEditingController(
      text: widget.draft.effectiveDateText,
    );
    _reviewController = TextEditingController(
      text: widget.draft.nextReviewDateText,
    );
    _policyController = TextEditingController(text: widget.draft.linkedPolicy);
  }

  @override
  void didUpdateWidget(covariant CompanyCompensationBandFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_codeController, widget.draft.bandCode);
    _sync(_levelController, widget.draft.levelName);
    _sync(_minController, widget.draft.minSalaryText);
    _sync(_midpointController, widget.draft.midpointSalaryText);
    _sync(_maxController, widget.draft.maxSalaryText);
    _sync(_currencyController, widget.draft.currency);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_approverController, widget.draft.approverName);
    _sync(_effectiveController, widget.draft.effectiveDateText);
    _sync(_reviewController, widget.draft.nextReviewDateText);
    _sync(_policyController, widget.draft.linkedPolicy);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _levelController.dispose();
    _minController.dispose();
    _midpointController.dispose();
    _maxController.dispose();
    _currencyController.dispose();
    _ownerController.dispose();
    _approverController.dispose();
    _effectiveController.dispose();
    _reviewController.dispose();
    _policyController.dispose();
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
      icon: Icons.price_change_outlined,
      title: 'Compensation Band Form',
      subtitle: 'Manage salary ranges, levels, approvals, and reviews',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-band-code-field'),
                      controller: _codeController,
                      label: 'Band code',
                      icon: Icons.sell_outlined,
                      onChanged: widget.onBandCodeChanged,
                      validator:
                          (value) =>
                              CompanyCompensationBandDraft.validateRequired(
                                value,
                                'band code',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-band-level-field'),
                      controller: _levelController,
                      label: 'Level name',
                      icon: Icons.stacked_bar_chart_outlined,
                      onChanged: widget.onLevelChanged,
                      validator:
                          (value) =>
                              CompanyCompensationBandDraft.validateRequired(
                                value,
                                'level name',
                              ),
                    ),
                  ),
                ],
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
                          (value) =>
                              CompanyCompensationBandDraft.validateRequired(
                                value,
                                'legal entity',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        DropdownButtonFormField<CompanyCompensationBandFamily>(
                          isExpanded: true,
                          initialValue: widget.draft.family,
                          decoration: const InputDecoration(
                            labelText: 'Family',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items:
                              CompanyCompensationBandFamily.values
                                  .map(
                                    (family) => DropdownMenuItem(
                                      value: family,
                                      child: Text(
                                        family.label,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (family) {
                            if (family != null) {
                              widget.onFamilyChanged(family);
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
                    child:
                        DropdownButtonFormField<CompanyCompensationBandStatus>(
                          isExpanded: true,
                          initialValue: widget.draft.status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.task_alt_outlined),
                          ),
                          items:
                              CompanyCompensationBandStatus.values
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
                    child: _TextInput(
                      key: const Key('company-band-currency-field'),
                      controller: _currencyController,
                      label: 'Currency',
                      icon: Icons.payments_outlined,
                      onChanged: widget.onCurrencyChanged,
                      validator:
                          (value) =>
                              CompanyCompensationBandDraft.validateRequired(
                                value,
                                'currency',
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-band-min-field'),
                      controller: _minController,
                      label: 'Minimum',
                      icon: Icons.arrow_downward_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onMinSalaryChanged,
                      validator:
                          (value) =>
                              CompanyCompensationBandDraft.validatePositiveInt(
                                value,
                                'minimum',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-band-midpoint-field'),
                      controller: _midpointController,
                      label: 'Midpoint',
                      icon: Icons.remove_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onMidpointSalaryChanged,
                      validator:
                          (value) =>
                              CompanyCompensationBandDraft.validatePositiveInt(
                                value,
                                'midpoint',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-band-max-field'),
                      controller: _maxController,
                      label: 'Maximum',
                      icon: Icons.arrow_upward_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onMaxSalaryChanged,
                      validator:
                          (value) =>
                              CompanyCompensationBandDraft.validatePositiveInt(
                                value,
                                'maximum',
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-band-owner-field'),
                      controller: _ownerController,
                      label: 'Owner',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onOwnerChanged,
                      validator:
                          (value) =>
                              CompanyCompensationBandDraft.validateRequired(
                                value,
                                'owner',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-band-approver-field'),
                      controller: _approverController,
                      label: 'Approver',
                      icon: Icons.verified_outlined,
                      onChanged: widget.onApproverChanged,
                      validator:
                          (value) =>
                              CompanyCompensationBandDraft.validateRequired(
                                value,
                                'approver',
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-band-effective-field'),
                      controller: _effectiveController,
                      label: 'Effective (YYYY-MM-DD)',
                      icon: Icons.event_available_outlined,
                      onChanged: widget.onEffectiveDateChanged,
                      validator: CompanyCompensationBandDraft.validateDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-band-review-field'),
                      controller: _reviewController,
                      label: 'Next review (YYYY-MM-DD)',
                      icon: Icons.event_outlined,
                      onChanged: widget.onNextReviewChanged,
                      validator: CompanyCompensationBandDraft.validateDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-band-policy-field'),
                controller: _policyController,
                label: 'Linked policy',
                icon: Icons.policy_outlined,
                onChanged: widget.onLinkedPolicyChanged,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onClear,
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    key: const Key('company-band-save-button'),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        widget.onSubmit();
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save band'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
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
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _TextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.validator,
    this.keyboardType,
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
      validator: validator,
      onChanged: onChanged,
    );
  }
}
