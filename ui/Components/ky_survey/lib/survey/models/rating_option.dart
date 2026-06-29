
import 'custom_icons.dart';

class RatingOptions {
  final int scale;
  final String? startLabel;
  final String? endLabel;
  final bool showLabels;
  final bool showValues;
  final bool allowHalfRatings;
  final CustomIcons? customIcons;

  RatingOptions({
    required this.scale,
    this.startLabel,
    this.endLabel,
    required this.showLabels,
    required this.showValues,
    required this.allowHalfRatings,
    this.customIcons,
  });

  Map<String, dynamic> toJson() => {
        'scale': scale,
        'startLabel': startLabel,
        'endLabel': endLabel,
        'showLabels': showLabels,
        'showValues': showValues,
        'allowHalfRatings': allowHalfRatings,
        'customIcons': customIcons?.toJson(),
      };

  factory RatingOptions.fromJson(Map<String, dynamic> json) => RatingOptions(
        scale: json['scale'],
        startLabel: json['startLabel'],
        endLabel: json['endLabel'],
        showLabels: json['showLabels'],
        showValues: json['showValues'],
        allowHalfRatings: json['allowHalfRatings'],
        customIcons: json['customIcons'] != null
            ? CustomIcons.fromJson(json['customIcons'])
            : null,
      );
}
