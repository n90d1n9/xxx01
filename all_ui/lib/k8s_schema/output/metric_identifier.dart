import 'label_selector.dart';

class MetricIdentifier {
  final String name;
  final LabelSelector? selector;
  MetricIdentifier({required this.name, this.selector});
  factory MetricIdentifier.fromJson(Map<String, dynamic> json) {
    return MetricIdentifier(
      name: json['name'],
      selector:
          json['selector'] != null
              ? LabelSelector.fromJson(json['selector'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {'name': name, if (selector != null) 'selector': selector!.toJson()};
  }
}
