class ForZone {
  final String name;
  ForZone({required this.name});
  factory ForZone.fromJson(Map<String, dynamic> json) {
    return ForZone(name: json['name']);
  }
  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
