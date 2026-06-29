import 'idrange.dart';

class RunAsUserStrategyOptions {
  final String rule;
  final List<IDRange>? ranges;
  RunAsUserStrategyOptions({required this.rule, this.ranges});
  factory RunAsUserStrategyOptions.fromJson(Map<String, dynamic> json) {
    return RunAsUserStrategyOptions(
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
      'rule': rule,
      if (ranges != null) 'ranges': ranges!.map((e) => e.toJson()).toList(),
    };
  }
}
