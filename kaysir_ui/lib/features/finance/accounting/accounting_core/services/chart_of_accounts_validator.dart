import '../models/accounting_account.dart';

/// Severity level for chart-of-accounts validation feedback.
enum ChartOfAccountsValidationSeverity { warning, error }

/// One chart-of-accounts validation issue for setup or posting readiness.
class ChartOfAccountsValidationIssue {
  const ChartOfAccountsValidationIssue({
    required this.message,
    required this.severity,
    this.accountId,
    this.code,
  });

  final String message;
  final ChartOfAccountsValidationSeverity severity;
  final String? accountId;
  final String? code;

  bool get isError => severity == ChartOfAccountsValidationSeverity.error;
}

/// Validation summary for a chart of accounts.
class ChartOfAccountsValidationResult {
  ChartOfAccountsValidationResult({
    required Iterable<ChartOfAccountsValidationIssue> issues,
  }) : issues = List<ChartOfAccountsValidationIssue>.unmodifiable(issues);

  final List<ChartOfAccountsValidationIssue> issues;

  bool get isValid => issues.every((issue) => !issue.isError);
  int get errorCount => issues.where((issue) => issue.isError).length;
  int get warningCount => issues.length - errorCount;
}

/// Validates CoA setup rules required by posting and financial reporting.
class ChartOfAccountsValidator {
  const ChartOfAccountsValidator({
    this.requiredPostingCodes = const [
      '1000',
      '1100',
      '2000',
      '3000',
      '4000',
      '5000',
    ],
  });

  final List<String> requiredPostingCodes;

  ChartOfAccountsValidationResult validate(
    Iterable<AccountingAccount> accounts,
  ) {
    final accountList = accounts.toList(growable: false);
    final issues = <ChartOfAccountsValidationIssue>[];
    final byCode = <String, AccountingAccount>{};
    final duplicateCodes = <String>{};
    final byId = {for (final account in accountList) account.id: account};
    final childCountByParent = <String, int>{};

    for (final account in accountList) {
      final normalizedCode = account.code.trim();
      final normalizedName = account.name.trim();
      if (normalizedCode.isEmpty) {
        issues.add(
          ChartOfAccountsValidationIssue(
            accountId: account.id,
            message: 'Account code is required.',
            severity: ChartOfAccountsValidationSeverity.error,
          ),
        );
      } else if (byCode.containsKey(normalizedCode)) {
        duplicateCodes.add(normalizedCode);
      } else {
        byCode[normalizedCode] = account;
      }

      if (normalizedName.isEmpty) {
        issues.add(
          ChartOfAccountsValidationIssue(
            accountId: account.id,
            code: normalizedCode,
            message: 'Account name is required.',
            severity: ChartOfAccountsValidationSeverity.error,
          ),
        );
      }

      if (account.parentId case final parentId?) {
        childCountByParent[parentId] = (childCountByParent[parentId] ?? 0) + 1;
      }
    }

    for (final code in duplicateCodes) {
      issues.add(
        ChartOfAccountsValidationIssue(
          code: code,
          message: 'Account code $code is already used.',
          severity: ChartOfAccountsValidationSeverity.error,
        ),
      );
    }

    for (final account in accountList) {
      final parentId = account.parentId;
      if (parentId == null) continue;
      if (parentId == account.id) {
        issues.add(
          ChartOfAccountsValidationIssue(
            accountId: account.id,
            code: account.code,
            message: 'Account cannot be its own parent.',
            severity: ChartOfAccountsValidationSeverity.error,
          ),
        );
        continue;
      }

      final parent = byId[parentId];
      if (parent == null) {
        issues.add(
          ChartOfAccountsValidationIssue(
            accountId: account.id,
            code: account.code,
            message: 'Parent account is missing.',
            severity: ChartOfAccountsValidationSeverity.error,
          ),
        );
        continue;
      }

      if (parent.type != account.type) {
        issues.add(
          ChartOfAccountsValidationIssue(
            accountId: account.id,
            code: account.code,
            message: 'Child account type must match parent account type.',
            severity: ChartOfAccountsValidationSeverity.error,
          ),
        );
      }

      if (account.isActive && !parent.isActive) {
        issues.add(
          ChartOfAccountsValidationIssue(
            accountId: account.id,
            code: account.code,
            message: 'Active account has an inactive parent.',
            severity: ChartOfAccountsValidationSeverity.warning,
          ),
        );
      }
    }

    for (final account in accountList) {
      if ((childCountByParent[account.id] ?? 0) > 0 && account.allowPosting) {
        issues.add(
          ChartOfAccountsValidationIssue(
            accountId: account.id,
            code: account.code,
            message: 'Parent account should not allow direct posting.',
            severity: ChartOfAccountsValidationSeverity.warning,
          ),
        );
      }
    }

    for (final code in requiredPostingCodes) {
      final account = byCode[code];
      if (account == null) {
        issues.add(
          ChartOfAccountsValidationIssue(
            code: code,
            message: 'Required posting account $code is missing.',
            severity: ChartOfAccountsValidationSeverity.error,
          ),
        );
      } else if (!account.isActive) {
        issues.add(
          ChartOfAccountsValidationIssue(
            accountId: account.id,
            code: code,
            message: 'Required posting account $code is inactive.',
            severity: ChartOfAccountsValidationSeverity.error,
          ),
        );
      }
    }

    return ChartOfAccountsValidationResult(issues: issues);
  }
}
