import 'package:flutter/material.dart';

import '../models/accounting_policy_profile.dart';
import '../models/financial_report_tax_profile.dart';

class AccountingPolicyHeader extends StatelessWidget {
  final AccountingPolicyProfile profile;
  final FinancialReportTaxProfile taxProfile;
  final int reviewCount;

  const AccountingPolicyHeader({
    required this.profile,
    required this.taxProfile,
    required this.reviewCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent =
        reviewCount == 0 ? Colors.teal.shade700 : Colors.orange.shade700;

    return _PolicySurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 700;
              final title = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PolicyIcon(
                    icon: Icons.policy_rounded,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Accounting Policy Center',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${profile.entityName} | ${profile.framework.frameworkName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final status = AccountingPolicyStatusBadge(
                label: reviewCount == 0 ? 'Ready' : '$reviewCount review',
                color: accent,
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 12), status],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 16),
                  status,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AccountingPolicyStatusBadge(
                label: profile.presentationCurrency,
                color: colorScheme.primary,
              ),
              AccountingPolicyStatusBadge(
                label: profile.closeCadence.label,
                color: Colors.blueGrey,
              ),
              AccountingPolicyStatusBadge(
                label: taxProfile.shortLabel,
                color: Colors.teal.shade700,
              ),
              AccountingPolicyStatusBadge(
                label: profile.ppnRegistered ? 'PPN registered' : 'No PPN',
                color:
                    profile.ppnRegistered
                        ? Colors.teal.shade700
                        : Colors.orange.shade700,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AccountingPolicyFrameworkSelector extends StatelessWidget {
  final AccountingPolicyProfile profile;
  final ValueChanged<AccountingPolicyFramework> onChanged;

  const AccountingPolicyFrameworkSelector({
    required this.profile,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _PolicySurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PolicySectionTitle(
            icon: Icons.account_balance_rounded,
            title: 'Reporting Framework',
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columnCount =
                  constraints.maxWidth >= 900
                      ? 4
                      : constraints.maxWidth >= 620
                      ? 2
                      : 1;
              const spacing = 10.0;
              final width =
                  columnCount == 1
                      ? constraints.maxWidth
                      : (constraints.maxWidth - spacing * (columnCount - 1)) /
                          columnCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children:
                    AccountingPolicyFramework.values.map((framework) {
                      return SizedBox(
                        width: width,
                        child: _FrameworkOptionCard(
                          framework: framework,
                          selected: framework == profile.framework,
                          onSelected: () => onChanged(framework),
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AccountingPolicySettingsPanel extends StatelessWidget {
  final AccountingPolicyProfile profile;
  final FinancialReportTaxProfile taxProfile;
  final ValueChanged<String> onEntityNameChanged;
  final ValueChanged<String> onJurisdictionChanged;
  final ValueChanged<String> onFunctionalCurrencyChanged;
  final ValueChanged<String> onPresentationCurrencyChanged;
  final ValueChanged<AccountingPolicyCloseCadence> onCloseCadenceChanged;
  final ValueChanged<FinancialReportTaxProfile> onTaxProfileChanged;
  final ValueChanged<bool> onAccrualBasisChanged;
  final ValueChanged<bool> onRequireComparativesChanged;
  final ValueChanged<bool> onPpnRegisteredChanged;
  final ValueChanged<bool> onManagementAssertionsChanged;

  const AccountingPolicySettingsPanel({
    required this.profile,
    required this.taxProfile,
    required this.onEntityNameChanged,
    required this.onJurisdictionChanged,
    required this.onFunctionalCurrencyChanged,
    required this.onPresentationCurrencyChanged,
    required this.onCloseCadenceChanged,
    required this.onTaxProfileChanged,
    required this.onAccrualBasisChanged,
    required this.onRequireComparativesChanged,
    required this.onPpnRegisteredChanged,
    required this.onManagementAssertionsChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _PolicySurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PolicySectionTitle(
            icon: Icons.tune_rounded,
            title: 'Policy Settings',
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;
              final fields = [
                _PolicyTextField(
                  label: 'Entity',
                  initialValue: profile.entityName,
                  onChanged: onEntityNameChanged,
                ),
                _PolicyTextField(
                  label: 'Jurisdiction',
                  initialValue: profile.jurisdiction,
                  onChanged: onJurisdictionChanged,
                ),
                _PolicyTextField(
                  label: 'Functional currency',
                  initialValue: profile.functionalCurrency,
                  onChanged: onFunctionalCurrencyChanged,
                ),
                _PolicyTextField(
                  label: 'Presentation currency',
                  initialValue: profile.presentationCurrency,
                  onChanged: onPresentationCurrencyChanged,
                ),
              ];

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    fields
                        .map(
                          (field) => SizedBox(
                            width:
                                compact
                                    ? constraints.maxWidth
                                    : (constraints.maxWidth - 10) / 2,
                            child: field,
                          ),
                        )
                        .toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DropdownShell(
                width: 260,
                child: DropdownButton<AccountingPolicyCloseCadence>(
                  value: profile.closeCadence,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items:
                      AccountingPolicyCloseCadence.values
                          .map(
                            (cadence) => DropdownMenuItem(
                              value: cadence,
                              child: Text(cadence.label),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onCloseCadenceChanged(value);
                    }
                  },
                ),
              ),
              _DropdownShell(
                width: 300,
                child: DropdownButton<FinancialReportTaxProfile>(
                  value: taxProfile,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items:
                      FinancialReportTaxProfiles.values
                          .map(
                            (profile) => DropdownMenuItem(
                              value: profile,
                              child: Text(profile.shortLabel),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onTaxProfileChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PolicySwitch(
                label: 'Accrual basis',
                value: profile.accrualBasis,
                onChanged: onAccrualBasisChanged,
              ),
              _PolicySwitch(
                label: 'Comparatives',
                value: profile.requireComparatives,
                onChanged: onRequireComparativesChanged,
              ),
              _PolicySwitch(
                label: 'PPN registered',
                value: profile.ppnRegistered,
                onChanged: onPpnRegisteredChanged,
              ),
              _PolicySwitch(
                label: 'Management assertions',
                value: profile.includeManagementAssertions,
                onChanged: onManagementAssertionsChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AccountingPolicyReviewGrid extends StatelessWidget {
  final List<AccountingPolicyReviewItem> items;

  const AccountingPolicyReviewGrid({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return _PolicySurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PolicySectionTitle(
            icon: Icons.fact_check_rounded,
            title: 'Policy Review',
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columnCount =
                  constraints.maxWidth >= 900
                      ? 3
                      : constraints.maxWidth >= 620
                      ? 2
                      : 1;
              const spacing = 10.0;
              final width =
                  columnCount == 1
                      ? constraints.maxWidth
                      : (constraints.maxWidth - spacing * (columnCount - 1)) /
                          columnCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children:
                    items
                        .map(
                          (item) => SizedBox(
                            width: width,
                            child: _PolicyReviewCard(item: item),
                          ),
                        )
                        .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AccountingPolicyStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const AccountingPolicyStatusBadge({
    required this.label,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FrameworkOptionCard extends StatelessWidget {
  final AccountingPolicyFramework framework;
  final bool selected;
  final VoidCallback onSelected;

  const _FrameworkOptionCard({
    required this.framework,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = selected ? colorScheme.primary : colorScheme.outline;

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              selected
                  ? colorScheme.primary.withValues(alpha: 0.08)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    framework.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              framework.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            AccountingPolicyStatusBadge(
              label: framework.standardReference,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyReviewCard extends StatelessWidget {
  final AccountingPolicyReviewItem item;

  const _PolicyReviewCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color =
        item.status == AccountingPolicyReviewStatus.ready
            ? Colors.teal.shade700
            : Colors.orange.shade700;

    return Container(
      constraints: const BoxConstraints(minHeight: 142),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                item.status == AccountingPolicyReviewStatus.ready
                    ? Icons.check_circle_rounded
                    : Icons.rate_review_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              AccountingPolicyStatusBadge(
                label: item.status.label,
                color: color,
              ),
              AccountingPolicyStatusBadge(
                label: item.reference,
                color: colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PolicyTextField extends StatelessWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _PolicyTextField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('$label:$initialValue'),
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }
}

class _PolicySwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PolicySwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _DropdownShell extends StatelessWidget {
  final double width;
  final Widget child;

  const _DropdownShell({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _PolicySectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _PolicySectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _PolicyIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _PolicyIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _PolicySurface extends StatelessWidget {
  final Widget child;

  const _PolicySurface({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}
