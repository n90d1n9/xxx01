class HTTPHeader {
  final String name;
  final String value;
  HTTPHeader({required this.name, required this.value});
  factory HTTPHeader.fromJson(Map<String, dynamic> json) {
    return HTTPHeader(name: json['name'], value: json['value']);
  }
  Map<String, dynamic> toJson() {
    return {'name': name, 'value': value};
  }
}
