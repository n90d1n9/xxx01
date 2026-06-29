
class Sysctl {final String name; final String value; Sysctl({required this.name, required this.value}); factory Sysctl.fromJson(Map<String, dynamic> json) {return Sysctl(name: json['name'], value: json['value']);} Map<String, dynamic> toJson() {return {'name' : name, 'value' : value};}}
