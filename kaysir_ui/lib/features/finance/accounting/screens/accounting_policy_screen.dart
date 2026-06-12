import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../accounting_path.dart';
import '../states/accounting_policy_provider.dart';
import '../states/fin_statement/financial_report_pack_provider.dart';
import '../widgets/accounting_policy_center_components.dart';

class AccountingPolicyScreen extends ConsumerWidget {
  const AccountingPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policy = ref.watch(accountingPolicyProvider);
    final reviewItems = ref.watch(accountingPolicyReviewItemsProvider);
    final reviewCount = ref
        .watch(accountingPolicyServiceProvider)
        .reviewCount(policy);
    final taxProfile = ref.watch(selectedFinancialReportTaxProfileProvider);
    final notifier = ref.read(accountingPolicyProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Accounting Policy'),
        actions: [
          IconButton(
            tooltip: 'Financial statements',
            onPressed: () => context.go(AccountingPath.finStatement),
            icon: const Icon(Icons.summarize_rounded),
          ),
          IconButton(
            tooltip: 'Period close',
            onPressed: () => context.go(AccountingPath.periodClose),
            icon: const Icon(Icons.lock_clock_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          AccountingPolicyHeader(
            profile: policy,
            taxProfile: taxProfile,
            reviewCount: reviewCount,
          ),
          const SizedBox(height: 14),
          AccountingPolicyFrameworkSelector(
            profile: policy,
            onChanged: notifier.updateFramework,
          ),
          const SizedBox(height: 14),
          AccountingPolicySettingsPanel(
            profile: policy,
            taxProfile: taxProfile,
            onEntityNameChanged: notifier.updateEntityName,
            onJurisdictionChanged: notifier.updateJurisdiction,
            onFunctionalCurrencyChanged: notifier.updateFunctionalCurrency,
            onPresentationCurrencyChanged: notifier.updatePresentationCurrency,
            onCloseCadenceChanged: notifier.updateCloseCadence,
            onTaxProfileChanged: (profile) {
              ref
                  .read(selectedFinancialReportTaxProfileProvider.notifier)
                  .state = profile;
            },
            onAccrualBasisChanged: notifier.updateAccrualBasis,
            onRequireComparativesChanged: notifier.updateRequireComparatives,
            onPpnRegisteredChanged: notifier.updatePpnRegistered,
            onManagementAssertionsChanged: notifier.updateManagementAssertions,
          ),
          const SizedBox(height: 14),
          AccountingPolicyReviewGrid(items: reviewItems),
        ],
      ),
    );
  }
}
