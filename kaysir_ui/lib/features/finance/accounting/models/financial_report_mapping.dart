import 'financial_entry.dart';

enum FinancialReportExpenseGroup { operating, finance, tax }

enum FinancialReportCashFlowGroup { operating, investing, financing }

class FinancialReportLineMappingRule {
  final String lineLabel;
  final Set<String> entryTypes;
  final List<String> codePrefixes;
  final List<String> keywords;
  final int sortOrder;
  final FinancialReportExpenseGroup? expenseGroup;

  const FinancialReportLineMappingRule({
    required this.lineLabel,
    required this.entryTypes,
    required this.sortOrder,
    this.codePrefixes = const [],
    this.keywords = const [],
    this.expenseGroup,
  });

  bool matches(FinancialEntry entry) {
    if (!entryTypes.contains(entry.type)) {
      return false;
    }

    final accountCode = FinancialReportLineMapper.accountCodeFor(entry);
    if (accountCode != null &&
        codePrefixes.any((prefix) => accountCode.startsWith(prefix))) {
      return true;
    }

    final label = FinancialReportLineMapper.searchLabelFor(entry);
    return keywords.any(label.contains);
  }
}

class FinancialReportLineMapper {
  final List<FinancialReportLineMappingRule> rules;

  const FinancialReportLineMapper({
    this.rules = FinancialReportLineMapperDefaults.rules,
  });

  String lineLabelFor(FinancialEntry entry) {
    return _ruleFor(entry)?.lineLabel ?? _fallbackLabelFor(entry);
  }

  bool hasExplicitMapping(FinancialEntry entry) {
    return _ruleFor(entry) != null;
  }

  int sortOrderForLabel(String label) {
    final matchingRules = rules.where((rule) => rule.lineLabel == label);
    if (matchingRules.isEmpty) {
      return 9000;
    }
    return matchingRules
        .map((rule) => rule.sortOrder)
        .reduce((value, element) => value <= element ? value : element);
  }

  FinancialReportExpenseGroup expenseGroupFor(FinancialEntry entry) {
    final rule = _ruleFor(entry);
    if (rule?.expenseGroup != null) {
      return rule!.expenseGroup!;
    }

    final label = searchLabelFor(entry);
    if (label.contains('tax') ||
        label.contains('pajak') ||
        label.contains('pph')) {
      return FinancialReportExpenseGroup.tax;
    }
    if (label.contains('interest') ||
        label.contains('finance') ||
        label.contains('financing') ||
        label.contains('loan') ||
        label.contains('pinjaman')) {
      return FinancialReportExpenseGroup.finance;
    }
    return FinancialReportExpenseGroup.operating;
  }

  FinancialReportCashFlowGroup cashFlowGroupFor(FinancialEntry entry) {
    final label = searchLabelFor(entry);
    if (label.contains('loan') ||
        label.contains('capital') ||
        label.contains('equity') ||
        label.contains('financing') ||
        label.contains('modal') ||
        label.contains('pinjaman')) {
      return FinancialReportCashFlowGroup.financing;
    }
    if (label.contains('equipment') ||
        label.contains('fixed') ||
        label.contains('invest') ||
        label.contains('asset disposal') ||
        label.contains('aset tetap')) {
      return FinancialReportCashFlowGroup.investing;
    }
    return FinancialReportCashFlowGroup.operating;
  }

  FinancialReportLineMappingRule? _ruleFor(FinancialEntry entry) {
    for (final rule in rules) {
      if (rule.matches(entry)) {
        return rule;
      }
    }
    return null;
  }

  String _fallbackLabelFor(FinancialEntry entry) {
    if (entry.category.trim().isNotEmpty) {
      return entry.category;
    }
    return entry.name;
  }

  static String? accountCodeFor(FinancialEntry entry) {
    return RegExp(r'^\s*(\d+)').firstMatch(entry.category)?.group(1) ??
        RegExp(r'^\s*(\d+)').firstMatch(entry.name)?.group(1);
  }

  static String searchLabelFor(FinancialEntry entry) {
    return '${entry.name} ${entry.category} ${entry.sourceCategory ?? ''}'
        .toLowerCase();
  }
}

abstract final class FinancialReportLineMapperDefaults {
  static const rules = <FinancialReportLineMappingRule>[
    FinancialReportLineMappingRule(
      lineLabel: 'Cash and cash equivalents',
      entryTypes: {'asset'},
      sortOrder: 100,
      codePrefixes: ['100'],
      keywords: ['cash', 'bank', 'kas'],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Trade and other receivables',
      entryTypes: {'asset'},
      sortOrder: 110,
      codePrefixes: ['110'],
      keywords: ['receivable', 'piutang'],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Inventories',
      entryTypes: {'asset'},
      sortOrder: 120,
      codePrefixes: ['120'],
      keywords: ['inventory', 'inventories', 'persediaan'],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'VAT input tax assets',
      entryTypes: {'asset'},
      sortOrder: 123,
      keywords: [
        'input vat',
        'vat input',
        'vat receivable',
        'ppn masukan',
        'ppn dibayar dimuka',
        'ppn lebih bayar',
      ],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Income tax assets',
      entryTypes: {'asset'},
      sortOrder: 125,
      keywords: [
        'prepaid income tax',
        'prepaid tax',
        'tax credit',
        'withholding tax credit',
        'pph 22',
        'pph 23',
        'pph 25',
        'pajak dibayar dimuka',
        'kredit pajak',
      ],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Prepayments and other current assets',
      entryTypes: {'asset'},
      sortOrder: 130,
      codePrefixes: ['130', '140'],
      keywords: ['prepaid', 'advance', 'uang muka'],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Property and equipment',
      entryTypes: {'asset'},
      sortOrder: 150,
      codePrefixes: ['150', '160', '170', '180'],
      keywords: [
        'equipment',
        'vehicle',
        'building',
        'fixed asset',
        'ppe',
        'aset tetap',
      ],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Trade and other payables',
      entryTypes: {'liability'},
      sortOrder: 200,
      codePrefixes: ['200'],
      keywords: ['payable', 'utang usaha', 'hutang usaha'],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Borrowings and financing liabilities',
      entryTypes: {'liability'},
      sortOrder: 210,
      codePrefixes: ['210', '220', '230'],
      keywords: ['loan', 'borrow', 'notes payable', 'mortgage', 'pinjaman'],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'VAT output tax liabilities',
      entryTypes: {'liability'},
      sortOrder: 218,
      keywords: [
        'output vat',
        'vat output',
        'vat payable',
        'ppn keluaran',
        'ppn kurang bayar',
        'utang ppn',
        'hutang ppn',
      ],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Tax liabilities',
      entryTypes: {'liability'},
      sortOrder: 220,
      codePrefixes: ['240', '250'],
      keywords: ['tax payable', 'ppn', 'pph', 'pajak'],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Retained earnings',
      entryTypes: {'equity'},
      sortOrder: 300,
      keywords: [
        'retained earnings',
        'saldo laba',
        'dividend',
        'distribution',
        'drawing',
        'drawings',
        'prive',
      ],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Other reserves and OCI',
      entryTypes: {'equity'},
      sortOrder: 320,
      keywords: [
        'oci',
        'other comprehensive income',
        'revaluation reserve',
        'fair value reserve',
        'cadangan revaluasi',
      ],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Owner/share capital',
      entryTypes: {'equity'},
      sortOrder: 310,
      codePrefixes: ['300', '310', '320'],
      keywords: ['owner capital', 'share capital', 'paid in capital', 'modal'],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Revenue from contracts with customers',
      entryTypes: {'income'},
      sortOrder: 400,
      codePrefixes: ['400'],
      keywords: ['sales revenue', 'service revenue', 'revenue', 'penjualan'],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Finance income',
      entryTypes: {'income'},
      sortOrder: 410,
      codePrefixes: ['410', '420'],
      keywords: ['interest income', 'finance income'],
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Current tax expense',
      entryTypes: {'expense'},
      sortOrder: 590,
      codePrefixes: ['590'],
      keywords: ['income tax', 'tax expense', 'pajak penghasilan', 'pph'],
      expenseGroup: FinancialReportExpenseGroup.tax,
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Interest expense and finance charges',
      entryTypes: {'expense'},
      sortOrder: 560,
      codePrefixes: ['560', '570'],
      keywords: ['interest expense', 'finance cost', 'loan interest'],
      expenseGroup: FinancialReportExpenseGroup.finance,
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Cost of sales',
      entryTypes: {'expense'},
      sortOrder: 500,
      keywords: ['cost of sales', 'cost of goods', 'cogs', 'hpp'],
      expenseGroup: FinancialReportExpenseGroup.operating,
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Occupancy expenses',
      entryTypes: {'expense'},
      sortOrder: 510,
      codePrefixes: ['500'],
      keywords: ['rent', 'lease', 'occupancy', 'sewa'],
      expenseGroup: FinancialReportExpenseGroup.operating,
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Utilities and office expenses',
      entryTypes: {'expense'},
      sortOrder: 520,
      codePrefixes: ['510'],
      keywords: ['utilities', 'supplies', 'office', 'listrik', 'air'],
      expenseGroup: FinancialReportExpenseGroup.operating,
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Employee benefits expenses',
      entryTypes: {'expense'},
      sortOrder: 530,
      codePrefixes: ['520'],
      keywords: ['salary', 'salaries', 'payroll', 'employee', 'gaji'],
      expenseGroup: FinancialReportExpenseGroup.operating,
    ),
    FinancialReportLineMappingRule(
      lineLabel: 'Selling and marketing expenses',
      entryTypes: {'expense'},
      sortOrder: 540,
      codePrefixes: ['530', '540'],
      keywords: ['marketing', 'advertising', 'promotion', 'iklan'],
      expenseGroup: FinancialReportExpenseGroup.operating,
    ),
  ];
}
