import 'shadow_layer.dart';

class Shadow {
  final List<ShadowLayer>? boxShadow;
  final String? dropShadow;

  Shadow({this.boxShadow, this.dropShadow});

  factory Shadow.fromJson(Map<String, dynamic> json) {
    return Shadow(
      boxShadow:
          json['boxShadow'] != null
              ? (json['boxShadow'] as List)
                  .map((s) => ShadowLayer.fromJson(s as Map<String, dynamic>))
                  .toList()
              : null,
      dropShadow: json['dropShadow'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (boxShadow != null)
      'boxShadow': boxShadow!.map((s) => s.toJson()).toList(),
    if (dropShadow != null) 'dropShadow': dropShadow,
  };
}
