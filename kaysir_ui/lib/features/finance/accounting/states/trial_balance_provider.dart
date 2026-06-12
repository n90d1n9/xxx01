import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/trial_balance_service.dart';

/// Service provider for deriving trial balance reports from ledger activity.
final trialBalanceServiceProvider = Provider<TrialBalanceService>((ref) {
  return const TrialBalanceService();
});
