
class WatchEvent {final String type; final Map<String, dynamic> object; WatchEvent({required this.type, required this.object}); factory WatchEvent.fromJson(Map<String, dynamic> json) {return WatchEvent(type: json['type'], object: json['object']);} Map<String, dynamic> toJson() {return {'type' : type, 'object' : object};}}
