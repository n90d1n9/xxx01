
class ServiceBackendPort {final String? name; final int? number; ServiceBackendPort({this.name, this.number}); factory ServiceBackendPort.fromJson(Map<String, dynamic> json) {return ServiceBackendPort(name: json['name'], number: json['number']);} Map<String, dynamic> toJson() {return {if (name != null) 'name' : name, if (number != null) 'number' : number};}}
