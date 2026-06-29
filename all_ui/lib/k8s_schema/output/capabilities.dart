class Capabilities {
  final List<String>? add;
  final List<String>? drop;
  Capabilities({this.add, this.drop});
  factory Capabilities.fromJson(Map<String, dynamic> json) {
    return Capabilities(
      add: json['add'] != null ? List<String>.from(json['add']) : null,
      drop: json['drop'] != null ? List<String>.from(json['drop']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {if (add != null) 'add': add, if (drop != null) 'drop': drop};
  }
}
