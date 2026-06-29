
class Overhead {final Map<String, String>? podFixed; Overhead({this.podFixed}); factory Overhead.fromJson(Map<String, dynamic> json) {return Overhead(podFixed: json['podFixed'] != null ? Map<String, String>.from(json['podFixed']) : null);} Map<String, dynamic> toJson() {return {if (podFixed != null) 'podFixed' : podFixed};}}
