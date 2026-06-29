class ResourceHandle {
  final String? driverName;
  final String? data;
  ResourceHandle({this.driverName, this.data});
  factory ResourceHandle.fromJson(Map<String, dynamic> json) {
    return ResourceHandle(driverName: json['driverName'], data: json['data']);
  }
  Map<String, dynamic> toJson() {
    return {
      if (driverName != null) 'driverName': driverName,
      if (data != null) 'data': data,
    };
  }
}
