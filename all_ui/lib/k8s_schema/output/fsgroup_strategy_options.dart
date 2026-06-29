import 'idrange.dart';

class FSGroupStrategyOptions {
  final String? rule;
  final List<IDRange>? ranges;
  FSGroupStrategyOptions({this.rule, this.ranges});
  factory FSGroupStrategyOptions.fromJson(Map<String, dynamic> json) {
    return FSGroupStrategyOptions(
      rule: json['rule'],
      ranges:
          json['ranges'] != null
              ? (json['ranges'] as List)
                  .map((e) => IDRange.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (rule != null) 'rule': rule,
      if (ranges != null) 'ranges': ranges!.map((e) => e.toJson()).toList(),
    };
  }
}
