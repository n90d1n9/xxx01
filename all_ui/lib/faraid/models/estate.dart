import 'assets.dart';

class Estate {
  final List<Asset> assets;
  final List<Debt> debts;
  final List<Expense> expenses;
  final List<Bequest> bequests;
  final double funeralExpenses;
  final double administrativeCosts;
  final double netValue;

  Estate({
    this.assets = const [],
    this.debts = const [],
    this.expenses = const [],
    this.bequests = const [],
    this.funeralExpenses = 0.0,
    this.administrativeCosts = 0.0,
    this.netValue = 0.0,
  });

  // Total assets with appreciation
  double get totalAssets =>
      assets.fold(0.0, (sum, asset) => sum + asset.currentValue);

  // Liquid assets (cash, bank accounts, etc.)
  double get liquidAssets => assets
      .where((asset) => asset.isLiquid)
      .fold(0.0, (sum, asset) => sum + asset.currentValue);

  // Illiquid assets (property, vehicles, etc.)
  double get illiquidAssets => assets
      .where((asset) => !asset.isLiquid)
      .fold(0.0, (sum, asset) => sum + asset.currentValue);

  // Total debts (prioritized according to Islamic law)
  double get totalDebts =>
      debts.fold(0.0, (sum, debt) => sum + debt.remainingAmount);

  // Total expenses (funeral + administrative)
  double get totalExpenses => funeralExpenses + administrativeCosts;

  // Bequests (max 1/3 of net estate after debts and expenses)
  double get totalBequests {
    final netAfterDebtsExpenses = totalAssets - totalDebts - totalExpenses;
    final maxBequests = netAfterDebtsExpenses * (1 / 3);
    final requestedBequests = bequests.fold(
      0.0,
      (sum, bequest) => sum + bequest.amount,
    );

    return requestedBequests > maxBequests ? maxBequests : requestedBequests;
  }

  // Net estate available for distribution according to Faraid
  double get netEstate {
    return totalAssets - totalDebts - totalExpenses - totalBequests;
  }

  // Check if estate can cover all obligations
  bool get isSolvent => netEstate >= 0;

  // Get assets by category
  Map<String, List<Asset>> get assetsByCategory {
    final map = <String, List<Asset>>{};
    for (final asset in assets) {
      map.putIfAbsent(asset.category, () => []).add(asset);
    }
    return map;
  }

  Estate copyWith({
    List<Asset>? assets,
    List<Debt>? debts,
    List<Expense>? expenses,
    List<Bequest>? bequests,
    double? funeralExpenses,
    double? administrativeCosts,
    double? netValue,
  }) {
    return Estate(
      assets: assets ?? this.assets,
      debts: debts ?? this.debts,
      expenses: expenses ?? this.expenses,
      bequests: bequests ?? this.bequests,
      funeralExpenses: funeralExpenses ?? this.funeralExpenses,
      administrativeCosts: administrativeCosts ?? this.administrativeCosts,
      netValue: netValue ?? this.netValue,
    );
  }
}

class Debt {
  final String id;
  final String creditor;
  final String description;
  final double originalAmount;
  final double remainingAmount;
  final DateTime dueDate;
  final bool isSecured;
  final String priority; // High, Medium, Low

  Debt({
    required this.id,
    required this.creditor,
    required this.description,
    required this.originalAmount,
    required this.remainingAmount,
    required this.dueDate,
    this.isSecured = false,
    this.priority = 'Medium',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'creditor': creditor,
    'description': description,
    'originalAmount': originalAmount,
    'remainingAmount': remainingAmount,
    'dueDate': dueDate.toIso8601String(),
    'isSecured': isSecured,
    'priority': priority,
  };

  factory Debt.fromJson(Map<String, dynamic> json) => Debt(
    id: json['id'],
    creditor: json['creditor'],
    description: json['description'],
    originalAmount: json['originalAmount'],
    remainingAmount: json['remainingAmount'],
    dueDate: DateTime.parse(json['dueDate']),
    isSecured: json['isSecured'] ?? false,
    priority: json['priority'] ?? 'Medium',
  );
}

class Expense {
  final String id;
  final String category;
  final String description;
  final double amount;
  final bool isPaid;

  Expense({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    this.isPaid = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'description': description,
    'amount': amount,
    'isPaid': isPaid,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    category: json['category'],
    description: json['description'],
    amount: json['amount'],
    isPaid: json['isPaid'] ?? false,
  );
}

class Bequest {
  final String id;
  final String beneficiary;
  final String description;
  final double amount;
  final String relationship;

  Bequest({
    required this.id,
    required this.beneficiary,
    required this.description,
    required this.amount,
    required this.relationship,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'beneficiary': beneficiary,
    'description': description,
    'amount': amount,
    'relationship': relationship,
  };

  factory Bequest.fromJson(Map<String, dynamic> json) => Bequest(
    id: json['id'],
    beneficiary: json['beneficiary'],
    description: json['description'],
    amount: json['amount'],
    relationship: json['relationship'],
  );
}
