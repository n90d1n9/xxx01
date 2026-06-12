class PWAIcon {
  final String src;
  final String sizes;
  final String type;
  final String? purpose;

  PWAIcon({
    required this.src,
    required this.sizes,
    required this.type,
    this.purpose,
  });

  factory PWAIcon.fromJson(Map<String, dynamic> json) {
    return PWAIcon(
      src: json['src'] as String,
      sizes: json['sizes'] as String,
      type: json['type'] as String,
      purpose: json['purpose'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'src': src,
    'sizes': sizes,
    'type': type,
    if (purpose != null) 'purpose': purpose,
  };
}
