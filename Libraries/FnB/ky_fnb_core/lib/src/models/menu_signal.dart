/// Captures live menu demand, margin, speed, and availability risk.
class FnbMenuSignal {
  const FnbMenuSignal({
    required this.id,
    required this.name,
    required this.category,
    required this.orders,
    required this.grossMarginPercent,
    required this.soldOutRiskPercent,
    required this.prepMinutes,
    required this.tags,
  });

  final String id;
  final String name;
  final String category;
  final int orders;
  final int grossMarginPercent;
  final int soldOutRiskPercent;
  final int prepMinutes;
  final List<String> tags;

  FnbMenuSignal copyWith({
    String? name,
    String? category,
    int? orders,
    int? grossMarginPercent,
    int? soldOutRiskPercent,
    int? prepMinutes,
    List<String>? tags,
  }) {
    return FnbMenuSignal(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      orders: orders ?? this.orders,
      grossMarginPercent: grossMarginPercent ?? this.grossMarginPercent,
      soldOutRiskPercent: soldOutRiskPercent ?? this.soldOutRiskPercent,
      prepMinutes: prepMinutes ?? this.prepMinutes,
      tags: tags ?? this.tags,
    );
  }
}
